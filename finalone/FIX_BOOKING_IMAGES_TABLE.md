# Fix "booking_images" Table Error

## Problem
Getting error: `relation "booking_images" does not exist` when trying to use "call worker instantly" feature.

## Quick Solution

### Option 1: Restart Backend Server (Automatic Fix)
The server will now automatically create the missing tables on startup. Just restart:

```bash
cd backend
npm start
```

### Option 2: Run the Updated Fix Script
```bash
cd backend
./fix-instant-booking.sh
```

This script now also creates the `booking_images` and `worker_estimates` tables.

### Option 3: Run SQL Directly
1. Open pgAdmin 4
2. Right-click on your database > Query Tool
3. Copy and paste the contents of `backend/fix-instant-booking-constraints.sql`
4. Execute (F5)

## What Gets Created

1. **booking_images table** - Stores images uploaded with instant call requests
2. **worker_estimates table** - Stores worker price estimates/bids
3. All necessary indexes for performance

## After Running the Fix

1. Restart your backend server
2. Try "call worker instantly" again
3. It should work without errors!

## Verification

You can verify the tables were created by running:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('booking_images', 'worker_estimates');
```

Both tables should appear in the results.

