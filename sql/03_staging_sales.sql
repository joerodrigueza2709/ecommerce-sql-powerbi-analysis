-- =============================================
-- File: 03_staging_sales.sql
-- Project: E-commerce Marketplace Analytics
-- Purpose:
-- Create a sales staging table at the order-item level
-- by joining orders, customers, products, and sellers.
--
-- Grain:
-- One row per order item.
--
-- Business use:
-- Supports revenue, product, seller, customer, and
-- delivery performance analysis in SQL and Power BI.
-- =============================================

USE EcommerceAnalytics;
GO

-- Remove table if it already exists
DROP TABLE IF EXISTS stg_sales;
GO

SELECT
    -- order item grain
    oi.order_id,
    oi.order_item_id,

    -- customer
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    -- order attributes
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- product
    oi.product_id,
    p.product_category_name,
    ct.product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    -- seller
    oi.seller_id,
    s.seller_city,
    s.seller_state,

    -- financials
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_item_value,

    -- logistics metrics
    DATEDIFF(
        DAY,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date
    ) AS delivery_days,

    DATEDIFF(
        DAY,
        o.order_estimated_delivery_date,
        o.order_delivered_customer_date
    ) AS delay_days,

    CASE
        WHEN o.order_status = 'delivered' THEN 1
        ELSE 0
    END AS is_delivered,

    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1
        ELSE 0
    END AS is_late

INTO stg_sales
FROM raw_order_items oi
LEFT JOIN raw_orders o
    ON oi.order_id = o.order_id
LEFT JOIN raw_customers c
    ON o.customer_id = c.customer_id
LEFT JOIN raw_products p
    ON oi.product_id = p.product_id
LEFT JOIN stg_category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN raw_sellers s
    ON oi.seller_id = s.seller_id;
GO