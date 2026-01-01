# Fix: "relation products does not exist" Error

## Problem
You're seeing errors like:
- "relation 'products' does not exist"
- "server error, please try again later"
- "network error"

This happens because the **products table hasn't been created** in your database yet.

## Solution: Create the Products Table

You have **3 options** to fix this:

---

### Option 1: Use the Setup Script (Easiest) ⭐

I've created a script that will automatically run the migration for you:

```bash
cd /Users/maishaahmed/Desktop/finalone
./setup-products-db.sh
```

This script will:
- Read your database credentials from `backend/.env`
- Run the migration SQL file
- Create all necessary tables (products, cart_items, orders, order_items)

**If the script doesn't work**, use Option 2 or 3 below.

---

### Option 2: Using pgAdmin 4 (Recommended for beginners)

1. **Open pgAdmin 4**
2. **Connect to your database**
   - Find your database in the left sidebar
   - Right-click on it → **Query Tool**
3. **Open the migration file**
   - Click **Open File** (folder icon) or press `Ctrl+O` / `Cmd+O`
   - Navigate to: `backend/database/migration_add_products.sql`
   - Click **Open**
4. **Run the SQL**
   - Click the **Execute** button (▶) or press `F5`
   - Wait for "Query returned successfully"
5. **Done!** ✅

---

### Option 3: Using psql Command Line

1. **Open Terminal**

2. **Navigate to project directory**:
   ```bash
   cd /Users/maishaahmed/Desktop/finalone
   ```

3. **Read your database credentials** from `backend/.env`:
   - Open `backend/.env` file
   - Find: `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`

4. **Run the migration**:
   ```bash
   psql -h YOUR_DB_HOST -p YOUR_DB_PORT -U YOUR_DB_USER -d YOUR_DB_NAME -f backend/database/migration_add_products.sql
   ```
   
   Replace the placeholders with your actual values, for example:
   ```bash
   psql -h localhost -p 5432 -U postgres -d workercalling -f backend/database/migration_add_products.sql
   ```

5. **Enter your database password** when prompted

6. **Done!** ✅

---

## After Creating the Tables

### Step 1: Restart Backend Server

```bash
# Stop the server (Ctrl+C) and restart
cd backend
npm start
```

### Step 2: Verify Tables Created

You can check if tables were created by running this in pgAdmin Query Tool:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('products', 'cart_items', 'orders', 'order_items');
```

Should return 4 rows (one for each table).

### Step 3: Test Adding Products

1. Go to http://localhost:3000
2. Login as admin
3. Go to Admin Dashboard
4. Click **"Products"** tab
5. Click **"+ Add New Product"**
6. Fill in the form and add a product

---

## What Tables Will Be Created?

The migration creates 4 tables:

1. **`products`** - Stores all shop products
2. **`cart_items`** - Shopping cart for users
3. **`orders`** - Order history
4. **`order_items`** - Individual items in orders

---

## Troubleshooting

### "Permission denied" when running script?
```bash
chmod +x setup-products-db.sh
./setup-products-db.sh
```

### "psql: command not found"?
- Install PostgreSQL or use pgAdmin 4 (Option 2)
- Or add PostgreSQL to your PATH

### "database does not exist"?
- Create the database first:
  ```sql
  CREATE DATABASE your_database_name;
  ```

### "password authentication failed"?
- Check your `DB_USER` and `DB_PASSWORD` in `backend/.env`
- Make sure the user has permissions to create tables

### Still getting errors after creating tables?
1. Make sure backend server is restarted
2. Check backend console for error messages
3. Verify database connection in `.env` file
4. Try accessing: `http://localhost:5050/api/products` (should return empty array, not error)

---

## Quick Verification

After running the migration, test the API:

```bash
curl http://localhost:5050/api/products
```

Should return:
```json
{
  "success": true,
  "data": [],
  "total": 0,
  ...
}
```

If you still get an error, the tables weren't created successfully.

