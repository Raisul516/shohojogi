# Face Verification System Setup Guide

## Overview
This system implements a three-way face matching verification using face-api.js:
- **NID Photo** vs **Live Selfie** vs **Profile Picture**
- Uses Euclidean distance (< 0.6 threshold) for face matching
- Combines with existing OCR verification for dual-verification

## Installation Steps

### 1. Install Required NPM Packages

#### Frontend (worker-calling-frontend)
```bash
cd worker-calling-frontend
npm install @vladmandic/face-api react-webcam
```

#### Backend
No additional packages needed - face matching is done on frontend, results sent to backend.

### 2. Download face-api.js Models

Download the required models from: https://github.com/vladmandic/face-api/tree/master/model

Create the models directory:
```bash
cd worker-calling-frontend/public
mkdir models
```

Download these files to `public/models/`:
- `tiny_face_detector_model-weights_manifest.json`
- `tiny_face_detector_model-shard1`
- `face_landmark_68_model-weights_manifest.json`
- `face_landmark_68_model-shard1`
- `face_recognition_model-weights_manifest.json`
- `face_recognition_model-shard1`

**Quick Download Script (Linux/Mac):**
```bash
cd worker-calling-frontend/public/models
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/tiny_face_detector_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/tiny_face_detector_model-shard1
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_landmark_68_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_landmark_68_model-shard1
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_recognition_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_recognition_model-shard1
```

**Windows PowerShell:**
```powershell
cd worker-calling-frontend\public
mkdir models
cd models
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/vladmandic/face-api/master/model/tiny_face_detector_model-weights_manifest.json" -OutFile "tiny_face_detector_model-weights_manifest.json"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/vladmandic/face-api/master/model/tiny_face_detector_model-shard1" -OutFile "tiny_face_detector_model-shard1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_landmark_68_model-weights_manifest.json" -OutFile "face_landmark_68_model-weights_manifest.json"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_landmark_68_model-shard1" -OutFile "face_landmark_68_model-shard1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_recognition_model-weights_manifest.json" -OutFile "face_recognition_model-weights_manifest.json"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_recognition_model-shard1" -OutFile "face_recognition_model-shard1"
```

### 3. Run Database Migration

Run the face verification migration:
```bash
cd backend
node scripts/run-face-verification-migration.js
```

Or manually in pgAdmin:
```sql
-- Execute backend/database/migration_add_face_verification.sql
```

### 4. Update Modal Component (if needed)

If your Modal component doesn't support a `size` prop, update it or remove the `size="large"` prop from FaceVerification modal.

## Verification Flow

1. **Worker uploads NID photo** → OCR extraction begins
2. **Worker provides consent** → Face verification modal opens
3. **Worker captures live selfie** → Face detection and matching
4. **System matches faces:**
   - Selfie vs Profile Photo
   - Selfie vs NID Photo
5. **Backend processes:**
   - OCR results (name, NID number, age, etc.)
   - Face matching results
6. **Auto-approval only if:**
   - OCR confidence ≥ 85%
   - Name similarity ≥ 85%
   - Age ≥ 18
   - **ALL face matches pass** (distance < 0.6)
   - No tampering detected

## Configuration

### Face Matching Threshold
Default: **0.6** (Euclidean distance)
- Lower = stricter matching
- Higher = more lenient matching
- Adjust in `FaceVerification.jsx` and `faceMatchingService.js`

### Auto-Approval Criteria
Both OCR and Face Verification must pass:
- OCR: Confidence ≥ 85%, Name match ≥ 85%, Age ≥ 18
- Face: All matches (selfie-profile, selfie-NID) must pass

## Troubleshooting

### Models not loading
- Check that models are in `public/models/`
- Check browser console for 404 errors
- Verify model file names match exactly

### Camera not working
- Ensure HTTPS or localhost (required for getUserMedia)
- Check browser permissions for camera access
- Try different browser

### Face detection not working
- Ensure good lighting
- Face should be clearly visible
- Remove glasses/hat if possible
- Check browser console for errors

### Face matching always fails
- Verify profile photo exists
- Check image quality (should be clear)
- Adjust threshold if needed (in code)

## Files Created/Modified

### New Files:
- `worker-calling-frontend/src/components/verification/FaceVerification.jsx`
- `backend/src/services/faceMatchingService.js`
- `backend/database/migration_add_face_verification.sql`

### Modified Files:
- `worker-calling-frontend/src/components/verification/NIDVerification.jsx`
- `backend/src/controllers/nidVerificationController.js`
- `worker-calling-frontend/package.json` (add dependencies)

## Testing

1. Upload NID photo
2. Grant camera permission
3. Capture selfie with face clearly visible
4. Verify all three matches pass
5. Check backend logs for verification results
6. Verify database stores face verification data

## Security Notes

- Face descriptors are stored in database (128-dimensional arrays)
- Selfie images are temporarily stored, deleted after processing
- All verification data is encrypted where applicable
- Face matching happens client-side, results sent to server


