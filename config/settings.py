"""
Project configuration and constants.
"""
import os
from pathlib import Path
from dotenv import load_dotenv

# Base paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data"
RAW_DATA_DIR = DATA_DIR / "raw"
LAKEHOUSE_DIR = DATA_DIR / "lakehouse"
DUNE_DATA_DIR = DATA_DIR / "dune"
ABIS_DIR = PROJECT_ROOT / "config" / "abis"

# Load environment variables
load_dotenv(PROJECT_ROOT / ".env")

# RPC & Chain Configuration
RPC_URL = os.getenv("RPC_URL", "https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY")
CHAIN_ID = int(os.getenv("CHAIN_ID", 1))

# Default Uniswap V3 Pool: USDC/ETH 0.05%
USDC_ETH_POOL_ADDRESS = os.getenv(
    "POOL_ADDRESS", "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640"
).lower()

DEFAULT_START_BLOCK = int(os.getenv("START_BLOCK", 17000000))
DEFAULT_END_BLOCK = int(os.getenv("END_BLOCK", 17002000))
BLOCK_CHUNK_SIZE = int(os.getenv("BLOCK_CHUNK_SIZE", 2000))

# Event Signatures
SWAP_EVENT_SIGNATURE = "Swap(address,address,int256,int256,uint160,uint128,int24)"
MINT_EVENT_SIGNATURE = "Mint(address,address,int24,int24,uint128,uint256,uint256)"
BURN_EVENT_SIGNATURE = "Burn(address,int24,int24,uint128,uint256,uint256)"

# DuckDB Database path
DUCKDB_PATH = os.getenv("DUCKDB_PATH", str(LAKEHOUSE_DIR / "uniswap_v3.duckdb"))
