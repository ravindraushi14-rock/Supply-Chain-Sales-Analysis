"""
RUN THE WHOLE PIPELINE
----------------------
Runs steps 01 -> 05 in order. Use this after you change data/raw/*.csv,
then click Refresh in Power BI and Sync Changes in VS Code (updates the live web dashboard).

Run (from the project folder):  python python/run_pipeline.py
"""

import runpy
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))   # so each step can "import config"
STEPS = [
    "step01_load_and_explore.py",
    "step02_clean.py",
    "step03_load_to_sql.py",
    "step04_analysis.py",
    "step05_build_web_dashboard.py",
]

for step in STEPS:
    print("\n" + "=" * 70)
    print(f"RUNNING {step}")
    print("=" * 70)
    runpy.run_path(str(HERE / step), run_name="__main__")

print("\nPipeline finished. Next: Power BI -> Home -> Refresh, and VS Code -> Sync Changes.")
