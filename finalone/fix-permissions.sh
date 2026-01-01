#!/bin/bash

# Fix permissions for node_modules executables
# This fixes issues when node_modules were copied from Windows to Mac

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Fixing permissions for node_modules executables...${NC}\n"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Fix frontend permissions
echo -e "${YELLOW}Fixing frontend permissions...${NC}"
cd "$SCRIPT_DIR/worker-calling-frontend"
if [ -d "node_modules/.bin" ]; then
    chmod +x node_modules/.bin/* 2>/dev/null
    echo -e "${GREEN}✓ Frontend permissions fixed${NC}"
else
    echo -e "${YELLOW}⚠ Frontend node_modules/.bin not found${NC}"
fi

# Fix backend permissions
echo -e "${YELLOW}Fixing backend permissions...${NC}"
cd "$SCRIPT_DIR/backend"
if [ -d "node_modules/.bin" ]; then
    chmod +x node_modules/.bin/* 2>/dev/null
    echo -e "${GREEN}✓ Backend permissions fixed${NC}"
else
    echo -e "${YELLOW}⚠ Backend node_modules/.bin not found${NC}"
fi

echo -e "\n${GREEN}✅ Permissions fixed!${NC}"
echo -e "${YELLOW}You can now run: npm start${NC}\n"

