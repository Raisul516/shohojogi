# Mac Setup Guide - Worker Calling System

This guide will help you set up and run the project on your Mac.

## Prerequisites Check

✅ **Node.js**: v20.19.0 (installed - meets requirement of v18+)  
✅ **npm**: v11.6.2 (installed)  
✅ **PostgreSQL**: Installed at `/opt/homebrew/bin/psql`

## Step 1: Database Setup

### 1.1 Start PostgreSQL (if not running)

```bash
# Check if PostgreSQL is running
pg_isready

# If not running, start it using Homebrew
brew services start postgresql

# Or if installed differently, try:
# sudo service postgresql start
# or
# pg_ctl -D /usr/local/var/postgres start
```

### 1.2 Create Database

```bash
# Connect to PostgreSQL (default user is usually your Mac username)
psql postgres

# Or if you have a postgres user:
psql -U postgres
```

Once connected, run these SQL commands:

```sql
-- Create database
CREATE DATABASE workercalling;

-- Exit psql
\q
```

### 1.3 Initialize Database Schema

```bash
# Connect to the workercalling database
psql -d workercalling

# Copy and paste the contents of backend/database/init.sql
# Or run it directly:
psql -d workercalling -f backend/database/init.sql
```

### 1.4 (Optional) Seed Sample Data

```bash
# Run seed script for initial categories
psql -d workercalling -f backend/database/seed.sql
```

## Step 2: Environment Configuration

### 2.1 Backend .env File

The `.env` file already exists in the `backend` folder. Make sure it has the following **required** variables:

```env
# Database Configuration (REQUIRED)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=workercalling
DB_USER=your_postgres_username        # Usually 'postgres' or your Mac username
DB_PASSWORD=your_postgres_password    # Your PostgreSQL password

# JWT Configuration (REQUIRED)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Server Configuration
PORT=5050
NODE_ENV=development
BACKEND_URL=http://localhost:5050
FRONTEND_URL=http://localhost:3000
```

**Note**: If you don't have a PostgreSQL password set, you may need to:
1. Set a password for the postgres user, OR
2. Use your Mac username as DB_USER and leave DB_PASSWORD empty (if configured for peer authentication)

### 2.2 Check Current .env

```bash
cd backend
cat .env
```

Update the database credentials if needed.

## Step 3: Install Dependencies

Dependencies appear to be installed, but if you need to reinstall:

```bash
# Backend dependencies
cd backend
npm install

# Frontend dependencies
cd ../worker-calling-frontend
npm install
```

## Step 4: Create Admin User (Optional but Recommended)

```bash
cd backend
node createAdmin.js
```

This creates an admin user:
- Email: `admin@workercalling.com`
- Password: `Admin@12345`

## Step 5: Seed Sample Workers (Optional)

```bash
cd backend
node seedWorkers.js
```

This creates sample workers you can use for testing.

## Step 6: Start the Project

### Option 1: Use the Startup Script (Recommended)

```bash
# Make the script executable (if needed)
chmod +x start-project.sh

# Run the startup script
./start-project.sh
```

This will start both backend and frontend servers.

### Option 2: Start Servers Manually

**Terminal 1 - Backend:**
```bash
cd backend
npm start
# or for development with auto-reload:
npm run dev
```

**Terminal 2 - Frontend:**
```bash
cd worker-calling-frontend
npm start
```

## Step 7: Verify Everything is Working

1. **Backend Health Check:**
   - Open browser: http://localhost:5050/health
   - Should see: `{"success":true,"message":"Server is running",...}`

2. **Frontend:**
   - Open browser: http://localhost:3000
   - Should see the application homepage

## Troubleshooting

### Database Connection Issues

**Error: "password authentication failed"**
- Check your `.env` file has correct DB_USER and DB_PASSWORD
- Try connecting manually: `psql -U postgres -d workercalling`
- If you haven't set a password, you may need to configure PostgreSQL authentication

**Error: "database does not exist"**
- Create the database: `createdb workercalling`
- Or run: `psql postgres` → `CREATE DATABASE workercalling;`

**Error: "relation does not exist"**
- Run the init.sql script: `psql -d workercalling -f backend/database/init.sql`

### Port Already in Use

**Port 5050 (backend) in use:**
```bash
# Find process using port 5050
lsof -i :5050

# Kill the process (replace PID with actual process ID)
kill -9 PID
```

**Port 3000 (frontend) in use:**
```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 PID
```

### PostgreSQL Not Running

```bash
# Check status
brew services list

# Start PostgreSQL
brew services start postgresql

# Check if running
pg_isready
```

### Node Modules Issues

If you encounter dependency issues:

```bash
# Backend - reinstall
cd backend
rm -rf node_modules package-lock.json
npm install

# Frontend - reinstall
cd ../worker-calling-frontend
rm -rf node_modules package-lock.json
npm install
```

## Default Login Credentials

After running `createAdmin.js`:
- **Admin Email**: `admin@workercalling.com`
- **Admin Password**: `Admin@12345`

After running `seedWorkers.js`:
- **Worker Email**: Check the seed script output
- **Worker Password**: `Worker123`

## Next Steps

1. ✅ Database is set up and running
2. ✅ Backend server is running on port 5050
3. ✅ Frontend server is running on port 3000
4. ✅ Visit http://localhost:3000 to use the application

## Optional: Configure Additional Services

The project supports optional services (already configured with defaults if not set):
- **Cloudinary**: For image hosting (otherwise uses base64)
- **Gemini AI**: For OCR and price estimation
- **Email**: For sending emails
- **SMS**: For sending SMS notifications
- **Payment Gateways**: SSLCommerz, bKash, Stripe

These are optional - the project will work without them using fallback methods.

---

**Need Help?** Check the other documentation files:
- `START_PROJECT.md` - General project overview
- `backend/SETUP_INSTRUCTIONS.md` - Detailed backend setup
- `QUICK_START.md` - Quick start guide

