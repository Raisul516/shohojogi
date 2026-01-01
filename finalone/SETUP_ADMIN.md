# Admin Login Setup Guide

## Step 1: Start Backend Server

Open Terminal and run:
```bash
cd /Users/maishaahmed/Desktop/finalone/backend
npm start
```

Wait until you see:
```
✓ Server running on port 5050
```

**Keep this terminal window open!**

## Step 2: Create/Verify Admin User

**In a NEW terminal window**, run:
```bash
cd /Users/maishaahmed/Desktop/finalone/backend
node createAdmin.js
```

This will:
- Create the admin user if it doesn't exist
- Update the password if the user already exists
- Set the user as active and verified

**Admin Credentials:**
- Email: `admin@workercalling.com`
- Password: `Admin@12345`

## Step 3: Start Frontend Server

**In another NEW terminal window**, run:
```bash
cd /Users/maishaahmed/Desktop/finalone/worker-calling-frontend
npm start
```

## Step 4: Login

1. Open http://localhost:3000 in your browser
2. Click "Login"
3. Enter:
   - Email: `admin@workercalling.com`
   - Password: `Admin@12345`
4. Click Login

## Troubleshooting

### "Network error, please check your connection"
- Make sure backend server is running (check Step 1)
- Verify backend is on port 5050: Open http://localhost:5050/health in browser
- Should show: `{"success":true,"message":"Server is running",...}`

### "Invalid email or password"
- Run `node createAdmin.js` again to reset the password
- Make sure you're using: `admin@workercalling.com` and `Admin@12345`

### Port 5050 already in use
```bash
# Kill process on port 5050
lsof -ti:5050 | xargs kill -9

# Then start backend again
cd backend
npm start
```

### Database connection error
- Check your `backend/.env` file has correct database credentials
- Make sure PostgreSQL is running: `brew services start postgresql`
- Verify database exists: `psql -l | grep workercalling`

