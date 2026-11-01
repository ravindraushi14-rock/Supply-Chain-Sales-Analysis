# 04 · SQL Guide (PostgreSQL)

All SQL is in [`/sql`](../sql). Every file runs on its own in pgAdmin, and `step03_load_to_sql.py` runs them in order.

## 1. Schema: `01_create_tables.sql`
A **star schema**: one fact table of order lines and two dimensions.

| Design choice | Reason |
| --- | --- |
| `PRIMARY KEY` on every table | Duplicate lines, customers or products cannot be loaded |
| `FOREIGN KEY` fact → dimensions | Every line has a known customer and product |
| `CHECK (days_real >= 0)`, `CHECK (sales >= 0)`, `CHECK (quantity > 0)` | The database rejects impossible values |
| Indexes on date, customer, product, order | Fast filters and joins for Power BI |
| `DROP … CASCADE` | Safe to re-run |

Loading uses PostgreSQL **`COPY`** (bulk load), and row counts are compared after every load.

## 2. KPI views: `02_kpi_views.sql`
| View | Technique to notice |
| --- | --- |
| v_kpi_by_year | `AVG(is_late::int) FILTER (WHERE is_shipped)`: a conditional average |
| v_yoy | `LAG(...) OVER (ORDER BY year)` with a named `WINDOW` |
| v_like_for_like | `EXTRACT(MONTH FROM order_date) <= 9` |
| v_shipping_sla | `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_real)`: the median |
| v_market_performance | `SUM(SUM(sales)) OVER ()`: share of the total |
| v_product_abc | Running total `SUM(...) OVER (ORDER BY sales DESC ROWS UNBOUNDED PRECEDING)` + `CASE` for the ABC class |
| v_customer_profitability | `SUM(profit) < 0` as a Boolean flag |
| v_discount_impact | `CASE` bands on discount_rate |

## 3. Business questions: `03_analysis_queries.sql`
| # | Question | Answer (2015–2017) |
| --- | --- | --- |
| Q1 | Size and reliability | $36.45M sales, $3.93M profit (10.79%), 63,629 orders, **57.27% late** (shipped) |
| Q2 | Are promises realistic? | First Class 1d → 2.0d (100% late) · Second 2d → 4.0d (79.8%) · Same Day 0d → 0.5d (48.0%) · Standard 4d → 4.0d (39.8%) |
| Q3 | How late is late? | 33.6% of lines 1 day late, 15.9% 2 days, 7.8% 3–4 days; 24.1% early |
| Q4 | Second Class detail | Actual days spread evenly from 2 to 6 (~20% each), so the 2-day promise is met by only 20% |
| Q5 | Worst market/region | Western Europe 58.5%, South of USA 58.5%, South Asia 58.5%. Lateness is similar everywhere, so it is systemic, not regional |
| Q6 | YoY | 2017: sales −4.03%, profit −0.46%, orders +4.83%, customers +48.27%, AOV −8.45% |
| Q7 | Like-for-like | Jan–Sep 2017 vs 2016: **sales +4.72%** |
| Q8 | Pareto | **8 of 118 products = 85.5% of sales** (A class) |
| Q9 | Top products | Field & Stream Gun Safe $6.93M, Perfect Fitness Rip Deck $4.42M, Diamondback Bike $4.12M |
| Q10 | Loss-making customers | 3,660 customers, $7.05M sales, **−$1.04M profit** (19.3% of sales) |
| Q11 | Discounts | Margin 11.79% (0–4%) → 9.01% (20–25%) |
| Q12 | Order funnel | 33% complete, 22% pending payment, 2.3% suspected fraud, 2.1% cancelled |
| Q13 | Fraud | Only TRANSFER payments: ~8% fraud rate in every market |
| Q14 | Cost of late delivery | $19.9M of sales delivered late. Consumer $10.4M |
| Q15 | Market × month | In most months one market has >95% of sales |

The original 30-query analysis ([`archive/reports_v1/05_DataCo_30_SQL_Business_Analyses.sql`](../archive/reports_v1/05_DataCo_30_SQL_Business_Analyses.sql)) and the advanced queries ([`sql/legacy/`](../sql/legacy)) are kept for reference.
