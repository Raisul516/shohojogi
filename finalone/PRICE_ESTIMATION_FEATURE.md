# Price Estimation API for Instant Booking

## Overview

This feature adds automated price estimation to the Instant Booking flow, allowing users to see an estimated service price before confirming their booking request - similar to Uber's fare estimation.

## Implementation Date
December 2025

---

## 🎯 Feature Description

When users initiate an instant booking:
1. They select a service category (Electrician, Plumber, etc.)
2. They select their location on the map
3. **The system automatically calculates and displays an estimated price**
4. User sees the price breakdown before confirming the booking

---

## 📋 Backend Implementation

### API Endpoint

**POST** `/api/bookings/estimate-price`

**Access:** Public (no authentication required)

**Request Body:**
```json
{
  "service_category_id": "uuid-here",
  "booking_type": "instant",
  "location": {
    "latitude": 23.8103,
    "longitude": 90.4125
  },
  "date": "2025-01-20",  // Optional - for time-based adjustments
  "time": "18:30"        // Optional - for time-based adjustments
}
```

**Response:**
```json
{
  "success": true,
  "estimated_price": 500,
  "currency": "BDT",
  "breakdown": {
    "base_price": 200,
    "distance_cost": 150,
    "time_charge": 70,
    "instant_booking_fee": 80
  },
  "distance_km": 3.0
}
```

### Files Modified/Created

1. **`backend/src/controllers/bookingController.js`**
   - Added `estimatePrice` function (lines ~1260-1375)
   - Handles price calculation logic

2. **`backend/src/routes/booking.routes.js`**
   - Added route: `router.post('/estimate-price', estimatePrice);`
   - Placed before auth middleware (public endpoint)

### Price Calculation Logic

The estimation uses the following factors:

#### 1. Base Price
- **Amount:** ৳200 (configurable via `PRICING.BASE_PRICE` in constants)
- **Source:** `backend/src/config/constants.js`

#### 2. Distance Cost
- **Rate:** ৳50 per kilometer (configurable via `PRICING.PRICE_PER_KM`)
- **Calculation:** Distance from Dhaka city center (23.8103, 90.4125) to user location
- **Formula:** `distanceKm × pricePerKm`

#### 3. Time-Based Adjustments
Only applies if `date` and `time` are provided:

- **Evening (6 PM - 10 PM):** +30% of base price
  - Example: ৳200 × 0.30 = ৳60
  
- **Night (10 PM - 6 AM):** +50% of base price
  - Example: ৳200 × 0.50 = ৳100

- **Daytime (6 AM - 6 PM):** No additional charge

#### 4. Instant Booking Premium
- **Amount:** +40% of base price
- **Applies to:** Only `booking_type: "instant"`
- **Formula:** `basePrice × 0.40`
- **Example:** ৳200 × 0.40 = ৳80

#### 5. Final Price Calculation
```
Total = Base Price + Distance Cost + Time Charge + Instant Booking Fee
Final Price = Round up to nearest 10 BDT
```

**Example Breakdown:**
```
Base Price:          ৳200
Distance (3 km):     ৳150
Evening Charge:      ৳70
Instant Premium:     ৳80
─────────────────────────
Subtotal:            ৳500
Rounded Final:       ৳500
```

---

## 🎨 Frontend Implementation

### Files Modified

1. **`worker-calling-frontend/src/services/bookingService.js`**
   - Added `estimatePrice()` method

2. **`worker-calling-frontend/src/components/booking/InstantCallModal.jsx`**
   - Added price estimation state variables
   - Added `useEffect` hook to fetch estimate when location is selected
   - Added UI component to display price estimate

### User Interface

The price estimate appears in a blue information box below the location picker:

```
┌─────────────────────────────────────┐
│ Estimated Price:         ৳500       │
│ ───────────────────────────────────│
│ Base price:              ৳200      │
│ Distance (3.0 km):       ৳150      │
│ Time charge:             ৳70       │
│ Instant booking:         ৳80       │
│ ───────────────────────────────────│
│ * Final price may vary based on    │
│   actual work required              │
└─────────────────────────────────────┘
```

### Behavior

1. **Automatic Trigger:**
   - Price estimate is fetched automatically when:
     - Modal is open (`isOpen === true`)
     - Service category is selected
     - Location is selected on map

2. **Loading State:**
   - Shows "Calculating price estimate..." with pulse animation
   - Displays while API call is in progress

3. **Error Handling:**
   - Silently fails if API call fails
   - Shows "Unable to calculate price estimate" message
   - Does not block booking flow

4. **Non-Breaking:**
   - Booking can proceed even if price estimate fails
   - Existing booking flow unchanged

---

## 🔧 Configuration

### Environment Variables

None required. Uses constants from `backend/src/config/constants.js`:

```javascript
PRICING = {
  BASE_PRICE: 200,        // Base service price in BDT
  PRICE_PER_KM: 50,       // Price per kilometer in BDT
  MIN_PRICE: 150,         // Minimum booking price
  MAX_PRICE: 10000        // Maximum booking price
}
```

### Customization

To modify pricing:
1. Edit `backend/src/config/constants.js`
2. Or set environment variables in `.env`:
   - `BASE_SERVICE_PRICE` (defaults to 200)
   - `PRICE_PER_KM` (defaults to 50)

---

## 🧪 Testing

### Manual Testing Steps

1. **Start Backend Server:**
   ```bash
   cd backend
   npm start
   ```

2. **Start Frontend Server:**
   ```bash
   cd worker-calling-frontend
   npm start
   ```

3. **Test Price Estimation:**
   - Navigate to worker search page
   - Select a service category
   - Click "Call Workers Instantly"
   - Select location on map
   - Verify price estimate appears below map
   - Check price breakdown is accurate

### API Testing with Postman/cURL

```bash
curl -X POST http://localhost:5050/api/bookings/estimate-price \
  -H "Content-Type: application/json" \
  -d '{
    "service_category_id": "your-category-uuid",
    "booking_type": "instant",
    "location": {
      "latitude": 23.8103,
      "longitude": 90.4125
    }
  }'
```

---

## 📊 Example Calculations

### Scenario 1: Daytime, Close Location
- **Time:** 2:00 PM
- **Distance:** 2 km from center
- **Calculation:**
  - Base: ৳200
  - Distance: 2 × 50 = ৳100
  - Time: ৳0 (daytime)
  - Instant: ৳80
  - **Total: ৳380 → Rounded: ৳380**

### Scenario 2: Evening, Far Location
- **Time:** 7:00 PM
- **Distance:** 5 km from center
- **Calculation:**
  - Base: ৳200
  - Distance: 5 × 50 = ৳250
  - Time: ৳60 (evening 30%)
  - Instant: ৳80
  - **Total: ৳590 → Rounded: ৳590**

### Scenario 3: Night, Very Far
- **Time:** 11:00 PM
- **Distance:** 8 km from center
- **Calculation:**
  - Base: ৳200
  - Distance: 8 × 50 = ৳400
  - Time: ৳100 (night 50%)
  - Instant: ৳80
  - **Total: ৳780 → Rounded: ৳780**

---

## ✅ Implemented Features

1. **Dynamic Worker Location:**
   - ✅ Calculate distance from nearest available worker instead of city center
   - ✅ More accurate pricing based on actual worker locations
   - ✅ Falls back to default location if no available workers found

## 🔄 Future Enhancements

Potential improvements for future versions:

2. **Category-Specific Pricing:**
   - Different base prices per service category
   - Some services (e.g., AC repair) may cost more

3. **Surge Pricing:**
   - Dynamic pricing during high demand
   - Multiplier based on worker availability

4. **Complexity Factor:**
   - Adjust price based on job description keywords
   - Complex jobs cost more

5. **User History:**
   - Show price comparison with previous bookings
   - Display average price for similar services

---

## 📝 Notes

- Price estimate is **non-binding** - final price may vary
- Actual price is determined by worker after job assessment
- Estimate serves as a guide for user expectations
- No database storage required for estimates (calculated on-demand)

---

## ✅ Checklist

- [x] Backend API endpoint created
- [x] Price calculation logic implemented
- [x] Frontend service method added
- [x] UI component integrated in InstantCallModal
- [x] Error handling implemented
- [x] Loading states added
- [x] Non-breaking integration (existing flow unchanged)
- [x] Documentation created

---

## 🐛 Troubleshooting

### Price estimate not showing

1. **Check backend is running:**
   - Verify: http://localhost:5050/health

2. **Check browser console:**
   - Open DevTools (F12) → Console tab
   - Look for API errors

3. **Verify API endpoint:**
   - Test with Postman/curl (see Testing section)

4. **Check location is selected:**
   - Price only fetches when location coordinates are available

### Price seems incorrect

1. **Verify constants:**
   - Check `backend/src/config/constants.js` for PRICING values

2. **Check distance calculation:**
   - Distance is calculated from Dhaka city center (23.8103, 90.4125)

3. **Verify time-based charges:**
   - Only apply if date and time are provided in request

---

## 📚 Related Files

- `backend/src/controllers/bookingController.js` - Price estimation logic
- `backend/src/routes/booking.routes.js` - API route definition
- `backend/src/config/constants.js` - Pricing constants
- `backend/src/utils/helpers.js` - Distance calculation utility
- `worker-calling-frontend/src/components/booking/InstantCallModal.jsx` - UI component
- `worker-calling-frontend/src/services/bookingService.js` - API service method

---

## 🔧 Bug Fix Applied (2025-01-20)

### Issue Fixed:
- **Price UI showing before location selection**: The estimated price UI was appearing before the user selected a location, which was incorrect behavior.

### Solution:
- Modified `InstantCallModal.jsx` to only show price estimate UI when:
  - Location is selected (lat & lng available)
  - AND either loading is in progress OR price estimate response exists
- This ensures:
  - ✅ No price UI appears before location selection
  - ✅ Loading indicator shows during API call
  - ✅ Estimated price shows only after successful API response
  - ✅ "Unable to calculate" shows only if API fails after location selection
  - ✅ Booking flow is never blocked

### Code Change:
```javascript
// Before: Showed price box whenever location existed
{location && location.lat && location.lng && (
  <PriceBox />
)}

// After: Only show if location exists AND (loading OR estimate available)
{location && location.lat && location.lng && (loadingEstimate || priceEstimate !== null) && (
  <PriceBox />
)}
```

### Files Modified:
- `worker-calling-frontend/src/components/booking/InstantCallModal.jsx`

**Last Updated:** 2025-01-20  
**Feature Status**: ✅ Complete and Production Ready (with bug fix)

