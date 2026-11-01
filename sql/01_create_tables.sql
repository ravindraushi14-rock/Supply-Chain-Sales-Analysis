-- =====================================================================
-- 01_create_tables.sql   (PostgreSQL)  -  STAR SCHEMA
-- dim_customer  1 ──< fact_order_lines >── 1  dim_product
-- Run by python/step03_load_to_sql.py, or in pgAdmin's Query Tool.
-- Re-running is safe: CASCADE also drops the views built on these tables.
-- =====================================================================

DROP TABLE IF EXISTS fact_order_lines CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;

CREATE TABLE dim_customer (
    customer_id       INTEGER PRIMARY KEY,
    customer_fname    VARCHAR(50),
    customer_lname    VARCHAR(50),
    customer_segment  VARCHAR(20),          -- Consumer, Corporate, Home Office
    customer_city     VARCHAR(60),
    customer_state    VARCHAR(10),
    customer_country  VARCHAR(30),
    customer_zipcode  VARCHAR(10)
);

CREATE TABLE dim_product (
    product_id       INTEGER PRIMARY KEY,
    product_name     VARCHAR(120),
    unit_price       NUMERIC(10, 2),
    category_id      INTEGER,
    category_name    VARCHAR(60),
    department_id    INTEGER,
    department_name  VARCHAR(40)
);

CREATE TABLE fact_order_lines (
    order_item_id       INTEGER PRIMARY KEY,
    order_id            INTEGER NOT NULL,
    customer_id         INTEGER NOT NULL REFERENCES dim_customer (customer_id),
    product_id          INTEGER NOT NULL REFERENCES dim_product (product_id),
    order_date          TIMESTAMP NOT NULL,
    order_day           DATE NOT NULL,
    ship_date           TIMESTAMP NOT NULL,
    year                INTEGER,
    month               CHAR(7),                 -- 'YYYY-MM'
    payment_type        VARCHAR(10),
    order_status        VARCHAR(20),
    shipping_mode       VARCHAR(20),             -- Same Day, First, Second, Standard Class
    delivery_status     VARCHAR(20),
    days_real           INTEGER CHECK (days_real >= 0),
    days_scheduled      INTEGER CHECK (days_scheduled >= 0),
    sla_gap_days        INTEGER,                 -- days_real - days_scheduled (+ = late vs promise)
    is_shipped          BOOLEAN,
    is_suspected_fraud  BOOLEAN,
    is_late             BOOLEAN,
    is_on_time          BOOLEAN,
    market              VARCHAR(20),
    order_region        VARCHAR(30),
    order_country       VARCHAR(40),
    order_state         VARCHAR(60),
    order_city          VARCHAR(60),
    latitude            NUMERIC(10, 6),
    longitude           NUMERIC(10, 6),
    quantity            INTEGER CHECK (quantity > 0),
    sales               NUMERIC(12, 2) CHECK (sales >= 0),   -- gross: price x quantity
    discount            NUMERIC(12, 2),
    discount_rate       NUMERIC(5, 3),
    net_sales           NUMERIC(12, 2),                      -- after discount
    profit              NUMERIC(12, 2),
    profit_ratio        NUMERIC(6, 3),
    in_scope            BOOLEAN,                 -- 2015-2017 reporting scope
    period_flag         VARCHAR(30)
);

CREATE INDEX idx_fol_order_day ON fact_order_lines (order_day);
CREATE INDEX idx_fol_customer  ON fact_order_lines (customer_id);
CREATE INDEX idx_fol_product   ON fact_order_lines (product_id);
CREATE INDEX idx_fol_order     ON fact_order_lines (order_id);
