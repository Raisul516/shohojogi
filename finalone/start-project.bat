@echo off
echo ========================================
echo   Worker Calling System - Startup
echo ========================================
echo.

echo [1/2] Starting Backend Server...
start "Backend Server" cmd /k "cd backend && npm start"
timeout /t 3 /nobreak >nul

echo [2/2] Starting Frontend Server...
start "Frontend Server" cmd /k "cd worker-calling-frontend && npm start"
timeout /t 2 /nobreak

echo.
echo ========================================
echo   Both servers are starting!
echo ========================================
echo.
echo Backend:  http://localhost:5050
echo Frontend: http://localhost:3000
echo.
echo Press any key to close this window...
pause >nul

