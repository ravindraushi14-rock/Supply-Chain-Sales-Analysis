# Power BI setup

## v2: Power BI Project connected to PostgreSQL
1. Run the pipeline first: `python python/run_pipeline.py`. This creates **supply_chain_db** (pgAdmin → Databases).
2. Double-click **`SupplyChain_Dashboard_v2.pbip`** in this folder. Power BI Desktop (the free version) opens it.
3. The visuals start empty, because the project stores no data. Click **Home → Refresh**.
4. Login: choose **Database**, user `postgres`, and your pgAdmin password, then click **Connect**. If Power BI asks about encryption, click **OK** (normal for `localhost`).
5. Check the 5 pages. Optionally use **File → Save as → .pbix** to get a single shareable file.

**Like-for-like:** in the *Period* slicer choose **Jan-Sep**. Every YoY label then compares January–September only.

## v1: original dashboard
Open **`Supply Chain & Sales Analysis.pbix`**. It contains its own imported data.

## Refresh routine
New data in `data/raw/` → `python python/run_pipeline.py` → Power BI **Refresh** → VS Code **Sync Changes** (updates the live web dashboard).

## If something goes wrong
| Message | Fix |
| --- | --- |
| `password authentication failed` | Use the password that opens PostgreSQL in pgAdmin |
| `could not connect to server` | Windows → Services → postgresql-x64-NN → Start |
| A visual shows an error after Refresh | Right-click the visual → *Edit*, re-select the field, and tell your analyst which visual |
