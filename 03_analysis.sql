/* =====================================================
   TOY STORE SALES ANALYSIS
   Business Question:
   How is the toy store performing across products,
   stores, and time—and where can management increase
   revenue, optimize inventory, and reduce operational risk?
===================================================== */


/* =====================================================
   EXECUTIVE KPIs
===================================================== */

-- Overall Business Performance
SELECT
    SUM(revenue) AS total_revenue,
    SUM(cost) AS total_cost,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(revenue) * 100, 2) AS profit_margin,
    COUNT(DISTINCT store_id) AS total_stores,
    COUNT(DISTINCT product_id) AS total_products
FROM master_sales;


/* =====================================================
   PRODUCT PERFORMANCE
===================================================== */

-- Product Category Performance
SELECT
    product_category,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(revenue) * 100, 2) AS profit_margin
FROM master_sales
GROUP BY product_category
ORDER BY total_profit DESC;


-- Top 5 Products by Profit
SELECT
    product_name,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(revenue) * 100, 2) AS profit_margin
FROM master_sales
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 5;


-- Bottom 5 Products by Profit
SELECT
    product_name,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(revenue) * 100, 2) AS profit_margin
FROM master_sales
GROUP BY product_name
ORDER BY total_profit
LIMIT 5;


-- Top 5 Products by Profit Margin
SELECT
    product_name,
    ROUND(SUM(profit) / SUM(revenue) * 100, 2) AS profit_margin
FROM master_sales
GROUP BY product_name
ORDER BY profit_margin DESC
LIMIT 5;


-- Monthly Revenue Trend
WITH monthly_revenue AS (

    SELECT
        DATE_FORMAT(sale_date,'%Y-%m') AS month,
        SUM(revenue) AS total_revenue
    FROM master_sales
    GROUP BY month

)

SELECT
    month,
    total_revenue,
    LAG(total_revenue) OVER(ORDER BY month) AS previous_month,
    ROUND(
        (
            total_revenue -
            LAG(total_revenue) OVER(ORDER BY month)
        ) /
        LAG(total_revenue) OVER(ORDER BY month) *100,
        2
    ) AS mom_growth_pct
FROM monthly_revenue;


-- Product Revenue Ranking Within Category
WITH product_sales AS (

    SELECT
        product_name,
        product_category,
        SUM(revenue) AS total_revenue
    FROM master_sales
    GROUP BY product_name, product_category

)

SELECT
    product_name,
    product_category,
    total_revenue,
    RANK() OVER(
        PARTITION BY product_category
        ORDER BY total_revenue DESC
    ) AS category_rank
FROM product_sales;


-- Product Profit Ranking Within Category
WITH product_profit AS (

    SELECT
        product_name,
        product_category,
        SUM(profit) AS total_profit
    FROM master_sales
    GROUP BY product_name, product_category

)

SELECT
    product_name,
    product_category,
    total_profit,
    RANK() OVER(
        PARTITION BY product_category
        ORDER BY total_profit DESC
    ) AS category_rank
FROM product_profit;


/* =====================================================
   STORE PERFORMANCE
===================================================== */

-- Revenue Contribution by Store
SELECT
    store_name,
    SUM(revenue) AS total_revenue,
    ROUND(
        SUM(revenue) /
        SUM(SUM(revenue)) OVER() *100,
        2
    ) AS revenue_share_pct
FROM master_sales
GROUP BY store_name
ORDER BY revenue_share_pct DESC;


-- Store Profitability
SELECT
    store_name,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(
        SUM(profit) / SUM(revenue) *100,
        2
    ) AS profit_margin
FROM master_sales
GROUP BY store_name
ORDER BY profit_margin DESC;


-- Revenue Trend by Product Category
SELECT
    product_category,
    DATE_FORMAT(sale_date,'%Y-%m') AS month,
    SUM(revenue) AS monthly_revenue
FROM master_sales
GROUP BY product_category, month
ORDER BY product_category, month;


-- Monthly Store Rankings
WITH monthly_store_revenue AS (

    SELECT
        store_name,
        DATE_FORMAT(sale_date,'%Y-%m') AS month,
        SUM(revenue) AS monthly_revenue
    FROM master_sales
    GROUP BY store_name, month

)

SELECT
    store_name,
    month,
    monthly_revenue,
    RANK() OVER(
        PARTITION BY month
        ORDER BY monthly_revenue DESC
    ) AS monthly_rank
FROM monthly_store_revenue;


/* =====================================================
   INVENTORY ANALYSIS
===================================================== */

-- Low Stock Products
SELECT
    p.product_name,
    i.store_id,
    i.stock_on_hand
FROM inventory i
JOIN products p
ON i.product_id = p.product_id
WHERE stock_on_hand < 10
ORDER BY stock_on_hand;


-- Sell-Through Rate
SELECT
    p.product_name,
    SUM(ms.units) AS total_units_sold,
    SUM(i.stock_on_hand) AS total_stock,
    ROUND(
        SUM(ms.units) /
        NULLIF(SUM(i.stock_on_hand),0) *100,
        2
    ) AS sell_through_pct
FROM master_sales ms
JOIN inventory i
    ON ms.product_id = i.product_id
   AND ms.store_id = i.store_id
JOIN products p
    ON ms.product_id = p.product_id
GROUP BY p.product_name
ORDER BY sell_through_pct DESC;
