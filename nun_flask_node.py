#!/usr/bin/env python3
"""
NuN Nexus x VIREÁX — Omni-Mesh P2P Flask Wrapper
Serves WORM state-chain (ledger.jsonl) to the network.
"""
from flask import Flask, jsonify
import json
from pathlib import Path

app = Flask(__name__)
LEDGER_FILE = Path("ledger.jsonl")

@app.route('/status', methods=['GET'])
def get_status():
    blocks = 0
    if LEDGER_FILE.exists():
        with LEDGER_FILE.open("r", encoding="utf-8") as f:
            blocks = sum(1 for _ in f)
    
    return jsonify({
        "environment": "Omni-Mesh Layer 0",
        "tangle_active": True,
        "verified_nodes": 1,
        "blocks": blocks,
        "latest_commit": "b0b350c",
        "vfe_threshold": "<= 0.009"
    })

@app.route('/chain', methods=['GET'])
def get_chain():
    if not LEDGER_FILE.exists():
        return jsonify({"error": "WORM Ledger not found"}), 404
    
    chain_data = []
    with LEDGER_FILE.open("r", encoding="utf-8") as f:
        for line in f:
            chain_data.append(json.loads(line.strip()))
            
    return jsonify({"chain": chain_data, "length": len(chain_data)})

if __name__ == '__main__':
    print("[NuN-NODE] Initiating Flask P2P wrapper on 0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000)
