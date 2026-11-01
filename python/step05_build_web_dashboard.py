"""
STEP 05 - BUILD THE LIVE WEB DASHBOARD
--------------------------------------
Goal: turn the clean star schema into ONE self-contained web page
(index.html at the project root). GitHub Pages publishes it, so anyone
can open the dashboard in a browser - no Power BI or login needed.

How the data fits in one page:
  - only the 2015-2017 reporting scope is used (178,396 order lines)
  - text columns become small numbers (codes) with a lookup list
  - every line is packed into 20 bytes, then base64-encoded
  - sales are rebuilt in the browser as unit_price x quantity (checked below)

Run:  python python/step05_build_web_dashboard.py
"""

import base64
import json
import numpy as np
import pandas as pd
from config import CLEAN_FACT, CLEAN_PRODUCTS, CLEAN_CUSTOMERS, PROJECT_DIR, WEB_DASHBOARD

TEMPLATE = PROJECT_DIR / "python" / "web" / "dashboard_template.html"


def codes(series, order=None):
    """Text column -> (numeric codes, list of labels)."""
    labels = order or sorted(series.unique())
    lookup = {v: i for i, v in enumerate(labels)}
    return series.map(lookup).astype(np.uint16).to_numpy(), labels


def build():
    f = pd.read_csv(CLEAN_FACT, parse_dates=["order_date"])
    f = f[f["in_scope"]].reset_index(drop=True)
    p = pd.read_csv(CLEAN_PRODUCTS).sort_values("product_id").reset_index(drop=True)
    c = pd.read_csv(CLEAN_CUSTOMERS)[["customer_id", "customer_segment"]]
    f = f.merge(c, on="customer_id", how="left")

    # Sales must equal unit price x quantity, otherwise the page would show wrong totals
    price = f["product_id"].map(p.set_index("product_id")["unit_price"])
    assert np.allclose(price * f["quantity"], f["sales"], atol=0.01), "sales != price x quantity"

    months = sorted(f["month"].unique())
    mo, _ = codes(f["month"], months)
    mk, markets = codes(f["market"])
    sg, segments = codes(f["customer_segment"])
    sm, modes = codes(f["shipping_mode"], ["Same Day", "First Class", "Second Class", "Standard Class"])
    ds, dstat = codes(f["delivery_status"], ["Advance shipping", "Shipping on time", "Late delivery", "Shipping canceled"])
    os_, ostat = codes(f["order_status"])
    pt, pays = codes(f["payment_type"])
    rg, regions = codes(f["order_region"])
    pr, _ = codes(f["product_id"], list(p["product_id"]))
    bands = ["00-04%", "05-09%", "10-14%", "15-19%", "20-25%"]
    bd = np.digitize(f["discount_rate"].to_numpy(), [0.05, 0.10, 0.15, 0.20]).astype(np.uint8)
    o, _ = codes(f["order_id"], sorted(f["order_id"].unique()))          # < 65,536 orders
    cu, _ = codes(f["customer_id"], sorted(f["customer_id"].unique()))   # < 65,536 customers

    n = len(f)
    rec = np.zeros(n, dtype=[("mo", "u1"), ("mk", "u1"), ("sg", "u1"), ("sm", "u1"), ("ds", "u1"),
                             ("os", "u1"), ("pt", "u1"), ("bd", "u1"), ("rg", "u1"), ("pr", "u1"),
                             ("dr", "u1"), ("dsch", "u1"), ("q", "u1"),
                             ("o", "<u2"), ("c", "<u2"), ("pf", "<f4")])
    for name, arr in [("mo", mo), ("mk", mk), ("sg", sg), ("sm", sm), ("ds", ds), ("os", os_),
                      ("pt", pt), ("bd", bd), ("rg", rg), ("pr", pr), ("o", o), ("c", cu)]:
        rec[name] = arr
    rec["dr"] = f["days_real"]
    rec["dsch"] = f["days_scheduled"]
    rec["q"] = f["quantity"]
    rec["pf"] = f["profit"]
    # store column by column (columnar = fast to read in the browser)
    blob = b"".join(np.ascontiguousarray(rec[name]).tobytes() for name in rec.dtype.names)

    meta = {
        "n": n, "fields": [[k, rec.dtype[k].str] for k in rec.dtype.names],
        "months": months, "markets": markets, "segments": segments, "modes": modes,
        "dstat": dstat, "ostat": ostat, "pays": pays, "regions": regions, "bands": bands,
        "products": [{"name": r.product_name, "cat": r.category_name, "dept": r.department_name,
                      "price": float(r.unit_price)} for r in p.itertuples()],
        "check": {"sales": round(float(f["sales"].sum()), 2), "profit": round(float(f["profit"].sum()), 2),
                  "orders": int(f["order_id"].nunique()), "customers": int(f["customer_id"].nunique())},
    }
    html = TEMPLATE.read_text(encoding="utf-8")
    html = html.replace("__META__", json.dumps(meta, separators=(",", ":")))
    html = html.replace("__DATA__", base64.b64encode(blob).decode("ascii"))
    WEB_DASHBOARD.write_text(html, encoding="utf-8")
    print(f"Web dashboard: {WEB_DASHBOARD.name} ({WEB_DASHBOARD.stat().st_size / 1e6:.1f} MB, {n:,} order lines)")
    print(f"  check: sales {meta['check']['sales'] / 1e6:.2f}M, orders {meta['check']['orders']:,}")


if __name__ == "__main__":
    build()
