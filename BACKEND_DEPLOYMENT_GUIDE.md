# Backend Deployment Guide

## 🚀 Deploy Backend to Railway (Recommended - Free Tier Available)

Railway is the easiest way to deploy your Node.js backend with PostgreSQL database.

### Step 1: Create Railway Account

1. Go to https://railway.app
2. Click **"Start a New Project"**
3. Sign in with **GitHub** (recommended) or email

### Step 2: Create PostgreSQL Database

1. In Railway dashboard, click **"+ New"**
2. Select **"Database"** → **"Add PostgreSQL"**
3. Wait for the database to be created
4. Click on the PostgreSQL service
5. Go to **"Variables"** tab
6. **Copy these values** (you'll need them):
   - `PGHOST`
   - `PGPORT`
   - `PGDATABASE`
   - `PGUSER`
   - `PGPASSWORD`

### Step 3: Deploy Backend Code

#### Option A: Deploy from GitHub (Recommended)

1. **Push backend to GitHub:**
   ```bash
   cd "/Users/maishaahmed/Desktop/finalone 2/finalone/backend"
   git init
   git add .
   git commit -m "Initial backend commit"
   git branch -M main
   ```
   
   Then create a new GitHub repository and push:
   ```bash
   git remote add origin https://github.com/maisha0055/worker-calling-backend.git
   git push -u origin main
   ```

2. **In Railway:**
   - Click **"+ New"** → **"GitHub Repo"**
   - Select your `worker-calling-backend` repository
   - Railway will auto-detect it's a Node.js app

#### Option B: Deploy from Local Directory

1. In Railway dashboard, click **"+ New"** → **"Empty Project"**
2. Click **"+ New"** → **"GitHub Repo"** or **"Deploy from GitHub repo"**
3. Select your backend repository

### Step 4: Configure Environment Variables

1. Click on your **backend service** in Railway
2. Go to **"Variables"** tab
3. Add these environment variables:

#### Required Variables:

```env
# Database (from PostgreSQL service you created)
DB_HOST=${{Postgres.PGHOST}}
DB_PORT=${{Postgres.PGPORT}}
DB_NAME=${{Postgres.PGDATABASE}}
DB_USER=${{Postgres.PGUSER}}
DB_PASSWORD=${{Postgres.PGPASSWORD}}

# JWT Secret (generate a random string)
JWT_SECRET=your-super-secret-jwt-key-change-this-to-random-string

# Port (Railway will set this automatically, but you can add)
PORT=5050

# Frontend URL (your Vercel URL - update after frontend is deployed)
FRONTEND_URL=https://your-frontend.vercel.app

# Backend URL (will be set automatically by Railway)
BACKEND_URL=${{RAILWAY_PUBLIC_DOMAIN}}
```

#### Optional Variables (for full functionality):

```env
# Cloudinary (for image uploads)
CLOUDINARY_CLOUD_NAME=your-cloudinary-cloud-name
CLOUDINARY_API_KEY=your-cloudinary-api-key
CLOUDINARY_API_SECRET=your-cloudinary-api-secret

# SSLCommerz (for payments - optional)
SSLC_STORE_ID=your-store-id
SSLC_STORE_PASSWORD=your-store-password
SSLC_SUCCESS_URL=https://your-frontend.vercel.app/payment-success
SSLC_FAIL_URL=https://your-frontend.vercel.app/payment-fail
SSLC_CANCEL_URL=https://your-frontend.vercel.app/payment-cancel

# Email (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password

# SMS (optional)
SMS_API_KEY=your-sms-api-key
```

**Important Notes:**
- For database variables, use Railway's reference syntax: `${{Postgres.PGHOST}}`
- Replace `Postgres` with your actual PostgreSQL service name if different
- Generate a strong `JWT_SECRET` (you can use: `openssl rand -base64 32`)

### Step 5: Connect Database to Backend

1. In Railway, click on your **backend service**
2. Go to **"Settings"** tab
3. Scroll to **"Service Connections"**
4. Click **"Connect"** next to your PostgreSQL service
5. This will automatically add database connection variables

### Step 6: Deploy

1. Railway will automatically deploy when you:
   - Push code to GitHub (if connected)
   - Or click **"Deploy"** button
2. Wait for deployment to complete (2-3 minutes)
3. Once deployed, Railway will provide a public URL like: `https://your-app.up.railway.app`

### Step 7: Get Your Backend URL

1. Click on your backend service
2. Go to **"Settings"** tab
3. Under **"Domains"**, you'll see your public URL
4. **Copy this URL** - you'll need it for frontend deployment!

Example: `https://worker-calling-backend-production.up.railway.app`

---

## 🔄 Alternative: Deploy to Render

### Step 1: Create Account
- Go to https://render.com
- Sign up with GitHub

### Step 2: Create PostgreSQL Database
1. Click **"New +"** → **"PostgreSQL"**
2. Name it: `worker-calling-db`
3. Select free tier
4. Copy the **Internal Database URL**

### Step 3: Deploy Backend
1. Click **"New +"** → **"Web Service"**
2. Connect your GitHub repository
3. Configure:
   - **Name:** `worker-calling-backend`
   - **Environment:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Plan:** Free

### Step 4: Add Environment Variables
Add the same variables as Railway (see above)

### Step 5: Get Backend URL
After deployment, Render will provide: `https://worker-calling-backend.onrender.com`

---

## ✅ After Backend is Deployed

1. **Test your backend:**
   - Visit: `https://your-backend-url.railway.app/health`
   - Should return: `{"success": true, "message": "Server is running"}`

2. **Update Frontend Environment Variable:**
   - Go to Vercel dashboard
   - Your project → Settings → Environment Variables
   - Update `REACT_APP_API_URL` = `https://your-backend-url.railway.app`
   - Redeploy frontend

3. **Update Backend CORS:**
   - In Railway, add environment variable:
     - `FRONTEND_URL` = `https://your-frontend.vercel.app`
   - Redeploy backend

---

## 🐛 Troubleshooting

### Database Connection Issues
- Make sure PostgreSQL service is connected to backend service
- Check that database variables use correct reference syntax
- Verify database is running (green status in Railway)

### Build Failures
- Check that `package.json` has correct `engines` field
- Ensure all dependencies are in `package.json`
- Check Railway build logs for errors

### CORS Errors
- Make sure `FRONTEND_URL` is set correctly in backend
- Update CORS in `src/app.js` if needed
- Ensure frontend URL matches exactly (no trailing slash)

---

## 📝 Quick Checklist

- [ ] Railway account created
- [ ] PostgreSQL database created
- [ ] Backend code pushed to GitHub
- [ ] Backend service deployed on Railway
- [ ] Environment variables configured
- [ ] Database connected to backend
- [ ] Backend URL obtained
- [ ] Health check endpoint working
- [ ] Frontend `REACT_APP_API_URL` updated
- [ ] Backend `FRONTEND_URL` updated
- [ ] Both services tested and working

---

## 🎉 You're Done!

Once your backend is deployed and you have the URL, update your Vercel frontend deployment with:
- `REACT_APP_API_URL` = your backend URL

Then both your frontend and backend will be live! 🚀

