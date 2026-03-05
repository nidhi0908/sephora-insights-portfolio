-- ============================================================
-- 04_price_analysis.sql
-- Purpose : Price vs performance analysis
-- Source  : silver.product_info
-- Author  : [Your Name]
-- Business: Where is the pricing sweet spot that maximises
--           both quality and customer engagement?
-- ============================================================


-- ============================================================
-- QUERY 1: Price distribution overview
-- Business: Understand the shape of pricing data before analysis
-- Skills  : MIN, MAX, AVG, PERCENTILE_CONT (median)
-- Key insight: Use median not average for skewed price data
-- ============================================================
SELECT
    ROUND(MIN(price_usd)::NUMERIC, 2)                           AS min_price,
    ROUND(MAX(price_usd)::NUMERIC, 2)                           AS max_price,
    ROUND(AVG(price_usd)::NUMERIC, 2)                           AS avg_price,
    ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY price_usd)::NUMERIC, 2)          AS median_price,
    COUNT(*)                                                     AS total_products
FROM silver.product_info
WHERE price_usd IS NOT NULL;

-- avg ($51.66) vs median ($35.00) confirms right-skewed distribution
-- A few luxury products pull average up — median tells true story


-- ============================================================
-- QUERY 2: Top 3 brands per price tier
-- Business: Which brands lead in each price segment?
-- Skills  : CTE, CASE WHEN, RANK() OVER (PARTITION BY)
--           Window function — first real business use
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
-- QUERY 3: Performance by price bucket
-- Business: Which exact price range maximises engagement?
-- Skills  : CTE, CASE WHEN, PERCENTILE_CONT, sort order fix
-- Note    : A. B. C. prefix forces correct sort in any BI tool
-- ============================================================
WITH price_buckets AS (
    SELECT
        CASE
            WHEN price_usd BETWEEN 0   AND 20  THEN 'A. $0-20'
            WHEN price_usd BETWEEN 21  AND 40  THEN 'B. $21-40'
            WHEN price_usd BETWEEN 41  AND 60  THEN 'C. $41-60'
            WHEN price_usd BETWEEN 61  AND 80  THEN 'D. $61-80'
            WHEN price_usd BETWEEN 81  AND 100 THEN 'E. $81-100'
            WHEN price_usd BETWEEN 101 AND 150 THEN 'F. $101-150'
            WHEN price_usd BETWEEN 151 AND 200 THEN 'G. $151-200'
            ELSE                                    'H. $200+'
        END AS price_bucket,
        rating,
        loves_count,
        reviews
    FROM silver.product_info
    WHERE price_usd IS NOT NULL
)
SELECT
    price_bucket,
    COUNT(*)                                                    AS total_products,
    ROUND(AVG(rating)::NUMERIC, 2)                              AS avg_rating,
    ROUND(AVG(loves_count)::NUMERIC, 0)                         AS avg_loves,
    ROUND(AVG(reviews)::NUMERIC, 0)                             AS avg_reviews,
    ROUND(PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY loves_count)::NUMERIC, 0)        AS median_loves
FROM price_buckets
GROUP BY price_bucket
ORDER BY price_bucket;

-- Key findings:
-- Sweet spot for engagement = B. $21-40 (highest avg loves)
-- Rating peaks at D. $61-80 then becomes volatile
-- Above $80 = better quality but NOT more engagement
-- Luxury products show diminishing returns on customer love
