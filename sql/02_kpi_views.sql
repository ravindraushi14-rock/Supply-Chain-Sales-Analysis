-- =====================================================================
-- 02_kpi_views.sql   (PostgreSQL)
-- Views recalculate on every read, so KPIs are always current.
-- All views use the 2015-2017 reporting scope (in_scope = TRUE).
-- Delivery KPIs use shipped orders only (is_shipped = TRUE).
-- =====================================================================

-- ---------------------------------------------------------------------
-- v_fact_order_lines: one wide row per order line for Power BI.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_fact_order_lines AS
SELECT f.*,
       c.customer_segment, c.customer_state, c.customer_city,
       p.product_name, p.category_name, p.department_name,
       CASE WHEN f.discount_rate < 0.05 THEN '00-04%'
            WHEN f.discount_rate < 0.10 THEN '05-09%'
            WHEN f.discount_rate < 0.15 THEN '10-14%'
            WHEN f.discount_rate < 0.20 THEN '15-19%'
            ELSE '20-25%' END                                        AS discount_band
FROM fact_order_lines f
JOIN dim_customer c USING (customer_id)
JOIN dim_product  p USING (product_id)
WHERE f.in_scope;

-- ---------------------------------------------------------------------
-- v_kpi_by_year: the executive KPI cards.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_kpi_by_year AS
SELECT year,
       SUM(sales)                                                     AS sales,
       SUM(profit)                                                    AS profit,
       ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2)          AS margin_pct,
       COUNT(DISTINCT order_id)                                       AS orders,
       COUNT(DISTINCT customer_id)                                    AS customers,
       ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)                AS avg_order_value,
       ROUND(100.0 * AVG(is_late::int)    FILTER (WHERE is_shipped), 2) AS late_pct,
       ROUND(100.0 * AVG(is_on_time::int) FILTER (WHERE is_shipped), 2) AS on_time_pct,
       ROUND(AVG(days_real) FILTER (WHERE is_shipped), 2)              AS avg_lead_time_days
FROM fact_order_lines
WHERE in_scope
GROUP BY year
ORDER BY year;

-- ---------------------------------------------------------------------
-- v_yoy: year-over-year change for every KPI (LAG window function).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_yoy AS
SELECT year, sales, profit, orders, customers, avg_order_value, late_pct,
       ROUND(100.0 * (sales  / LAG(sales)  OVER w - 1), 2)            AS sales_yoy_pct,
       ROUND(100.0 * (profit / LAG(profit) OVER w - 1), 2)            AS profit_yoy_pct,
       ROUND(100.0 * (orders::numeric / LAG(orders) OVER w - 1), 2)   AS orders_yoy_pct,
       ROUND(100.0 * (customers::numeric / LAG(customers) OVER w - 1), 2) AS customers_yoy_pct,
       ROUND(100.0 * (avg_order_value / LAG(avg_order_value) OVER w - 1), 2) AS aov_yoy_pct,
       ROUND(late_pct - LAG(late_pct) OVER w, 2)                      AS late_change_pts
FROM v_kpi_by_year
WINDOW w AS (ORDER BY year);

-- ---------------------------------------------------------------------
-- v_like_for_like: Jan-Sep of each year (removes the Q4-2017 data change).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_like_for_like AS
SELECT year,
       SUM(sales)                                    AS sales_jan_sep,
       SUM(profit)                                   AS profit_jan_sep,
       COUNT(DISTINCT order_id)                      AS orders_jan_sep,
       COUNT(DISTINCT customer_id)                   AS customers_jan_sep,
       ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS aov_jan_sep
FROM fact_order_lines
WHERE in_scope AND EXTRACT(MONTH FROM order_date) <= 9
GROUP BY year
ORDER BY year;

-- ---------------------------------------------------------------------
-- v_monthly_trend
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_monthly_trend AS
SELECT month,
       SUM(sales)                                                     AS sales,
       SUM(profit)                                                    AS profit,
       COUNT(DISTINCT order_id)                                       AS orders,
       ROUND(100.0 * AVG(is_late::int) FILTER (WHERE is_shipped), 2)   AS late_pct
FROM fact_order_lines
WHERE in_scope
GROUP BY month
ORDER BY month;

-- ---------------------------------------------------------------------
-- v_shipping_sla: promise vs reality per shipping mode (the core supply-chain view).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_shipping_sla AS
SELECT shipping_mode,
       COUNT(DISTINCT order_id)                                        AS orders,
       ROUND(AVG(days_scheduled), 2)                                   AS promised_days,
       ROUND(AVG(days_real), 2)                                        AS actual_days,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_real)          AS median_actual_days,
       ROUND(AVG(sla_gap_days), 2)                                     AS avg_gap_days,
       ROUND(100.0 * AVG(is_late::int), 2)                             AS late_pct,
       SUM(sales)                                                      AS sales
FROM fact_order_lines
WHERE in_scope AND is_shipped
GROUP BY shipping_mode
ORDER BY late_pct DESC;

-- ---------------------------------------------------------------------
-- v_market_performance: commercial and delivery view by market.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_market_performance AS
SELECT market,
       SUM(sales)                                                      AS sales,
       SUM(profit)                                                     AS profit,
       ROUND(100.0 * SUM(profit) / SUM(sales), 2)                      AS margin_pct,
       COUNT(DISTINCT order_id)                                        AS orders,
       ROUND(100.0 * AVG(is_late::int) FILTER (WHERE is_shipped), 2)    AS late_pct,
       ROUND(100.0 * SUM(sales) / SUM(SUM(sales)) OVER (), 2)          AS share_of_sales_pct
FROM fact_order_lines
WHERE in_scope
GROUP BY market
ORDER BY sales DESC;

-- ---------------------------------------------------------------------
-- v_category_performance
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_category_performance AS
SELECT p.department_name, p.category_name,
       SUM(f.sales)                                                    AS sales,
       SUM(f.profit)                                                   AS profit,
       ROUND(100.0 * SUM(f.profit) / SUM(f.sales), 2)                  AS margin_pct,
       SUM(f.quantity)                                                 AS units
FROM fact_order_lines f
JOIN dim_product p USING (product_id)
WHERE f.in_scope
GROUP BY p.department_name, p.category_name
ORDER BY sales DESC;

-- ---------------------------------------------------------------------
-- v_product_abc: Pareto / ABC classification (A = products that make the first 80% of sales).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_product_abc AS
WITH p AS (
    SELECT d.product_name, d.category_name, SUM(f.sales) AS sales, SUM(f.profit) AS profit
    FROM fact_order_lines f JOIN dim_product d USING (product_id)
    WHERE f.in_scope
    GROUP BY d.product_name, d.category_name
), r AS (
    SELECT p.*,
           RANK() OVER (ORDER BY sales DESC)                                        AS sales_rank,
           100.0 * SUM(sales) OVER (ORDER BY sales DESC ROWS UNBOUNDED PRECEDING)
                 / SUM(sales) OVER ()                                               AS cum_share_pct,
           100.0 * (SUM(sales) OVER (ORDER BY sales DESC ROWS UNBOUNDED PRECEDING) - sales)
                 / SUM(sales) OVER ()                                               AS prev_cum_pct
    FROM p
)
SELECT product_name, category_name, sales, profit, sales_rank,
       ROUND(cum_share_pct, 2) AS cum_share_pct,
       -- a product is A if the products ranked above it have not yet reached 80%
       CASE WHEN prev_cum_pct < 80 THEN 'A'
            WHEN prev_cum_pct < 95 THEN 'B'
            ELSE 'C' END        AS abc_class
FROM r
ORDER BY sales_rank;

-- ---------------------------------------------------------------------
-- v_customer_profitability: each customer's total, flagged if loss-making.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_customer_profitability AS
SELECT c.customer_id, c.customer_segment,
       COUNT(DISTINCT f.order_id)      AS orders,
       SUM(f.sales)                    AS sales,
       SUM(f.profit)                   AS profit,
       SUM(f.profit) < 0               AS is_loss_making
FROM fact_order_lines f
JOIN dim_customer c USING (customer_id)
WHERE f.in_scope
GROUP BY c.customer_id, c.customer_segment;

-- ---------------------------------------------------------------------
-- v_discount_impact: does discounting buy volume or destroy margin?
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_discount_impact AS
SELECT discount_band,
       COUNT(*)                                        AS lines,
       SUM(sales)                                      AS sales,
       ROUND(100.0 * SUM(profit) / SUM(sales), 2)      AS margin_pct,
       ROUND(100.0 * AVG((profit < 0)::int), 2)        AS loss_line_pct
FROM v_fact_order_lines
GROUP BY discount_band
ORDER BY discount_band;

-- ---------------------------------------------------------------------
-- v_order_status: the order funnel (incl. fraud and cancellations).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_order_status AS
SELECT order_status,
       COUNT(DISTINCT order_id)                                        AS orders,
       SUM(sales)                                                      AS sales,
       ROUND(100.0 * COUNT(DISTINCT order_id)
             / SUM(COUNT(DISTINCT order_id)) OVER (), 2)               AS share_pct
FROM fact_order_lines
WHERE in_scope
GROUP BY order_status
ORDER BY orders DESC;
