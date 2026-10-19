#!/usr/bin/env python3
import base64, gzip, tarfile, io
from pathlib import Path
here = Path(__file__).resolve().parent
b64 = "".join((here / "tar_parts12" / f"u{i}.txt").read_text() for i in range(12))
data = gzip.decompress(base64.b64decode(b64))
art = here.parent / "Art"
art.mkdir(parents=True, exist_ok=True)
with tarfile.open(fileobj=io.BytesIO(data), mode="r") as tar:
    tar.extractall(art)
    for m in tar.getmembers():
        print("wrote", m.name)
print("DONE - quit Civ 6, start a NEW game")
