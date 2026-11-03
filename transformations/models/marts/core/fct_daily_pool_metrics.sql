{{ config(materialized='table') }}

WITH daily_swaps AS (
    SELECT
        CAST(block_timestamp AS DATE) AS metric_date,
        COUNT(DISTINCT transaction_hash) AS total_swap_txs,
        COUNT(*) AS total_swap_count,
        COUNT(DISTINCT recipient) AS unique_traders,
        SUM(ABS(amount0_adjusted)) AS total_volume_token0,
        SUM(ABS(amount1_adjusted)) AS total_volume_token1,
        -- Fee tier: 0.05% (500 ppm)
        SUM(ABS(amount0_adjusted)) * 0.0005 AS estimated_fee_token0,
        SUM(ABS(amount1_adjusted)) * 0.0005 AS estimated_fee_token1
    FROM {{ ref('stg_uniswap_swaps') }}
    GROUP BY 1
),

daily_mints AS (
    SELECT
        CAST(block_timestamp AS DATE) AS metric_date,
        COUNT(*) AS total_mints,
        SUM(amount0_adjusted) AS mint_token0_total,
        SUM(amount1_adjusted) AS mint_token1_total
    FROM {{ ref('stg_uniswap_mints') }}
    GROUP BY 1
),

daily_burns AS (
    SELECT
        CAST(block_timestamp AS DATE) AS metric_date,
        COUNT(*) AS total_burns,
        SUM(amount0_adjusted) AS burn_token0_total,
        SUM(amount1_adjusted) AS burn_token1_total
    FROM {{ ref('stg_uniswap_burns') }}
    GROUP BY 1
)

SELECT
    s.metric_date,
    s.total_swap_txs,
    s.total_swap_count,
    s.unique_traders,
    s.total_volume_token0,
    s.total_volume_token1,
    s.estimated_fee_token0,
    s.estimated_fee_token1,
    COALESCE(m.total_mints, 0) AS total_mints,
    COALESCE(b.total_burns, 0) AS total_burns
FROM daily_swaps s
LEFT JOIN daily_mints m ON s.metric_date = m.metric_date
LEFT JOIN daily_burns b ON s.metric_date = b.metric_date
ORDER BY s.metric_date DESC
