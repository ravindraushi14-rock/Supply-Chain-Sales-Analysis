"""
STEP 02 - CLEAN, FIX AND MODEL
------------------------------
Goal: fix every problem found in step 01 (one small function per fix) and
split the single wide file into a STAR SCHEMA:

    fact_order_lines  (one row per order line: dates, delivery, money)
    dim_customer      (one row per customer)
    dim_product       (one row per product, with category and department)

Every fix prints BEFORE -> AFTER and is written to cleaning_log.csv.

Run:  python python/step02_clean.py
"""

import pandas as pd
from config import (CLEAN_FACT, CLEAN_CUSTOMERS, CLEAN_PRODUCTS, CLEANING_LOG,
                    COUNTRY_TRANSLATION, SCOPE_START, SCOPE_END, STRUCTURAL_BREAK,
                    NOT_SHIPPED_STATUSES, make_folders)
from step01_load_and_explore import load_raw, SUSPECTED_DUPLICATE_COLUMNS

log = []


def record(step, problem, rows, action):
    print(f"  [{step}] {problem}: {rows:,} -> {action}")
    log.append({"step": step, "problem": problem, "rows_affected": int(rows), "action": action})


# ---------------- Fixes ----------------

def drop_duplicate_columns(df):
    """Fix 1: six columns are exact copies of another column. Keep one of each pair."""
    for a, b in SUSPECTED_DUPLICATE_COLUMNS:
        assert (df[a] == df[b]).all(), f"{a} and {b} are not identical - check before dropping"
    df = df.drop(columns=[a for a, _ in SUSPECTED_DUPLICATE_COLUMNS])
    record("F1", "Duplicate columns", len(SUSPECTED_DUPLICATE_COLUMNS), "dropped the copy, kept one of each pair")
    return df


def drop_useless_columns(df):
    """Fix 2: columns with no information (masked, empty or one value) or mostly blank."""
    useless = ["Customer Email", "Customer Password",        # masked as XXXXXXXXX
               "Product Description",                        # 100% blank
               "Product Status",                             # always 0
               "Product Image",                              # website URL, not analysis data
               "Order Zipcode",                              # 86% blank
               "Late_delivery_risk"]                         # copy of Delivery Status = Late
    df = df.drop(columns=useless)
    record("F2", "Useless or empty columns", len(useless), "dropped: " + ", ".join(useless))
    return df


def rename_columns(df):
    """Fix 3: 'Days for shipping (real)' -> 'days_real' style names for SQL and DAX."""
    names = {
        "Type": "payment_type", "Days for shipping (real)": "days_real",
        "Days for shipment (scheduled)": "days_scheduled", "Delivery Status": "delivery_status",
        "Category Id": "category_id", "Category Name": "category_name",
        "Customer City": "customer_city", "Customer Country": "customer_country",
        "Customer Fname": "customer_fname", "Customer Id": "customer_id",
        "Customer Lname": "customer_lname", "Customer Segment": "customer_segment",
        "Customer State": "customer_state", "Customer Street": "customer_street",
        "Customer Zipcode": "customer_zipcode", "Department Id": "department_id",
        "Department Name": "department_name", "Latitude": "latitude", "Longitude": "longitude",
        "Market": "market", "Order City": "order_city", "Order Country": "order_country",
        "order date (DateOrders)": "order_date", "Order Id": "order_id",
        "Order Item Discount": "discount", "Order Item Discount Rate": "discount_rate",
        "Order Item Id": "order_item_id", "Order Item Profit Ratio": "profit_ratio",
        "Order Item Quantity": "quantity", "Sales": "sales", "Order Item Total": "net_sales",
        "Order Profit Per Order": "profit", "Order Region": "order_region",
        "Order State": "order_state", "Order Status": "order_status",
        "Product Card Id": "product_id", "Product Name": "product_name",
        "Product Price": "unit_price", "shipping date (DateOrders)": "ship_date",
        "Shipping Mode": "shipping_mode",
    }
    df = df.rename(columns=names)
    record("F3", "Column names with spaces and brackets", len(names), "renamed to snake_case")
    return df


def trim_text(df):
    """Fix 4: extra spaces ('Smart watch ', 'South of  USA') split one value into two."""
    changed = 0
    for col in df.select_dtypes(include=["object", "string"]).columns:
        before = df[col].copy()
        df[col] = df[col].str.strip().str.replace(r"\s+", " ", regex=True)
        changed += int((before.fillna("") != df[col].fillna("")).sum())
    record("F4", "Text with extra spaces", changed, "trimmed and collapsed double spaces")
    return df


def parse_dates(df):
    """Fix 5: two date formats in one column ('1/31/2018 22:56' and '01-31-2018 22:56').
    Both are month-first, so 'mixed' parsing with month-first is safe."""
    for col in ["order_date", "ship_date"]:
        df[col] = pd.to_datetime(df[col], format="mixed", dayfirst=False)
    assert (df["ship_date"] >= df["order_date"]).all(), "a shipment before its order date"
    record("F5", "Mixed date formats", len(df) * 2, "parsed order_date and ship_date to real datetimes")
    return df


def translate_countries(df):
    """Fix 6: country names are in Spanish ('Estados Unidos', 'Alemania')."""
    m = pd.read_csv(COUNTRY_TRANSLATION).set_index("spanish_name")["english_name"]
    missing = set(df["order_country"]) - set(m.index)
    assert not missing, f"add these to country_translation.csv: {missing}"
    changed = int((df["order_country"] != df["order_country"].map(m)).sum()
                  + (df["customer_country"] != df["customer_country"].map(m)).sum())
    df["order_country"] = df["order_country"].map(m)
    df["customer_country"] = df["customer_country"].map(m)
    record("F6", "Country names in Spanish", changed, "translated to English with data/reference/country_translation.csv")
    return df


def fill_missing(df):
    """Fix 7: 8 customers without a last name, 3 without a zip code."""
    n = int(df["customer_lname"].isna().sum() + df["customer_zipcode"].isna().sum())
    df["customer_lname"] = df["customer_lname"].fillna("")
    df["customer_zipcode"] = df["customer_zipcode"].astype("Int64").astype(str).replace("<NA>", "")
    record("F7", "Missing last name / zip code", n, "filled with blank (no effect on any KPI)")
    return df


def add_business_columns(df):
    """Fix 8: add the columns a supply-chain manager actually asks about."""
    df["order_day"] = df["order_date"].dt.date
    df["year"] = df["order_date"].dt.year
    df["month"] = df["order_date"].dt.strftime("%Y-%m")
    df["is_shipped"] = ~df["order_status"].isin(NOT_SHIPPED_STATUSES)
    df["is_suspected_fraud"] = df["order_status"].eq("SUSPECTED_FRAUD")
    df["is_late"] = df["delivery_status"].eq("Late delivery")
    df["is_on_time"] = df["delivery_status"].isin(["Shipping on time", "Advance shipping"])
    df["sla_gap_days"] = df["days_real"] - df["days_scheduled"]       # + = slower than promised
    df["in_scope"] = df["order_date"].between(SCOPE_START, SCOPE_END + " 23:59:59")
    df["period_flag"] = "Normal"
    df.loc[df["order_date"] >= STRUCTURAL_BREAK, "period_flag"] = "Q4-2017 structure change"
    df.loc[df["order_date"] > SCOPE_END + " 23:59:59", "period_flag"] = "Jan-2018 partial month"
    record("F8", "Business columns", len(df),
           "added year, month, is_shipped, is_late, is_on_time, sla_gap_days, in_scope, period_flag")
    return df


# ---------------- Star schema ----------------

def split_star_schema(df):
    """One wide table -> fact + 2 dimensions. Checks every customer/product has ONE description."""
    cust_cols = ["customer_id", "customer_fname", "customer_lname", "customer_segment",
                 "customer_city", "customer_state", "customer_country", "customer_zipcode"]
    prod_cols = ["product_id", "product_name", "unit_price", "category_id", "category_name",
                 "department_id", "department_name"]

    customers = df[cust_cols].drop_duplicates()
    products = df[prod_cols].drop_duplicates()
    assert customers["customer_id"].is_unique, "a customer has two different descriptions"
    assert products["product_id"].is_unique, "a product has two different descriptions"

    fact_cols = ["order_item_id", "order_id", "customer_id", "product_id",
                 "order_date", "order_day", "ship_date", "year", "month",
                 "payment_type", "order_status", "shipping_mode", "delivery_status",
                 "days_real", "days_scheduled", "sla_gap_days",
                 "is_shipped", "is_suspected_fraud", "is_late", "is_on_time",
                 "market", "order_region", "order_country", "order_state", "order_city",
                 "latitude", "longitude",
                 "quantity", "sales", "discount", "discount_rate", "net_sales", "profit", "profit_ratio",
                 "in_scope", "period_flag"]
    fact = df[fact_cols]
    print(f"  Star schema: fact {len(fact):,} rows | customers {len(customers):,} | products {len(products):,}")
    return fact, customers, products


def check_result(fact):
    assert fact["order_item_id"].is_unique, "duplicate order lines"
    assert fact["sales"].ge(0).all(), "negative sales"
    assert (fact["days_real"] >= 0).all(), "negative shipping days"
    s = fact[fact["in_scope"]]
    print("\nCheck against the Power BI dashboard (2015-2017):")
    print(f"  Sales {s['sales'].sum() / 1e6:.2f}M | Profit {s['profit'].sum() / 1e6:.2f}M | "
          f"Orders {s['order_id'].nunique():,} | Customers {s['customer_id'].nunique():,} | "
          f"Late {s['is_late'].mean():.2%}")
    print("All checks passed.")


if __name__ == "__main__":
    make_folders()
    raw = load_raw()
    print(f"Start: {len(raw):,} rows x {raw.shape[1]} columns")
    df = drop_duplicate_columns(raw)
    df = drop_useless_columns(df)
    df = rename_columns(df)
    df = trim_text(df)
    df = parse_dates(df)
    df = translate_countries(df)
    df = fill_missing(df)
    df = add_business_columns(df)
    fact, customers, products = split_star_schema(df)
    check_result(fact)

    fact.to_csv(CLEAN_FACT, index=False)
    customers.to_csv(CLEAN_CUSTOMERS, index=False)
    products.to_csv(CLEAN_PRODUCTS, index=False)
    pd.DataFrame(log).to_csv(CLEANING_LOG, index=False)
    print(f"Saved: {CLEAN_FACT.name}, {CLEAN_CUSTOMERS.name}, {CLEAN_PRODUCTS.name}, {CLEANING_LOG.name}")
