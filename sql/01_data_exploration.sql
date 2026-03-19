-- =============================================
-- File: 01_data_exploration.sql
-- Project: E-commerce Marketplace Analytics
-- Purpose:
-- Initial exploratory analysis of the raw dataset
-- to understand table structure, data volume,
-- categorical values, and potential data issues.
-- =============================================


-- =============================================
-- Inspect raw tables
-- =============================================

SELECT TOP 10 *
FROM raw_orders;

SELECT TOP 10 *
FROM raw_order_items;

SELECT TOP 10 *
FROM raw_customers;

SELECT TOP 10 *
FROM raw_products;

SELECT TOP 10 *
FROM raw_sellers;

SELECT TOP 10 *
FROM raw_order_reviews;


-- =============================================
-- Row count validation
-- Purpose: understand dataset scale
-- =============================================

SELECT COUNT(*) AS orders
FROM raw_orders;

SELECT COUNT(*) AS order_items
FROM raw_order_items;

SELECT COUNT(*) AS customers
FROM raw_customers;

SELECT COUNT(*) AS products
FROM raw_products;

SELECT COUNT(*) AS sellers
FROM raw_sellers;


-- =============================================
-- Identify order status categories
-- =============================================

SELECT DISTINCT order_status
FROM raw_orders;


-- =============================================
-- Explore delivery time distribution
-- =============================================

SELECT
    AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS avg_delivery_days,
    MIN(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS min_delivery_days,
    MAX(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS max_delivery_days
FROM raw_orders;


-- =============================================
-- Check missing values in review comments
-- =============================================

SELECT
    COUNT(*) AS total_reviews,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS missing_titles,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS missing_messages
FROM raw_order_reviews;


-- =============================================
-- Identify top product categories
-- =============================================

SELECT
    product_category_name,
    COUNT(*) AS products
FROM raw_products
GROUP BY product_category_name
ORDER BY products DESC;