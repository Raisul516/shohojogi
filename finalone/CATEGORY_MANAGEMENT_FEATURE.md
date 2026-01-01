# Category Management Feature

## Overview
Admins can now add, edit, delete, and manage service categories directly from the admin panel.

## Features Added

### 1. Admin Panel - Categories Tab
- New "Categories" tab added to the admin dashboard
- Located between "Users" and "Reports" tabs
- Full CRUD (Create, Read, Update, Delete) operations for categories

### 2. Category Management Interface
- **View All Categories**: Table view showing all categories (active and inactive)
- **Add New Category**: Modal form to add new categories
- **Edit Category**: Modal form to edit existing categories
- **Delete Category**: Delete categories (with protection if workers are using it)
- **Activate/Deactivate**: Toggle category active status

### 3. Category Fields
Each category can have:
- **Name (English)**: Required
- **Name (Bangla)**: Required
- **Description (English)**: Optional
- **Description (Bangla)**: Optional
- **Icon URL**: Optional

## How to Use

### Adding a New Category (e.g., "Driver")

1. Log in as admin
2. Go to Admin Dashboard
3. Click on the "Categories" tab
4. Click "+ Add New Category" button
5. Fill in the form:
   - Name (English): `Driver`
   - Name (Bangla): `ড্রাইভার` (or any Bangla name)
   - Description (English): Optional description
   - Description (Bangla): Optional description
   - Icon URL: Optional (leave empty if not needed)
6. Click "Add Category"

### Editing a Category

1. Go to Categories tab
2. Find the category in the table
3. Click "Edit" button
4. Modify the fields
5. Click "Update Category"

### Activating/Deactivating

1. Go to Categories tab
2. Find the category
3. Click "Activate" or "Deactivate" button
4. Only active categories will show on the homepage and search pages

### Deleting a Category

1. Go to Categories tab
2. Find the category
3. Click "Delete" button
4. Confirm deletion
5. **Note**: Categories with active workers cannot be deleted (you'll see an error message)

## Technical Implementation

### Backend Changes

1. **New Admin Endpoint**: `GET /api/admin/categories`
   - Returns all categories (including inactive ones)
   - Admin-only access

2. **Existing Endpoints Used**:
   - `POST /api/categories` - Create category (admin only)
   - `PUT /api/categories/:id` - Update category (admin only)
   - `DELETE /api/categories/:id` - Delete category (admin only)

3. **Public Endpoint** (unchanged):
   - `GET /api/categories` - Returns only active categories (used by homepage/search)

### Frontend Changes

1. **New Component**: `CategoryManagement.jsx`
   - Located in `worker-calling-frontend/src/components/admin/CategoryManagement.jsx`
   - Handles all category management UI

2. **Admin Dashboard Updates**:
   - Added "Categories" tab
   - Integrated CategoryManagement component

### Category Display

Categories automatically appear on:
- **Homepage**: "Popular Services" section (shows first 10 active categories)
- **Search/Workers Page**: Category filter dropdown
- **Anywhere** that fetches from `/api/categories` endpoint

Only **active** categories are shown to users. Inactive categories are only visible in the admin panel.

## Notes

- Categories require both English and Bangla names (required fields)
- Descriptions and icon URLs are optional
- Deactivated categories won't appear on public pages but remain in the database
- Categories with workers assigned cannot be deleted (for data integrity)
- New categories are set to "active" by default when created

