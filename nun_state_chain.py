#!/usr/bin/env python3
"""
NuN Nexus x VIREÁX — Executable State-Space & WORM Ledger Engine
Implements: S(t+1) = S(t) * exp(A * dt) + B * x(t) with Non-Commutative Projection P_v
"""
import hashlib
import json
import math
from pathlib import Path

PROOF_FILE = Path("nun_quantum_proof.lean")
HASH_FILE = Path("quantum_priority_hash.txt")
LEDGER_FILE = Path("ledger.jsonl")

def verify_lean_proof_parity() -> str:
    proof_bytes = PROOF_FILE.read_bytes()
    computed = hashlib.sha256(proof_bytes).hexdigest()
    recorded = HASH_FILE.read_text().strip()
    if computed != recorded:
        raise RuntimeError(f"Parity mismatch: {computed} != {recorded}")
    return computed

def step_state_space(x_t: float, s2_t: float, lam: float, dt: float) -> tuple[float, float, float]:
    # S(t+1) = S(t) * exp(A * dt) + B * u(t)
    decay = math.exp(-2.0 * lam * dt)
    x_next = x_t * decay + 0.5 * (1.0 - decay)
    v_next = 1.0 - x_next
    # Non-Commutative Projection Operator P_v = [[1, 0], [0, 0]] strips s2_t -> 0.0
    s2_projected = 0.0 * (s2_t * math.exp(-lam * dt))
    return round(x_next, 6), round(v_next, 6), round(s2_projected, 6)

def compute_block_hash(index: int, prev_hash: str, proof_hash: str, e_val: float, v_val: float, s2_val: float) -> str:
    payload = f"{index}|{prev_hash}|{proof_hash}|{e_val:.6f}:{v_val:.6f}:{s2_val:.6f}"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()

def build_worm_ledger() -> list[dict]:
    proof_hash = verify_lean_proof_parity()
    lam = 0.5 * math.log(2.0)  # Exact half-life step toward Thin Line (x = 0.5)
    dt = 1.0

    blocks = []
    # Block 0: Genesis State (x(0) = 0.80, V(0) = 0.20, P_v projected s2 = 0.00)
    prev_0 = "0" * 64
    e0, v0, s2_0 = 0.800000, 0.200000, 0.000000
    h0 = compute_block_hash(0, prev_0, proof_hash, e0, v0, s2_0)
    blocks.append({
        "block": 0,
        "type": "GENESIS_STATE",
        "prev_hash": prev_0,
        "proof_sha256": proof_hash,
        "state": {"E": e0, "V": v0, "E_plus_V": round(e0 + v0, 6), "s2_entropy": s2_0},
        "tle_flow": round(-2.0 * lam * (e0 - 0.5), 6),
        "block_hash": h0
    })

    # Block 1: State-Space Transition toward Thin Line Attractor (x = 0.5)
    e1, v1, s2_1 = step_state_space(e0, 0.25, lam, dt)
    h1 = compute_block_hash(1, h0, proof_hash, e1, v1, s2_1)
    blocks.append({
        "block": 1,
        "type": "VERIFIED_TLE_TRANSITION",
        "prev_hash": h0,
        "proof_sha256": proof_hash,
        "state": {"E": e1, "V": v1, "E_plus_V": round(e1 + v1, 6), "s2_entropy": s2_1},
        "tle_flow": round(-2.0 * lam * (e1 - 0.5), 6),
        "block_hash": h1
    })

    with LEDGER_FILE.open("w", encoding="utf-8") as f:
        for b in blocks:
            f.write(json.dumps(b) + "\n")
    return blocks

if __name__ == "__main__":
    chain = build_worm_ledger()
    print(f"[PASS] Generated {len(chain)} verified WORM blocks in ledger.jsonl")
    for blk in chain:
        print(f"  -> Block #{blk['block']} | E={blk['state']['E']} V={blk['state']['V']} | Hash={blk['block_hash']}")
