-- ================= ANALYSIS 01 =================
-- Problem: Find Total Sales
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
SUM("Sales") AS total_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw; -- ACTION: Read the data from the source table.

-- ================= ANALYSIS 02 =================
-- Problem: Find Total Profit
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
SUM("Order Profit Per Order") AS total_profit -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw; -- ACTION: Read the data from the source table.

-- ================= ANALYSIS 03 =================
-- Problem: Find Total Orders
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
COUNT(DISTINCT "Order Id") AS total_orders -- ACTION: Count unique business IDs.
FROM dataco_raw; -- ACTION: Read the data from the source table.

-- ================= ANALYSIS 04 =================
-- Problem: Find Total Customers
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
COUNT(DISTINCT "Customer Id") AS total_customers -- ACTION: Count unique business IDs.
FROM dataco_raw; -- ACTION: Read the data from the source table.

-- ================= ANALYSIS 05 =================
-- Problem: Find Average Order Value (AOV)
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
SUM("Sales") / COUNT(DISTINCT "Order Id") AS aov -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw; -- ACTION: Read the data from the source table.

-- ================= ANALYSIS 06 =================
-- Problem: Find overall Profit Margin
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
SUM("Order Profit Per Order") / SUM("Sales") * 100 -- ACTION: Aggregate the numeric field with SUM.
AS profit_margin -- ACTION: Give the calculated field a clear output name.
FROM dataco_raw; -- ACTION: Read the data from the source table.

-- ================= ANALYSIS 07 =================
-- Problem: Sales by Customer Segment
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Customer Segment", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS segment_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Customer Segment" -- ACTION: Group rows by the selected business dimension.
ORDER BY segment_sales DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 08 =================
-- Problem: Profit by Customer Segment
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Customer Segment", -- ACTION: Continue this part of the SQL calculation.
SUM("Order Profit Per Order") AS segment_profit -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Customer Segment" -- ACTION: Group rows by the selected business dimension.
ORDER BY segment_profit DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 09 =================
-- Problem: Sales by Category
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Category Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS category_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Category Name" -- ACTION: Group rows by the selected business dimension.
ORDER BY category_sales DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 10 =================
-- Problem: Profit by Category
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Category Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Order Profit Per Order") AS category_profit -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Category Name" -- ACTION: Group rows by the selected business dimension.
ORDER BY category_profit DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 11 =================
-- Problem: Find Top 10 Products by Sales
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Product Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS product_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Product Name" -- ACTION: Group rows by the selected business dimension.
ORDER BY product_sales DESC -- ACTION: Sort the result for easier interpretation.
LIMIT 10; -- ACTION: Restrict the result to the requested number of rows.

-- ================= ANALYSIS 12 =================
-- Problem: Find Top 10 Products by Profit
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Product Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Order Profit Per Order") AS product_profit -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Product Name" -- ACTION: Group rows by the selected business dimension.
ORDER BY product_profit DESC -- ACTION: Sort the result for easier interpretation.
LIMIT 10; -- ACTION: Restrict the result to the requested number of rows.

-- ================= ANALYSIS 13 =================
-- Problem: Find loss-making products
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Product Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Order Profit Per Order") AS product_profit -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Product Name" -- ACTION: Group rows by the selected business dimension.
ORDER BY product_profit ASC -- ACTION: Sort the result for easier interpretation.
LIMIT 10; -- ACTION: Restrict the result to the requested number of rows.

-- ================= ANALYSIS 14 =================
-- Problem: Sales by Market
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Market", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS market_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Market" -- ACTION: Group rows by the selected business dimension.
ORDER BY market_sales DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 15 =================
-- Problem: Profit by Market
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Market", -- ACTION: Continue this part of the SQL calculation.
SUM("Order Profit Per Order") AS market_profit -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Market" -- ACTION: Group rows by the selected business dimension.
ORDER BY market_profit DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 16 =================
-- Problem: Find overall Late Delivery %
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
SUM(CASE -- ACTION: Create conditional business logic.
WHEN "Late_delivery_risk" = 1 THEN 1 -- ACTION: Test the business condition.
ELSE 0 -- ACTION: Return the default result.
END) * 100.0 / COUNT(*) AS late_delivery_pct -- ACTION: Close the CASE expression.
FROM dataco_raw; -- ACTION: Read the data from the source table.

-- ================= ANALYSIS 17 =================
-- Problem: Find Late Delivery % by Shipping Mode
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Shipping Mode", -- ACTION: Continue this part of the SQL calculation.
AVG("Late_delivery_risk") * 100 AS late_delivery_pct -- ACTION: Calculate the average.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Shipping Mode" -- ACTION: Group rows by the selected business dimension.
ORDER BY late_delivery_pct DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 18 =================
-- Problem: Compare actual vs scheduled shipping days
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Shipping Mode", -- ACTION: Continue this part of the SQL calculation.
AVG("Days for shipping (real)") AS actual_days, -- ACTION: Calculate the average.
AVG("Days for shipment (scheduled)") AS scheduled_days, -- ACTION: Calculate the average.
AVG("Days for shipping (real)") -- ACTION: Calculate the average.
- AVG("Days for shipment (scheduled)") AS delay_gap -- ACTION: Give the calculated field a clear output name.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Shipping Mode" -- ACTION: Group rows by the selected business dimension.
ORDER BY delay_gap DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 19 =================
-- Problem: Count orders by Order Status
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Order Status", -- ACTION: Continue this part of the SQL calculation.
COUNT(DISTINCT "Order Id") AS total_orders -- ACTION: Count unique business IDs.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Order Status" -- ACTION: Group rows by the selected business dimension.
ORDER BY total_orders DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 20 =================
-- Problem: Sales by Order Status
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Order Status", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS total_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Order Status" -- ACTION: Group rows by the selected business dimension.
ORDER BY total_sales DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 21 =================
-- Problem: Classify orders as Profit / Loss
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Order Id", -- ACTION: Continue this part of the SQL calculation.
"Order Profit Per Order", -- ACTION: Continue this part of the SQL calculation.
CASE -- ACTION: Create conditional business logic.
WHEN "Order Profit Per Order" > 0 THEN 'Profit' -- ACTION: Test the business condition.
WHEN "Order Profit Per Order" < 0 THEN 'Loss' -- ACTION: Test the business condition.
ELSE 'Break-even' -- ACTION: Return the default result.
END AS profit_status -- ACTION: Close the CASE expression.
FROM dataco_raw -- ACTION: Read the data from the source table.
LIMIT 10; -- ACTION: Restrict the result to the requested number of rows.

-- ================= ANALYSIS 22 =================
-- Problem: Find categories with profit greater than $100K
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Category Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Order Profit Per Order") AS total_profit -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Category Name" -- ACTION: Group rows by the selected business dimension.
HAVING SUM("Order Profit Per Order") > 100000 -- ACTION: Filter aggregated groups after GROUP BY.
ORDER BY total_profit DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 23 =================
-- Problem: Find products with sales above $1M
WITH product_sales AS ( -- ACTION: Start a Common Table Expression for an intermediate result.
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Product Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS total_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Product Name" -- ACTION: Group rows by the selected business dimension.
) -- ACTION: Close the SQL function/block.
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Product Name", -- ACTION: Continue this part of the SQL calculation.
total_sales -- ACTION: Continue this part of the SQL calculation.
FROM product_sales -- ACTION: Read the data from the source table.
WHERE total_sales > 1000000 -- ACTION: Filter rows before aggregation.
ORDER BY total_sales DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 24 =================
-- Problem: Rank products by Sales
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Product Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS total_sales, -- ACTION: Aggregate the numeric field with SUM.
RANK() OVER ( -- ACTION: Start ranking logic.
ORDER BY SUM("Sales") DESC -- ACTION: Sort the result for easier interpretation.
) AS sales_rank -- ACTION: Give the calculated field a clear output name.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Product Name"; -- ACTION: Group rows by the selected business dimension.

-- ================= ANALYSIS 25 =================
-- Problem: Find Top 10 Customers by Sales
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Customer Id", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS total_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Customer Id" -- ACTION: Group rows by the selected business dimension.
ORDER BY total_sales DESC -- ACTION: Sort the result for easier interpretation.
LIMIT 10; -- ACTION: Restrict the result to the requested number of rows.

-- ================= ANALYSIS 26 =================
-- Problem: Find Average Order Value by Customer Segment
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Customer Segment", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") / COUNT(DISTINCT "Order Id") AS aov -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Customer Segment" -- ACTION: Group rows by the selected business dimension.
ORDER BY aov DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 27 =================
-- Problem: Find Profit Margin by Category
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Category Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Order Profit Per Order") / -- ACTION: Aggregate the numeric field with SUM.
SUM("Sales") * 100 AS profit_margin -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Category Name" -- ACTION: Group rows by the selected business dimension.
ORDER BY profit_margin DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 28 =================
-- Problem: Find products with high sales but relatively low profit
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Product Name", -- ACTION: Continue this part of the SQL calculation.
SUM("Sales") AS total_sales, -- ACTION: Aggregate the numeric field with SUM.
SUM("Order Profit Per Order") AS total_profit -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Product Name" -- ACTION: Group rows by the selected business dimension.
HAVING SUM("Sales") > 100000 -- ACTION: Filter aggregated groups after GROUP BY.
AND SUM("Order Profit Per Order") < 10000 -- ACTION: Continue this part of the SQL calculation.
ORDER BY total_sales DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 29 =================
-- Problem: Profit by Customer Segment
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
"Customer Segment", -- ACTION: Continue this part of the SQL calculation.
SUM("Order Profit Per Order") AS segment_profit, -- ACTION: Aggregate the numeric field with SUM.
SUM("Sales") AS segment_sales -- ACTION: Aggregate the numeric field with SUM.
FROM dataco_raw -- ACTION: Read the data from the source table.
GROUP BY "Customer Segment" -- ACTION: Group rows by the selected business dimension.
ORDER BY segment_profit DESC; -- ACTION: Sort the result for easier interpretation.

-- ================= ANALYSIS 30 =================
-- Problem: Create one executive-level KPI query.
SELECT -- ACTION: Start the result set and choose the fields/calculations to return.
SUM("Sales") AS total_sales, -- ACTION: Aggregate the numeric field with SUM.
SUM("Order Profit Per Order") AS total_profit, -- ACTION: Aggregate the numeric field with SUM.
COUNT(DISTINCT "Order Id") AS total_orders, -- ACTION: Count unique business IDs.
COUNT(DISTINCT "Customer Id") AS total_customers, -- ACTION: Count unique business IDs.
SUM("Sales") / COUNT(DISTINCT "Order Id") AS aov, -- ACTION: Aggregate the numeric field with SUM.
SUM("Order Profit Per Order") / -- ACTION: Aggregate the numeric field with SUM.
SUM("Sales") * 100 AS profit_margin, -- ACTION: Aggregate the numeric field with SUM.
AVG("Late_delivery_risk") * 100 AS late_delivery_pct -- ACTION: Calculate the average.
FROM dataco_raw; -- ACTION: Read the data from the source table.