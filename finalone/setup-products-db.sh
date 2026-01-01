#!/bin/bash

# Script to create products tables in PostgreSQL database
# Usage: ./setup-products-db.sh

echo "========================================="
echo "  Products Database Setup Script"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f "backend/.env" ]; then
    echo -e "${RED}Error: backend/.env file not found!${NC}"
    echo "Please make sure you're in the project root directory."
    exit 1
fi

# Read database credentials from .env file
echo -e "${YELLOW}Reading database credentials from backend/.env...${NC}"

# Extract database credentials (this is a simple extraction, may need adjustment)
DB_HOST=$(grep DB_HOST backend/.env | cut -d '=' -f2 | tr -d ' ' | tr -d '"')
DB_PORT=$(grep DB_PORT backend/.env | cut -d '=' -f2 | tr -d ' ' | tr -d '"')
DB_NAME=$(grep DB_NAME backend/.env | cut -d '=' -f2 | tr -d ' ' | tr -d '"')
DB_USER=$(grep DB_USER backend/.env | cut -d '=' -f2 | tr -d ' ' | tr -d '"')
DB_PASSWORD=$(grep DB_PASSWORD backend/.env | cut -d '=' -f2 | tr -d ' ' | tr -d '"')

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
    echo -e "${RED}Error: Could not read DB_NAME or DB_USER from backend/.env${NC}"
    echo "Please check your .env file has DB_NAME and DB_USER set."
    exit 1
fi

echo -e "${GREEN}Database: ${DB_NAME}${NC}"
echo -e "${GREEN}User: ${DB_USER}${NC}"
echo ""

# Check if migration file exists
MIGRATION_FILE="backend/database/migration_add_products.sql"
if [ ! -f "$MIGRATION_FILE" ]; then
    echo -e "${RED}Error: Migration file not found at $MIGRATION_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}Running migration: $MIGRATION_FILE${NC}"
echo ""

# Set password as environment variable for psql
export PGPASSWORD="$DB_PASSWORD"

# Run the migration
if psql -h "$DB_HOST" -p "${DB_PORT:-5432}" -U "$DB_USER" -d "$DB_NAME" -f "$MIGRATION_FILE" 2>&1; then
    echo ""
    echo -e "${GREEN}✅ Success! Products tables created successfully.${NC}"
    echo ""
    echo "You can now:"
    echo "1. Restart your backend server"
    echo "2. Go to Admin Dashboard → Products tab"
    echo "3. Add products!"
else
    echo ""
    echo -e "${RED}❌ Error running migration.${NC}"
    echo ""
    echo "Common issues:"
    echo "- Make sure PostgreSQL is running"
    echo "- Check your database credentials in backend/.env"
    echo "- Make sure the database exists"
    echo ""
    echo "You can also run the migration manually:"
    echo "  psql -U $DB_USER -d $DB_NAME -f $MIGRATION_FILE"
    exit 1
fi

# Unset password
unset PGPASSWORD

