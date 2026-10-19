#!/usr/bin/env python3
"""Generate Civ 6 leader portrait DDS files from PNG sources in Art/.

Requires: Pillow, ImageMagick (`convert`)

Usage (from Serbia_Civ_Pack folder):
  python3 tools/generate_leader_portraits.py

Reads:
  Art/FALLBACK_NEUTRAL_TITO.png
  Art/FALLBACK_NEUTRAL_DRAZA.png
  Art/FALLBACK_NEUTRAL_MILOSEVIC.png

Writes into Art/:
  LEADER_*_NEUTRAL.dds          (loading screen / large portrait)
  FALLBACK_NEUTRAL_LEADER_*.dds (optional diplo fallback name)
  ICON_LEADER_*_{32,45,50,55,64,80,256}.dds
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Install Pillow: pip install pillow")
    sys.exit(1)

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "Art"
ICON_SIZES = (32, 45, 50, 55, 64, 80, 256)

LEADERS = {
    "TITO": "FALLBACK_NEUTRAL_TITO.png",
    "DRAZA": "FALLBACK_NEUTRAL_DRAZA.png",
    "MILOSEVIC": "FALLBACK_NEUTRAL_MILOSEVIC.png",
}


def make_square(im: Image.Image, size: int) -> Image.Image:
    w, h = im.size
    side = min(w, h)
    left = (w - side) // 2
    top = (h - side) // 2
    cropped = im.crop((left, top, left + side, top + side))
    return cropped.resize((size, size), Image.Resampling.LANCZOS)


def make_neutral(im: Image.Image, target: int = 1024) -> Image.Image:
    w, h = im.size
    scale = target / max(w, h)
    nw, nh = int(w * scale), int(h * scale)
    resized = im.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (target, target), (0, 0, 0, 0))
    canvas.paste(resized, ((target - nw) // 2, (target - nh) // 2), resized)
    return canvas


def to_dds(png_path: Path, dds_path: Path) -> None:
    cmd = ["convert", str(png_path), "-define", "dds:compression=dxt5", str(dds_path)]
    try:
        subprocess.run(cmd, check=True, capture_output=True)
    except FileNotFoundError:
        print("ImageMagick `convert` not found. Install ImageMagick.")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print("convert failed:", e.stderr.decode(errors="ignore"))
        sys.exit(1)


def main() -> None:
    ART.mkdir(parents=True, exist_ok=True)
    tmp = ART / "_portrait_tmp"
    tmp.mkdir(exist_ok=True)

    for key, src_name in LEADERS.items():
        src = ART / src_name
        if not src.exists():
            print(f"MISSING source: {src}")
            continue
        im = Image.open(src).convert("RGBA")
        print(f"Processing {key} from {src.name} ({im.size[0]}x{im.size[1]})")

        neutral = make_neutral(im, 1024)
        n_png = tmp / f"LEADER_{key}_NEUTRAL.png"
        neutral.save(n_png)
        to_dds(n_png, ART / f"LEADER_{key}_NEUTRAL.dds")
        to_dds(n_png, ART / f"FALLBACK_NEUTRAL_LEADER_{key}.dds")

        for s in ICON_SIZES:
            icon = make_square(im, s)
            i_png = tmp / f"ICON_LEADER_{key}_{s}.png"
            icon.save(i_png)
            to_dds(i_png, ART / f"ICON_LEADER_{key}_{s}.dds")

        print(f"  wrote LEADER_{key}_NEUTRAL.dds + icons")

    # cleanup temp pngs
    for p in tmp.glob("*"):
        p.unlink()
    tmp.rmdir()
    print("Done. DDS files are in Art/")


if __name__ == "__main__":
    main()
