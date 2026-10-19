#!/usr/bin/env python3
"""Decode portrait .b64 files into Art/. Run: python tools/apply_portraits.py"""
import base64
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "Art"
DATA = Path(__file__).resolve().parent / "portrait_data"
ART.mkdir(parents=True, exist_ok=True)
if not DATA.exists():
    raise SystemExit(f"Missing {DATA}")
count = 0
for p in sorted(DATA.glob("*.b64")):
    out = ART / p.name[:-4]
    out.write_bytes(base64.b64decode(p.read_text().strip()))
    print("wrote", out.name)
    count += 1
print(f"Done ({count} files). Quit Civ 6, start a NEW game.")
