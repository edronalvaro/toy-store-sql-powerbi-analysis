# Retail Performance & Inventory Optimization Analysis

**Tools Used:** SQL (MySQL), Power BI  
**Dataset Size:** 800K+ Records

---

## Project Overview

This project analyzes sales, product performance, store performance, and inventory data for a multi-store toy retailer to identify revenue drivers, profitability gaps, and inventory risks.

The goal was to determine where management can increase revenue, improve profit margins, optimize inventory allocation, and reduce operational inefficiencies.

---

## Business Problem

Despite strong overall sales, the company lacks visibility into key business questions:

- Which products generate the most revenue and profit?
- Which products sell well but have poor margins?
- Which stores perform best in revenue versus efficiency?
- Is inventory aligned with product demand?
- Where is capital tied up in slow-moving stock?

This project answers the following question:

> How is the toy store performing across products, stores, and time — and where can management increase revenue, optimize inventory, and reduce operational risk?

---

## Objectives

- Evaluate overall business performance
- Identify top and underperforming products
- Measure store performance
- Detect inventory risks such as overstock and stockouts
- Provide actionable recommendations for management

---

## Dataset Overview

The dataset consists of five tables:

- `sales` — transaction-level sales records
- `products` — product details, cost, and price
- `stores` — store metadata and location
- `inventory` — stock levels by store and product
- `calendar` — date dimension for trend analysis

A centralized **master_sales** table was created to combine all relevant business dimensions and improve analytical efficiency.

---

## Data Cleaning & Preparation

Data preparation included:

- Removing currency symbols from price and cost columns
- Converting text-based numeric fields into decimal values
- Converting date columns into SQL date format
- Handling missing values using `COALESCE`
- Checking for nulls, duplicates, and invalid values
- Creating a unified analytical table for reporting

This reduced repeated joins and improved query performance.

---

## Key Performance Indicators

| KPI | Value |
|---|---:|
| Total Revenue | $14.44M |
| Total Profit | $4.01M |
| Profit Margin | 27.8% |
| Records Analyzed | 800K+ |

---

## Analysis

### Executive Performance

The business generated **$14.44M in revenue** and **$4.01M in profit**, resulting in a healthy **27.8% overall profit margin**.

This indicates strong overall profitability, though performance varies significantly across products and stores.

---

### Product Performance

Product analysis revealed major differences between revenue and profitability.

- **Toys** generated the highest overall revenue
- **Electronics** generated nearly the same total profit as Toys despite less than half the revenue due to significantly higher margins
- **Colorbuds** was the most profitable product, generating approximately **$835K in profit** with a **53.4% margin**
- **Lego Bricks** generated the highest revenue but maintained only a **12.5% profit margin**

This shows that high sales volume does not always translate into strong profitability.

---

### Store Performance

Store performance showed both scale-driven and efficiency-driven success.

- **Ciudad de Mexico 2** was the top-performing store in both revenue(555K) and profit($170K).
- **Revenue appears to be concentrated in a small number of major-city stores, particularly Mexico City, Guadalajara, and Monterrey.
- **Morelia 1 and Mexicali 1** had the highest profit margins at **33.1%**

---

### Inventory & Risk Analysis

Inventory analysis indicates a systemic overstocking and low inventory turnover issue across most products.

- **Playfoam** had the highest sell-through rate at 21.16%, making it the fastest-moving product, though still below healthy retail benchmarks
- **Deck of Cards** had a sell-through rate of only 2.20%, highlighting extremely slow inventory movement
- Most products fall below 10% sell-through, indicating widespread overstocking rather than isolated inefficiencies

This suggests that inventory levels are not aligned with actual demand patterns, resulting in excess stock and low capital efficiency across the product portfolio.
---

### Sales Trends

Revenue trends show strong seasonality with pronounced Q4 peaks and mid-year declines.

- Revenue peaks in Q4, with December 2022 reaching 877K (+32.65% MoM), the highest month in the dataset
- This is followed by a sharp post-peak drop in January 2023 (747K, -14.82% MoM)
- Mid-year periods consistently underperform, with notable declines such as July–August 2022 (-16.00% and -11.98%) and August 2023 (-20.22%), the steepest monthly drop in the dataset
- Outside of seasonal peaks, monthly revenue typically ranges between ~650K and ~830K, showing volatility rather than steady growth
- While there are intermittent spikes (e.g., March 2023 at 883K, +22.26% MoM), these are not sustained month-over-month trends

Overall, the business demonstrates strong seasonal demand (especially Q4-driven spikes) combined with high volatility and no consistent linear growth trend.

---

## Key Insights

- Revenue and profitability are not always aligned: for example, Maven Toys Ciudad de Mexico 2 generates the highest revenue (~555K) and profit (~170K), but its margin (~30.6%) is lower than top efficiency stores like Morelia (~33.1%) and Mexicali (~33.1%)
- High-revenue stores and products can still underperform in margin: several high-volume stores (e.g., Ciudad de Mexico 1 ~434K revenue, ~25.7% margin; Toluca 1 ~411K revenue, ~25.4% margin) earn strong sales but relatively weak profitability efficiency
- Store performance depends on both scale and efficiency: top performers like CDMX 2 (170K profit, 555K revenue) show scale dominance, while stores like Morelia (~90484 profit on ~273K revenue, ~33.1% margin) demonstrate efficiency advantage
- Inventory is not fully optimized relative to demand: most products show extremely low sell-through rates, typically 2%–10%, far below healthy retail benchmarks (~60%–80%), indicating systemic overstocking
- Slow-moving products tie up capital and increase risk: examples include Deck of Cards (2.2% sell-through), PlayDoh Can (3.83%), Rubik’s Cube (4.04%), and Lego Bricks (5.53%), all indicating excessive inventory relative to demand

---

## Business Recommendations

Based on the analysis, management should consider:

- Optimizing pricing for high-revenue, low-margin stores/products such as CDMX 1 (~25.7% margin) and Toluca 1 (~25.4% margin) to improve profitability efficiency
- Reallocating inventory toward relatively faster-moving products like Playfoam (21.16%), Jenga (16.09%), and Hot Wheels 5-Pack (14.22%), while reducing excess stock in products below ~5% sell-through
- Reducing stock exposure in slow-moving SKUs such as Deck of Cards (2.2%) and other <5% sell-through products to free up working capital and reduce holding costs
- Studying high-margin stores such as Morelia (~33.1% margin) and Mexicali (~33.1% margin) to identify pricing, cost structure, or operational practices that drive efficiency
- Tracking product and store performance using both revenue and margin metrics, as shown by the contrast between CDMX 2 (scale leader) and high-margin but lower-volume stores (~33% efficiency leaders)

---

## Skills Demonstrated

- SQL Data Cleaning
- Exploratory Data Analysis
- Data Modeling
- KPI Development
- Window Functions
- Business Intelligence Reporting
- Dashboard Design in Power BI
- Business Storytelling

---

## Top 5 Products by Profit Margin
```sql
SELECT 
    product_name, 
    ROUND(SUM(profit)/SUM(revenue) * 100, 2) AS profit_margin
FROM master_sales 
GROUP BY product_name
ORDER BY profit_margin DESC
LIMIT 5;

This query identifies the most profitable products based on margin rather than revenue, helping prioritize high-value inventory decisions.
```

## Month-over-Month Revenue Growth
```sql
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(sale_date, '%Y-%m') AS month,
        SUM(revenue) AS total_revenue 
    FROM master_sales 
    GROUP BY 1
)
SELECT 
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month) AS prev_month,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY month)) 
        / LAG(total_revenue) OVER (ORDER BY month) * 100, 2
    ) AS mom_growth_pct
FROM monthly_revenue;

This query highlights month-over-month revenue trends and captures seasonality patterns in sales performance.
```
These queries demonstrate both profitability analysis and time-series analysis using window functions.
