# Deployment Guide

## Prerequisites
- GitHub account
- Vercel account (free tier works)

## Step 1: Push to GitHub

### For Frontend (worker-calling-frontend):

1. **Create a new repository on GitHub:**
   - Go to https://github.com/new
   - Name it: `worker-calling-frontend` (or any name you prefer)
   - Make it public or private (your choice)
   - **Don't** initialize with README, .gitignore, or license
   - Click "Create repository"

2. **Push the frontend code:**
   ```bash
   cd "/Users/maishaahmed/Desktop/finalone 2/finalone/worker-calling-frontend"
   git remote add origin https://github.com/YOUR_USERNAME/worker-calling-frontend.git
   git push -u origin main
   ```
   (Replace `YOUR_USERNAME` with your GitHub username)

### For Backend (Optional - if you want to deploy backend separately):

The backend can be deployed to services like:
- Railway (https://railway.app)
- Render (https://render.com)
- Heroku
- DigitalOcean App Platform

## Step 2: Deploy to Vercel

### Method 1: Using Vercel CLI (Recommended)

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel:**
   ```bash
   vercel login
   ```

3. **Deploy from frontend directory:**
   ```bash
   cd "/Users/maishaahmed/Desktop/finalone 2/finalone/worker-calling-frontend"
   vercel
   ```

4. **Follow the prompts:**
   - Set up and deploy? **Yes**
   - Which scope? (select your account)
   - Link to existing project? **No**
   - Project name: `worker-calling-frontend` (or your preferred name)
   - Directory: `./` (current directory)
   - Override settings? **No**

5. **Set Environment Variables:**
   After deployment, go to your Vercel dashboard:
   - Navigate to your project → Settings → Environment Variables
   - Add: `REACT_APP_API_URL` = `https://your-backend-url.com` (your backend API URL)

### Method 2: Using Vercel Dashboard (GitHub Integration)

1. **Go to Vercel Dashboard:**
   - Visit https://vercel.com
   - Sign in with GitHub

2. **Import Project:**
   - Click "Add New Project"
   - Select your GitHub repository (`worker-calling-frontend`)
   - Click "Import"

3. **Configure Project:**
   - Framework Preset: **Create React App** (should auto-detect)
   - Root Directory: `./` (or leave default)
   - Build Command: `npm run build` (should be auto-filled)
   - Output Directory: `build` (should be auto-filled)
   - Install Command: `npm install` (should be auto-filled)

4. **Add Environment Variables:**
   - Under "Environment Variables", add:
     - Key: `REACT_APP_API_URL`
     - Value: Your backend API URL (e.g., `https://your-backend.railway.app` or `https://api.yourdomain.com`)
   - Select all environments (Production, Preview, Development)

5. **Deploy:**
   - Click "Deploy"
   - Wait for the build to complete
   - Your site will be live at `https://your-project.vercel.app`

## Step 3: Update Backend CORS (Important!)

Make sure your backend allows requests from your Vercel domain:

```javascript
// In backend/src/app.js, update CORS configuration:
const corsOptions = {
  origin: [
    'http://localhost:3000',
    'https://your-project.vercel.app',  // Add your Vercel URL here
  ],
  credentials: true,
};
```

## Notes:

- The frontend is now configured with `vercel.json` for optimal deployment
- All recent features (dark mode, worker slots, image fixes, scroll-to-top) are included
- Make sure your backend is deployed and accessible before deploying the frontend
- Update the `REACT_APP_API_URL` environment variable in Vercel to point to your deployed backend

