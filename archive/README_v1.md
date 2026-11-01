# Supply Chain & Sales Analysis
### End-to-End Data Analyst Project

---

## 1. Project Overview

**Supply Chain & Sales Analysis** is a comprehensive end-to-end business analytics project built around the **DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS** dataset.

The project examines a multi-dimensional supply-chain business from both **commercial and operational perspectives** — understanding how Sales, Customers, Orders, Profitability and Delivery Performance are changing, where significant performance gaps exist, and what business factors contribute to those changes.

The analysis begins with a **raw operational dataset** and follows a structured analytical journey. Data quality and consistency are first established, followed by data preparation and exploratory analysis. The investigation then moves into SQL-based business analysis, where high-level performance changes are progressively examined across Markets, Customer Segments, Categories, Products, Customers, Shipping Modes and Delivery SLAs.

The project goes beyond reporting what happened. Where significant changes were identified, the analysis moves deeper to understand **where the change occurred, what contributed to it, and what operational or commercial areas require attention**.

The final findings are brought together through a **five-page Power BI dashboard**, supported by detailed analytical documentation and business recommendations.

### Analytical Journey

```text
Raw Operational Data
        ↓
Data Quality & Validation
        ↓
Data Preparation
        ↓
Python Exploratory Analysis
        ↓
SQL Business Analysis
        ↓
Root-Cause Investigation
        ↓
5-Page Power BI Dashboard
        ↓
Key Business Findings
        ↓
Business Recommendations & Action Areas
        ↓
Expected Business Impact
```

---

## 2. Project Objective

The objective of this project is to develop a **data-driven view of supply-chain and sales performance** and identify the factors influencing commercial and operational outcomes.

The analysis focuses on:

- Sales and Profit performance
- Customer and Order growth
- Average Order Value
- Market and Customer Segment performance
- Category and Product performance
- Customer-level profitability
- Loss-making customer impact
- Late Delivery performance
- Shipping Mode performance
- SLA alignment and execution performance

The broader objective is to move from **performance reporting to business understanding** — identifying not only what changed, but where deeper investigation and management action may be required.

---

## 3. Business Questions

The analysis was structured around a series of connected business questions.

### Sales & Growth

- How are Sales, Profit, Orders and Customers changing over time?
- Why did Sales decline despite strong customer growth?
- What happened to Average Order Value?
- Which Markets, Segments, Categories and Products contributed to major Sales changes?

### Profitability

- Where is Profit being generated?
- How consistent are margins across Markets, Segments, Categories and Products?
- Which customers are generating losses?
- What is the financial impact of loss-making customers?

### Delivery & Operations

- Why does Late Delivery remain persistently high?
- Which Shipping Modes contribute most to the problem?
- Are scheduled delivery times realistic compared with actual execution?
- Where does SLA misalignment exist?
- After considering SLA alignment, where does an execution problem still remain?

These questions guide the analysis from **business performance → deeper investigation → root cause → action area**.

---

## 4. Dataset & Business Context

The project uses the **DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS** dataset.

The dataset combines commercial, customer, product, order and logistics information, enabling the analysis to connect **revenue performance with operational delivery performance**.

Key business dimensions include:

- Customers
- Orders
- Markets
- Customer Segments
- Categories
- Products
- Shipping Modes
- Order Status

Key analytical measures include:

- Sales
- Order Profit Per Order
- Orders
- Customers
- Shipping Days
- Scheduled Shipping Days
- Late Delivery Risk
- Order Dates

This structure provides the foundation for analysing the business from both **commercial and operational perspectives**.

---

## 5. Data Cleaning & Validation

Before drawing business conclusions, the dataset was systematically audited, cleaned and validated.

### Data Quality Assessment

The initial audit covered:

- Dataset structure
- Column names
- Data types
- Missing values and percentages
- Duplicate rows
- Unique-value analysis
- Statistical summaries
- Categorical summaries

### Data Quality Findings & Preparation

- **0 duplicate rows** were identified.
- `Product Description` was identified as **100% missing**.
- High-missing, non-analytical, sensitive/customer-related and constant fields were excluded from the Python analysis dataset.
- Fields such as customer contact/address information, password, product image and constant Product Status were removed from the analysis dataset.

### Date Validation

The dataset contained mixed date formats.

- Order Date and Shipping Date were standardized and validated during Python preparation.
- The **Order Date format issue was also rectified through SQL date-conversion logic** before business analysis.
- Invalid Shipping Dates were explicitly checked.

### Business Validation

Core business measures were validated before deeper analysis:

- Total Sales
- Total Profit
- Average Profit per Order
- Late Delivery %
- Total Customers
- Total Orders
- Total Products

This stage established the data foundation required for reliable downstream analysis.

---

## 6. Python Exploratory Data Analysis

Python was used to move from data preparation into **Exploratory Data Analysis and business validation**.

The analysis examined:

- Business distributions
- Sales and Profit patterns
- Trends
- Outliers
- Customer and Product behaviour
- Delivery-related patterns

Analytical features were created to support deeper investigation, including:

- Shipping Delay
- Profit Margin %
- Order Year
- Order Month
- Order Quarter
- Late Delivery Flag

The EDA stage helped identify patterns and areas requiring deeper business investigation through SQL.

---

## 7. SQL Business Analysis

SQL was used to move from exploratory observations into **structured business analysis and root-cause investigation**.

The analysis covered:

- Sales trends
- Market performance
- Customer Segment performance
- Category performance
- Product performance
- Customer profitability
- Loss-making customers
- Shipping Mode performance
- Late Delivery
- SLA feasibility
- Year-over-Year performance

The analysis progressively moved from high-level business performance into deeper dimensions.

For example:

```text
Sales Decline
    ↓
Market
    ↓
Customer Segment
    ↓
Category
    ↓
Product
```

and:

```text
Late Delivery
    ↓
Shipping Mode
    ↓
Scheduled vs Actual Days
    ↓
SLA Feasibility
    ↓
Execution Delay
```

This approach helped distinguish **business symptoms from underlying contributing factors**.

---

## 8. Power BI Dashboard

The final Power BI solution consists of **five analytical pages**, designed to move from executive performance monitoring into focused business investigation.

### Page 1 — Executive Overview

Provides the overall business picture through key performance indicators and high-level trends.

**Focus:**
- Sales
- Profit
- Orders
- Customers
- AOV
- Profit Margin
- Late Delivery

**Purpose:** Establish the overall business position before moving into deeper analysis.

### Page 2 — Sales Analysis

Examines where Sales are being generated and where significant changes are occurring.

**Focus:**
- Sales Trend
- Market Sales & Profit
- Category Sales
- Customer Segment Sales
- Top Customers
- Top Products

**Purpose:** Understand Sales performance, concentration and major contributors.

### Page 3 — Profitability Analysis

Examines profitability from Market, Segment, Category, Product and Customer perspectives.

**Focus:**
- Profit by Market
- Profit by Customer Segment
- Category Profitability
- Product Profitability
- Profit Margin
- Loss-Making Customer Profit Impact

**Purpose:** Understand where profitability is created and where profit leakage exists.

### Page 4 — Delivery & Operations Analysis

Investigates the persistent Late Delivery problem and the relationship between scheduled and actual execution.

**Focus:**
- Late Delivery by Shipping Mode
- Actual vs Scheduled Shipping Days
- Order Status
- SLA / Delivery Performance

**Purpose:** Separate SLA alignment issues from underlying execution problems.

### Page 5 — Customer & Product Analysis

Provides deeper customer and product-level analysis.

**Focus:**
- Customer Performance
- Top Customers
- Product Sales
- Product Profit
- Customer Segment × Market
- Category × Customer Segment

**Purpose:** Support deeper commercial and customer-level investigation.

> **Dashboard screenshots for all five pages are included in the project documentation.**

---

## 9. Key Business Findings

### Sales Performance

Customer growth was significantly stronger than Order growth, while Average Order Value declined.

The resulting business pattern was:

**Customers ↑ → Orders ↑ → AOV ↓ → Sales ↓**

Sales and absolute Profit declined, while Profit Margin improved.

### 2017 Sales Decline

The decline was concentrated toward the final months of 2017 rather than being evenly distributed throughout the year.

Further investigation identified **Europe as a major contributor**, with the decline concentrated across multiple Customer Segments and specific products.

### Late Delivery

Late Delivery remained persistently high at approximately **54–55%** across the analysis period.

Shipping Mode emerged as the strongest differentiator.

First Class showed a **1-day scheduled duration against a typical 2-day actual duration**, while Second Class showed a **2-day schedule against a typical 4-day actual duration**.

The investigation also identified a substantial **5–6 day execution group**, showing that SLA adjustment alone would not eliminate the complete delivery problem.

### Customer Profitability

**3,660 loss-making customers** generated approximately:

- **7.05M Sales**
- **-1.04M Profit**
- **19.34% of total Sales**
- Loss equivalent to **26.55% of total Profit**

The issue was distributed across major Customer Segments and Markets rather than being isolated to one area.

---

## 10. Business Recommendations & Expected Business Impact

The analysis identifies specific performance gaps across **Sales, Customer Profitability and Delivery Operations**.

The recommended actions are designed to create a connected improvement cycle:

```text
Better SLA Alignment
        ↓
More Reliable Delivery
        ↓
Improved Customer Experience
        ↓
Better Revenue Quality
        ↓
Reduced Profit Leakage
        ↓
Improved Profitability
        ↓
Stronger Overall Business Performance
```

### 1. Improve SLA Alignment & Delivery Reliability

Review First Class and Second Class delivery commitments against observed execution performance.

**Expected Business Impact:**
- More realistic customer commitments
- Lower avoidable Late Delivery
- Improved delivery reliability
- Better customer experience

### 2. Improve Operational Execution

Investigate the substantial 5–6 day execution group for operational bottlenecks.

**Expected Business Impact:**
- More consistent delivery performance
- Faster identification of operational bottlenecks
- Improved service reliability
- Reduced customer dissatisfaction

### 3. Convert Customer Growth into Revenue Growth

Customer growth has not translated proportionally into Sales because AOV declined.

Investigate basket size, product mix and purchasing behaviour.

**Expected Business Impact:**
- Higher revenue per order
- Better conversion of customer growth into revenue
- Improved Sales performance
- Stronger revenue quality

### 4. Reduce Customer-Level Profit Leakage

3,660 customers collectively generated **7.05M Sales but -1.04M Profit**.

Identify the commercial and operational drivers behind these loss-making relationships.

**Expected Business Impact:**
- Reduced avoidable losses
- Improved customer profitability
- Stronger overall Profit
- Better quality of revenue

### 5. Establish Continuous Performance Monitoring

Use the Power BI dashboard to monitor:

**Sales → Customers → AOV → Profit → Margin → Delivery → Customer Profitability**

**Expected Business Impact:**
- Earlier identification of negative trends
- Faster management intervention
- Better performance visibility
- More consistent decision-making

### Overall Business Opportunity

The analysis demonstrates that the business has **identifiable performance gaps as well as identifiable areas for improvement**.

Addressing SLA alignment, delivery execution, revenue quality and customer profitability together could create a stronger operating cycle:

> **Better Delivery → Better Customer Experience → Better Revenue Quality → Lower Profit Leakage → Stronger Profitability → Sustainable Business Performance**

The recommendations therefore transform the project from a **reporting exercise into an action-oriented business analysis**.

---

## 11. Tools & Technologies

| Tool / Technology | Role in the Project |
|---|---|
| **Python** | Data cleaning, validation, feature engineering and EDA |
| **Pandas** | Data manipulation and data-quality analysis |
| **NumPy** | Numerical calculations and feature creation |
| **PostgreSQL / SQL** | Business analysis, KPI calculations and root-cause investigation |
| **Power BI** | Five-page interactive dashboard and business visualization |
| **GitHub** | Project documentation, repository management and version control |

---

## 12. Project Structure

```text
Supply-Chain-Sales-Analysis/
│
├── README.md
│
├── documentation/
│
├── python/
│
├── sql/
│
├── powerbi/
│
├── screenshots/
│
└── data/
```

---

## Final Project Outcome

This project demonstrates an end-to-end analytical approach that connects:

**Data Quality → Data Preparation → EDA → SQL Business Analysis → Root-Cause Investigation → Power BI → Business Findings → Action Areas**

The final outcome is not simply a collection of charts or KPIs.

It provides a structured view of:

> **What changed → Where it changed → What contributed → What requires attention → Where business improvement can be pursued**

The project therefore combines **technical data analysis with business interpretation and action-oriented decision support**.
