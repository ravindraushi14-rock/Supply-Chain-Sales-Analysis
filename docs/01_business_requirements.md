# 01 · Business Requirements

## Background
DataCo sells sporting goods, apparel, fitness and technology products through five markets (Europe, LATAM, Pacific Asia, USCA, Africa). Orders ship in four service levels: Same Day, First Class, Second Class and Standard Class. Leadership saw high late-delivery rates and a confusing 2017 picture (sales down, customers up) but had no single trusted view.

## Objectives
| # | Objective | Success measure |
| --- | --- | --- |
| O1 | One trusted dataset | Clean star schema in PostgreSQL, every fix logged |
| O2 | Executive performance view | Sales, profit, margin, orders, customers and AOV, with YoY |
| O3 | Diagnose late delivery | Promise vs actual by shipping mode, gap distribution, region view |
| O4 | Explain 2017 growth | Full-year vs like-for-like (Jan–Sep) comparison |
| O5 | Find margin leaks | Product Pareto (ABC), category margin, discount impact, loss-making customers |
| O6 | Flag risk | Suspected fraud by payment type, order-status funnel |
| O7 | Repeatable and shareable | One-command pipeline, Power BI on PostgreSQL, public web dashboard |

## Stakeholders
| Role | Needs |
| --- | --- |
| CEO / Sales head | Growth, margin, market performance |
| Logistics / Operations head | On-time %, lead time, SLA gaps by mode and region |
| Category managers | Product concentration, category margin, discount policy |
| Finance / Risk | Loss-making customers, fraud exposure |
| Analytics team | Documented, auditable, refreshable pipeline |

## KPI definitions
| KPI | Definition |
| --- | --- |
| Sales | `SUM(sales)`: price × quantity, before discount |
| Profit / Margin % | `SUM(profit)` / Sales |
| Orders / Customers | Distinct `order_id` / `customer_id` |
| Avg Order Value | Sales ÷ Orders |
| Late % | Late lines ÷ **shipped** lines (cancelled and suspected-fraud orders never ship) |
| On-time % | (On time + Advance) lines ÷ shipped lines |
| Avg lead time | Average `days_real` on shipped lines |
| SLA gap | `days_real − days_scheduled` (positive = later than promised) |
| YoY (YTD) | Year to date vs the same dates of the previous year |
| Like-for-like | January–September only, to remove the Q4-2017 data change |

## Scope
- **In scope:** orders 1 Jan 2015 – 31 Dec 2017 (178,396 lines, 63,629 orders, 18,529 customers).
- **Excluded:** January 2018 (a partial month, 2,123 lines). It is kept in the database with `in_scope = FALSE`.
- **Assumption:** both date formats in the raw file are month-first (verified: no shipment before its order date).
