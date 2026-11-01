# 03 · Data Quality Report

## Method
1. **Profile first** (`step01_load_and_explore.py`): shape, nulls, constant columns, duplicate columns, text spacing, date formats, value lists.
2. **One function per fix** (`step02_clean.py`), each printing before → after.
3. **Log** every fix to `data/clean/cleaning_log.csv`.
4. **Validate** automatically: unique keys, one description per customer and product, ship date ≥ order date, no negative sales or days, and KPIs reconciled to the Power BI dashboard.
5. **Enforce in PostgreSQL**: primary keys, foreign keys and `CHECK` constraints.

## Issues and fixes
| # | Issue | Scale | Fix | Why it matters |
| --- | --- | ---: | --- | --- |
| F1 | Duplicate columns (e.g. *Benefit per order* = *Order Profit Per Order*) | 6 columns | Equality asserted, then dropped | Avoids double counting and confusion in DAX |
| F2 | No-information columns: masked email/password, 100% blank description, constant status, image URLs, 86% blank order zip, *Late_delivery_risk* (copy of status) | 7 columns | Dropped | Smaller, clearer model |
| F3 | Column names with spaces and brackets | 40 | snake_case | Clean SQL and DAX |
| F4 | Leading/trailing/double spaces: `Smart watch `, `South of  USA` | 24,640 cells | Trimmed and collapsed | One product or region no longer splits into two |
| F5 | Two date formats: `1/31/2018 22:56` and `01-31-2018 22:56` | 71,103 rows use dashes | Mixed parsing, month-first | Correct monthly trends. Verified no ship date before its order date |
| F6 | Spanish country names (`Estados Unidos`, `Alemania`, `EE. UU.`) | 164 + 2 values | Reference table `country_translation.csv` | Readable reports. A new value stops the pipeline until added |
| F7 | Missing last name (8) and zip code (3) | 11 | Blank | No KPI impact |
| F8 | No business flags | – | `is_shipped`, `is_late`, `is_on_time`, `sla_gap_days`, `in_scope`, `period_flag` | Correct, consistent KPI logic |
| N1 | January 2018 holds only 2,123 lines | 2,123 | Flagged `in_scope = FALSE` | A partial month would distort trends and YoY |
| N2 | Late % counted cancelled and fraud orders | 7,754 lines | Late % on shipped lines only | **57.3%** true late rate vs 54.8% understated |

## Structural observations (flagged, not changed)
- **Q4-2017 change:** from October 2017 every order has one item and every customer is new. Full-year 2017 vs 2016 therefore shows sales −4.0% and customers +48.3%, while **Jan–Sep like-for-like shows sales +4.7%** and customers −0.2%. Rows are tagged `period_flag = 'Q4-2017 structure change'`.
- **Market × time:** in most months a single market carries over 95% of sales, so market totals partly reflect how many months each market is present.
- **Delivery status consistency:** shipping mode, delivery status and days are identical across all lines of an order (verified), so line-level and order-level delivery KPIs agree.

## Reconciliation with the Power BI dashboard (2015–2017)
| KPI | Power BI v1 | Pipeline |
| --- | ---: | ---: |
| Sales | 36.45M | 36.45M ✓ |
| Profit | 3.93M | 3.93M ✓ |
| Orders | 63,629 | 63,629 ✓ |
| Customers | 18,529 | 18,529 ✓ |
| Avg order value | 572.90 | 572.90 ✓ |
| Late % (all lines) | 54.81% | 54.81% ✓ (57.27% on shipped lines) |
