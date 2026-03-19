-- =============================================
-- File: 05_advanced_analysis.sql
-- Project: E-commerce Marketplace Analytics
-- Purpose:
-- Advanced SQL analysis including order-level metrics,
-- repeat customer analysis, seller ranking, and
-- revenue concentration.
-- =============================================

-- =============================================
-- Query 1: Create order-level summary table
-- Purpose:
-- Aggregate item-level sales into one row per order
-- =============================================

DROP TABLE IF EXISTS stg_order_summary;
GO

SELECT
    order_id,
    customer_id,
    customer_unique_id,
    customer_state,
    order_status,
    CAST(order_purchase_timestamp AS DATE) AS order_date,
    COUNT(*) AS total_items,
    SUM(price) AS product_revenue,
    SUM(freight_value) AS total_freight,
    SUM(total_item_value) AS total_order_value,
    AVG(CAST(delivery_days AS DECIMAL(10,2))) AS avg_delivery_days,
    MAX(is_delivered) AS is_delivered,
    MAX(is_late) AS is_late
INTO stg_order_summary
FROM stg_sales
GROUP BY
    order_id,
    customer_id,
    customer_unique_id,
    customer_state,
    order_status,
    CAST(order_purchase_timestamp AS DATE);
GO

-- =============================================
-- Query 2: Average order value
-- Purpose:
-- Calculate the average value per order
-- =============================================

SELECT
    COUNT(*) AS total_orders,
    SUM(total_order_value) AS total_revenue,
    AVG(total_order_value) AS avg_order_value
FROM stg_order_summary;

-- =============================================
-- Query 3: Repeat customer analysis
-- Purpose:
-- Identify how many customers purchase more than once
-- =============================================

WITH customer_order_counts AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM stg_order_summary
    GROUP BY customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    CAST(
        100.0 * SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS repeat_customer_rate_pct
FROM customer_order_counts;

-- =============================================
-- Query 4: Top customers by revenue
-- Purpose:
-- Identify highest-value customers
-- =============================================

SELECT TOP 10
    customer_unique_id,
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_order_value) AS total_revenue,
    AVG(total_order_value) AS avg_order_value
FROM stg_order_summary
GROUP BY
    customer_unique_id,
    customer_state
ORDER BY total_revenue DESC;

-- =============================================
-- Query 5: Rank sellers by revenue within each state
-- Purpose:
-- Use a window function to rank sellers by performance
-- =============================================

WITH seller_revenue AS (
    SELECT
        seller_state,
        seller_id,
        SUM(total_item_value) AS total_revenue
    FROM stg_sales
    GROUP BY
        seller_state,
        seller_id
)

SELECT
    seller_state,
    seller_id,
    total_revenue,
    RANK() OVER (
        PARTITION BY seller_state
        ORDER BY total_revenue DESC
    ) AS seller_rank_in_state
FROM seller_revenue
ORDER BY
    seller_state,
    seller_rank_in_state;

-- =============================================
-- Query 6: Revenue concentration by product category
-- Purpose:
-- Identify whether revenue is concentrated in a small
-- number of categories
-- =============================================

WITH category_revenue AS (
    SELECT
        product_category_name_english,
        SUM(total_item_value) AS total_revenue
    FROM stg_sales
    GROUP BY product_category_name_english
),
category_ranked AS (
    SELECT
        product_category_name_english,
        total_revenue,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS overall_revenue
    FROM category_revenue
)

SELECT
    product_category_name_english,
    total_revenue,
    cumulative_revenue,
    CAST(100.0 * cumulative_revenue / overall_revenue AS DECIMAL(10,2)) AS cumulative_revenue_pct
FROM category_ranked
ORDER BY total_revenue DESC;