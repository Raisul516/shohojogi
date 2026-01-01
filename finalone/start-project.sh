#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Worker Calling System - Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js v18 or higher.${NC}"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Start backend server in new terminal window (macOS)
echo -e "${GREEN}[1/2] Starting Backend Server...${NC}"
osascript -e "tell application \"Terminal\" to do script \"cd '$SCRIPT_DIR/backend' && npm start\"" 2>/dev/null

# If osascript fails (Terminal.app not available), try opening in iTerm or run in background
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}   Note: Could not open new terminal window. Starting in background...${NC}"
    cd backend
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}   Installing backend dependencies...${NC}"
        npm install > /dev/null 2>&1
    fi
    npm start > /tmp/backend.log 2>&1 &
    BACKEND_PID=$!
    cd ..
else
    sleep 2
fi

# Wait a bit for backend to start
sleep 3

# Start frontend server in new terminal window (macOS)
echo -e "${GREEN}[2/2] Starting Frontend Server...${NC}"
osascript -e "tell application \"Terminal\" to do script \"cd '$SCRIPT_DIR/worker-calling-frontend' && npm start\"" 2>/dev/null

# If osascript fails, try opening in iTerm or run in background
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}   Note: Could not open new terminal window. Starting in background...${NC}"
    cd worker-calling-frontend
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}   Installing frontend dependencies...${NC}"
        npm install > /dev/null 2>&1
    fi
    npm start > /tmp/frontend.log 2>&1 &
    FRONTEND_PID=$!
    cd ..
else
    sleep 2
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Both servers are starting!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Backend:  http://localhost:5050${NC}"
echo -e "${GREEN}Frontend: http://localhost:3000${NC}"
echo ""
echo -e "${YELLOW}Note: Servers are running in separate terminal windows.${NC}"
echo -e "${YELLOW}Close those windows or press Ctrl+C in them to stop the servers.${NC}"
echo ""

