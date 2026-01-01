# Quick Fix for Instant Booking Error

## Problem
Getting error: `"pending_estimation" status is not allowed. Please run the migration to update the database constraint`

## Quick Solution (Run This Now!)

### Option 1: Run the Fix Script (Easiest)
```bash
cd backend
./fix-instant-booking.sh
```

### Option 2: Run SQL Directly in pgAdmin 4
1. Open pgAdmin 4
2. Right-click on your database > Query Tool
3. Copy and paste the contents of `backend/fix-instant-booking-constraints.sql`
4. Execute (F5)

### Option 3: Run SQL via psql Command Line
```bash
cd backend
PGPASSWORD=your_password psql -h localhost -U your_user -d your_database -f fix-instant-booking-constraints.sql
```

## What This Fixes
1. ✅ Makes `worker_id` nullable (needed for call_worker bookings)
2. ✅ Adds `'call_worker'` to booking_type constraint
3. ✅ Adds `'pending_estimation'` to status constraint

## After Running the Fix
1. Restart your backend server
2. Try the "call worker instantly" feature again
3. It should work without errors!

## Verification
After running the fix, you can verify it worked by running this query:
```sql
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'public'
  AND check_clause LIKE '%pending_estimation%';
```

You should see a constraint that includes `pending_estimation` in the check_clause.

