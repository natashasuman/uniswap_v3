-- Dune Analytics Baseline Verification Query
-- Target: Uniswap V3 USDC/ETH 0.05% pool (0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640)
-- Replace block ranges with your target block window (e.g. 17000000 to 17002000)

SELECT
    block_date AS metric_date,
    COUNT(DISTINCT tx_hash) AS dune_total_swap_txs,
    COUNT(*) AS dune_total_swaps,
    COUNT(DISTINCT recipient) AS dune_unique_traders,
    SUM(ABS(amount0)) AS dune_volume_token0,
    SUM(ABS(amount1)) AS dune_volume_token1
FROM uniswap_v3_ethereum.pair_swaps
WHERE pool = 0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640
  AND block_number >= 17000000
  AND block_number <= 17002000
GROUP BY 1
ORDER BY 1 DESC;
