# How to Run Backend and Frontend

## Quick Start (Easiest Method)

### Option 1: Use the Batch File (Windows)
1. Navigate to the `finalone` folder
2. Double-click `start-project.bat`
3. Two command windows will open - one for backend, one for frontend
4. Wait for both to start (about 10-30 seconds)

### Option 2: Manual Start (Recommended for Development)

#### Start Backend Server:
1. Open a terminal/command prompt
2. Navigate to backend folder:
   ```bash
   cd "E:\finalone 2\finalone\backend"
   ```
3. Start the server:
   ```bash
   npm start
   ```
   Or for development with auto-reload:
   ```bash
   npm run dev
   ```
4. Backend will run on: **http://localhost:5050**

#### Start Frontend Server:
1. Open a **NEW** terminal/command prompt
2. Navigate to frontend folder:
   ```bash
   cd "E:\finalone 2\finalone\worker-calling-frontend"
   ```
3. Start the server:
   ```bash
   npm start
   ```
4. Frontend will run on: **http://localhost:3000** (opens automatically in browser)

## Verify Servers Are Running

### Check Backend:
- Open browser: http://localhost:5050/health
- Should see: `{"success":true,"message":"Server is running",...}`

### Check Frontend:
- Open browser: http://localhost:3000
- Should see the application homepage

## Current Status

✅ **Backend dependencies:** Installed
✅ **Frontend dependencies:** Installed  
✅ **Database:** Connected (you mentioned you already connected it)
✅ **.env file:** Exists

## Troubleshooting

### If Backend Won't Start:
- Check that `.env` file exists in `backend` folder
- Verify database credentials in `.env` file
- Make sure PostgreSQL is running
- Check if port 5050 is already in use

### If Frontend Won't Start:
- Check if port 3000 is already in use
- Make sure backend is running first
- Check browser console for errors

### Port Already in Use:
- Backend: Change `PORT` in `backend/.env` file
- Frontend: Create `.env` file in `worker-calling-frontend` with `PORT=3001`

## Stop Servers

- Press `Ctrl + C` in each terminal window
- Or close the terminal windows

