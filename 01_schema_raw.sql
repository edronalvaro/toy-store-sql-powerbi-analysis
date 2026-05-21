-- =====================================================
-- TOY STORE DATABASE SCHEMA
-- This file documents the structure of the database
-- imported from raw dataset files.
-- =====================================================

-- TABLE: products
-- Purpose: Stores product-level information

/*
Columns:
- product_id (INT)
- product_name (text)
- product_category (text)
- product_cost (DECIMAL)
- product_price (DECIMAL)
*/

-- TABLE: stores
-- Purpose: Stores retail store information

/*
Columns:
- store_id (INT)
- store_name (text)
- store_city (text)
- store_location (text)
- store_open_date (DATE)
*/

-- TABLE: inventory
-- Purpose: Stores inventory levels for each product by store

/*
Columns:
- store_id (INT)
- product_id (INT)
- stock_on_hand (INT)
*/

-- TABLE: sales
-- Purpose: Transaction-level sales data

/*
Columns:
- sale_id (INT)
- date (DATE)
- store_id (INT)
- product_id (INT)
- units (INT)
*/
