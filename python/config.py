"""
config.py - All folder paths, business rules and database settings in ONE place.

Every step script imports from here. Move the project to another laptop,
or change your PostgreSQL login, and only this file changes.
"""

import os
from getpass import getpass
from pathlib import Path

# The project folder = one level above this "python" folder
PROJECT_DIR = Path(__file__).resolve().parent.parent

# Input: the raw file exactly as downloaded (never edited by code)
RAW_FILE = PROJECT_DIR / "data" / "raw" / "DataCoSupplyChainDataset.csv"
RAW_ENCODING = "latin-1"          # the file contains Spanish letters (á, é, ñ)
COUNTRY_TRANSLATION = PROJECT_DIR / "data" / "reference" / "country_translation.csv"

# Output of step 02: clean star-schema files
CLEAN_DIR = PROJECT_DIR / "data" / "clean"
CLEAN_FACT = CLEAN_DIR / "fact_order_lines.csv"
CLEAN_CUSTOMERS = CLEAN_DIR / "dim_customer.csv"
CLEAN_PRODUCTS = CLEAN_DIR / "dim_product.csv"
CLEANING_LOG = CLEAN_DIR / "cleaning_log.csv"

# SQL scripts (open and run them in pgAdmin too)
SQL_DIR = PROJECT_DIR / "sql"

# Output of step 04 and 05
CHART_DIR = PROJECT_DIR / "outputs" / "charts"
EXPORT_DIR = PROJECT_DIR / "outputs" / "exports"
WEB_DASHBOARD = PROJECT_DIR / "index.html"          # published by GitHub Pages

# ---------------- Business rules ----------------
# Reporting scope used by the dashboard: three complete years.
# January 2018 has only 2,123 lines, so it is kept in the database but flagged.
SCOPE_START = "2015-01-01"
SCOPE_END = "2017-12-31"
# From October 2017 the data changes shape (1 item per order, new customers only).
STRUCTURAL_BREAK = "2017-10-01"
# Orders that never shipped: excluded from delivery KPIs, kept for sales KPIs.
NOT_SHIPPED_STATUSES = ["CANCELED", "SUSPECTED_FRAUD"]

# ---------------- PostgreSQL (the server you open in pgAdmin) ----------------
PG_HOST = "localhost"
PG_PORT = 5432
PG_DATABASE = "supply_chain_db"   # created automatically by step 03 if missing
PG_USER = "postgres"


def pg_password():
    """Never written in code. Read from PG_PASSWORD, or asked once."""
    if "PG_PASSWORD" not in os.environ:
        os.environ["PG_PASSWORD"] = getpass(f"PostgreSQL password for user '{PG_USER}': ")
    return os.environ["PG_PASSWORD"]


def connect(database=PG_DATABASE):
    """Open a connection to PostgreSQL."""
    import psycopg2
    return psycopg2.connect(host=PG_HOST, port=PG_PORT, dbname=database,
                            user=PG_USER, password=pg_password())


def query_df(conn, sql):
    """Run a SELECT and return a pandas DataFrame (NUMERIC -> normal numbers)."""
    import pandas as pd
    with conn.cursor() as cur:
        cur.execute(sql)
        columns = [col[0] for col in cur.description]
        df = pd.DataFrame(cur.fetchall(), columns=columns)
    for col in df.columns:
        try:
            df[col] = pd.to_numeric(df[col])
        except (ValueError, TypeError):
            pass
    return df


def make_folders():
    for folder in [CLEAN_DIR, CHART_DIR, EXPORT_DIR]:
        folder.mkdir(parents=True, exist_ok=True)
