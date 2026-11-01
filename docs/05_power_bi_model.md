# 05 · Power BI Model

Two versions are in [`/powerbi`](../powerbi):

| | v1: `Supply Chain & Sales Analysis.pbix` | v2: `SupplyChain_Dashboard_v2.pbip` |
| --- | --- | --- |
| Built | By hand in Power BI Desktop, over 100+ hours | Generated as a Power BI Project (text files, Git-friendly) |
| Source | Raw CSV via Power Query | PostgreSQL view `v_fact_order_lines` |
| Pages | Overview, Sales & Customers, Delivery & Operations, Products, Insights | Executive Overview, Delivery & SLA, Products & Margin, Customers & Risk, Market Detail |
| Refresh | Re-import the CSV | `run_pipeline.py`, then **Refresh** |

## v2 data model
```
Calendar (Date) 1 ──< fact_order_lines (order_day)
_Measures        (53 measures in display folders)
Metric Selector  (field parameter: Sales · Profit · Orders · Late %)
```
- **Calendar:** DAX `CALENDAR(2015-01-01, 2017-12-31)` with Year, Month (sorted by MonthNo), Quarter and **Period** (Jan-Sep / Oct-Dec) for like-for-like slicing.
- **Power Query (M):** `PostgreSQL.Database("localhost", "supply_chain_db")`, selects 33 columns and sets every data type.

## Measure catalogue (53)
| Folder | Measures |
| --- | --- |
| Core | Total Sales, Sales ($M), Total Profit, Profit ($M), Profit Margin %, Total Orders, Total Customers, Avg Order Value, Units Sold, Avg Discount % |
| Delivery | Shipped Lines, Late %, On-Time %, Avg Lead Time (Days), Avg Promised Days, Avg SLA Gap (Days), Late Sales |
| Risk | Fraud Orders, Fraud Rate %, Loss-Making Customers, Loss Customers Profit, Loss Customers % |
| Growth | YoY for Sales, Profit, Margin, Orders, Customers, AOV, On-Time, Late, Lead Time, Fraud |
| Growth › Card labels | A label (`▲ +4.7% vs last year`) and a colour measure for each YoY. The colour logic knows that **lower is better** for Late %, Lead Time and Fraud |
| Labels | Report Subtitle |

### YoY logic (like-for-like dates)
```DAX
Sales YoY =
VAR _LastDay   = MAX(fact_order_lines[order_day])
VAR _YearStart = DATE(YEAR(_LastDay), 1, 1)
VAR _Cur  = CALCULATE([Total Sales], REMOVEFILTERS('Calendar'),
                      DATESBETWEEN('Calendar'[Date], _YearStart, _LastDay))
VAR _Prev = CALCULATE([Total Sales], REMOVEFILTERS('Calendar'),
                      DATESBETWEEN('Calendar'[Date], EDATE(_YearStart, -12), EDATE(_LastDay, -12)))
RETURN DIVIDE(_Cur - _Prev, _Prev)
```
With **Period = Jan-Sep** selected, the same measures give the like-for-like view (+4.7% sales).

### Loss-making customers
```DAX
Loss-Making Customers = COUNTROWS(FILTER(VALUES(fact_order_lines[customer_id]), [Total Profit] < 0))
```

## v2 pages
| Page | Visuals |
| --- | --- |
| Executive Overview | 5 slicers · 6 KPI cards with YoY · monthly trend (field parameter) · segment donut · sales by market and department · late % by market |
| Delivery & SLA | KPIs (on-time, late, lead time, promised, gap, late sales) · promise vs actual by mode · late % by mode · SLA gap distribution · late % by region |
| Products & Margin | KPIs · ranked product table · margin by category · margin by discount band |
| Customers & Risk | KPIs (loss customers, profit lost, fraud) · order status funnel · fraud rate by payment type · segment matrix · profit by market |
| Market Detail | Market › region matrix with 8 KPIs |

Theme: *Supply Chain Midnight*, a dark navy with a consistent colour per meaning: blue = sales, green = profit and good, red = late and bad, amber = warning.
