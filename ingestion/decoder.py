"""
Event log binary decoder and normalizer using eth_abi and Web3.
"""
from typing import Dict, Any, List
from eth_abi import decode
from eth_utils import to_checksum_address


def decode_swap_log(log: Dict[str, Any]) -> Dict[str, Any]:
    """
    Decodes a Swap event log:
    Swap(address indexed sender, address indexed recipient, int256 amount0, int256 amount1, uint160 sqrtPriceX96, uint128 liquidity, int24 tick)
    """
    # topics[0] is event signature hash
    # topics[1] = sender, topics[2] = recipient
    sender = to_checksum_address(f"0x{log['topics'][1][-40:]}")
    recipient = to_checksum_address(f"0x{log['topics'][2][-40:]}")

    # data contains: (int256 amount0, int256 amount1, uint160 sqrtPriceX96, uint128 liquidity, int24 tick)
    data_bytes = bytes.fromhex(log['data'][2:])
    amount0, amount1, sqrtPriceX96, liquidity, tick = decode(
        ['int256', 'int256', 'uint160', 'uint128', 'int24'],
        data_bytes
    )

    return {
        "block_number": int(log['blockNumber'], 16) if isinstance(log['blockNumber'], str) else log['blockNumber'],
        "transaction_hash": log['transactionHash'],
        "log_index": int(log['logIndex'], 16) if isinstance(log['logIndex'], str) else log['logIndex'],
        "sender": sender.lower(),
        "recipient": recipient.lower(),
        "amount0": str(amount0),
        "amount1": str(amount1),
        "sqrt_price_x96": str(sqrtPriceX96),
        "liquidity": str(liquidity),
        "tick": tick
    }
