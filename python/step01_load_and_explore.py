"""
STEP 01 - LOAD AND EXPLORE
--------------------------
Goal: measure the raw data BEFORE changing anything, and list its problems.

Run:  python python/step01_load_and_explore.py
"""

import pandas as pd
from config import RAW_FILE, RAW_ENCODING

# Pairs of columns that look like duplicates of each other
SUSPECTED_DUPLICATE_COLUMNS = [
    ("Benefit per order", "Order Profit Per Order"),
    ("Sales per customer", "Order Item Total"),
    ("Order Customer Id", "Customer Id"),
    ("Product Category Id", "Category Id"),
    ("Order Item Cardprod Id", "Product Card Id"),
    ("Order Item Product Price", "Product Price"),
]


def load_raw():
    """Read the raw CSV. latin-1 is needed because of Spanish letters."""
    return pd.read_csv(RAW_FILE, encoding=RAW_ENCODING)


def profile(df):
    print(f"Rows: {len(df):,}   Columns: {df.shape[1]}")
    print("Exact duplicate rows:", df.duplicated().sum())

    nulls = df.isna().sum()
    print("\nColumns with missing values:")
    for col, n in nulls[nulls > 0].items():
        print(f"  {col:30} {n:>8,}  ({n / len(df):.0%})")

    print("\nColumns with only ONE value (carry no information):")
    for col in df.columns:
        if df[col].nunique(dropna=False) == 1:
            print(f"  {col:30} -> {df[col].iloc[0]!r}")


def find_problems(df):
    print("\n========== PROBLEMS FOUND ==========")

    print("1. Duplicate columns (identical values):")
    for a, b in SUSPECTED_DUPLICATE_COLUMNS:
        print(f"   {a!r} == {b!r}: {(df[a] == df[b]).all()}")

    text_cols = df.select_dtypes(include=["object", "string"]).columns
    print("2. Text cells with extra spaces:")
    for col in text_cols:
        n = (df[col].astype(str) != df[col].astype(str).str.strip()).sum()
        if n:
            print(f"   {col:25} {n:>7,}")

    dash = df["order date (DateOrders)"].str.contains("-").sum()
    print(f"3. Mixed date formats: {dash:,} order dates use '01-31-2018', the rest '1/31/2018'")

    print("4. Country names in Spanish, e.g.:",
          df["Order Country"].value_counts().head(5).index.tolist(),
          "| customer country:", df["Customer Country"].unique().tolist())

    status = df["Order Status"].value_counts()
    print("5. Orders that never shipped:",
          {s: int(status.get(s, 0)) for s in ["CANCELED", "SUSPECTED_FRAUD"]})

    years = pd.to_datetime(df["order date (DateOrders)"], format="mixed").dt.year.value_counts().sort_index()
    print("6. Lines per year:", years.to_dict(), "<- 2018 is only January")

    same = (df["Late_delivery_risk"] == (df["Delivery Status"] == "Late delivery")).all()
    print("7. 'Late_delivery_risk' is just a copy of Delivery Status = Late:", same)


if __name__ == "__main__":
    raw = load_raw()
    profile(raw)
    find_problems(raw)
