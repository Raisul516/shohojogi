# Fix Instant Booking "pending_estimation" Error

## Problem
When clicking "call worker instantly" and submitting the form, you get this error:
```
Database configuration error: "pending_estimation" status is not allowed. 
Please run the migration to update the database constraint.
```

## Solution

The database constraint for the `bookings` table doesn't include `pending_estimation` status. 

### Automatic Fix (Recommended)
The server will automatically update the constraint when it starts. Just restart your backend server:

```bash
cd backend
npm start
```

The server will check and update the constraint automatically on startup.

### Manual Fix (Alternative)
If you prefer to run the migration manually:

1. **Using the script:**
   ```bash
   cd backend
   ./run-pending-estimation-migration.sh
   ```

2. **Using psql directly:**
   ```bash
   cd backend
   PGPASSWORD=your_password psql -h localhost -U your_user -d your_database -f database/migration_add_pending_estimation_status.sql
   ```

3. **Using pgAdmin 4:**
   - Open pgAdmin 4
   - Right-click on your database > Query Tool
   - Copy and paste the contents of `backend/database/migration_add_pending_estimation_status.sql`
   - Execute the script (F5)

## What This Does

The migration updates the `bookings` table constraint to allow these statuses:
- `pending`
- `pending_estimation` (new - for instant call worker bookings)
- `accepted`
- `in_progress`
- `completed`
- `cancelled`
- `rejected`

## Verification

After running the migration, the "call worker instantly" feature should work without errors.

## Note

If you see this error again after restarting, check:
1. Database credentials in `.env` are correct
2. Database connection is working
3. You have proper permissions to alter table constraints

