{{ config(materialized='table') }}

WITH tick_events AS (
    SELECT
        block_number,
        block_timestamp,
        tick_lower,
        tick_upper,
        CAST(liquidity AS HUGEINT) AS liquidity_delta
    FROM {{ ref('stg_uniswap_mints') }}

    UNION ALL

    SELECT
        block_number,
        block_timestamp,
        tick_lower,
        tick_upper,
        -1 * CAST(liquidity AS HUGEINT) AS liquidity_delta
    FROM {{ ref('stg_uniswap_burns') }}
)

SELECT
    tick_lower,
    tick_upper,
    COUNT(*) AS total_liquidity_actions,
    SUM(liquidity_delta) AS net_liquidity,
    MAX(block_timestamp) AS last_updated_at
FROM tick_events
GROUP BY 1, 2
ORDER BY net_liquidity DESC
