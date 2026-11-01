-- =====================================================================
-- 03_analysis_queries.sql   (PostgreSQL)  -  supply-chain business questions
-- In pgAdmin: Query Tool on supply_chain_db -> select ONE query -> F5.
-- Scope: 2015-2017 (in_scope). Delivery questions use shipped orders only.
-- =====================================================================

-- Q1. Executive summary: how big is the business and how reliable is delivery?
SELECT ROUND(SUM(sales) / 1e6, 2)                                       AS sales_m,
       ROUND(SUM(profit) / 1e6, 2)                                      AS profit_m,
       ROUND(100.0 * SUM(profit) / SUM(sales), 2)                       AS margin_pct,
       COUNT(DISTINCT order_id)                                         AS orders,
       COUNT(DISTINCT customer_id)                                      AS customers,
       ROUND(100.0 * AVG(is_late::int) FILTER (WHERE is_shipped), 2)     AS late_pct_shipped,
       ROUND(100.0 * AVG(is_late::int), 2)                              AS late_pct_all_lines
FROM fact_order_lines
WHERE in_scope;

-- Q2. Are delivery promises realistic? Promise vs reality by shipping mode.
SELECT shipping_mode, promised_days, actual_days, median_actual_days, avg_gap_days, late_pct
FROM v_shipping_sla;

-- Q3. How late is late? Distribution of days beyond the promise (shipped orders).
SELECT sla_gap_days,
       COUNT(*)                                                   AS lines,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)         AS share_pct
FROM fact_order_lines
WHERE in_scope AND is_shipped
GROUP BY sla_gap_days
ORDER BY sla_gap_days;

-- Q4. Second Class deep dive: how many orders take longer than scheduled?
SELECT days_real,
       COUNT(DISTINCT order_id)                                               AS orders,
       ROUND(100.0 * COUNT(DISTINCT order_id)
             / SUM(COUNT(DISTINCT order_id)) OVER (), 2)                      AS share_pct
FROM fact_order_lines
WHERE in_scope AND is_shipped AND shipping_mode = 'Second Class'
GROUP BY days_real
ORDER BY days_real;

-- Q5. Which market / region combinations have the worst delivery?
--     HAVING keeps only regions with enough orders to be meaningful.
SELECT market, order_region,
       COUNT(DISTINCT order_id)                                   AS orders,
       ROUND(100.0 * AVG(is_late::int), 2)                        AS late_pct
FROM fact_order_lines
WHERE in_scope AND is_shipped
GROUP BY market, order_region
HAVING COUNT(DISTINCT order_id) >= 1000
ORDER BY late_pct DESC
LIMIT 10;

-- Q6. Sales and profit by year with YoY (window function LAG).
SELECT year, sales, profit, sales_yoy_pct, profit_yoy_pct, orders_yoy_pct, customers_yoy_pct, aov_yoy_pct
FROM v_yoy;

-- Q7. Like-for-like: Jan-Sep 2017 vs Jan-Sep 2016 (removes the Q4-2017 data change).
SELECT year, sales_jan_sep, orders_jan_sep, customers_jan_sep, aov_jan_sep,
       ROUND(100.0 * (sales_jan_sep / LAG(sales_jan_sep) OVER (ORDER BY year) - 1), 2) AS sales_yoy_pct
FROM v_like_for_like;

-- Q8. Pareto: how many products make 80% of sales?
SELECT abc_class,
       COUNT(*)                                         AS products,
       ROUND(SUM(sales) / 1e6, 2)                       AS sales_m,
       ROUND(100.0 * SUM(sales) / SUM(SUM(sales)) OVER (), 2) AS share_pct
FROM v_product_abc
GROUP BY abc_class
ORDER BY abc_class;

-- Q9. Top 10 products by sales, with margin.
SELECT product_name, category_name, ROUND(sales) AS sales,
       ROUND(100.0 * profit / sales, 2) AS margin_pct, abc_class
FROM v_product_abc
ORDER BY sales_rank
LIMIT 10;

-- Q10. Loss-making customers: how many, and what do they cost?
SELECT COUNT(*) FILTER (WHERE is_loss_making)                              AS loss_customers,
       ROUND(SUM(sales)  FILTER (WHERE is_loss_making) / 1e6, 2)           AS their_sales_m,
       ROUND(SUM(profit) FILTER (WHERE is_loss_making) / 1e6, 2)           AS their_profit_m,
       ROUND(100.0 * SUM(sales) FILTER (WHERE is_loss_making) / SUM(sales), 2) AS share_of_sales_pct
FROM v_customer_profitability;

-- Q11. Does discounting pay? Margin and loss-making lines by discount band.
SELECT * FROM v_discount_impact;

-- Q12. Order funnel: how much value is stuck or lost (pending, on hold, fraud, cancelled)?
SELECT * FROM v_order_status;

-- Q13. Suspected fraud: where does it concentrate?
SELECT market, payment_type,
       COUNT(DISTINCT order_id) FILTER (WHERE is_suspected_fraud)              AS fraud_orders,
       ROUND(100.0 * COUNT(DISTINCT order_id) FILTER (WHERE is_suspected_fraud)
             / COUNT(DISTINCT order_id), 2)                                    AS fraud_rate_pct
FROM fact_order_lines
WHERE in_scope
GROUP BY market, payment_type
HAVING COUNT(DISTINCT order_id) FILTER (WHERE is_suspected_fraud) > 0
ORDER BY fraud_rate_pct DESC;

-- Q14. Cost of late delivery: sales and profit carried by late shipments, by segment.
SELECT c.customer_segment,
       ROUND(SUM(f.sales) FILTER (WHERE f.is_late) / 1e6, 2)                AS late_sales_m,
       ROUND(100.0 * SUM(f.sales) FILTER (WHERE f.is_late) / SUM(f.sales), 2) AS late_share_pct
FROM fact_order_lines f
JOIN dim_customer c USING (customer_id)
WHERE f.in_scope AND f.is_shipped
GROUP BY c.customer_segment
ORDER BY late_sales_m DESC;

-- Q15. Market x month concentration: why market totals partly reflect time.
SELECT month,
       (ARRAY_AGG(market ORDER BY s DESC))[1]                       AS top_market,
       ROUND(100.0 * MAX(s) / SUM(s), 1)                            AS top_market_share_pct
FROM (SELECT month, market, SUM(sales) AS s
      FROM fact_order_lines WHERE in_scope GROUP BY month, market) t
GROUP BY month
ORDER BY month;
