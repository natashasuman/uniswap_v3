{{ config(materialized='view') }}

WITH raw_burns AS (
    SELECT *
    FROM read_parquet('../data/raw/burn/**/*.parquet', hive_partitioning=1)
)

SELECT
    transaction_hash,
    log_index,
    block_number,
    transaction_hash || '-' || CAST(log_index AS VARCHAR) AS burn_id,
    to_timestamp(block_timestamp) AS block_timestamp,
    LOWER(owner) AS owner,
    tick_lower,
    tick_upper,
    liquidity,
    CAST(amount0 AS DOUBLE) / 1e6 AS amount0_adjusted,
    CAST(amount1 AS DOUBLE) / 1e18 AS amount1_adjusted,
    year,
    month,
    day
FROM raw_burns
