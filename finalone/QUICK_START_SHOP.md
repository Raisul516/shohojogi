# Quick Start: See Shop Section on Homepage

## Current Status
The shop section is now visible on your homepage! However, you'll see a "Products Coming Soon!" message because there are no products in the database yet.

## To Add Products and See Them

### Step 1: Create the Database Tables

Run this SQL file in your database:

```bash
# Using psql
psql -U your_username -d your_database_name -f backend/database/migration_add_products.sql

# Or use pgAdmin 4:
# 1. Open pgAdmin 4
# 2. Connect to your database
# 3. Right-click database → Query Tool
# 4. Open: backend/database/migration_add_products.sql
# 5. Click Execute (▶)
```

### Step 2: Add Sample Products

After creating the tables, add some products using SQL:

```sql
-- Copy and paste this in pgAdmin Query Tool or psql

INSERT INTO products (name_en, name_bn, category, price, stock_quantity, is_featured, description_en) VALUES
('Hammer', 'হাতুড়ি', 'tools', 500.00, 50, true, 'Heavy-duty hammer for construction work'),
('Screwdriver Set', 'স্ক্রু ড্রাইভার সেট', 'tools', 800.00, 30, true, 'Complete screwdriver set with multiple sizes'),
('Wire (10m)', 'তার (১০ মি)', 'electrical', 300.00, 100, true, '10 meter electrical wire'),
('LED Light Bulb', 'এলইডি বাল্ব', 'electrical', 150.00, 200, true, 'Energy efficient LED light bulb'),
('Ceiling Fan', 'সিলিং ফ্যান', 'electrical', 2500.00, 20, true, 'High quality ceiling fan'),
('Switch', 'সুইচ', 'electrical', 50.00, 500, true, 'Electrical switch'),
('Socket', 'সকেট', 'electrical', 80.00, 400, true, 'Electrical socket outlet'),
('Pipe Wrench', 'পাইপ রেঞ্চ', 'plumbing', 600.00, 40, true, 'Pipe wrench for plumbing work');
```

### Step 3: Refresh Your Homepage

After adding products, refresh your browser at http://localhost:3000

You should now see:
- ✅ Shop section with heading "🛒 Shop Household Items"
- ✅ Product cards showing the items you added
- ✅ "Add to Cart" buttons
- ✅ Prices and stock information

## Verification

Check if products exist:
```sql
SELECT COUNT(*) FROM products;
```

Should return 8 (if you added all sample products).

Test the API:
```bash
curl http://localhost:5050/api/products?featured=true&limit=8
```

Should return JSON with products array.

## Troubleshooting

**Still seeing "Products Coming Soon!"?**
- Check if products table exists: `SELECT * FROM products LIMIT 1;`
- Check if products are marked as featured: `SELECT * FROM products WHERE is_featured = true;`
- Check if products are available: `SELECT * FROM products WHERE is_available = true;`

**Getting errors?**
- Make sure backend server is running
- Check backend console for error messages
- Verify database connection in `.env` file

