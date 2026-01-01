# Notification System Explanation

This document explains how the notification system works in the Worker Calling platform.

## Overview

The notification system uses a **dual approach**:
1. **Database Storage**: All notifications are stored in PostgreSQL
2. **Real-time Delivery**: Socket.IO is used for instant real-time notifications

---

## Architecture

### Backend Components

#### 1. Database Table (`notifications`)
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,           -- Who receives the notification
    title VARCHAR(255) NOT NULL,      -- Notification title
    message TEXT NOT NULL,            -- Notification message
    type VARCHAR(50) NOT NULL,        -- Type: 'booking', 'payment', 'review', 'message', 'job_alert', 'call_worker'
    reference_id UUID,                -- Links to booking_id or other entities
    is_read BOOLEAN DEFAULT FALSE,    -- Read/unread status
    created_at TIMESTAMP
);
```

#### 2. Socket.IO Server (`backend/src/socket/socketServer.js`)

**Key Functions:**
- `notifyUser(userId, event, data)` - Sends real-time notification to a specific user
- `notifyWorker(workerId, event, data)` - Sends real-time notification to a specific worker
- `broadcastCallRequest(categoryId, bookingData)` - Broadcasts job requests to all active workers in a category

**Socket Rooms:**
- `user:{userId}` - Personal room for each user (for direct notifications)
- `worker:{workerId}` - Personal room for each worker
- `category:{categoryId}` - Room for all active workers in a service category

---

## How Notifications Are Created

### 1. Booking Notifications

**When a user creates a booking:**
```javascript
// backend/src/controllers/bookingController.js - createBooking()
- Creates notification in database for the worker
- Type: 'booking'
- Title: "New Instant Job Request!" or "New Scheduled Job Request"
- Reference: booking_id
```

**When booking status changes (accepted, rejected, completed, cancelled):**
- Creates notifications for both user and worker
- Includes relevant status information

### 2. Message Notifications

**When a user sends a chat message:**
```javascript
// backend/src/controllers/chatController.js - sendMessage()
1. Creates notification in database
2. Sends real-time socket notification via notifyUser()
   - Event: 'message:new'
   - Data: { message_id, sender_id, sender_name, message_text, booking_id }
```

### 3. Job Alert Notifications (For Workers)

**When a user calls a worker (instant request):**
```javascript
// backend/src/controllers/bookingController.js - callWorker()
1. Creates job_alert notifications in database for ALL active workers in category
2. Broadcasts via Socket.IO to category room
   - Event: 'worker:call-request'
   - All active workers in that category receive it instantly
```

### 4. Payment Notifications

**When payment is successful:**
- Creates notification for user
- Type: 'payment'
- Includes payment details

### 5. Review Notifications

**When a user leaves a review:**
- Creates notification for worker
- Type: 'review'
- Includes review details

---

## Frontend Implementation

### 1. Socket Connection (`worker-calling-frontend/src/hooks/useSocket.js`)

```javascript
- Establishes WebSocket connection to backend
- Authenticates using JWT token
- Provides: socket, connected, emit(), on(), off()
```

### 2. Navbar Notifications (`worker-calling-frontend/src/components/common/Navbar.jsx`)

**Regular Notifications:**
- Fetches from API: `GET /api/users/notifications`
- Polls every 30 seconds
- Shows unread count badge
- Excludes job alerts (those are separate)

**Job Alerts (Workers Only):**
- Fetches from API: `GET /api/users/job-alerts`
- Listens to real-time socket event: `worker:call-request`
- Shows separate badge count
- Auto-refreshes when new call request arrives

### 3. Worker Dashboard (`worker-calling-frontend/src/pages/WorkerDashboard.jsx`)

**Real-time Call Requests:**
- Listens to `worker:call-request` socket event
- Shows incoming requests immediately
- Shows toast notification when new request arrives
- Updates when another worker accepts (`worker:call-request-accepted`)

---

## Notification Flow Examples

### Example 1: User Creates Booking

```
1. User creates booking via API
   ↓
2. Backend creates notification record in database:
   - user_id: worker's ID
   - type: 'booking'
   - title: "New Scheduled Job Request"
   - reference_id: booking.id
   ↓
3. Backend sends socket notification:
   notifyUser(workerId, 'booking:new', {...})
   ↓
4. Frontend (if worker is online):
   - Receives socket event
   - Navbar polls API and updates notification list
   - Shows unread badge
```

### Example 2: Worker Receives Instant Call Request

```
1. User clicks "Call Worker" button
   ↓
2. Backend:
   a. Creates booking without worker_id
   b. Creates job_alert notifications for ALL active workers in category
   c. Broadcasts via Socket.IO: broadcastCallRequest(categoryId, data)
   ↓
3. All active workers in that category:
   - Receive socket event: 'worker:call-request'
   - WorkerDashboard shows request immediately
   - Toast notification appears
   - Navbar job alerts badge updates
   ↓
4. When worker accepts:
   - Notification updated
   - Other workers receive 'worker:call-request-accepted' event
   - Their request list updates
```

### Example 3: User Sends Chat Message

```
1. User sends message via API
   ↓
2. Backend:
   a. Saves message to database
   b. Creates notification record
   c. Sends socket: notifyUser(receiverId, 'message:new', {...})
   ↓
3. Receiver's frontend:
   - Receives socket event (if connected)
   - Navbar polls and shows notification
   - Can click to open chat
```

---

## API Endpoints

### Get Notifications
```
GET /api/users/notifications
Query params:
  - page, limit (pagination)
  - is_read (filter by read status)
  - exclude_type (exclude job_alert, call_worker)
  
Returns:
  - notifications array
  - unread_count
```

### Get Job Alerts (Workers Only)
```
GET /api/users/job-alerts
Query params:
  - page, limit
  
Returns:
  - alerts array (only job_alert and call_worker types)
  - unread_count
```

### Mark as Read
```
PUT /api/users/notifications/:id/read
Marks single notification as read
```

### Mark All as Read
```
PUT /api/users/notifications/read-all
Marks all user notifications as read
```

---

## Socket Events

### Events Sent by Backend

| Event | Recipient | When | Data |
|-------|-----------|------|------|
| `message:new` | Specific user | New chat message | `{ message_id, sender_id, message_text, booking_id }` |
| `worker:call-request` | All workers in category | Instant job request | `{ booking_id, service_description, location, etc. }` |
| `worker:call-request-accepted` | Other workers in category | Request accepted by someone else | `{ booking_id, accepted_by }` |
| `booking:new` | Worker/User | New booking created | Booking details |
| `booking:updated` | User/Worker | Booking status changed | Updated booking |

### Events Sent by Frontend

| Event | When | Data |
|-------|------|------|
| `worker:availability-update` | Worker changes availability | `{ availability_status, service_category_id }` |

---

## Key Features

1. **Persistent Storage**: All notifications saved in database (won't lose if user offline)
2. **Real-time Delivery**: Instant notifications via Socket.IO when user is online
3. **Separation**: Job alerts separate from regular notifications
4. **Read/Unread Tracking**: Database tracks read status
5. **Polling Fallback**: API polling every 30 seconds as backup
6. **Category Broadcasting**: Job requests broadcast to relevant workers only

---

## Notification Types

| Type | Description | Created For |
|------|-------------|-------------|
| `booking` | Booking created/updated | User & Worker |
| `message` | New chat message | Message receiver |
| `payment` | Payment status updates | User |
| `review` | New review received | Worker |
| `job_alert` | Instant job request | All active workers in category |
| `call_worker` | Call worker request | All active workers in category |
| `system` | System/admin notifications | User/Worker |

---

## Frontend Display

### Navbar Notification Dropdown
- Shows last 10 regular notifications
- Badge shows unread count
- Click to mark as read
- Click notification to navigate (booking → booking details, message → chat)

### Worker Dashboard
- Shows incoming call requests in real-time
- Separate section for job alerts
- Instant updates via Socket.IO

---

## Important Notes

1. **Job Alerts vs Regular Notifications**: Job alerts are excluded from regular notifications endpoint to avoid clutter
2. **Socket Authentication**: Socket connections require valid JWT token
3. **Worker Registration**: Workers must be verified and available to receive job alerts
4. **Polling Interval**: Frontend polls API every 30 seconds (can be adjusted)
5. **Real-time Priority**: Socket events take priority, API polling is backup

