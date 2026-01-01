# Instant Worker Call Feature Documentation

## 📋 Overview

The **Instant Worker Call** feature is an image-based worker bidding system that allows users to upload service problem images and receive price estimates from multiple workers. Workers review images, submit their own price estimates, and users choose the best offer. This feature enables transparent pricing and better service matching based on visual assessment of the problem.

## 🎯 Key Features

- **📸 Image-Based Requests**: Users upload 1-3 images of the service problem
- **💰 Worker Bidding**: Workers submit their own price estimates based on images
- **🎯 User Choice**: Users can compare and select from multiple worker offers
- **⚡ Real-time Notifications**: Workers receive instant notifications via WebSocket
- **📍 Location-Based**: GPS integration for accurate service location
- **🔔 Multi-Channel Notifications**: Socket.io + Database notifications for reliability
- **📱 Mobile-Friendly**: Works seamlessly on mobile devices with camera support
- **🖼️ Image Preview**: Workers can view uploaded images before submitting estimates
- **☁️ Cloudinary Integration**: Automatic image upload to Cloudinary with base64 fallback

## 🔄 How It Works

### User Flow

1. **User Initiates Call**
   - User selects a service category (e.g., Plumber, Electrician)
   - Enters service description
   - **Uploads 1-3 images** of the service problem (camera or gallery)
   - Selects service location (GPS or manual entry)
   - Chooses payment method (Cash or Online)
   - Submits request

2. **System Processing**
   - Frontend sends images as files via FormData
   - Backend middleware processes files:
     - Uploads to Cloudinary (if configured)
     - Falls back to base64 encoding (if Cloudinary unavailable)
   - Creates a booking with:
     - `booking_type = 'call_worker'`
     - `status = 'pending_estimation'` (waiting for worker estimates)
     - `worker_id = NULL` (no worker assigned yet)
     - `estimated_price = NULL` (no auto-estimation)
   - Stores uploaded images in `booking_images` table
   - Broadcasts request + images to all active workers in the category

3. **User Waiting State**
   - User sees: "Waiting for worker estimates..."
   - Real-time updates as workers submit estimates via socket
   - Can view all received estimates with worker details

4. **Worker Estimates**
   - Multiple workers review images and submit price estimates
   - Each estimate includes:
     - Estimated price (required)
     - Optional note/explanation
     - Worker name, photo, rating, reviews, experience
   - Estimates appear in real-time to the user via socket events

5. **User Selection**
   - User reviews all worker estimates in a card-based UI
   - Compares prices, ratings, notes, and experience
   - Selects preferred worker by clicking "Select Worker" button
   - System assigns selected worker to booking
   - Booking status changes to `accepted`
   - Selected estimate status: `accepted`
   - Other estimates status: `rejected`
   - Selected worker status changes to `busy`

6. **Booking Completion**
   - Normal booking flow continues (start service, complete, payment)

### Worker Flow

1. **Receive Notification**
   - Worker must be online and connected via WebSocket
   - Worker must be in `available` status
   - Worker must be verified (`verification_status = 'verified'`)
   - Worker must match the service category
   - Receives call request via socket event `worker:call-request` with:
     - Service description
     - Location details
     - **Uploaded images (1-3 images as URLs)**

2. **Review Request**
   - Worker opens call request modal (`CallRequestModal`)
   - Views uploaded images in a gallery grid
   - Reads service description
   - Checks location on map
   - Reviews user details (name, phone, photo)

3. **Submit Estimate**
   - Worker enters estimated price (required, must be > 0)
   - Optionally adds a note explaining the estimate
   - Submits estimate via `POST /api/bookings/:id/submit-estimate`
   - Estimate is saved in `worker_estimates` table with status `pending`
   - User receives real-time notification via socket event `booking:new-estimate`
   - Worker sees confirmation message

4. **Wait for Selection**
   - Worker's estimate status: `pending`
   - Worker can see if user has selected another worker via `worker:call-request-closed` event
   - If selected:
     - Estimate status: `accepted`
     - Worker receives notification via `booking:worker-selected` socket event
     - Worker status changes to `busy`
     - Booking assigned to worker
   - If not selected:
     - Estimate status: `rejected`
     - Worker notified that another worker was chosen

## 🛠️ Technical Implementation

### Frontend Components

#### 1. CallWorker Page (`/call-worker`)
- **Location**: `worker-calling-frontend/src/pages/CallWorker.jsx`
- **Purpose**: Main page for users to initiate instant worker calls with images
- **Features**:
  - Service category selection dropdown
  - Service description textarea
  - **Image upload (1-3 images)**:
    - File input with `accept="image/*"` and `capture="environment"` for mobile camera
    - Drag & drop or click to upload
    - Image preview thumbnails with remove option
    - Validation: 1-3 images required
  - Location picker with GPS support
  - Payment method selection (Cash/Online)
  - Real-time socket connection status indicator
  - **Worker estimates display**:
    - Card-based UI showing all estimates
    - Worker photo, name, rating, reviews, experience
    - Estimated price prominently displayed
    - Optional note in highlighted box
    - "Select Worker" button for each estimate
  - **Worker selection interface**:
    - Real-time updates via socket events
    - Loading states during selection
    - Success/error notifications

#### 2. CallRequestModal Component
- **Location**: `worker-calling-frontend/src/components/booking/CallRequestModal.jsx`
- **Purpose**: Modal for workers to view call requests and submit estimates
- **Features**:
  - **Image gallery**:
    - Grid layout displaying all uploaded images
    - Full-size image preview on click
    - Images loaded from `GET /api/bookings/:id/images`
  - User details section (name, phone, photo)
  - Service description display
  - Location map view (read-only)
  - **Price estimate input form**:
    - Number input for estimated price (required)
    - Textarea for optional note
    - Validation: price must be > 0
    - Submit button with loading state
  - Success confirmation after submission
  - Disable submission if already submitted

#### 3. Worker Search Integration
- **Location**: `worker-calling-frontend/src/pages/WorkerSearch.jsx`
- **Feature**: "Call Workers" button that opens InstantCallModal
- **Requirement**: User must select a category first

### Backend Implementation

#### 1. API Endpoint: Call Worker
```javascript
POST /api/bookings/call-worker
Authorization: Bearer <user_token>
Content-Type: multipart/form-data

Request Body (FormData):
- service_category_id: string (UUID)
- service_description: string
- service_location: string
- location_latitude: number (optional)
- location_longitude: number (optional)
- payment_method: string ('cash' | 'online')
- images: File[] (1-3 image files)

OR (Fallback - JSON with base64):
Content-Type: application/json
{
  "service_category_id": "uuid",
  "service_description": "Fix leaking pipe",
  "service_location": "House 12, Road 5, Dhanmondi",
  "location_latitude": 23.7465,
  "location_longitude": 90.3840,
  "payment_method": "cash",
  "image_urls": ["data:image/jpeg;base64,..."] // Fallback only
}

Response:
{
  "success": true,
  "message": "Call request sent to active workers",
  "data": {
    "booking": {
      "id": "uuid",
      "booking_number": "BK1234567890",
      "booking_type": "call_worker",
      "status": "pending_estimation",
      "worker_id": null,
      "estimated_price": null,
      ...
    },
    "workers_notified": 5
  }
}
```

**Middleware Chain:**
1. `protect` - Authentication check
2. `authorize('user')` - User role check
3. `uploadMultiple('images', 3)` - Multer file upload (max 3 files)
4. `uploadMultipleToCloudinary` - Cloudinary upload or base64 conversion
5. `callWorker` - Controller handler

**Image Processing:**
- Files uploaded via `multer` middleware
- If Cloudinary configured: Upload to Cloudinary, get URLs
- If Cloudinary fails/not configured: Convert to base64 data URLs
- Images stored in `booking_images` table with `image_order`

#### 2. API Endpoint: Submit Estimate
```javascript
POST /api/bookings/:id/submit-estimate
Authorization: Bearer <worker_token>
Content-Type: application/json

Request Body:
{
  "estimated_price": 1200.00,
  "note": "Pipe replacement needed, includes materials"  // Optional
}

Response (Status: 201 Created):
{
  "success": true,
  "message": "Estimate submitted successfully",
  "data": {
    "estimate": {
      "id": "uuid",
      "booking_id": "uuid",
      "worker_id": "uuid",
      "estimated_price": 1200.00,
      "note": "Pipe replacement needed",
      "status": "pending",
      "created_at": "2024-01-15T10:30:00Z"
    },
    "worker_info": {
      "full_name": "John Worker",
      "profile_photo": "https://...",
      "average_rating": 4.5,
      "total_reviews": 25
    }
  }
}
```

**Validation:**
- Worker must be authenticated and active (`is_active = true`)
- Worker account must be activated (NID verification completed and admin approved)
- Worker must be verified (`verification_status = 'verified'`)
- Worker must match service category
- Worker must be available (not busy) (`availability_status = 'available'`)
- Booking must be in `pending_estimation` status
- Worker can only submit one estimate per booking (enforced by UNIQUE constraint)
- Estimated price must be > 0 and valid number

**Error Responses:**
- `400`: Invalid estimated price
- `403`: Account not activated (NID verification pending or not approved)
- `404`: Booking not found or not accepting estimates
- `400`: Worker already submitted estimate
- `400`: Worker not verified
- `400`: Worker category mismatch
- `400`: Worker not available

**Socket Event Emitted:**
- `booking:new-estimate` to user's socket room with worker details and estimate

#### 3. API Endpoint: Select Worker
```javascript
PUT /api/bookings/:id/select-worker
Authorization: Bearer <user_token>
Content-Type: application/json

Request Body:
{
  "worker_id": "uuid"  // ID of the worker whose estimate to accept
}

Response:
{
  "success": true,
  "message": "Worker selected successfully",
  "data": {
    "booking": {
      "id": "uuid",
      "status": "accepted",
      "worker_id": "uuid",
      "estimated_price": 1200.00,
      ...
    },
    "worker_estimate": {
      "estimated_price": 1200.00,
      "note": "Pipe replacement needed",
      ...
    }
  }
}
```

**Validation:**
- User must own the booking
- Booking must be in `pending_estimation` status
- Worker estimate must exist and be in `pending` status
- Worker must still be available (checked before selection)

**Error Responses:**
- `400`: Missing worker_id
- `404`: Booking not found or not in pending_estimation status
- `404`: Worker estimate not found or already processed

**Actions Performed:**
1. Update booking: `worker_id`, `status = 'accepted'`, `estimated_price = selected_estimate.estimated_price`
2. Update selected estimate: `status = 'accepted'`
3. Update other estimates: `status = 'rejected'`
4. Update worker: `availability_status = 'busy'`
5. Create notifications for user and selected worker
6. Emit socket events:
   - `booking:worker-selected` to user
   - `booking:worker-selected` to selected worker
   - `worker:call-request-closed` to category room (other workers)

#### 4. API Endpoint: Get Booking Estimates
```javascript
GET /api/bookings/:id/estimates
Authorization: Bearer <user_token>

Response:
{
  "success": true,
  "data": {
    "estimates": [
      {
        "id": "uuid",
        "worker_id": "uuid",
        "worker_name": "John Worker",
        "worker_photo": "https://...",
        "worker_phone": "+880...",
        "average_rating": 4.5,
        "total_reviews": 25,
        "experience_years": 5,
        "estimated_price": 1200.00,
        "note": "Pipe replacement needed",
        "status": "pending",
        "created_at": "2024-01-15T10:30:00Z"
      },
      ...
    ]
  }
}
```

**Authorization:**
- Only booking owner (user) can view estimates
- Returns only `pending` estimates (accepted/rejected are filtered out)

#### 5. API Endpoint: Get Booking Images
```javascript
GET /api/bookings/:id/images
Authorization: Bearer <user_token> or <worker_token>

Response:
{
  "success": true,
  "data": {
    "images": [
      "https://res.cloudinary.com/...",
      "data:image/jpeg;base64,..."
    ]
  }
}
```

**Authorization:**
- User who owns the booking
- Worker assigned to the booking
- Worker in same category (for `call_worker` bookings in `pending_estimation`)

#### 6. Socket Events

**Worker Side:**

**`worker:call-request`** - Received when a new call request is broadcast
```javascript
{
  "booking_id": "uuid",
  "booking_number": "BK1234567890",
  "service_category_id": "uuid",
  "service_description": "Fix leaking pipe",
  "service_location": "House 12, Road 5",
  "location_latitude": 23.7465,
  "location_longitude": 90.3840,
  "image_urls": [  // Array of image URLs (Cloudinary or base64)
    "https://res.cloudinary.com/...",
    "data:image/jpeg;base64,..."
  ],
  "user": {
    "full_name": "John Doe",
    "phone": "+880...",
    "profile_photo": "https://..."
  },
  "service_category": "Plumber",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**`worker:call-request-closed`** - Received when user selects another worker
```javascript
{
  "booking_id": "uuid",
  "message": "This request has been assigned to another worker"
}
```

**`booking:worker-selected`** - Received when user selects this worker
```javascript
{
  "booking_id": "uuid",
  "booking_number": "BK1234567890",
  "message": "Your estimate has been accepted!"
}
```

**User Side:**

**`booking:new-estimate`** - Received when a worker submits an estimate
```javascript
{
  "booking_id": "uuid",
  "worker_id": "uuid",
  "worker_name": "John Worker",
  "worker_rating": 4.5,
  "worker_reviews": 25,
  "estimated_price": 1200.00,
  "note": "Pipe replacement needed",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**`booking:worker-selected`** - Received when user selects a worker (confirmation)
```javascript
{
  "booking_id": "uuid",
  "worker_id": "uuid",
  "worker_info": {
    "full_name": "John Worker",
    "phone": "+880...",
    "profile_photo": "https://...",
    "average_rating": 4.5,
    "total_reviews": 25
  }
}
```

### Database Schema

#### Bookings Table
```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  worker_id UUID NULL,  -- NULL until user selects a worker
  service_category_id UUID NOT NULL,
  booking_type VARCHAR(20) CHECK (booking_type IN ('instant', 'scheduled', 'call_worker')),
  status VARCHAR(20) DEFAULT 'pending_estimation' CHECK (
    status IN ('pending', 'pending_estimation', 'accepted', 'in_progress', 'completed', 'cancelled', 'rejected')
  ),
  service_description TEXT,
  service_location TEXT,
  location_latitude DECIMAL(10, 8),
  location_longitude DECIMAL(11, 8),
  estimated_price DECIMAL(10, 2),  -- Set when user selects a worker
  payment_method VARCHAR(20),
  booking_number VARCHAR(50) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ...
);
```

#### Booking Images Table
```sql
CREATE TABLE booking_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,  -- Cloudinary URL or base64 data URL
  image_order INTEGER DEFAULT 0,  -- Order of images (0, 1, 2)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_booking_images_booking_id ON booking_images(booking_id);
```

**Image Storage:**
- Cloudinary URLs: `https://res.cloudinary.com/...` (preferred)
- Base64 URLs: `data:image/jpeg;base64,...` (fallback)
- Images stored in order (0, 1, 2) for consistent display

#### Worker Estimates Table
```sql
CREATE TABLE worker_estimates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  worker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  estimated_price DECIMAL(10, 2) NOT NULL,
  note TEXT,  -- Optional note from worker
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(booking_id, worker_id)  -- One estimate per worker per booking
);

CREATE INDEX idx_worker_estimates_booking_id ON worker_estimates(booking_id);
CREATE INDEX idx_worker_estimates_worker_id ON worker_estimates(worker_id);
CREATE INDEX idx_worker_estimates_status ON worker_estimates(status);
```

**Estimate Status Flow:**
- `pending` - Initial status when worker submits
- `accepted` - User selected this worker
- `rejected` - User selected another worker

#### Notifications Table
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  title VARCHAR(255),
  message TEXT,
  type VARCHAR(50),  -- 'job_alert' for call requests, 'booking' for selections
  reference_id UUID,  -- booking_id
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Socket Server Implementation

#### Worker Room Management
- Workers join category-specific rooms: `category:{categoryId}`
- Workers join user-specific rooms: `user:{userId}` or `worker:{workerId}`
- Active workers are tracked by category for efficient broadcasting
- Workers must be verified and available to join category rooms

#### Broadcast Function
```javascript
broadcastCallRequest(categoryId, bookingData)
```
- Finds all active workers in the category
- Emits `worker:call-request` event to the category room
- Includes `image_urls` array in the payload
- Returns count of workers notified

#### Notification Functions
```javascript
notifyUser(userId, event, data)
notifyWorker(workerId, event, data)
```
- Send socket events to specific user/worker rooms
- Used for real-time updates without broadcasting to all

## 📸 Image Upload Features

### Image Requirements
- **Count**: 1-3 images required
- **Format**: JPEG, PNG (handled by browser)
- **Size**: Maximum 5MB per image (configurable via `FILE_UPLOAD.MAX_SIZE`)
- **Source**: Camera or gallery selection
- **Mobile**: `capture="environment"` attribute enables camera on mobile

### Image Processing Flow

1. **Frontend Upload**
   - User selects 1-3 images via file input
   - Images stored in state as File objects
   - Preview thumbnails shown immediately
   - Images sent as FormData in `multipart/form-data` request

2. **Backend Processing**
   - `uploadMultiple('images', 3)` middleware:
     - Validates file count (1-3)
     - Validates file type (JPEG, PNG)
     - Validates file size (max 5MB)
     - Stores files in memory buffer
   - `uploadMultipleToCloudinary` middleware:
     - Checks if Cloudinary is configured
     - If configured: Uploads to Cloudinary, gets URLs
     - If not configured/fails: Converts to base64 data URLs
     - Attaches URLs to `req.cloudinaryUrls`

3. **Storage**
   - Images stored in `booking_images` table
   - Each image has `image_order` (0, 1, 2)
   - URLs stored as TEXT (supports both Cloudinary and base64)

4. **Retrieval**
   - Workers fetch images via `GET /api/bookings/:id/images`
   - Images displayed in modal gallery
   - Supports both URL types seamlessly

### Cloudinary Configuration

**Environment Variables:**
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

**Benefits:**
- Faster image loading
- Reduced database size
- Better performance
- Image optimization

**Fallback:**
- If Cloudinary not configured or fails, system automatically uses base64
- No user-facing errors
- Seamless experience

## 💰 Worker Bidding System

### Estimate Submission Process

1. **Worker Views Request**
   - Opens `CallRequestModal` from dashboard notification
   - Sees images, description, location
   - Assesses the problem

2. **Worker Submits Estimate**
   - Enters price (required, must be > 0)
   - Optionally adds note
   - Clicks "Submit Estimate"
   - Backend validates:
     - Worker eligibility
     - Booking status
     - No duplicate estimate
   - Estimate saved with status `pending`
   - User notified via socket

3. **User Receives Estimate**
   - Real-time notification via `booking:new-estimate` socket event
   - Estimate appears in estimates list
   - Shows worker details, price, note

### Estimate Display

**User Interface:**
- Card-based layout
- Each card shows:
  - Worker photo (or initial avatar)
  - Worker name
  - Rating and review count
  - Estimated price (large, prominent)
  - Optional note (in highlighted box)
  - Experience years (if available)
  - Submission timestamp
  - "Select Worker" button

**Sorting:**
- Estimates sorted by creation time (oldest first)
- User can compare all estimates side-by-side

### User Selection Process

1. **User Reviews Estimates**
   - Sees all pending estimates
   - Compares prices, ratings, notes
   - Makes decision

2. **User Selects Worker**
   - Clicks "Select Worker" on preferred estimate
   - Backend validates selection
   - Updates booking and estimates
   - Notifies all parties

3. **System Updates**
   - Booking: `worker_id`, `status = 'accepted'`, `estimated_price`
   - Selected estimate: `status = 'accepted'`
   - Other estimates: `status = 'rejected'`
   - Selected worker: `availability_status = 'busy'`

## 📍 Location Features

### GPS Integration
- **Browser Geolocation API**: Automatic location detection
- **Reverse Geocoding**: Converts coordinates to address using OSM (OpenStreetMap)
- **Manual Entry**: Users can type address manually
- **Map Picker**: Interactive map for location selection (Leaflet)

### Location Validation
- Latitude: -90 to 90
- Longitude: -180 to 180
- Address validation
- Coordinate format validation

## 🔔 Notification System

### Multi-Channel Notifications

1. **Real-time Socket Notifications**
   - Instant delivery via WebSocket
   - No page refresh needed
   - Works for active connections
   - Events:
     - `worker:call-request` (workers)
     - `booking:new-estimate` (users)
     - `booking:worker-selected` (users and selected worker)
     - `worker:call-request-closed` (other workers)

2. **Database Notifications**
   - Persistent notifications stored in database
   - Available when user returns
   - Type: `job_alert` for workers, `booking` for users
   - Marked as read/unread

3. **Email Notifications** (Optional)
   - Can be configured for important events

### Notification Types

**For Workers:**
- `job_alert`: New call request available (with images)
- `booking`: Estimate accepted by user

**For Users:**
- `booking:new-estimate`: New worker estimate received (socket only)
- `booking:worker-selected`: Worker selected confirmation

## 🚀 Usage Examples

### User Initiates Call with Images

```javascript
// From CallWorker.jsx
const handleSubmit = async (e) => {
  e.preventDefault();
  
  const callData = {
    service_category_id: selectedCategoryId,
    service_description: "Fix leaking pipe in kitchen",
    service_location: "House 12, Road 5, Dhanmondi",
    location_latitude: 23.7465,
    location_longitude: 90.3840,
    payment_method: "cash"
  };
  
  // Send images as files (FormData)
  const response = await bookingService.callWorker(callData, images);
  
  if (response.success) {
    setActiveCall({
      booking_id: response.data.booking.id,
      workers_notified: response.data.workers_notified
    });
    toast.success(`Request sent to ${response.data.workers_notified} workers. Waiting for estimates...`);
  }
};
```

### Worker Submits Estimate

```javascript
// From CallRequestModal.jsx
const handleSubmitEstimate = async () => {
  const estimateData = {
    estimated_price: parseFloat(priceInput),
    note: noteInput || null
  };
  
  const response = await bookingService.submitEstimate(bookingId, estimateData);
  
  if (response.success) {
    toast.success('Your estimate has been submitted!');
    setHasSubmitted(true);
  }
};
```

### User Selects Worker

```javascript
// From CallWorker.jsx
const handleSelectWorker = async (workerId) => {
  const response = await bookingService.selectWorker(bookingId, workerId);
  
  if (response.success) {
    toast.success('Worker selected successfully!');
    navigate('/bookings');
  }
};
```

### Socket Event Listeners

```javascript
// User side - Listen for new estimates
useEffect(() => {
  if (socket && connected && activeCall) {
    const handleNewEstimate = (data) => {
      setEstimates(prev => [...prev, {
        worker_id: data.worker_id,
        worker_name: data.worker_name,
        worker_rating: data.worker_rating,
        worker_reviews: data.worker_reviews,
        estimated_price: data.estimated_price,
        note: data.note,
        created_at: data.created_at
      }]);
      toast.info(`New estimate: ৳${data.estimated_price} from ${data.worker_name}`);
    };

    socket.on('booking:new-estimate', handleNewEstimate);
    
    return () => {
      socket.off('booking:new-estimate', handleNewEstimate);
    };
  }
}, [socket, connected, activeCall]);
```

```javascript
// Worker side - Listen for new requests
useEffect(() => {
  if (socket && connected && user?.role === 'worker') {
    const handleNewCallRequest = (data) => {
      // data.image_urls contains uploaded images
      setIncomingCallRequests(prev => [...prev, data]);
      toast.info(`New call request with ${data.image_urls?.length || 0} images`);
    };

    socket.on('worker:call-request', handleNewCallRequest);
    
    return () => {
      socket.off('worker:call-request', handleNewCallRequest);
    };
  }
}, [socket, connected, user]);
```

## ✅ Worker Requirements

For a worker to receive call requests and submit estimates, they must:

1. **Account Activated**: `is_active = true` (NID verification completed and admin approved)
2. **Be Verified**: `verification_status = 'verified'`
3. **Be Available**: `availability_status = 'available'` (not busy)
4. **Match Category**: `service_category_id` matches request category
5. **Be Online**: Connected via WebSocket (for real-time notifications)

**Note**: Workers who have completed NID verification but are waiting for admin activation (`is_active = false`) will receive a `403` error when attempting to submit estimates, with a message: "Your account must be activated to submit estimates. Please complete NID verification and wait for admin activation."

## 🔒 Security & Validation

### User Side
- Must be authenticated as `user` role
- Must upload 1-3 images
- Location coordinates validated
- Service description required
- Category must exist and be active
- Can only select one worker per booking
- Can only select from pending estimates
- Must own the booking to select worker

### Worker Side
- Must be authenticated as `worker` role
- Account must be active (`is_active = true`) - requires NID verification and admin approval
- Must be verified (`verification_status = 'verified'`)
- Must match service category
- Must be available (not busy) (`availability_status = 'available'`)
- Can only submit one estimate per booking (enforced by UNIQUE constraint)
- Estimated price must be > 0 and valid number
- Estimate can only be submitted for `pending_estimation` bookings
- Worker profile must exist in `worker_profiles` table

### Race Condition Handling
- Database transaction ensures atomicity
- `UNIQUE(booking_id, worker_id)` prevents duplicate estimates
- `worker_id IS NULL` check prevents double selection
- Socket notification to other workers when request is closed
- Database-level constraints ensure data integrity

## 📊 Status Flow

```
User Creates Call Request with Images
    ↓
Status: pending_estimation
worker_id: NULL
estimated_price: NULL
    ↓
Workers Submit Estimates
    ↓
Multiple estimates in worker_estimates table
status: pending
    ↓
User Selects Worker
    ↓
Status: accepted
worker_id: <selected_worker_uuid>
estimated_price: <selected_worker_price>
Selected estimate: status = 'accepted'
Other estimates: status = 'rejected'
Selected worker: availability_status = 'busy'
    ↓
Worker Starts Service
    ↓
Status: in_progress
    ↓
Worker Completes Service
    ↓
Status: completed
    ↓
Payment Processed
    ↓
Status: completed
payment_status: paid
```

## 🎨 UI/UX Features

### User Interface
- Clean, intuitive form design
- **Image upload with preview**:
  - Drag & drop or click to upload
  - Preview thumbnails with remove option
  - Clear visual feedback
  - Mobile camera support
- **Image gallery** - view uploaded images before submission
- Real-time connection status indicator
- GPS location button with permission handling
- **Worker estimates cards**:
  - Professional card-based layout
  - Worker photos and details
  - Prominent price display
  - Note highlighting
  - Easy comparison
- **Worker selection interface** - one-click selection
- Active call status banner
- Loading states and error handling
- Success/error toast notifications

### Worker Interface
- **Image gallery modal**:
  - Grid layout for multiple images
  - Full-size preview
  - Easy navigation
- **Price estimate form**:
  - Simple number input
  - Optional note textarea
  - Clear validation messages
  - Submit button with loading state
- Job alerts section in dashboard
- Real-time notification badges
- **Estimate submission confirmation**:
  - Success message
  - Clear next steps
- Request details modal with images
- Distance calculation display (if available)

## 🔧 Configuration

### Environment Variables
```env
# Cloudinary configuration (optional - falls back to base64)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Socket.io configuration
SOCKET_PORT=5050

# File upload limits
FILE_UPLOAD_MAX_SIZE=5242880  # 5MB in bytes
```

### Constants
```javascript
// Booking types
BOOKING_TYPES = ['instant', 'scheduled', 'call_worker']

// Booking statuses
BOOKING_STATUSES = [
  'pending',
  'pending_estimation',  // New status for bidding system
  'accepted',
  'in_progress',
  'completed',
  'cancelled',
  'rejected'
]

// Estimate statuses
ESTIMATE_STATUSES = ['pending', 'accepted', 'rejected']

// Notification types
NOTIFICATION_TYPES = {
  JOB_ALERT: 'job_alert',
  CALL_WORKER: 'call_worker',
  BOOKING: 'booking'
}
```

## 🐛 Troubleshooting

### Common Issues

1. **No Workers Notified**
   - Check if workers are online and connected
   - Verify workers are verified and active
   - Ensure workers match the service category
   - Check worker availability status
   - Verify socket server is running

2. **Images Not Uploading**
   - Check file size (max 5MB per image)
   - Verify image format (JPEG, PNG)
   - Check browser console for errors
   - Ensure Cloudinary is configured (or base64 will be used)
   - Verify multer middleware is working
   - Check network connectivity

3. **No Estimates Received**
   - Verify workers are viewing the request
   - Check if workers are submitting estimates
   - Ensure booking status is `pending_estimation`
   - Check socket connection
   - Verify worker eligibility (verified, available, correct category)

4. **Socket Not Connecting**
   - Verify WebSocket server is running
   - Check CORS configuration
   - Verify authentication token
   - Check browser console for errors
   - Ensure socket port matches frontend configuration

5. **Location Not Working**
   - Ensure HTTPS (required for geolocation)
   - Check browser permissions
   - Verify GPS/network connectivity
   - Use manual entry as fallback
   - Check browser console for errors

6. **Estimate Submission Fails**
   - Check if worker already submitted estimate
   - Verify worker account is activated (`is_active = true`)
   - Verify worker eligibility (verified, available, correct category)
   - Ensure price is valid number > 0
   - Check booking status is `pending_estimation`
   - Verify worker is not busy
   - Check database constraints
   - If receiving 403 error: Complete NID verification and wait for admin activation

7. **Worker Selection Fails**
   - Verify user owns the booking
   - Check booking status is `pending_estimation`
   - Ensure estimate exists and is pending
   - Verify worker is still available
   - Check for concurrent selections (race condition)

## 📝 API Reference

### POST /api/bookings/call-worker
Create a new instant worker call request with images.

**Headers:**
- `Authorization: Bearer <token>`
- `Content-Type: multipart/form-data` (for file uploads)

**Body (FormData):**
```
service_category_id: string (UUID)
service_description: string
service_location: string
location_latitude: number (optional)
location_longitude: number (optional)
payment_method: 'cash' | 'online'
images: File[] (1-3 image files)
```

**Response:**
```json
{
  "success": true,
  "message": "Call request sent to active workers",
  "data": {
    "booking": {
      "id": "uuid",
      "booking_type": "call_worker",
      "status": "pending_estimation",
      "worker_id": null,
      "estimated_price": null
    },
    "workers_notified": 5
  }
}
```

### POST /api/bookings/:id/submit-estimate
Worker submits a price estimate for a call request.

**Headers:**
- `Authorization: Bearer <worker_token>`

**Body:**
```json
{
  "estimated_price": 1200.00,
  "note": "Optional note"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Estimate submitted successfully",
  "data": {
    "estimate": { ... },
    "worker_info": { ... }
  }
}
```

### PUT /api/bookings/:id/select-worker
User selects a worker from submitted estimates.

**Headers:**
- `Authorization: Bearer <user_token>`

**Body:**
```json
{
  "worker_id": "uuid"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Worker selected successfully",
  "data": {
    "booking": { ... },
    "worker_estimate": { ... }
  }
}
```

### GET /api/bookings/:id/estimates
Get all worker estimates for a booking (User only).

**Headers:**
- `Authorization: Bearer <user_token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "estimates": [
      {
        "worker_id": "uuid",
        "worker_name": "string",
        "estimated_price": 1200.00,
        "note": "string",
        "average_rating": 4.5,
        "total_reviews": 25,
        ...
      }
    ]
  }
}
```

### GET /api/bookings/:id/images
Get booking images (User or Worker).

**Headers:**
- `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "images": ["url1", "url2", "url3"]
  }
}
```

## 🚦 Best Practices

1. **Always validate images** before upload (size, format, count)
2. **Show image previews** to users before submission
3. **Display estimates clearly** with worker information
4. **Handle socket disconnections** gracefully
5. **Provide fallback notifications** via database
6. **Update UI immediately** on socket events
7. **Handle race conditions** properly
8. **Show clear status** to users and workers
9. **Validate estimate prices** (must be > 0)
10. **Provide error messages** for all failure cases
11. **Store images efficiently** (use Cloudinary when possible)
12. **Filter invalid detections** in face verification
13. **Use transactions** for multi-step database operations
14. **Implement proper error handling** at all levels
15. **Log important events** for debugging

## 📚 Related Documentation

- [Socket Server Implementation](./backend/src/socket/socketServer.js)
- [Booking Controller](./backend/src/controllers/bookingController.js)
- [Upload Middleware](./backend/src/middleware/upload.js)
- [Notification System](./NOTIFICATION_SYSTEM_EXPLANATION.md)
- [Database Migration](./backend/database/migration_worker_bidding.sql)

## 🎯 Future Enhancements

Potential improvements for the instant call feature:

1. **Worker Ranking**: Prioritize estimates based on rating, response time, price
2. **Auto-Selection**: Automatically select best estimate if no user action after timeout
3. **Estimate Expiration**: Set time limit for estimate submission
4. **Price Negotiation**: Allow back-and-forth price discussion
5. **Image Annotation**: Allow workers to annotate images with notes
6. **Video Support**: Support video uploads for complex problems
7. **Scheduled Calls**: Schedule instant calls for future time
8. **Voice/Video Integration**: Add voice or video call capability
9. **Push Notifications**: Mobile app push notifications
10. **Analytics Dashboard**: Track estimate patterns, acceptance rates
11. **Price History**: Show worker's previous estimate patterns
12. **Bulk Estimates**: Allow workers to submit estimates for multiple requests

## 📋 Database Migration

To enable this feature, run the migration:

```sql
-- Execute in pgAdmin or PostgreSQL client
-- File: backend/database/migration_worker_bidding.sql
```

This creates:
- `booking_images` table
- `worker_estimates` table
- Updates `bookings` table status constraint
- Adds necessary indexes

## 🔄 Migration from Old System

If you have existing `call_worker` bookings with `status = 'pending'`:
- They will continue to work with the old accept-call flow
- New bookings will use `pending_estimation` status
- Old bookings can be migrated manually if needed:
  ```sql
  UPDATE bookings 
  SET status = 'pending_estimation' 
  WHERE booking_type = 'call_worker' AND status = 'pending' AND worker_id IS NULL;
  ```

## ✅ Implementation Checklist

- [x] Image upload (1-3 images) in frontend
- [x] File upload middleware in backend
- [x] Cloudinary integration with base64 fallback
- [x] Booking creation with `pending_estimation` status
- [x] Image storage in `booking_images` table
- [x] Socket broadcast with images
- [x] Worker estimate submission API
- [x] User estimate viewing API
- [x] Worker selection API
- [x] Real-time socket events
- [x] Estimate display UI
- [x] Worker selection UI
- [x] Image gallery in worker modal
- [x] Database constraints and indexes
- [x] Error handling and validation
- [x] Status flow management

---

**Last Updated**: December 2024  
**Version**: 2.1 (Image-Based Bidding System with Account Activation)  
**Status**: ✅ Fully Implemented  
**Maintainer**: WorkerCall Development Team

## 📝 Recent Updates (v2.1)

- Added account activation requirement for workers (`is_active = true`)
- Enhanced error messages for worker account activation status
- Improved validation for estimate submission
- Updated API response status codes (201 for estimate submission)
- Added comprehensive error handling documentation
