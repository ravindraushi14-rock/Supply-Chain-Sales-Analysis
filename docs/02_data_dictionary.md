# 02 · Data Dictionary

## Raw file: `DataCoSupplyChainDataset.csv`
180,519 rows × 53 columns, latin-1 encoding. One row = one order line.

| Group | Raw columns | Kept as |
| --- | --- | --- |
| Order | Order Id, Order Item Id, order date (DateOrders), Order Status, Type (payment) | order_id, order_item_id, order_date, order_status, payment_type |
| Shipping | shipping date, Shipping Mode, Days for shipping (real), Days for shipment (scheduled), Delivery Status, Late_delivery_risk | ship_date, shipping_mode, days_real, days_scheduled, delivery_status (*Late_delivery_risk dropped: a copy*) |
| Geography | Market, Order Region, Order Country, Order State, Order City, Latitude, Longitude, Order Zipcode | market, order_region, order_country (English), order_state, order_city, latitude, longitude (*zip dropped: 86% blank*) |
| Money | Sales, Order Item Total, Order Item Discount, Order Item Discount Rate, Order Profit Per Order, Order Item Profit Ratio, Order Item Quantity | sales, net_sales, discount, discount_rate, profit, profit_ratio, quantity |
| Customer | Customer Id, Fname, Lname, Segment, City, State, Country, Street, Zipcode, Email, Password | dim_customer (*email/password dropped: masked*) |
| Product | Product Card Id, Product Name, Product Price, Category Id/Name, Department Id/Name, Product Description, Product Image, Product Status | dim_product (*description, image, status dropped*) |
| Duplicates | Benefit per order, Sales per customer, Order Customer Id, Product Category Id, Order Item Cardprod Id, Order Item Product Price | dropped: each is identical to another column |

## Star schema (`supply_chain_db`)

```
dim_customer (20,652) 1 ──< fact_order_lines (180,519) >── 1 dim_product (118)
```

### `fact_order_lines`
| Column | Type | Notes |
| --- | --- | --- |
| order_item_id | INTEGER **PK** | |
| order_id, customer_id **FK**, product_id **FK** | INTEGER | |
| order_date, ship_date | TIMESTAMP | parsed from two formats |
| order_day, year, month | DATE, INT, CHAR(7) | reporting helpers |
| shipping_mode, delivery_status, order_status, payment_type | VARCHAR | |
| days_real, days_scheduled | INTEGER `CHECK >= 0` | |
| sla_gap_days | INTEGER | days_real − days_scheduled |
| is_shipped, is_late, is_on_time, is_suspected_fraud | BOOLEAN | delivery KPIs use is_shipped |
| market, order_region, order_country, order_state, order_city, latitude, longitude | | country in English |
| quantity, sales, discount, discount_rate, net_sales, profit, profit_ratio | NUMERIC | `sales >= 0`, `quantity > 0` |
| in_scope | BOOLEAN | 2015-01-01 … 2017-12-31 |
| period_flag | VARCHAR | Normal · Q4-2017 structure change · Jan-2018 partial month |

### `dim_customer`
customer_id **PK**, customer_fname, customer_lname, customer_segment (Consumer / Corporate / Home Office), customer_city, customer_state, customer_country, customer_zipcode.

### `dim_product`
product_id **PK**, product_name, unit_price, category_id, category_name, department_id, department_name.

## Views
| View | Grain | Purpose |
| --- | --- | --- |
| v_fact_order_lines | order line (in scope) | Power BI source, with customer/product attributes and discount_band |
| v_kpi_by_year | year | executive KPIs |
| v_yoy | year | YoY % for every KPI (`LAG`) |
| v_like_for_like | year | Jan–Sep comparison |
| v_monthly_trend | month | trend |
| v_shipping_sla | shipping mode | promise vs actual, median, late % |
| v_market_performance | market | sales, margin, late %, share |
| v_category_performance | department × category | sales, margin, units |
| v_product_abc | product | Pareto rank, cumulative share, ABC class |
| v_customer_profitability | customer | loss-making flag |
| v_discount_impact | discount band | margin and loss-line % |
| v_order_status | order status | order funnel |
