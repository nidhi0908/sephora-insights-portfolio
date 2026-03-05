CREATE SCHEMA IF NOT EXISTS silver;


-- Cleaning Brinze layer first to create a silver layer for analysis

SELECT COUNT(*) AS total_rows
FROM bronze.product_info;

-- Distinct product IDs (check for duplicates)
SELECT COUNT(DISTINCT product_id) AS distinct_products
FROM bronze.product_info;

-- Null audit across key columns
SELECT
    COUNT(*) - COUNT(product_id)        AS product_id_nulls,
    COUNT(*) - COUNT(product_name)      AS product_name_nulls,
    COUNT(*) - COUNT(brand_name)        AS brand_name_nulls,
    COUNT(*) - COUNT(rating)            AS rating_nulls,
    COUNT(*) - COUNT(reviews)           AS reviews_nulls,
    COUNT(*) - COUNT(price_usd)         AS price_usd_nulls,
    COUNT(*) - COUNT(loves_count)       AS loves_count_nulls
FROM bronze.product_info;

-- Check data types of boolean columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name   = 'product_info'
  AND column_name  IN (
      'limited_edition',
      'new',
      'online_only',
      'out_of_stock',
      'sephora_exclusive'
  );

DROP TABLE IF EXISTS silver.product_info;

CREATE TABLE silver.product_info AS
SELECT
    -- Core identifiers (never NULL — rows failing WHERE below are excluded)
    product_id,
    product_name,
    brand_id,
    brand_name,

    -- Categories
    primary_category,
    secondary_category,        -- NULL acceptable: not all categories have sub-levels
    tertiary_category,         -- NULL acceptable: not all categories have sub-levels

    -- Pricing (NULL acceptable: sale/value price only exists when applicable)
    price_usd,
    value_price_usd,
    sale_price_usd,
    child_min_price,           -- NULL acceptable: only exists for multi-variation products
    child_max_price,           -- NULL acceptable: only exists for multi-variation products

    -- Engagement metrics (NULL → 0: product exists but has no activity yet)
    COALESCE(loves_count, 0)   AS loves_count,
    COALESCE(reviews, 0)       AS reviews,
    COALESCE(rating, 0)        AS rating,

    -- Product flags
    -- Stored as bigint (0/1) in bronze → converted to boolean in silver
    -- Pattern: (column = 1) returns TRUE/FALSE, COALESCE handles NULLs
    COALESCE(limited_edition   = 1, FALSE) AS limited_edition,
    COALESCE(new               = 1, FALSE) AS new,
    COALESCE(online_only       = 1, FALSE) AS online_only,
    COALESCE(out_of_stock      = 1, FALSE) AS out_of_stock,
    COALESCE(sephora_exclusive = 1, FALSE) AS sephora_exclusive,

    -- Optional descriptive fields (NULL acceptable)
    size,
    variation_type,
    variation_value,
    variation_desc,
    ingredients,
    highlights,
    child_count,

    -- Audit timestamp: records when this row was cleaned and loaded
    NOW() AS loaded_at

FROM bronze.product_info
WHERE product_id   IS NOT NULL    -- exclude rows with no product identifier
  AND brand_name   IS NOT NULL    -- exclude rows with no brand
  AND price_usd    IS NOT NULL;   -- exclude rows with no price (unusable for analysis)


  SELECT COUNT(*) AS silver_row_count FROM silver.product_info;

-- Confirm no NULLs in key columns
SELECT
    COUNT(*) - COUNT(rating)        AS rating_nulls,
    COUNT(*) - COUNT(reviews)       AS reviews_nulls,
    COUNT(*) - COUNT(loves_count)   AS loves_count_nulls,
    COUNT(*) - COUNT(limited_edition) AS limited_edition_nulls
FROM silver.product_info;




