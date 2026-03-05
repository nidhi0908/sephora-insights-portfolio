SELECT COUNT(*) FROM silver.product_info;

-- VIEW 1: vw_brand_summary
-- Purpose : Brand level aggregation for bar charts and KPIs
-- Used by : Looker Page 1 — bar chart, scatter, KPI tiles
-- Note    : Grouped by brand_name ONLY to avoid duplicates
-- ============================================================
DROP VIEW IF EXISTS silver.vw_brand_summary;

CREATE VIEW silver.vw_brand_summary AS
SELECT
    brand_name,
    COUNT(product_id)                       AS total_products,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating,
    ROUND(AVG(loves_count)::NUMERIC, 0)     AS avg_loves,
    SUM(loves_count)                        AS total_loves,
    SUM(reviews)                            AS total_reviews,
    ROUND(AVG(price_usd)::NUMERIC, 2)       AS avg_price_usd,
    ROUND(
        SUM(loves_count)::NUMERIC /
        NULLIF(COUNT(product_id), 0), 0
    )                                       AS loves_per_product
FROM silver.product_info
WHERE brand_name IS NOT NULL
GROUP BY brand_name
HAVING COUNT(product_id) >= 3;

-- ============================================================
-- VIEW 2: vw_brand_analysis
-- Purpose : Brand level with category and tier dimensions
-- Used by : Looker Page 1 — leaderboard table and filters
-- Note    : Grouped by brand + category + tier + exclusive
--           Use for filtered leaderboard only
-- ============================================================
DROP VIEW IF EXISTS silver.vw_brand_analysis;

CREATE VIEW silver.vw_brand_analysis AS
SELECT
    brand_name,
    primary_category,
    sephora_exclusive,
    CASE
        WHEN price_usd < 20              THEN '1 - Budget'
        WHEN price_usd BETWEEN 20 AND 50 THEN '2 - Mid Range'
        WHEN price_usd BETWEEN 51 AND 100 THEN '3 - Premium'
        ELSE                                  '4 - Luxury'
    END                                     AS price_tier,
    COUNT(product_id)                       AS total_products,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating,
    ROUND(AVG(loves_count)::NUMERIC, 0)     AS avg_loves,
    SUM(loves_count)                        AS total_loves,
    SUM(reviews)                            AS total_reviews,
    ROUND(AVG(price_usd)::NUMERIC, 2)       AS avg_price_usd,
    ROUND(
        SUM(loves_count)::NUMERIC /
        NULLIF(COUNT(product_id), 0), 0
    )                                       AS loves_per_product
FROM silver.product_info
WHERE brand_name IS NOT NULL
GROUP BY brand_name, primary_category, price_tier, sephora_exclusive;

-- ============================================================
-- VIEW 3: vw_price_analysis
-- Purpose : Raw product data with price buckets for Looker
-- Used by : Looker Page 2 — all price analysis charts
-- Note    : A. B. C. prefix forces correct alphabetical sort
-- ============================================================
DROP VIEW IF EXISTS silver.vw_price_analysis;

CREATE VIEW silver.vw_price_analysis AS
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
    END                  AS price_bucket,
    primary_category,
    brand_name,
    sephora_exclusive,
    limited_edition,
    new                  AS new_arrival,
    price_usd,
    rating,
    loves_count,
    reviews
FROM silver.product_info
WHERE price_usd IS NOT NULL;

-- VIEW 4: vw_category_analysis
-- Purpose : Raw product data for category level analysis
-- Used by : Looker Page 3 — all category charts
-- ============================================================
DROP VIEW IF EXISTS silver.vw_category_analysis;

CREATE VIEW silver.vw_category_analysis AS
SELECT
    primary_category,
    secondary_category,
    brand_name,
    price_usd,
    rating,
    loves_count,
    reviews,
    sephora_exclusive,
    limited_edition,
    CASE
        WHEN price_usd < 20              THEN '1 - Budget'
        WHEN price_usd BETWEEN 20 AND 50 THEN '2 - Mid Range'
        WHEN price_usd BETWEEN 51 AND 100 THEN '3 - Premium'
        ELSE                                  '4 - Luxury'
    END                                  AS price_tier
FROM silver.product_info
WHERE primary_category IS NOT NULL;

SELECT COUNT(*) AS brand_summary_rows    FROM silver.vw_brand_summary;

SELECT COUNT(*) AS brand_analysis_rows   FROM silver.vw_brand_analysis;

SELECT COUNT(*) AS price_analysis_rows   FROM silver.vw_price_analysis;

SELECT COUNT(*) AS category_analysis_rows FROM silver.vw_category_analysis;




