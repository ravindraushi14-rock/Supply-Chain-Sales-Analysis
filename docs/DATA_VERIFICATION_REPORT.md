# Data Verification Report

Every number in the project documents was recomputed from the data inside `Supply Chain & Sales Analysis.pbix` (180,519 order lines, 53 source columns), once with Pandas and once with SQL (`sql/06_DataCo_Advanced_Business_Analyses.sql`). Dashboard scope = orders from **01-Jan-2015 to 31-Dec-2017** (178,396 lines, 63,629 orders, 18,529 customers).

## 1. Confirmed (matches the documents and the dashboard)

| Item | Result |
|---|---|
| KPI cards | Sales 36.45M, Profit 3.93M, Orders 63,629, Customers 18,529, AOV 572.90, Margin 10.79%, Late 54.81% |
| Full-dataset (Python scope) | Sales 36.78M, Profit 3.97M, Orders 65,752, Customers 20,652, AOV 559.45, Margin 10.78%, Late 54.83% |
| Annual table 2015 / 2016 / 2017 | Sales 12.34M / 12.30M / 11.81M, Orders 20,904 / 20,859 / 21,866, Customers 10,131 / 10,222 / 15,156, AOV 590.36 / 589.86 / 540.04 |
| YoY cards (2017 vs 2016) | Sales -4.03%, Profit -0.46%, Orders +4.83%, Customers +48.27%, AOV -8.45%, Margin +3.72% (relative), Late -1.13% |
| Market, Segment, Category, Product tables | All match the documents (for example Europe 10.87M / 10.76% margin) |
| Loss-making customers | 3,660 customers, 7.05M sales, -1.04M profit, 19.34% of sales, loss = 26.55% of profit |
| Loss-making by segment | Consumer 1,885, Corporate 1,090, Home Office 685 |
| Second Class | Median actual 4 days vs 2 scheduled; 79.89% of orders take longer than scheduled; 40.07% take 5-6 days |
| First Class | Scheduled 1 day, actual 2 days for 100% of lines |

## 2. Findings that change how the story should be told

### F1. The data changes structure in October 2017

| Period | Order lines per order | Orders per customer | First-time customers per month | AOV |
|---|---|---|---|---|
| Jan 2015 - Sep 2017 | about 3.0 | about 1.07 | 13 to 176 (total 304 in Jan-Sep 2017) | 579 to 664 |
| Oct 2017 | 1.07 | 1.00 | 2,020 | 511 |
| Nov 2017 | 1.00 | 1.00 | 2,055 | 305 |
| Dec 2017 | 1.00 | 1.00 | 2,124 | 237 |
| Jan 2018 | 1.00 | 1.00 | 2,123 | 156 |

From October 2017 every order has exactly one item and comes from a customer who has never ordered before.

What this does to the headline numbers (2017 vs 2016):

| KPI | Full year | Jan-Sep only (like for like) |
|---|---|---|
| Sales | -4.0% | **+4.7%** |
| Profit | -0.5% | **+8.0%** |
| Orders | +4.8% | -0.1% |
| Customers | **+48.3%** | -0.2% |
| AOV | **-8.4%** | **+4.8%** |
| Profit margin (relative) | +3.7% | +3.1% |

6,199 of the 15,156 customers in 2017 placed their first order in the last three months. The chain "Customers up, Orders up, AOV down, Sales down" comes from those three months only. The data cannot say why. Either the business really changed, or the public dataset was assembled in blocks. Both are possible, so the project should say so openly and show both views.

### F2. Market and time are mixed together

- In **27 of 36 months** one market has more than 95% of the month's sales.
- Each market appears in only part of the period: Europe 18 months, Pacific Asia 15, LATAM 11, USCA 10, Africa 6.
- Products sold per month: 42 to 54 until Sep 2017, then 20 (Oct), 8 (Nov), 14 (Dec).

So market totals partly show how many months a market is present, and month-to-month changes are often products or markets switching on and off.

The "Europe / Consumer decline" drill-down in the SQL report and in `11_Business_Recommendations` was reproduced exactly (Computers -0.27M, Cameras -0.14M, Children's Clothing -0.09M, Dell Laptop -0.27M, Web Camera -0.14M; offsets Crafts +0.06M, Consumer Electronics +0.03M, DVDs +0.02M). It is a comparison of **November 2017 with October 2017**, not 2017 with 2016. Compared with 2016, Europe Q4 sales actually rose (0.57M in Q4 2016 to 1.28M in Q4 2017), and Dell Laptop had no sales at all in Europe / Consumer in 2016.

### F3. Second Class SLA number is wrong in the documents

| | Documents | Recomputed (order level) |
|---|---|---|
| Late today | 76.70% | 76.70% |
| Late if SLA were 4 days | not stated | 40.07% |
| Reduction | 39.82 pp (about 4,911 orders) | **36.63 pp (4,518 orders)** |

39.82% is close to the share that stays late (40.07%), not the reduction. The conclusion (a 4-day SLA does not remove the 5-6 day group) stays correct.

### F4. "Late Delivery" has two definitions and two units

- The dashboard and DAX use `Late_delivery_risk` (line level). It is identical to `Delivery Status = "Late delivery"` in every row.
- `10_KPI_and_Business_Metrics_Dictionary` and `08_Technical_Appendix` define it as "actual days > scheduled days". That rule agrees with the model in only 97.5% of lines.
- Shipping-mode numbers differ because of the unit, not because of an error:

| Shipping mode | Dashboard (line level) | SQL report and documents (order level) | Python (full data, line level) |
|---|---|---|---|
| First Class | 95.29% | 95.18% | 95.32% |
| Second Class | 76.63% | 76.70% | 76.63% |
| Same Day | 45.79% | 46.31% | 45.74% |
| Standard Class | 38.06% | 38.10% | 38.07% |

### F5. Loss-making customers by market

The table in the SQL report (Europe 2,452, Pacific Asia 2,351, LATAM 1,981, USCA 1,344, Africa 688) adds up to 8,816, not 3,660. It counts customer-market pairs, because one customer can order in several markets. Call it "customer-market relationships".

### F6. The loss-making finding is solid

- Using only data before October 2017: 2,510 of 12,330 customers (20.4%) are loss-making, against 19.8% in the full scope.
- 13,499 of 63,629 orders (21.2%) lose money in total, about -2.58M.
- Only 3 products have negative total profit (about -1.4K in total), so "no major product-level margin outlier" is also correct.

## 3. Mismatches between repository files

| File | Problem |
|---|---|
| `05_DataCo_30_SQL_Business_Analyses.sql` | Does not contain YoY, loss-making customers, Second Class SLA, sales drill-down or date conversion described in the SQL report, README and Technical Appendix. #08 and #29 are the same query. #13 is called "loss-making products" but returns the 10 lowest-profit products. #21 uses LIMIT without ORDER BY. No date filter, so totals are 36.78M, not 36.45M. The new file `06_DataCo_Advanced_Business_Analyses.sql` adds the missing analyses. |
| `06_DataCo_DAX_Reference.dax` (old) | 14 measures; the model has 34. Names differ (`Average Order Value` vs `AOV`, `Customers PY` vs `Customer PY`). `Total Profit`, `Total Orders`, `Sales per Customer` are not in the model. PY measures use `SAMEPERIODLASTYEAR`; the model uses `DATESBETWEEN`. The new file is copied from the model. |
| `06A_DAX_Formula_Reference_Source.docx` | Says the code of AOV CY/PY, Customers YoY and others "was not preserved". It is all in the model. |
| `04A_Python_Code_&_Clean.py.docx` | Contains only a Pandas copy of the 30 SQL queries (30 empty "WHY WE USE" lines). The cleaning, feature engineering and IQR outlier code described in reports 03 and 04 is not in the repository. |
| Power BI model | Loads the raw PostgreSQL table directly (`localhost:5432`, no Power Query steps). The cleaned Python data is not used. 20+ unused columns, including customer names and street, are loaded. |
| `README.md` | Page names and folder structure do not match the repository or the dashboard. |

## 4. Text to correct in the documents

| File | Find | Replace with |
|---|---|---|
| `05_SQL_Business_Analysis_Report.docx` | `fileciteturn41file1` ... `turn41file7` (about 8 places) | delete |
| `05_SQL_Business_Analysis_Report.docx`, section 11 | "reduced the late classification by approximately 39.82 percentage points" | "reduced the late classification by approximately 36.6 percentage points (from 76.70% to 40.07%)" |
| `11_Business_Recommendations_and_Action_Plan.docx`, Action Area 06 and section 16 | "39.82 percentage points ... approximately 4,911 orders" | "36.63 percentage points ... approximately 4,518 orders" |
| `05_SQL_Business_Analysis_Report.docx` section 8 and `11_...` Action Area 03 | "Europe: Major late-2017 decline" | "Europe / Consumer, November 2017 compared with October 2017" and add the F2 note |
| `05_SQL_Business_Analysis_Report.docx` section 14 | "Loss-Making Customers by Market", column "Customers" | "Loss-making customer-market relationships" (note: adds to more than 3,660) |
| `06A_DAX_Formula_Reference_Source.docx` | "Do not worry: ..." sentence; "I have not silently presented ..."; "available to me"; section 7 "Interview Memory"; list of source files that are not in the repository | delete, and replace sections 4-5 with the measures from `06_DataCo_DAX_Reference.dax` |
| `10_KPI_and_Business_Metrics_Dictionary.docx` | "Late Delivery % = Late Orders / Total Orders"; "Late Delivery Flag = Actual Days > Scheduled Days" | "Late Delivery % = share of order lines with Delivery Status 'Late delivery' (Late_delivery_risk = 1)"; add the line / order level note from F4 |
| `04A_Python_Code_&_Clean.py.docx` | 30 lines "WHY WE USE: ." | fill with one sentence each, or delete the line |
| `COPYRIGHT.md.` | file name with a trailing dot | rename to `COPYRIGHT.md` |
