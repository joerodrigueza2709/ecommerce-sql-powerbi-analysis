-- File: 02_staging_orders.sql
-- Project: E-commerce Marketplace Analytics
-- Purpose:
-- Create a cleaned staging table from raw_orders
-- and derive delivery performance metrics that
-- will later be used in analysis and dashboards.

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    -- delivery duration
    DATEDIFF(
        DAY,
        order_purchase_timestamp,
        order_delivered_customer_date
    ) AS delivery_days,

    -- delivery delay
    DATEDIFF(
        DAY,
        order_estimated_delivery_date,
        order_delivered_customer_date
    ) AS delay_days,

    -- delivered flag
    CASE
        WHEN order_status = 'delivered' THEN 1
        ELSE 0
    END AS is_delivered,

    -- late flag
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_late

INTO stg_orders
FROM raw_orders;

--stg_orders validation

SELECT TOP 10 *
FROM stg_orders;
