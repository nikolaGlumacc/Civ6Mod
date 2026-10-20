#!/usr/bin/env python3
"""Generate Civ 6 leader portrait DDS files from PNG sources in Art/ using Pillow directly."""
from __future__ import annotations

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


def main() -> None:
    ART.mkdir(parents=True, exist_ok=True)

    for key, src_name in LEADERS.items():
        src = ART / src_name
        if not src.exists():
            print(f"MISSING source: {src}")
            continue
        im = Image.open(src).convert("RGBA")
        print(f"Processing {key} from {src.name} ({im.size[0]}x{im.size[1]})")

        neutral = make_neutral(im, 1024)
        neutral.save(ART / f"LEADER_{key}_NEUTRAL.dds", format="DDS")
        neutral.save(ART / f"FALLBACK_NEUTRAL_LEADER_{key}.dds", format="DDS")

        for s in ICON_SIZES:
            icon = make_square(im, s)
            icon.save(ART / f"ICON_LEADER_{key}_{s}.dds", format="DDS")

        print(f"  [OK] Generated LEADER_{key}_NEUTRAL.dds + {len(ICON_SIZES)} icons")

    print("\nAll missing leader portraits and icons generated successfully!")


if __name__ == "__main__":
    main()
