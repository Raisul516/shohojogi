# How to Run the Project

## Prerequisites
- ✅ Node.js v18+ installed (you have v24.11.1)
- ✅ PostgreSQL database connected
- ✅ Dependencies installed (node_modules exist)

## Quick Start Guide

### Option 1: Run Servers Manually (Recommended for debugging)

#### Step 1: Start Backend Server

Open a terminal/command prompt and run:

```bash
cd backend
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

The backend should start on **http://localhost:5050**

**Expected output:**
- ✓ Connected to PostgreSQL database
- ✓ Database tables verified
- ✓ Server running on port 5050

#### Step 2: Start Frontend Server

Open a **new** terminal/command prompt and run:

```bash
cd worker-calling-frontend
npm start
```

The frontend should start on **http://localhost:3000** and open automatically in your browser.

---

### Option 2: Use the Start Script (Windows)

I've created a `start-project.bat` file that will start both servers. Simply double-click it or run:

```bash
start-project.bat
```

---

## Verify Everything is Working

1. **Check Backend Health:**
   - Open browser: http://localhost:5050/health
   - Should see: `{"success":true,"message":"Server is running",...}`

2. **Check Frontend:**
   - Open browser: http://localhost:3000
   - Should see the application homepage

3. **Test Database Connection:**
   - If backend shows "✓ Connected to PostgreSQL database", your DB is connected!

---

## Common Issues & Solutions

### Backend won't start

**Missing environment variables:**
- Make sure `backend/.env` file exists with:
  - `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
  - `JWT_SECRET` (required)

**Database connection error:**
- Verify PostgreSQL is running
- Check database credentials in `.env` file
- Ensure database exists and tables are initialized (run `backend/database/init.sql`)

### Frontend can't connect to backend

- Make sure backend is running on port 5050
- Check `worker-calling-frontend/.env` (if exists) or verify API URL in code
- Default API URL: `http://localhost:5050`

### Port already in use

- Backend default: 5050
- Frontend default: 3000
- Change ports in `.env` (backend) or create `.env` for frontend with `PORT=3001`

---

## Database Setup (If needed)

If you need to initialize the database:

1. Open pgAdmin 4
2. Connect to your database
3. Right-click database > Query Tool
4. Run `backend/database/init.sql` to create tables
5. (Optional) Run `backend/database/seed.sql` for sample data

### Create Admin User

After database is set up:

```bash
cd backend
node createAdmin.js
```

This creates admin user:
- Email: `admin@workercalling.com`
- Password: `Admin@12345`

### Seed Sample Workers

```bash
node seedWorkers.js
```

---

## Project Structure

```
finalone/
├── backend/              # Node.js/Express API server
│   ├── src/             # Source code
│   ├── database/        # SQL scripts
│   ├── server.js        # Entry point
│   └── .env            # Environment variables (database config)
│
└── worker-calling-frontend/  # React frontend
    ├── src/             # React components
    ├── public/          # Static files
    └── package.json     # Dependencies
```

---

## Next Steps

Once both servers are running:

1. Visit http://localhost:3000
2. Register a new account or login
3. Explore the worker calling platform!

**Default Admin Login:**
- Email: `admin@workercalling.com`
- Password: `Admin@12345`

---

## Development Tips

- Use `npm run dev` in backend for auto-reload on file changes
- Frontend auto-reloads when you save files
- Check browser console and terminal for errors
- Use Postman to test API endpoints directly

