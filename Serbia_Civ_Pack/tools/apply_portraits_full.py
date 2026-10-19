#!/usr/bin/env python3
"""Assembles and runs the full portrait installer from py_parts/."""
from pathlib import Path
here = Path(__file__).resolve().parent
parts = "".join((here / "py_parts" / f"p{i}.txt").read_text() for i in range(8))
code = compile(parts, "apply_embedded.py", "exec")
exec(code)
