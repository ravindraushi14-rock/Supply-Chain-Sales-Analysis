"""
STEP 04 - ANALYSIS, CHARTS AND EXPORTS
--------------------------------------
Goal:
  a) read the KPI views from PostgreSQL and print the management insights
  b) save simple charts (for the README and quick checks)
  c) save CSV copies of the views in outputs/exports (handy for Excel)

Run:  python python/step04_analysis.py
"""

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from config import CHART_DIR, EXPORT_DIR, connect, query_df, make_folders

EXPORTS = ["v_kpi_by_year", "v_yoy", "v_like_for_like", "v_monthly_trend", "v_shipping_sla",
           "v_market_performance", "v_category_performance", "v_product_abc",
           "v_discount_impact", "v_order_status"]
BLUE, RED, GREY = "#2A78D6", "#D0453A", "#B9B6AD"


def view(conn, name):
    return query_df(conn, f"SELECT * FROM {name}")


def bar(df, x, y, title, file_name, colors=None, horizontal=True):
    fig, ax = plt.subplots(figsize=(8, 4.5))
    c = colors or BLUE
    if horizontal:
        ax.barh(df[x].astype(str), df[y], color=c)
        ax.invert_yaxis()
    else:
        ax.bar(df[x].astype(str), df[y], color=c)
        ax.tick_params(axis="x", rotation=90, labelsize=7)
    ax.set_title(title)
    ax.spines[["top", "right"]].set_visible(False)
    fig.tight_layout()
    fig.savefig(CHART_DIR / file_name, dpi=120)
    plt.close(fig)


def sla_chart(sla):
    """Promised vs actual days per shipping mode: the key supply-chain picture."""
    fig, ax = plt.subplots(figsize=(8, 4.5))
    x = range(len(sla))
    ax.bar([i - 0.2 for i in x], sla["promised_days"], 0.4, label="Promised", color=GREY)
    ax.bar([i + 0.2 for i in x], sla["actual_days"], 0.4, label="Actual", color=RED)
    ax.set_xticks(list(x), sla["shipping_mode"])
    ax.set_ylabel("Days")
    ax.set_title("Delivery promise vs reality (shipped orders, 2015-2017)")
    ax.legend()
    ax.spines[["top", "right"]].set_visible(False)
    fig.tight_layout()
    fig.savefig(CHART_DIR / "sla_promise_vs_actual.png", dpi=120)
    plt.close(fig)


def print_insights(conn):
    k = query_df(conn, """
        SELECT SUM(sales) AS sales, SUM(profit) AS profit, COUNT(DISTINCT order_id) AS orders,
               COUNT(DISTINCT customer_id) AS customers,
               AVG(is_late::int) FILTER (WHERE is_shipped) AS late_shipped,
               AVG(is_late::int) AS late_all
        FROM fact_order_lines WHERE in_scope""").iloc[0]
    print("\nKEY FIGURES (2015-2017)")
    print(f"  Sales {k.sales / 1e6:.2f}M | Profit {k.profit / 1e6:.2f}M | Margin {k.profit / k.sales:.2%}")
    print(f"  Orders {k.orders:,.0f} | Customers {k.customers:,.0f} | AOV {k.sales / k.orders:,.2f}")
    print(f"  Late: {k.late_shipped:.1%} of shipped lines ({k.late_all:.1%} of all lines, the old definition)")

    sla = view(conn, "v_shipping_sla")
    abc = query_df(conn, "SELECT abc_class, COUNT(*) n, SUM(sales) s FROM v_product_abc GROUP BY 1 ORDER BY 1")
    loss = query_df(conn, """SELECT COUNT(*) FILTER (WHERE is_loss_making) n,
                                    SUM(profit) FILTER (WHERE is_loss_making) p
                             FROM v_customer_profitability""").iloc[0]
    lfl = view(conn, "v_like_for_like").set_index("year")
    disc = view(conn, "v_discount_impact")

    print("\nINSIGHTS")
    for _, r in sla.iterrows():
        print(f"  {r.shipping_mode:15} promised {r.promised_days:.0f}d, actual {r.actual_days:.1f}d -> {r.late_pct:.1f}% late")
    a = abc.iloc[0]
    print(f"  Pareto: {a.n:.0f} products = {a.s / abc.s.sum():.0%} of sales")
    print(f"  Loss-making customers: {loss.n:,.0f}, losing {abs(loss.p) / 1e6:.2f}M of profit")
    print(f"  Like-for-like Jan-Sep 2017 vs 2016 sales: {lfl.loc[2017, 'sales_jan_sep'] / lfl.loc[2016, 'sales_jan_sep'] - 1:+.1%} "
          f"(full year shows -4.0% because of the Q4-2017 data change)")
    print(f"  Discount: margin {disc.margin_pct.iloc[0]:.1f}% at 0-4% discount vs {disc.margin_pct.iloc[-1]:.1f}% at 20-25%")


if __name__ == "__main__":
    make_folders()
    conn = connect()
    try:
        sla = view(conn, "v_shipping_sla")
        sla_chart(sla)
        bar(view(conn, "v_market_performance"), "market", "late_pct", "Late delivery % by market", "late_by_market.png")
        bar(view(conn, "v_product_abc").head(10), "product_name", "sales", "Top 10 products by sales", "top_products.png")
        mt = view(conn, "v_monthly_trend")
        mt["sales_m"] = mt["sales"] / 1e6
        bar(mt, "month", "sales_m", "Monthly sales (millions)", "monthly_sales.png", horizontal=False)
        bar(view(conn, "v_discount_impact"), "discount_band", "margin_pct",
            "Profit margin % by discount band", "discount_vs_margin.png", colors=RED)
        print(f"Charts saved in {CHART_DIR}")

        for name in EXPORTS:
            df = view(conn, name)
            df.to_csv(EXPORT_DIR / f"{name[2:]}.csv", index=False)
            print(f"  exported {name:24} -> outputs/exports/{name[2:]}.csv ({len(df):,} rows)")

        print_insights(conn)
    finally:
        conn.close()
