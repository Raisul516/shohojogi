#!/bin/bash

# Simple script to start both servers
# Run this script, then check the terminal output

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Starting Worker Calling System${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if backend .env exists
if [ ! -f "backend/.env" ]; then
    echo -e "${RED}❌ Error: backend/.env file not found!${NC}"
    echo -e "${YELLOW}   Please create it with your database credentials.${NC}"
    exit 1
fi

# Start backend
echo -e "${GREEN}Starting backend server on port 5050...${NC}"
echo -e "${YELLOW}(This will run in the foreground - open a NEW terminal for frontend)${NC}"
echo ""
cd backend

# Check for node_modules
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing backend dependencies first...${NC}"
    npm install
fi

# Start backend (this blocks, so user needs to open new terminal)
npm start

