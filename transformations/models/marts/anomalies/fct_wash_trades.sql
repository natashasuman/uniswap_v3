{{ config(materialized='table') }}

WITH base_swaps AS (
    SELECT
        swap_id,
        transaction_hash,
        block_number,
        block_timestamp,
        log_index,
        sender,
        recipient,
        amount0_adjusted,
        amount1_adjusted,
        -- Trade direction flag: 1 if buying token0 with token1, -1 if buying token1 with token0
        CASE WHEN amount0_adjusted > 0 THEN 1 ELSE -1 END AS direction
    FROM {{ ref('stg_uniswap_swaps') }}
),

windowed_swaps AS (
    SELECT
        *,
        -- Previous swap for same recipient or sender within window
        LAG(block_number, 1) OVER (PARTITION BY recipient ORDER BY block_number, log_index) AS prev_block_number,
        LAG(direction, 1) OVER (PARTITION BY recipient ORDER BY block_number, log_index) AS prev_direction,
        LAG(amount0_adjusted, 1) OVER (PARTITION BY recipient ORDER BY block_number, log_index) AS prev_amount0,
        LAG(block_timestamp, 1) OVER (PARTITION BY recipient ORDER BY block_number, log_index) AS prev_timestamp,

        -- Transaction count in same block by recipient
        COUNT(*) OVER (PARTITION BY recipient, block_number) AS same_block_tx_count
    FROM base_swaps
)

SELECT
    swap_id,
    transaction_hash,
    block_number,
    block_timestamp,
    recipient AS trader_address,
    amount0_adjusted,
    amount1_adjusted,
    -- Heuristic 1: Round-Trip Swap within 3 blocks with reversal direction
    CASE
        WHEN prev_block_number IS NOT NULL
         AND (block_number - prev_block_number) <= 3
         AND direction != prev_direction
         AND ABS(amount0_adjusted + prev_amount0) / GREATEST(ABS(amount0_adjusted), ABS(prev_amount0), 0.0001) < 0.05
        THEN TRUE
        ELSE FALSE
    END AS is_round_trip_wash,

    -- Heuristic 2: High Frequency Burst (> 3 swaps in single block or consecutive blocks)
    CASE
        WHEN same_block_tx_count > 3 THEN TRUE
        ELSE FALSE
    END AS is_high_frequency_burst,

    -- Flagged status if any heuristic triggered
    CASE
        WHEN (prev_block_number IS NOT NULL AND (block_number - prev_block_number) <= 3 AND direction != prev_direction)
          OR same_block_tx_count > 3
        THEN TRUE
        ELSE FALSE
    END AS is_anomaly_flagged
FROM windowed_swaps
