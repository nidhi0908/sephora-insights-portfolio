# 💄 Sephora Products & Skincare Reviews — Data Analytics Portfolio Project

![Dashboard Preview](dashboard/page1_brand_analysis.png)

---

## 📌 Project Overview

This project analyses over **8,494 Sephora products** to uncover what drives customer engagement, satisfaction, and loyalty in the beauty industry.

The analysis is framed around real business questions a **Customer Insights** or **Marketing Analyst** would be asked — making it directly relevant to DA/BA roles.

**Tools Used:** PostgreSQL · Looker Studio  
**Dataset:** [Sephora Products and Skincare Reviews — Kaggle](https://www.kaggle.com/datasets/nadyinky/sephora-products-and-skincare-reviews)  
**Role Focus:** Data Analyst · Business Analyst · Marketing Insights

---

## 🎯 Business Questions Answered

| # | Business Question | Analysis |
|---|-------------------|----------|
| 1 | Which brands generate the most customer love per product? | Brand Analysis |
| 2 | Are Sephora exclusive products outperforming non-exclusive ones? | Brand Analysis |
| 3 | Where is the pricing sweet spot for quality and engagement? | Price Analysis |
| 4 | Do premium brands outperform budget brands? | Price Analysis |
| 5 | Which product categories dominate customer engagement? | Category Analysis |
| 6 | Which Skincare subcategories drive the most engagement? | Category Analysis |
| 7 | Which categories have the most Sephora exclusive products? | Category Analysis |

---

## 📁 Project Structure

```
sephora-insights-portfolio/
│
├── sql/
│   ├── 01_schema_and_cleaning.sql   # Bronze audit + silver table
│   ├── 02_views.sql                 # All Looker Studio views
│   ├── 03_brand_analysis.sql        # Brand performance queries
│   ├── 04_price_analysis.sql        # Price vs engagement queries
│   └── 05_category_analysis.sql     # Category breakdown queries
│
├── dashboard/
│   ├── page1_brand_analysis.png     # Brand Performance dashboard
│   ├── page2_price_analysis.png     # Price Analysis dashboard
│   └── page3_category_analysis.png  # Category Analysis dashboard
│
└── README.md
```

---

## 🗄️ Data Architecture — Medallion Pattern

This project uses a **medallion architecture** — an industry standard data engineering pattern:

```
Bronze Layer          Silver Layer           Gold Layer
─────────────         ─────────────          ─────────────
Raw CSV data    →     Cleaned &        →     Aggregated
from Kaggle           standardised           views for
                      data                   Looker Studio
```

**Bronze → Silver transformations:**
- NULL `rating` and `reviews` replaced with `0`
- Boolean flags converted from `bigint (0/1)` to `BOOLEAN (TRUE/FALSE)`
- Rows missing `product_id`, `brand_name`, or `price_usd` excluded
- Audit timestamp (`loaded_at`) added to every row

---

## 🗃️ Dataset Schema

### `product_info` (8,494 products)

| Column | Type | Description |
|--------|------|-------------|
| product_id | VARCHAR | Primary key |
| product_name | TEXT | Full product name |
| brand_name | TEXT | Brand |
| loves_count | INT | Number of users who loved the product |
| rating | NUMERIC | Average star rating (1–5) |
| reviews | INT | Total review count |
| price_usd | NUMERIC | Listed price |
| primary_category | TEXT | Top level category |
| sephora_exclusive | BOOLEAN | Exclusive to Sephora |
| limited_edition | BOOLEAN | Limited edition item |

---

## 🔑 SQL Skills Demonstrated

| Skill | Where Used |
|-------|------------|
| Data quality audit | `01_schema_and_cleaning.sql` |
| NULL handling with COALESCE | `01_schema_and_cleaning.sql` |
| Data type casting `::BOOLEAN` `::NUMERIC` | `01_schema_and_cleaning.sql` |
| Aggregations — COUNT, SUM, AVG, ROUND | All files |
| CASE WHEN bucketing | `03_brand_analysis.sql`, `04_price_analysis.sql` |
| CTEs (WITH clauses) | `03_brand_analysis.sql`, `04_price_analysis.sql` |
| Window functions — RANK() OVER (PARTITION BY) | `03_brand_analysis.sql` |
| Statistical functions — PERCENTILE_CONT | `04_price_analysis.sql` |
| HAVING vs WHERE distinction | `05_category_analysis.sql` |
| NULLIF for safe division | All files |
| CREATE VIEW for BI tooling | `02_views.sql` |

---

## 📊 Looker Studio Dashboards

### Page 1 — Brand Performance Analysis
![Brand Analysis](dashboard/page1_brand_analysis.png)

**Key Insights:**
- Olaplex and Rare Beauty generate the highest customer love per product — outperforming brands with much larger catalogues
- Sephora exclusive products generate **22% more avg loves per product** than non-exclusive products despite representing only 28% of the catalogue
- stila appears as a top engagement brand despite having the lowest average rating — suggesting strong brand nostalgia disconnected from recent product quality

---

### Page 2 — Price Analysis
![Price Analysis](dashboard/page2_price_analysis.png)

**Key Insights:**
- The pricing sweet spot for customer engagement is **$21-40** — highest avg loves per product
- Rating peaks at **$61-80** then becomes volatile and inconsistent at higher price points
- Paying more above $80 does not guarantee better ratings or more customer engagement — luxury products show diminishing returns

---

### Page 3 — Category Analysis
![Category Analysis](dashboard/page3_category_analysis.png)

**Key Insights:**
- **Makeup** dominates total customer engagement despite Skincare having more products and a higher average rating
- Within Skincare, **Lip Balms & Treatments** generates 2x more avg loves than any other subcategory
- **Makeup and Skincare** account for the majority of Sephora exclusive products — suggesting strategic exclusivity focus in highest engagement categories

---

## 🚀 How To Run

### 1. Download Dataset
Download from [Kaggle](https://www.kaggle.com/datasets/nadyinky/sephora-products-and-skincare-reviews) and place CSVs in a `/data` folder.

### 2. PostgreSQL Setup
```bash
# Run in order
psql -U your_user -d your_database -f sql/01_schema_and_cleaning.sql
psql -U your_user -d your_database -f sql/02_views.sql

# Analysis queries (optional — for exploration)
psql -U your_user -d your_database -f sql/03_brand_analysis.sql
psql -U your_user -d your_database -f sql/04_price_analysis.sql
psql -U your_user -d your_database -f sql/05_category_analysis.sql
```

### 3. Looker Studio
Connect via PostgreSQL connector and use these views as data sources:
```
Page 1 → silver.vw_brand_summary    (charts + KPIs)
Page 1 → silver.vw_brand_analysis   (leaderboard + filters)
Page 2 → silver.vw_price_analysis   (all price charts)
Page 3 → silver.vw_category_analysis (all category charts)
```

---

## 💡 Key Takeaways

1. **Brand equity beats catalogue size** — smaller focused brands like Olaplex and Rare Beauty outperform larger brands on engagement efficiency
2. **Exclusivity drives ROI** — Sephora exclusive products generate disproportionate customer love relative to their catalogue share
3. **The $21-40 sweet spot** — mid-range products maximise both quality ratings and customer engagement
4. **Luxury ≠ more engagement** — premium pricing above $80 yields diminishing returns on customer love
5. **Category strategy matters** — Makeup dominates engagement while Skincare leads on quality

---

## 👤 Author

**[Your Name]**  
[LinkedIn Profile](#) · [GitHub Profile](#)

---

*This project was built as part of a self-directed data analytics portfolio focusing on SQL, Python, and BI tooling.*
