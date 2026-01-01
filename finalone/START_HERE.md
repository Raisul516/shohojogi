# 🚀 START HERE - Get Your Project Running

## Quick Start (Easiest Method)

You need to open **2 terminal windows** and run the servers separately.

### Terminal 1 - Backend Server

```bash
cd /Users/maishaahmed/Desktop/finalone/backend
npm start
```

Wait until you see: `✓ Server running on port 5050`

### Terminal 2 - Frontend Server

**Open a NEW terminal window** and run:

```bash
cd /Users/maishaahmed/Desktop/finalone/worker-calling-frontend
npm start
```

This will automatically open http://localhost:3000 in your browser.

---

## ✅ Verify Everything is Working

1. **Backend**: Open http://localhost:5050/health in your browser
   - Should show: `{"success":true,"message":"Server is running",...}`

2. **Frontend**: Should automatically open at http://localhost:3000
   - If not, manually open: http://localhost:3000

---

## ❌ Troubleshooting

### If Backend Won't Start

**Database connection error?**
- Check your `backend/.env` file has correct database credentials
- Make sure PostgreSQL is running: `brew services start postgresql`
- Verify database exists: `psql -l | grep workercalling`

**Port 5050 already in use?**
```bash
lsof -ti:5050 | xargs kill -9
```

### If Frontend Won't Start

**Port 3000 already in use?**
```bash
lsof -ti:3000 | xargs kill -9
```

**Dependencies missing?**
```bash
cd worker-calling-frontend
npm install
```

---

## 🎯 That's It!

Once both terminals show the servers running, open http://localhost:3000 in your browser!

