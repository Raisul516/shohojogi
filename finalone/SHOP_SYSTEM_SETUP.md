# Shop System Setup Guide

## Overview
A complete shop system has been added to your website, allowing users to browse and purchase household items like hammers, screws, wires, lights, fans, switches, sockets, and more.

## Database Setup

### Step 1: Run Database Migration

Execute the SQL migration file to create the necessary tables:

```bash
# Option 1: Using psql
psql -U your_username -d your_database_name -f backend/database/migration_add_products.sql

# Option 2: Using pgAdmin 4
# Open pgAdmin 4, connect to your database, and run the SQL file: backend/database/migration_add_products.sql
```

This will create:
- `products` table - Stores all shop products
- `cart_items` table - Shopping cart for users
- `orders` table - Order history (for future use)
- `order_items` table - Individual items in orders

### Step 2: Verify Tables Created

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('products', 'cart_items', 'orders', 'order_items');
```

## Adding Products (Admin)

### Option 1: Using SQL (Quick Start)

```sql
-- Example products to get you started
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

### Option 2: Using API (Recommended)

Once the admin panel is extended, you can add products through the UI. For now, you can use API calls:

```bash
# Add a product (requires admin authentication)
curl -X POST http://localhost:5050/api/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{
    "name_en": "Hammer",
    "name_bn": "হাতুড়ি",
    "category": "tools",
    "price": 500.00,
    "stock_quantity": 50,
    "is_featured": true,
    "description_en": "Heavy-duty hammer for construction work",
    "description_bn": "নির্মাণ কাজের জন্য ভারী হাতুড়ি"
  }'
```

## Frontend Features

### Homepage Shop Section

- Located under the "Popular Services" section
- Displays 8 featured products in a grid layout
- Shows product images, names, prices, stock status
- "Add to Cart" functionality
- "View All Products" link

### Product Display

Each product card shows:
- Product image (with placeholder if none)
- Product name
- Price (with discount if applicable)
- Stock availability
- Rating (if available)
- Add to Cart button

## API Endpoints

### Products

- `GET /api/products` - Get all products (public)
  - Query params: `category`, `search`, `featured`, `min_price`, `max_price`, `limit`, `offset`, `language`
- `GET /api/products/:id` - Get single product (public)
- `GET /api/products/categories` - Get product categories (public)
- `POST /api/products` - Create product (admin only)
- `PUT /api/products/:id` - Update product (admin only)
- `DELETE /api/products/:id` - Delete product (admin only)

### Shopping Cart

- `GET /api/cart` - Get user's cart (authenticated)
- `POST /api/cart` - Add item to cart (authenticated)
  - Body: `{ product_id, quantity }`
- `PUT /api/cart/:id` - Update cart item quantity (authenticated)
- `DELETE /api/cart/:id` - Remove item from cart (authenticated)
- `DELETE /api/cart` - Clear entire cart (authenticated)

## Product Categories

Current categories:
- `tools` - Hammers, screwdrivers, wrenches, etc.
- `electrical` - Wires, lights, fans, switches, sockets, etc.
- `plumbing` - Pipe wrenches, pipes, fittings, etc.
- `hardware` - Screws, nails, bolts, etc.

You can add more categories by simply using a new category name when creating products.

## Next Steps (Optional Enhancements)

1. **Full Shop Page** - Create `/shop` route with filters, search, pagination
2. **Product Detail Page** - Individual product pages with full details
3. **Cart Page** - Full shopping cart management page
4. **Checkout Flow** - Complete order placement and payment integration
5. **Admin Product Management** - Add products section to admin dashboard
6. **Product Reviews** - Allow users to review products
7. **Order Management** - View and track orders

## Testing

1. **Start Backend Server**:
   ```bash
   cd backend
   npm start
   ```

2. **Start Frontend Server**:
   ```bash
   cd worker-calling-frontend
   npm start
   ```

3. **Visit Homepage**: http://localhost:3000
   - Scroll down to see the shop section under "Popular Services"

4. **Add Products**: Use SQL or API to add some products

5. **Test Shopping Cart**: Login and try adding products to cart

## Troubleshooting

### Products not showing on homepage?
- Check if products are marked as `is_featured = true`
- Check if products have `is_available = true`
- Check browser console for API errors

### Database errors?
- Make sure you've run the migration SQL file
- Verify database connection in `.env` file
- Check that UUID extension is enabled: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`

### Cart not working?
- Make sure user is logged in
- Check authentication token is valid
- Verify cart_items table was created

