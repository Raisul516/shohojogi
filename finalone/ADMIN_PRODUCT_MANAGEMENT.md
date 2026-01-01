# Admin Product Management - Complete Setup

## ✅ What's Been Added

A complete product management system has been added to the admin panel, allowing admins to add, edit, delete, and manage products directly from the UI.

## Features

### Admin Panel - Products Tab
- New "Products" tab in the admin dashboard
- Located between "Categories" and "Reports" tabs
- Full CRUD operations for products

### Product Management Features
- **View All Products**: Table view showing all products with images, prices, stock
- **Add New Product**: Modal form to add products with all fields
- **Edit Product**: Modal form to edit existing products
- **Delete Product**: Delete products (soft delete if orders exist)
- **Feature/Unfeature**: Toggle featured status (shows on homepage)
- **Activate/Deactivate**: Toggle product availability

### Product Fields
Each product can have:
- **Name (English)**: Required
- **Name (Bangla)**: Optional
- **Category**: Required (tools, electrical, plumbing, hardware, other)
- **Price**: Required (in BDT)
- **Discount Price**: Optional (for sale items)
- **Stock Quantity**: Number of items in stock
- **Image URL**: Product image
- **Description (English)**: Optional
- **Description (Bangla)**: Optional
- **Featured**: Checkbox (shows on homepage)
- **Available**: Checkbox (active/inactive status)

## How to Use

### Step 1: Run Database Migration (First Time Only)

If you haven't created the products table yet:

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

### Step 2: Restart Backend Server

```bash
cd backend
npm start
```

### Step 3: Access Admin Panel

1. Login as admin at http://localhost:3000
2. Go to Admin Dashboard
3. Click on the **"Products"** tab

### Step 4: Add a Product

1. Click **"+ Add New Product"** button
2. Fill in the form:
   - **Name (English)**: e.g., "Hammer" (required)
   - **Name (Bangla)**: e.g., "হাতুড়ি" (optional)
   - **Category**: Select from dropdown (required)
   - **Price**: e.g., 500.00 (required)
   - **Discount Price**: e.g., 450.00 (optional, for sales)
   - **Stock Quantity**: e.g., 50 (optional, defaults to 0)
   - **Image URL**: URL to product image (optional)
   - **Description**: Product description (optional)
   - **Featured**: Check this to show on homepage
   - **Available**: Check this to make product active
3. Click **"Add Product"**

### Editing a Product

1. Find the product in the table
2. Click **"Edit"** button
3. Modify the fields
4. Click **"Update Product"**

### Managing Products

- **Feature/Unfeature**: Click "Feature" or "Unfeature" to control homepage visibility
- **Activate/Deactivate**: Click "Activate" or "Deactivate" to control availability
- **Delete**: Click "Delete" to remove product (soft delete if orders exist)

## Product Categories

Available categories:
- **tools** - Hammers, screwdrivers, wrenches, etc.
- **electrical** - Wires, lights, fans, switches, sockets, etc.
- **plumbing** - Pipe wrenches, pipes, fittings, etc.
- **hardware** - Screws, nails, bolts, etc.
- **other** - Miscellaneous items

## Technical Implementation

### Backend

1. **New Admin Endpoint**: `GET /api/admin/products`
   - Returns all products (including inactive ones)
   - Admin-only access

2. **Existing Endpoints Used**:
   - `POST /api/products` - Create product (admin only)
   - `PUT /api/products/:id` - Update product (admin only)
   - `DELETE /api/products/:id` - Delete product (admin only)

### Frontend

1. **New Component**: `ProductManagement.jsx`
   - Located in `worker-calling-frontend/src/components/admin/ProductManagement.jsx`
   - Handles all product management UI

2. **Admin Dashboard Updates**:
   - Added "Products" tab
   - Integrated ProductManagement component

## Notes

- Products require Name (English), Category, and Price (required fields)
- Other fields are optional
- Featured products appear on the homepage
- Only active products are visible to regular users
- Products with orders cannot be permanently deleted (soft delete)
- Products automatically appear on homepage if marked as featured and active

## Troubleshooting

### "Failed to load products" error?
- Make sure you've run the database migration
- Check if products table exists: `SELECT * FROM products LIMIT 1;`
- Verify backend server is running
- Check browser console for errors

### Products not showing on homepage?
- Make sure products are marked as `is_featured = true`
- Make sure products are marked as `is_available = true`
- Check browser console for API errors

### Can't add products?
- Make sure you're logged in as admin
- Check backend console for errors
- Verify database connection
- Check required fields are filled (Name EN, Category, Price)

