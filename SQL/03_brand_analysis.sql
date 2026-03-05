-- 03_brand_analysis.sql
-- Purpose : Brand performance analysis queries
-- Source  : silver.product_info
-- Author  : Gayatri
-- Business: Which brands dominate Sephora and which
--           punch above their weight?
-- ============================================================


-- ============================================================
-- QUERY 1: Top 20 brands by loves per product
-- Business: Identifies most efficient brands by engagement
-- Skills  : GROUP BY, aggregations, NULLIF, HAVING, ORDER BY
-- ============================================================
SELECT
    brand_name,
    COUNT(product_id)                       AS total_products,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating,
    SUM(loves_count)                        AS total_loves,
    SUM(reviews)                            AS total_reviews,
    ROUND(
        SUM(loves_count)::NUMERIC /
        NULLIF(COUNT(product_id), 0), 0
    )                                       AS loves_per_product
FROM silver.product_info
WHERE brand_name IS NOT NULL
GROUP BY brand_name
HAVING COUNT(product_id) >= 5
ORDER BY loves_per_product DESC
LIMIT 20;

-- ============================================================
-- QUERY 2: Brand performance by price tier
-- Business: Do premium brands outperform budget brands?
-- Skills  : CTE, CASE WHEN bucketing, aggregations
-- ============================================================
WITH brand_tier AS (
    SELECT
        CASE
            WHEN price_usd < 20              THEN '1 - Budget'
            WHEN price_usd BETWEEN 20 AND 50 THEN '2 - Mid Range'
            WHEN price_usd BETWEEN 51 AND 100 THEN '3 - Premium'
            ELSE                                  '4 - Luxury'
        END                                    AS price_tier,
        brand_name,
        COUNT(product_id)                      AS total_products,
        ROUND(AVG(rating)::NUMERIC, 2)         AS avg_rating,
        ROUND(AVG(loves_count)::NUMERIC, 0)    AS avg_loves
    FROM silver.product_info
    WHERE brand_name IS NOT NULL
    GROUP BY price_tier, brand_name
    HAVING COUNT(product_id) >= 3
),
ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY price_tier
            ORDER BY avg_loves DESC
        ) AS brand_rank
    FROM brand_tier
)
SELECT *
FROM ranked
WHERE brand_rank <= 3
ORDER BY price_tier, brand_rank;

-- ============================================================
-- QUERY 3: Sephora exclusive vs non-exclusive performance
-- Business: Are exclusivity deals worth the investment?
-- Skills  : GROUP BY boolean, conditional aggregation
-- ============================================================
SELECT
    sephora_exclusive,
    COUNT(product_id)                       AS total_products,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating,
    ROUND(AVG(loves_count)::NUMERIC, 0)     AS avg_loves
FROM silver.product_info
GROUP BY sephora_exclusive;

-- Senior insight from this query:
-- Exclusive products generate 22% more avg loves per product
-- and rate 0.06 points higher despite being only 28% of catalogue
-- Exclusivity deals are driving disproportionate customer engagement





