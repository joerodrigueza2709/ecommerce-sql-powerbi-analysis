-- =============================================
-- File: 02b_staging_category_translation.sql
-- Purpose:
-- Clean category translation table by removing
-- header row incorrectly loaded as data and
-- assigning proper column names.
-- =============================================

DROP TABLE IF EXISTS stg_category_translation;
GO

SELECT
    Column1 AS product_category_name,
    Column2 AS product_category_name_english
INTO stg_category_translation
FROM raw_category_translation
WHERE Column1 <> 'product_category_name';

-- stg_category_translation validation

SELECT TOP 10 *
FROM stg_category_translation;