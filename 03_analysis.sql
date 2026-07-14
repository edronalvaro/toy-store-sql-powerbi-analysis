CREATE DATABASE toy_store;
USE toy_store;

UPDATE products
SET 
    Product_Cost = REPLACE(Product_Cost, '$', ''),
    Product_Price = REPLACE(Product_Price, '$', '');

ALTER TABLE products
MODIFY Product_Cost DECIMAL(10,2),
MODIFY Product_Price DECIMAL(10,2);

-- Check duplicates in sales
SELECT Sale_ID, COUNT(*)
FROM sales
GROUP BY Sale_ID
HAVING COUNT(*) > 1;

-- Check invalid product references
SELECT s.*
FROM sales s
LEFT JOIN products p
ON s.Product_ID = p.Product_ID
WHERE p.Product_ID IS NULL;

CREATE TABLE master_sales AS
SELECT
    c.calendar_date AS sale_date,
    s.Store_ID,
    s.Product_ID,
    s.Units,
    
    COALESCE(s.Units * CAST(REPLACE(p.Product_Price, '$', '') AS DECIMAL(10,2)), 0) AS Revenue,
    COALESCE(s.Units * CAST(REPLACE(p.Product_Cost, '$', '') AS DECIMAL(10,2)), 0) AS Cost,
    
    COALESCE(
        (s.Units * CAST(REPLACE(p.Product_Price, '$', '') AS DECIMAL(10,2))) -
        (s.Units * CAST(REPLACE(p.Product_Cost, '$', '') AS DECIMAL(10,2))),
        0
    ) AS Profit
FROM sales s
LEFT JOIN products p ON s.Product_ID = p.Product_ID
LEFT JOIN calendar c ON s.Date = c.calendar_date;

