-- ============================================================
-- 05_category_analysis.sql
-- Purpose : Category and subcategory performance analysis
-- Source  : silver.product_info
-- Author  : [Your Name]
-- Business: Which product categories dominate Sephora and
--           where should we invest marketing budget?
-- ============================================================


-- ============================================================
-- QUERY 1: Category performance overview
-- Business: Top level view of all categories
-- Skills  : GROUP BY, aggregations, ORDER BY
-- ============================================================
SELECT
    primary_category,
    COUNT(product_id)                       AS total_products,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating,
    ROUND(AVG(price_usd)::NUMERIC, 2)       AS avg_price,
    SUM(loves_count)                        AS total_loves,
    SUM(reviews)                            AS total_reviews,
    ROUND(AVG(loves_count)::NUMERIC, 0)     AS avg_loves_per_product
FROM silver.product_info
WHERE primary_category IS NOT NULL
GROUP BY primary_category
ORDER BY total_loves DESC;


-- ============================================================
-- QUERY 2: Skincare subcategory breakdown
-- Business: Which subcategories drive Skincare engagement?
-- Skills  : WHERE filter, GROUP BY, ORDER BY
-- ============================================================
SELECT
    secondary_category,
    COUNT(product_id)                       AS total_products,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating,
    SUM(loves_count)                        AS total_loves,
    ROUND(AVG(loves_count)::NUMERIC, 0)     AS avg_loves
FROM silver.product_info
WHERE primary_category = 'Skincare'
  AND secondary_category IS NOT NULL
GROUP BY secondary_category
ORDER BY total_loves DESC;


-- ============================================================
-- QUERY 3: Significant subcategories only
-- Business: Filter to subcategories worth investing in
-- Skills  : HAVING clause — filter AFTER aggregation
-- Note    : WHERE filters rows BEFORE grouping
--           HAVING filters groups AFTER aggregation
-- ============================================================
SELECT
    secondary_category,
    COUNT(product_id)                       AS total_products,
    SUM(loves_count)                        AS total_loves
FROM silver.product_info
WHERE primary_category = 'Skincare'
GROUP BY secondary_category
HAVING COUNT(product_id) >= 100
   AND SUM(loves_count)  >= 1000000
ORDER BY total_loves DESC;


-- ============================================================
-- QUERY 4: Exclusive product count by category
-- Business: Which categories have most Sephora exclusives?
-- Skills  : FILTER on boolean, GROUP BY, ORDER BY
-- ============================================================
SELECT
    primary_category,
    COUNT(product_id)                                           AS total_products,
    SUM(CASE WHEN sephora_exclusive = TRUE THEN 1 ELSE 0 END)   AS exclusive_products,
    ROUND(
        100.0 * SUM(CASE WHEN sephora_exclusive = TRUE THEN 1 ELSE 0 END)
        / NULLIF(COUNT(product_id), 0), 1
    )                                                           AS exclusive_pct
FROM silver.product_info
WHERE primary_category IS NOT NULL
GROUP BY primary_category
ORDER BY exclusive_products DESC;


-- ============================================================
-- QUERY 5: Price tier distribution by category
-- Business: Are luxury products concentrated in certain categories?
-- Skills  : CASE WHEN, GROUP BY multiple columns
-- ============================================================
SELECT
    primary_category,
    CASE
        WHEN price_usd < 20              THEN '1 - Budget'
        WHEN price_usd BETWEEN 20 AND 50 THEN '2 - Mid Range'
        WHEN price_usd BETWEEN 51 AND 100 THEN '3 - Premium'
        ELSE                                  '4 - Luxury'
    END                                     AS price_tier,
    COUNT(product_id)                       AS total_products,
    ROUND(AVG(loves_count)::NUMERIC, 0)     AS avg_loves,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating
FROM silver.product_info
WHERE primary_category IS NOT NULL
GROUP BY primary_category, price_tier
ORDER BY primary_category, price_tier;
