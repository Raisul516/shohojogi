# Face Verification System - Installation Instructions

## Quick Start

### 1. Install NPM Packages

```bash
cd worker-calling-frontend
npm install @vladmandic/face-api react-webcam
```

### 2. Download Face-API Models

**Option A: Using the download script (Recommended)**
```bash
cd worker-calling-frontend
node scripts/download-face-api-models.js
```

**Option B: Manual Download**
1. Create directory: `worker-calling-frontend/public/models/`
2. Download these 6 files from: https://github.com/vladmandic/face-api/tree/master/model
   - `tiny_face_detector_model-weights_manifest.json`
   - `tiny_face_detector_model-shard1`
   - `face_landmark_68_model-weights_manifest.json`
   - `face_landmark_68_model-shard1`
   - `face_recognition_model-weights_manifest.json`
   - `face_recognition_model-shard1`

### 3. Database Migration (Already Done ✅)

The migration has been run automatically. If you need to run it again:
```bash
cd backend
node scripts/run-face-verification-migration.js
```

### 4. Restart Your Servers

```bash
# Frontend
cd worker-calling-frontend
npm start

# Backend (in another terminal)
cd backend
npm start
```

## Verification Flow

1. Worker uploads NID photo
2. Worker provides consent
3. **NEW:** Face verification modal opens
4. Worker captures live selfie
5. System matches:
   - Selfie ↔ Profile Photo
   - Selfie ↔ NID Photo
6. Backend processes both OCR and face matching
7. Auto-approval only if **BOTH** pass

## Testing

1. Go to Worker Dashboard
2. Click "Upload NID Image"
3. Select NID photo
4. Provide consent
5. **NEW:** Capture live selfie when prompted
6. Verify all matches pass
7. Submit for verification

## Troubleshooting

### Models Not Loading
- Check browser console for 404 errors
- Verify files are in `public/models/`
- Clear browser cache and reload

### Camera Not Working
- Ensure you're on HTTPS or localhost
- Grant camera permissions
- Try a different browser

### Face Detection Issues
- Ensure good lighting
- Face should be clearly visible
- Remove glasses/hat if possible

## Files Modified/Created

### New Files:
- `worker-calling-frontend/src/components/verification/FaceVerification.jsx`
- `backend/src/services/faceMatchingService.js`
- `backend/database/migration_add_face_verification.sql`
- `backend/scripts/run-face-verification-migration.js`
- `worker-calling-frontend/scripts/download-face-api-models.js`

### Modified Files:
- `worker-calling-frontend/src/components/verification/NIDVerification.jsx`
- `backend/src/controllers/nidVerificationController.js`
- `worker-calling-frontend/package.json`

## Configuration

Face matching threshold: **0.6** (Euclidean distance)
- Lower = stricter
- Higher = more lenient
- Adjust in `FaceVerification.jsx` and `faceMatchingService.js`


