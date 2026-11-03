"""
Automated SQL reconciliation script comparing local DuckDB lakehouse outputs
against baseline Dune Analytics query exports.
"""
import sys
from pathlib import Path
import duckdb
import pandas as pd

# Add project root to path
sys.path.append(str(Path(__file__).resolve().parent.parent))
from config.settings import DUCKDB_PATH, DUNE_DATA_DIR


def calculate_match_percentage(val_local: float, val_baseline: float) -> float:
    """Calculates accuracy match percentage between local metric and baseline."""
    if val_baseline == 0:
        return 100.0 if val_local == 0 else 0.0
    diff = abs(val_local - val_baseline)
    match_pct = max(0.0, 100.0 - (diff / abs(val_baseline) * 100.0))
    return round(match_pct, 2)


def run_reconciliation(
    duckdb_file: Path = Path(DUCKDB_PATH),
    dune_csv_path: Path = None
):
    """
    Compares daily swap metrics from local DuckDB mart against Dune CSV export.
    """
    if dune_csv_path is None:
        dune_files = list(DUNE_DATA_DIR.glob("*.csv"))
        if not dune_files:
            print(f"[!] No Dune export CSV found in {DUNE_DATA_DIR}. Please place baseline CSV there.")
            return
        dune_csv_path = dune_files[0]

    print(f"[*] Running reconciliation with Dune baseline: {dune_csv_path.name}")
    print(f"[*] DuckDB Source: {duckdb_file}")

    if not duckdb_file.exists():
        print(f"[!] DuckDB file {duckdb_file} does not exist. Run dbt build first.")
        return

    con = duckdb.connect(str(duckdb_file), read_only=True)
    local_df = con.execute("SELECT * FROM fct_daily_pool_metrics").df()
    dune_df = pd.read_csv(dune_csv_path)

    print("\n--- Reconciliation Summary ---")
    print(f"Local Records: {len(local_df)} | Dune Records: {len(dune_df)}")

    # Example comparison matrix for matching dates
    merged = pd.merge(local_df, dune_df, on="metric_date", how="inner")
    if merged.empty:
        print("[!] No overlapping dates found between local mart and Dune baseline.")
        return

    for idx, row in merged.iterrows():
        vol0_match = calculate_match_percentage(row.get("total_volume_token0", 0), row.get("dune_volume_token0", 0))
        trader_match = calculate_match_percentage(row.get("unique_traders", 0), row.get("dune_unique_traders", 0))
        print(f"Date: {row['metric_date']}")
        print(f"  Token0 Volume Match: {vol0_match}%")
        print(f"  Unique Traders Match: {trader_match}%")


if __name__ == "__main__":
    run_reconciliation()
