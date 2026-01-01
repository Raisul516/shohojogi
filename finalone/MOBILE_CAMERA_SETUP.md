# Mobile & Desktop Camera Setup - Face Verification

## ✅ Dependencies Installed

The following packages have been installed:
- `@vladmandic/face-api` - Face recognition library
- `react-webcam` - Webcam access for React

## 📱 Mobile & Desktop Compatibility

The FaceVerification component is now configured to work with:
- **Mobile devices**: Front-facing camera (selfie camera)
- **Laptops/Desktops**: Webcam
- **Tablets**: Front-facing camera

### Features for Mobile:
- Responsive design (works on small screens)
- Touch-friendly buttons
- Optimized video constraints for mobile
- Proper aspect ratio handling
- Camera permission handling

## 📥 Download Face-API Models

### Option 1: Manual Download (Recommended)

1. Go to: https://github.com/vladmandic/face-api/tree/master/model
2. Download these 6 files to `worker-calling-frontend/public/models/`:
   - `tiny_face_detector_model-weights_manifest.json`
   - `tiny_face_detector_model-shard1`
   - `face_landmark_68_model-weights_manifest.json`
   - `face_landmark_68_model-shard1`
   - `face_recognition_model-weights_manifest.json`
   - `face_recognition_model-shard1`

### Option 2: PowerShell Script

Run this in PowerShell from the project root:

```powershell
$modelsDir = "worker-calling-frontend\public\models"
New-Item -ItemType Directory -Path $modelsDir -Force

$baseUrl = "https://raw.githubusercontent.com/vladmandic/face-api/master/model"
$models = @(
    "tiny_face_detector_model-weights_manifest.json",
    "tiny_face_detector_model-shard1",
    "face_landmark_68_model-weights_manifest.json",
    "face_landmark_68_model-shard1",
    "face_recognition_model-weights_manifest.json",
    "face_recognition_model-shard1"
)

foreach ($model in $models) {
    $url = "$baseUrl/$model"
    $filepath = "$modelsDir\$model"
    Write-Host "Downloading $model..."
    Invoke-WebRequest -Uri $url -OutFile $filepath
    Write-Host "✅ Downloaded $model"
}

Write-Host "`n✅ All models downloaded to: $modelsDir"
```

### Option 3: Using Git (if you have git installed)

```bash
cd worker-calling-frontend/public
mkdir models
cd models
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/tiny_face_detector_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/tiny_face_detector_model-shard1
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_landmark_68_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_landmark_68_model-shard1
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_recognition_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/vladmandic/face-api/master/model/face_recognition_model-shard1
```

## 🔧 Mobile-Specific Features

### Camera Access
- Automatically detects mobile vs desktop
- Uses front camera on mobile (`facingMode: 'user'`)
- Uses webcam on laptop/desktop
- Handles camera permission requests

### Responsive Design
- Buttons stack vertically on mobile
- Video container adapts to screen size
- Touch-friendly interface
- Optimized for portrait and landscape

### Error Handling
- Clear error messages for camera access issues
- Permission denial handling
- Camera not found handling
- Mobile-specific error messages

## 🧪 Testing

### Test on Mobile:
1. Open the app on your mobile device
2. Navigate to Worker Dashboard
3. Click "Upload NID Image"
4. Grant camera permission when prompted
5. Verify front camera opens
6. Capture selfie
7. Verify face detection works

### Test on Desktop:
1. Open the app on your laptop
2. Navigate to Worker Dashboard
3. Click "Upload NID Image"
4. Grant camera permission when prompted
5. Verify webcam opens
6. Capture selfie
7. Verify face detection works

## 📋 Verification Checklist

- [x] Dependencies installed (`@vladmandic/face-api`, `react-webcam`)
- [ ] Face-api models downloaded to `public/models/`
- [x] Mobile camera support added
- [x] Desktop webcam support added
- [x] Responsive design implemented
- [x] Error handling for camera access
- [x] Database migration completed

## 🚀 Next Steps

1. **Download the models** (choose one option above)
2. **Restart your frontend server**: `npm start`
3. **Test on both mobile and desktop**
4. **Verify face detection works**

## ⚠️ Important Notes

- **HTTPS Required**: Camera access requires HTTPS in production (localhost works for development)
- **Permissions**: Users must grant camera permissions
- **Mobile Browsers**: Some mobile browsers may have restrictions
- **Performance**: First load may be slower as models download (~2-3MB total)

## 🐛 Troubleshooting

### Camera not working on mobile:
- Check browser permissions
- Try a different browser (Chrome recommended)
- Ensure you're on HTTPS or localhost
- Check if another app is using the camera

### Models not loading:
- Verify files are in `public/models/`
- Check browser console for 404 errors
- Clear browser cache
- Verify file names match exactly

### Face detection not working:
- Ensure good lighting
- Face should be clearly visible
- Remove glasses/hat if possible
- Check browser console for errors


