"""
Partitioned Parquet writer for raw on-chain event logs.
Saves records according to data/raw/{event_type}/year=YYYY/month=MM/day=DD/*.parquet.
"""
from pathlib import Path
from typing import List, Dict, Any
import pyarrow as pa
import pyarrow.parquet as pq


def write_partitioned_parquet(
    records: List[Dict[str, Any]],
    base_dir: Path,
    event_type: str,
    year: int,
    month: int,
    day: int,
    filename: str
) -> Path:
    """
    Writes a list of decoded event records to a partitioned Parquet destination.
    """
    target_dir = base_dir / event_type / f"year={year:04d}" / f"month={month:02d}" / f"day={day:02d}"
    target_dir.mkdir(parents=True, exist_ok=True)

    target_file = target_dir / filename
    table = pa.Table.from_pylist(records)
    pq.write_table(table, target_file)

    return target_file
