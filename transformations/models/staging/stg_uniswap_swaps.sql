{{ config(materialized='view') }}

WITH raw_swaps AS (
    SELECT *
    FROM read_parquet('../data/raw/swap/**/*.parquet', hive_partitioning=1)
)

SELECT
    transaction_hash,
    log_index,
    block_number,
    -- Construct composite primary key
    transaction_hash || '-' || CAST(log_index AS VARCHAR) AS swap_id,
    to_timestamp(block_timestamp) AS block_timestamp,
    LOWER(sender) AS sender,
    LOWER(recipient) AS recipient,
    -- Token amounts (USDC 6 decimals, WETH 18 decimals)
    CAST(amount0 AS DOUBLE) / 1e6 AS amount0_adjusted,
    CAST(amount1 AS DOUBLE) / 1e18 AS amount1_adjusted,
    sqrt_price_x96,
    liquidity,
    tick,
    year,
    month,
    day
FROM raw_swaps
