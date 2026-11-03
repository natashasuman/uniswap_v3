"""
Batch ingestion script querying Ethereum RPC nodes via eth_getLogs for Uniswap V3 events.
"""
import sys
from pathlib import Path

# Add project root to sys.path
sys.path.append(str(Path(__file__).resolve().parent.parent))

from config.settings import (
    RPC_URL,
    USDC_ETH_POOL_ADDRESS,
    DEFAULT_START_BLOCK,
    DEFAULT_END_BLOCK,
    BLOCK_CHUNK_SIZE,
    RAW_DATA_DIR
)


def extract_logs(
    start_block: int = DEFAULT_START_BLOCK,
    end_block: int = DEFAULT_END_BLOCK,
    pool_address: str = USDC_ETH_POOL_ADDRESS
):
    """
    Batches eth_getLogs queries across block ranges and writes decoded records
    to partitioned Parquet storage.
    """
    print(f"Starting extraction for pool: {pool_address}")
    print(f"Block range: {start_block} to {end_block} (chunk size: {BLOCK_CHUNK_SIZE})")
    # Batch query execution logic here


if __name__ == "__main__":
    extract_logs()
