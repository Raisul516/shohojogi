#!/bin/bash

# Database Setup Script for Mac
# This script helps you set up the PostgreSQL database

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🗄️  Database Setup for Worker Calling System${NC}\n"

# Check if PostgreSQL is running
if ! pg_isready &> /dev/null; then
    echo -e "${YELLOW}⚠️  PostgreSQL doesn't appear to be running.${NC}"
    echo -e "${YELLOW}   Starting PostgreSQL...${NC}\n"
    
    # Try to start PostgreSQL using Homebrew
    if command -v brew &> /dev/null; then
        brew services start postgresql
        sleep 2
    else
        echo -e "${RED}❌ Could not start PostgreSQL automatically.${NC}"
        echo -e "${YELLOW}   Please start PostgreSQL manually and run this script again.${NC}"
        echo -e "${YELLOW}   Try: brew services start postgresql${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ PostgreSQL is running${NC}\n"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if database exists
DB_EXISTS=$(psql -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw workercalling && echo "yes" || echo "no")

if [ "$DB_EXISTS" = "no" ]; then
    echo -e "${YELLOW}Creating database 'workercalling'...${NC}"
    
    # Try to create database (will prompt for password if needed)
    createdb workercalling 2>/dev/null || psql postgres -c "CREATE DATABASE workercalling;" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Database 'workercalling' created${NC}\n"
    else
        echo -e "${RED}❌ Could not create database automatically.${NC}"
        echo -e "${YELLOW}   Please create it manually:${NC}"
        echo -e "${YELLOW}   psql postgres${NC}"
        echo -e "${YELLOW}   CREATE DATABASE workercalling;${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Database 'workercalling' already exists${NC}\n"
fi

# Check if tables exist
TABLES_EXIST=$(psql -d workercalling -c "\dt" 2>/dev/null | grep -q "users" && echo "yes" || echo "no")

if [ "$TABLES_EXIST" = "no" ]; then
    echo -e "${YELLOW}Initializing database schema...${NC}"
    
    if [ -f "$SCRIPT_DIR/backend/database/init.sql" ]; then
        psql -d workercalling -f "$SCRIPT_DIR/backend/database/init.sql" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Database schema initialized${NC}\n"
        else
            echo -e "${RED}❌ Could not initialize schema automatically.${NC}"
            echo -e "${YELLOW}   Please run manually:${NC}"
            echo -e "${YELLOW}   psql -d workercalling -f backend/database/init.sql${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ init.sql file not found at: $SCRIPT_DIR/backend/database/init.sql${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Database tables already exist${NC}\n"
fi

# Optional: Seed data
echo -e "${YELLOW}Would you like to seed sample data? (y/n)${NC}"
read -r SEED_RESPONSE

if [ "$SEED_RESPONSE" = "y" ] || [ "$SEED_RESPONSE" = "Y" ]; then
    if [ -f "$SCRIPT_DIR/backend/database/seed.sql" ]; then
        echo -e "${YELLOW}Seeding sample data...${NC}"
        psql -d workercalling -f "$SCRIPT_DIR/backend/database/seed.sql" 2>/dev/null
        echo -e "${GREEN}✓ Sample data seeded${NC}\n"
    fi
fi

echo -e "${GREEN}✅ Database setup complete!${NC}\n"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Make sure your backend/.env file has correct database credentials"
echo -e "2. Create admin user: cd backend && node createAdmin.js"
echo -e "3. Start the project: ./start-project.sh"

