-- Custom singular test: Check for block discontinuities or non-sequential gaps
-- In dbt, test fails if any records are returned.

WITH ordered_blocks AS (
    SELECT DISTINCT
        block_number,
        LAG(block_number, 1) OVER (ORDER BY block_number) AS prev_block_number
    FROM {{ ref('stg_uniswap_swaps') }}
)

SELECT
    block_number,
    prev_block_number,
    (block_number - prev_block_number) AS block_gap
FROM ordered_blocks
WHERE prev_block_number IS NOT NULL
  AND (block_number - prev_block_number) < 0  -- Unordered or negative block sequence error
