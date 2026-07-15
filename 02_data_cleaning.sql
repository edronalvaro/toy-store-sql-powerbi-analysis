-- =====================================================
-- TOY STORE DATA CLEANING & PREPARATION
-- Purpose:
-- Validate raw data, clean data types, and create an
-- analytics-ready master table for reporting.
-- =====================================================

CREATE DATABASE toy_store;
USE toy_store;

-- =====================================================
-- DATA VALIDATION
-- =====================================================

-- Check for missing Product Cost and Product Price
SELECT
    SUM(CASE WHEN Product_Cost IS NULL THEN 1 ELSE 0 END) AS missing_cost,
    SUM(CASE WHEN Product_Price IS NULL THEN 1 ELSE 0 END) AS missing_price
FROM products;

-- Check for missing Product or Store IDs in Sales
SELECT *
FROM sales
WHERE Product_ID IS NULL
   OR Store_ID IS NULL;

-- Check for duplicate sales records
SELECT
    Sale_ID,
    COUNT(*) AS duplicate_count
FROM sales
GROUP BY Sale_ID
HAVING COUNT(*) > 1;

-- Check for invalid pricing
SELECT *
FROM products
WHERE Product_Price < Product_Cost;

-- Check inventory for missing stock values
SELECT *
FROM inventory
WHERE Stock_On_Hand IS NULL;

-- Verify all Product IDs in Sales exist in Products
SELECT s.*
FROM sales s
LEFT JOIN products p
    ON s.Product_ID = p.Product_ID
WHERE p.Product_ID IS NULL;

-- =====================================================
-- DATA CLEANING
-- =====================================================

SET SQL_SAFE_UPDATES = 0;

-- Remove currency symbols
UPDATE products
SET
    Product_Cost = REPLACE(Product_Cost, '$', ''),
    Product_Price = REPLACE(Product_Price, '$', '');

-- Convert prices to numeric data types
ALTER TABLE products
MODIFY Product_Cost DECIMAL(10,2),
MODIFY Product_Price DECIMAL(10,2);

-- Convert Sales Date to DATE
ALTER TABLE sales
MODIFY Date DATE;

SET SQL_SAFE_UPDATES = 1;

-- =====================================================
-- CREATE ANALYTICS TABLE
-- =====================================================

DROP TABLE IF EXISTS master_sales;

CREATE TABLE master_sales AS
SELECT
    c.calendar_date AS sale_date,
    YEAR(c.calendar_date) AS sale_year,
    MONTH(c.calendar_date) AS sale_month,
    QUARTER(c.calendar_date) AS sale_quarter,
    DAYOFWEEK(c.calendar_date) AS sale_day_of_week,

    s.Store_ID,
    st.Store_Name,
    st.Store_City,
    st.Store_Location,

    s.Product_ID,
    p.Product_Name,
    p.Product_Category,

    p.Product_Cost,
    p.Product_Price,

    COALESCE(s.Units,0) AS Units,

    COALESCE(s.Units * p.Product_Price,0) AS Revenue,

    COALESCE(s.Units * p.Product_Cost,0) AS Cost,

    COALESCE(
        (s.Units * p.Product_Price) -
        (s.Units * p.Product_Cost),
        0
    ) AS Profit,

    CASE
        WHEN s.Units IS NULL
             OR s.Units = 0
        THEN 0
        ELSE ROUND(
            (
                (s.Units * p.Product_Price) -
                (s.Units * p.Product_Cost)
            )
            /
            (s.Units * p.Product_Price)
            * 100,
            2
        )
    END AS Profit_Margin_Percent

FROM calendar c
LEFT JOIN sales s
    ON c.calendar_date = s.Date
LEFT JOIN products p
    ON s.Product_ID = p.Product_ID
LEFT JOIN stores st
    ON s.Store_ID = st.Store_ID;

-- =====================================================
-- VALIDATE ANALYTICS TABLE
-- =====================================================

SELECT COUNT(*) AS total_records
FROM master_sales;

SELECT *
FROM master_sales
LIMIT 10;
