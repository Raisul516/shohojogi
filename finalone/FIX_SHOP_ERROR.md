# Fix for Shop System Error

## Problem
You're seeing "server error please try again later" because the **products table doesn't exist yet** in your database.

## Solution

The error has been fixed in the code - it will now gracefully return an empty array if the table doesn't exist (instead of showing an error).

However, to actually use the shop system, you need to create the database tables.

### Quick Fix Steps:

1. **Run the database migration** to create the products table:

   ```bash
   # Option 1: Using psql command line
   psql -U your_username -d your_database_name -f backend/database/migration_add_products.sql
   
   # Option 2: Using pgAdmin 4
   # 1. Open pgAdmin 4
   # 2. Connect to your database
   # 3. Right-click on your database → Query Tool
   # 4. Open and run: backend/database/migration_add_products.sql
   ```

2. **Restart your backend server** (if it's running):
   ```bash
   # Stop the server (Ctrl+C) and start again
   cd backend
   npm start
   ```

3. **Add some sample products** using SQL:
   ```sql
   INSERT INTO products (name_en, name_bn, category, price, stock_quantity, is_featured) VALUES
   ('Hammer', 'হাতুড়ি', 'tools', 500.00, 50, true),
   ('Screwdriver Set', 'স্ক্রু ড্রাইভার সেট', 'tools', 800.00, 30, true),
   ('Wire (10m)', 'তার (১০ মি)', 'electrical', 300.00, 100, true),
   ('LED Light Bulb', 'এলইডি বাল্ব', 'electrical', 150.00, 200, true),
   ('Ceiling Fan', 'সিলিং ফ্যান', 'electrical', 2500.00, 20, true),
   ('Switch', 'সুইচ', 'electrical', 50.00, 500, true),
   ('Socket', 'সকেট', 'electrical', 80.00, 400, true),
   ('Pipe Wrench', 'পাইপ রেঞ্চ', 'plumbing', 600.00, 40, true);
   ```

4. **Check your homepage** - the shop section should now appear with products!

## What Was Fixed

- Added error handling in `productController.js` to gracefully handle missing tables
- The frontend will now silently hide the shop section if no products exist (no error popup)
- Once you create the table and add products, everything will work automatically

## Verification

After running the migration, test the API:
```bash
curl http://localhost:5050/api/products
```

You should get a JSON response with `"success": true` and an empty or populated data array.

