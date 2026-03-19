-- =============================================
-- File: 04_business_analysis.sql
-- Project: E-commerce Marketplace Analytics
-- Purpose:
-- Business analysis queries for revenue, categories,
-- sellers, delivery performance, and customer trends.
-- =============================================

-- =============================================
-- Query 1: Monthly revenue trend
-- Purpose:
-- Track sales performance over time
-- =============================================

SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(price) AS product_revenue,
    SUM(freight_value) AS total_freight,
    SUM(total_item_value) AS total_revenue
FROM stg_sales
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;

-- =============================================
-- Query 2: Top product categories by revenue
-- Purpose:
-- Identify which categories generate the most sales
-- =============================================

SELECT TOP 10
    product_category_name_english,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(price) AS product_revenue,
    SUM(freight_value) AS total_freight,
    SUM(total_item_value) AS total_revenue
FROM stg_sales
GROUP BY product_category_name_english
ORDER BY total_revenue DESC;

-- =============================================
-- Query 3: Top sellers by revenue
-- Purpose:
-- Rank marketplace sellers by sales performance
-- =============================================

SELECT TOP 10
    seller_id,
    seller_state,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(price) AS product_revenue,
    SUM(total_item_value) AS total_revenue
FROM stg_sales
GROUP BY
    seller_id,
    seller_state
ORDER BY total_revenue DESC;

-- =============================================
-- Query 4: Delivery performance summary
-- Purpose:
-- Measure average delivery speed and lateness
-- =============================================

SELECT
    AVG(CAST(delivery_days AS DECIMAL(10,2))) AS avg_delivery_days,
    AVG(CAST(delay_days AS DECIMAL(10,2))) AS avg_delay_days,
    SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) AS late_order_items,
    COUNT(*) AS total_order_items,
    CAST(
        100.0 * SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS late_item_rate_pct
FROM stg_sales
WHERE is_delivered = 1;

-- =============================================
-- Query 5: Top customer states by revenue
-- Purpose:
-- Identify which customer regions generate the most revenue
-- =============================================

SELECT TOP 10
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    SUM(total_item_value) AS total_revenue,
    AVG(total_item_value) AS avg_item_value
FROM stg_sales
GROUP BY customer_state
ORDER BY total_revenue DESC;