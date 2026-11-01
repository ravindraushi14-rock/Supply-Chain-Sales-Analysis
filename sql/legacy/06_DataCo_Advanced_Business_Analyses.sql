-- =====================================================================
-- DataCo Supply Chain & Sales Analytics
-- 06_DataCo_Advanced_Business_Analyses.sql   (queries 31-42)
--
-- Continues 05_DataCo_30_SQL_Business_Analyses.sql.
-- Covers the analyses that the SQL report describes but the 30-query file
-- does not contain: yearly KPIs, YoY, data-structure checks, late delivery
-- (line vs order level), loss-making customers, Second Class SLA.
--
-- Database : dataco_supply_chain      Table : dataco_raw (PostgreSQL)
-- Scope    : dashboard scope = orders from 2015-01-01 to 2017-12-31
--
-- Every query below was run on the full 180,519-row table and its result
-- compared with an independent Pandas calculation (see
-- docs/DATA_VERIFICATION_REPORT.md).
-- =====================================================================


-- ---------------------------------------------------------------------
-- STEP 0. Clean view with a real DATE column
-- Use ONE of the two options, depending on the column type in your table.
-- ---------------------------------------------------------------------

-- Option A: "order date (DateOrders)" is stored as TEXT like '1/31/2018 22:56'
CREATE OR REPLACE VIEW dataco_clean AS
SELECT r.*,
       TO_TIMESTAMP(r."order date (DateOrders)", 'MM/DD/YYYY HH24:MI')::date AS order_date
FROM dataco_raw r;

-- Option B: the column is already a TIMESTAMP / DATE
-- CREATE OR REPLACE VIEW dataco_clean AS
-- SELECT r.*, r."order date (DateOrders)"::date AS order_date
-- FROM dataco_raw r;

-- Quick check: should return 2015-01-01 and 2018-01-31
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order FROM dataco_clean;


-- ================= ANALYSIS 31 =================
-- Problem: Yearly KPIs (dashboard scope 2015-2017, plus 2018 partial month)
SELECT EXTRACT(YEAR FROM order_date)::int                              AS order_year,
       ROUND(SUM("Sales")::numeric, 0)                                 AS total_sales,
       ROUND(SUM("Order Profit Per Order")::numeric, 0)                AS total_profit,
       COUNT(DISTINCT "Order Id")                                      AS total_orders,
       COUNT(DISTINCT "Customer Id")                                   AS total_customers,
       ROUND((SUM("Sales") / COUNT(DISTINCT "Order Id"))::numeric, 2)  AS aov,
       ROUND((100 * SUM("Order Profit Per Order") / SUM("Sales"))::numeric, 2) AS profit_margin_pct,
       ROUND((100 * AVG("Late_delivery_risk"))::numeric, 2)            AS late_delivery_pct
FROM dataco_clean
GROUP BY 1
ORDER BY 1;


-- ================= ANALYSIS 32 =================
-- Problem: Year-over-Year change, 2017 vs 2016 (matches the dashboard "vs PY" labels)
WITH y AS (
    SELECT EXTRACT(YEAR FROM order_date)::int AS yr,
           SUM("Sales")                        AS sales,
           SUM("Order Profit Per Order")       AS profit,
           COUNT(DISTINCT "Order Id")          AS orders,
           COUNT(DISTINCT "Customer Id")       AS customers,
           SUM("Sales") / COUNT(DISTINCT "Order Id")             AS aov,
           SUM("Order Profit Per Order") / SUM("Sales")          AS margin,
           AVG("Late_delivery_risk")                             AS late
    FROM dataco_clean
    WHERE order_date <= DATE '2017-12-31'
    GROUP BY 1
), z AS (
    SELECT *,
           LAG(sales)     OVER (ORDER BY yr) AS sales_py,
           LAG(profit)    OVER (ORDER BY yr) AS profit_py,
           LAG(orders)    OVER (ORDER BY yr) AS orders_py,
           LAG(customers) OVER (ORDER BY yr) AS customers_py,
           LAG(aov)       OVER (ORDER BY yr) AS aov_py,
           LAG(margin)    OVER (ORDER BY yr) AS margin_py,
           LAG(late)      OVER (ORDER BY yr) AS late_py
    FROM y
)
SELECT yr,
       ROUND((100 * (sales / sales_py - 1))::numeric, 2)         AS sales_yoy_pct,
       ROUND((100 * (profit / profit_py - 1))::numeric, 2)       AS profit_yoy_pct,
       ROUND((100 * (orders::numeric / orders_py - 1)), 2)       AS orders_yoy_pct,
       ROUND((100 * (customers::numeric / customers_py - 1)), 2) AS customers_yoy_pct,
       ROUND((100 * (aov / aov_py - 1))::numeric, 2)             AS aov_yoy_pct,
       ROUND((100 * (margin / margin_py - 1))::numeric, 2)       AS margin_relative_change_pct,
       ROUND((100 * (margin - margin_py))::numeric, 2)           AS margin_change_in_pp,
       ROUND((100 * (late / late_py - 1))::numeric, 2)           AS late_yoy_pct
FROM z
WHERE yr = 2017;


-- ================= ANALYSIS 33 =================
-- Problem: Data-structure check by month (order lines per order, orders per customer,
--          first-time customers). Read this before trusting any 2017 trend.
WITH first_order AS (
    SELECT "Customer Id" AS cust, DATE_TRUNC('month', MIN(order_date))::date AS first_month
    FROM dataco_clean
    GROUP BY 1
), m AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           COUNT(*)                              AS order_lines,
           COUNT(DISTINCT "Order Id")            AS orders,
           COUNT(DISTINCT "Customer Id")         AS customers,
           SUM("Sales")                          AS sales
    FROM dataco_clean
    GROUP BY 1
)
SELECT m.month,
       m.orders,
       ROUND((m.order_lines::numeric / m.orders), 2)   AS lines_per_order,
       ROUND((m.orders::numeric / m.customers), 2)     AS orders_per_customer,
       ROUND((m.sales / m.orders)::numeric, 0)         AS aov,
       COALESCE(f.new_customers, 0)                    AS first_time_customers
FROM m
LEFT JOIN (SELECT first_month, COUNT(*) AS new_customers FROM first_order GROUP BY 1) f
       ON f.first_month = m.month
WHERE m.month >= DATE '2016-06-01'
ORDER BY m.month;


-- ================= ANALYSIS 34 =================
-- Problem: Like-for-like YoY (January-September only), 2017 vs 2016
WITH y AS (
    SELECT EXTRACT(YEAR FROM order_date)::int AS yr,
           SUM("Sales") AS sales, SUM("Order Profit Per Order") AS profit,
           COUNT(DISTINCT "Order Id") AS orders, COUNT(DISTINCT "Customer Id") AS customers,
           SUM("Sales") / COUNT(DISTINCT "Order Id") AS aov,
           SUM("Order Profit Per Order") / SUM("Sales") AS margin
    FROM dataco_clean
    WHERE EXTRACT(MONTH FROM order_date) <= 9
      AND EXTRACT(YEAR FROM order_date) IN (2016, 2017)
    GROUP BY 1
)
SELECT ROUND((100 * (a.sales  / b.sales  - 1))::numeric, 2)     AS sales_yoy_pct,
       ROUND((100 * (a.profit / b.profit - 1))::numeric, 2)     AS profit_yoy_pct,
       ROUND((100 * (a.orders::numeric / b.orders - 1)), 2)       AS orders_yoy_pct,
       ROUND((100 * (a.customers::numeric / b.customers - 1)), 2) AS customers_yoy_pct,
       ROUND((100 * (a.aov / b.aov - 1))::numeric, 2)           AS aov_yoy_pct
FROM y a JOIN y b ON a.yr = 2017 AND b.yr = 2016;


-- ================= ANALYSIS 35 =================
-- Problem: How concentrated is each month on one Market? (market vs time check)
WITH mm AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month, "Market", SUM("Sales") AS sales
    FROM dataco_clean
    WHERE order_date <= DATE '2017-12-31'
    GROUP BY 1, 2
), t AS (
    SELECT month, "Market", sales,
           sales / SUM(sales) OVER (PARTITION BY month) AS share,
           ROW_NUMBER() OVER (PARTITION BY month ORDER BY sales DESC) AS rn
    FROM mm
)
SELECT month,
       "Market"                              AS top_market,
       ROUND((100 * share)::numeric, 1)      AS top_market_share_pct
FROM t
WHERE rn = 1
ORDER BY month;


-- ================= ANALYSIS 36 =================
-- Problem: Late Delivery % by Shipping Mode, line level vs order level (2015-2017)
-- Line level  = share of order lines flagged late  (this is what the Power BI measure uses)
-- Order level = share of orders with at least one late line
WITH base AS (
    SELECT * FROM dataco_clean WHERE order_date <= DATE '2017-12-31'
), line_level AS (
    SELECT "Shipping Mode", 100 * AVG("Late_delivery_risk") AS late_pct_line
    FROM base GROUP BY 1
), order_level AS (
    SELECT "Shipping Mode", 100 * AVG(late) AS late_pct_order, COUNT(*) AS orders
    FROM (SELECT "Order Id", "Shipping Mode", MAX("Late_delivery_risk") AS late
          FROM base GROUP BY 1, 2) o
    GROUP BY 1
)
SELECT l."Shipping Mode",
       ROUND(l.late_pct_line::numeric, 2)  AS late_pct_line_level,
       ROUND(o.late_pct_order::numeric, 2) AS late_pct_order_level,
       o.orders
FROM line_level l JOIN order_level o USING ("Shipping Mode")
ORDER BY late_pct_line_level DESC;


-- ================= ANALYSIS 37 =================
-- Problem: Loss-making customers (customer total profit < 0), 2015-2017
WITH cust AS (
    SELECT "Customer Id" AS cust, SUM("Sales") AS sales, SUM("Order Profit Per Order") AS profit
    FROM dataco_clean
    WHERE order_date <= DATE '2017-12-31'
    GROUP BY 1
), tot AS (
    SELECT SUM("Sales") AS sales, SUM("Order Profit Per Order") AS profit
    FROM dataco_clean WHERE order_date <= DATE '2017-12-31'
)
SELECT COUNT(*)                                                  AS loss_making_customers,
       ROUND((SUM(c.sales) / 1e6)::numeric, 2)                   AS sales_millions,
       ROUND((SUM(c.profit) / 1e6)::numeric, 2)                  AS profit_millions,
       ROUND((100 * SUM(c.sales) / MAX(t.sales))::numeric, 2)    AS pct_of_total_sales,
       ROUND((100 * -SUM(c.profit) / MAX(t.profit))::numeric, 2) AS loss_as_pct_of_total_profit
FROM cust c CROSS JOIN tot t
WHERE c.profit < 0;


-- ================= ANALYSIS 38 =================
-- Problem: Loss-making customers by Customer Segment
WITH cust AS (
    SELECT "Customer Id" AS cust, MIN("Customer Segment") AS segment,
           SUM("Sales") AS sales, SUM("Order Profit Per Order") AS profit
    FROM dataco_clean
    WHERE order_date <= DATE '2017-12-31'
    GROUP BY 1
)
SELECT segment,
       COUNT(*)                                       AS loss_making_customers,
       ROUND((SUM(sales) / 1e6)::numeric, 2)          AS sales_millions,
       ROUND((SUM(profit) / 1e6)::numeric, 2)         AS profit_millions,
       ROUND((100 * SUM(profit) / SUM(sales))::numeric, 2) AS loss_margin_pct
FROM cust
WHERE profit < 0
GROUP BY segment
ORDER BY profit_millions;


-- ================= ANALYSIS 39 =================
-- Problem: Loss-making customer-market relationships by Market
-- NOTE: a customer can order in more than one market, so these counts add up to
--       more than the 3,660 customers in Analysis 37. Label them "customer-market
--       relationships", not "customers".
WITH cm AS (
    SELECT "Customer Id" AS cust, "Market", SUM("Sales") AS sales, SUM("Order Profit Per Order") AS profit
    FROM dataco_clean
    WHERE order_date <= DATE '2017-12-31'
    GROUP BY 1, 2
)
SELECT "Market",
       COUNT(*)                                       AS loss_making_relationships,
       ROUND((SUM(sales) / 1e6)::numeric, 2)          AS sales_millions,
       ROUND((SUM(profit) / 1e6)::numeric, 2)         AS profit_millions,
       ROUND((100 * SUM(profit) / SUM(sales))::numeric, 2) AS loss_margin_pct
FROM cm
WHERE profit < 0
GROUP BY "Market"
ORDER BY loss_making_relationships DESC;


-- ================= ANALYSIS 40 =================
-- Problem: Second Class SLA investigation (order level, 2015-2017)
WITH o AS (
    SELECT "Order Id",
           MAX("Days for shipping (real)")      AS actual_days,
           MAX("Days for shipment (scheduled)") AS scheduled_days,
           MAX("Late_delivery_risk")            AS late
    FROM dataco_clean
    WHERE order_date <= DATE '2017-12-31' AND "Shipping Mode" = 'Second Class'
    GROUP BY 1
)
SELECT COUNT(*)                                                             AS orders,
       MAX(scheduled_days)                                                  AS scheduled_days,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY actual_days)             AS median_actual_days,
       ROUND((100 * AVG(late))::numeric, 2)                                 AS late_pct_flagged,
       ROUND((100 * AVG((actual_days > scheduled_days)::int))::numeric, 2)  AS pct_actual_above_schedule,
       ROUND((100 * AVG((actual_days >= 5)::int))::numeric, 2)              AS pct_5_to_6_days,
       ROUND((100 * AVG((actual_days > 4)::int))::numeric, 2)               AS late_pct_if_sla_were_4_days,
       ROUND((100 * (AVG(late) - AVG((actual_days > 4)::int)))::numeric, 2) AS reduction_in_pp,
       ROUND((COUNT(*) * (AVG(late) - AVG((actual_days > 4)::int)))::numeric, 0) AS orders_no_longer_late
FROM o;


-- ================= ANALYSIS 41 =================
-- Problem: How many products and categories are sold each month?
-- (If the number jumps, month-to-month "declines" may just be products rotating.)
SELECT DATE_TRUNC('month', order_date)::date AS month,
       COUNT(DISTINCT "Product Name")        AS products_sold,
       COUNT(DISTINCT "Category Name")       AS categories_sold,
       COUNT(DISTINCT "Market")              AS markets_active
FROM dataco_clean
WHERE order_date >= DATE '2017-01-01'
GROUP BY 1
ORDER BY 1;


-- ================= ANALYSIS 42 =================
-- Problem: How many orders lose money? (order total profit < 0), 2015-2017
WITH o AS (
    SELECT "Order Id", SUM("Order Profit Per Order") AS profit, SUM("Sales") AS sales
    FROM dataco_clean
    WHERE order_date <= DATE '2017-12-31'
    GROUP BY 1
)
SELECT COUNT(*) FILTER (WHERE profit < 0)                                    AS loss_orders,
       COUNT(*)                                                              AS all_orders,
       ROUND((100.0 * COUNT(*) FILTER (WHERE profit < 0) / COUNT(*))::numeric, 2) AS loss_orders_pct,
       ROUND((SUM(profit) FILTER (WHERE profit < 0) / 1e6)::numeric, 2)      AS loss_profit_millions
FROM o;
