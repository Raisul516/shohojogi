# Quick Start Guide for Mac

This is a quick reference guide to get your friend's project running on your Mac.

## ✅ What's Already Done

- ✅ Node.js and npm are installed
- ✅ PostgreSQL is installed
- ✅ Dependencies appear to be installed (node_modules exist)
- ✅ Startup script created (`start-project.sh`)

## 🚀 Quick Start (3 Steps)

### Step 1: Set Up Database

**Option A - Use the setup script:**
```bash
chmod +x setup-database.sh
./setup-database.sh
```

**Option B - Manual setup:**
```bash
# 1. Start PostgreSQL (if not running)
brew services start postgresql

# 2. Create database
createdb workercalling

# 3. Initialize schema
psql -d workercalling -f backend/database/init.sql

# 4. (Optional) Seed sample data
psql -d workercalling -f backend/database/seed.sql
```

### Step 2: Configure Environment Variables

Edit `backend/.env` and make sure it has your database credentials:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=workercalling
DB_USER=your_username        # Usually your Mac username or 'postgres'
DB_PASSWORD=your_password    # Your PostgreSQL password (if set)
JWT_SECRET=your-secret-key-here
```

**Note:** If PostgreSQL doesn't have a password set, you might need to use peer authentication. Try using your Mac username as `DB_USER` and leave `DB_PASSWORD` empty, or set a password for your PostgreSQL user.

### Step 3: Start the Project

```bash
# Make scripts executable
chmod +x start-project.sh

# Start both servers
./start-project.sh
```

Or start manually in two terminals:
```bash
# Terminal 1 - Backend
cd backend
npm start

# Terminal 2 - Frontend  
cd worker-calling-frontend
npm start
```

## 🎯 Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5050
- **Health Check**: http://localhost:5050/health

## 👤 Default Login (After Setup)

After running `node backend/createAdmin.js`:
- **Email**: admin@workercalling.com
- **Password**: Admin@12345

## ⚠️ Common Issues

### PostgreSQL Not Running
```bash
brew services start postgresql
# Check status
pg_isready
```

### Database Connection Error
1. Check `backend/.env` has correct credentials
2. Make sure database exists: `psql -l | grep workercalling`
3. Try connecting manually: `psql -d workercalling`

### Port Already in Use
```bash
# Find and kill process on port 5050
lsof -ti:5050 | xargs kill -9

# Find and kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

### Need to Reinstall Dependencies
```bash
# Backend
cd backend
rm -rf node_modules package-lock.json
npm install

# Frontend
cd worker-calling-frontend
rm -rf node_modules package-lock.json
npm install
```

## 📚 More Help

- See `MAC_SETUP_GUIDE.md` for detailed setup instructions
- See `START_PROJECT.md` for general project information
- See `backend/SETUP_INSTRUCTIONS.md` for backend-specific details

---

**Ready to start?** Run: `./setup-database.sh` then `./start-project.sh`

