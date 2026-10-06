#!/usr/bin/env python3
"""Rebuild the MONEYME banner wordmark from any Horizon Customer Details PDF.

The SOA template needs logo_b64.txt (a transparent PNG of the wordmark in
#1C3132, sized to sit on the #BAEA02 banner). Every Customer Details PDF carries
the same wordmark in dark teal on white at top-left, so the logo can always be
regenerated from the job at hand -- no stored binary, no 58KB of base64 to
retype.  Usage:  python3 make_logo.py <customer_details.pdf>
"""
import sys, os, subprocess, tempfile, base64
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
PAD, SCALE, DPI = 8, 0.62, 600


def main(pdf):
    with tempfile.TemporaryDirectory() as td:
        stem = os.path.join(td, "p")
        try:
            subprocess.run(["pdftoppm", "-r", str(DPI), "-png", "-f", "1", "-l", "1", pdf, stem],
                           check=True)
        except FileNotFoundError:
            raise SystemExit(
                "pdftoppm not found (poppler-utils). You only need this to REGENERATE the\n"
                "logo -- scripts/logo_b64.txt is already bundled, so normally you never run\n"
                "this. If you do need it:  Windows: winget install poppler  |  "
                "macOS: brew install poppler  |  Linux: apt install poppler-utils")
        png = [os.path.join(td, f) for f in os.listdir(td) if f.endswith(".png")][0]
        im = Image.open(png).convert("RGB")
        a = np.array(im).astype(int)
        r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
        # brand teal ~ (11,40,40); g>r separates it from pure-black body text
        teal = (abs(r - 11) < 40) & (abs(g - 40) < 40) & (abs(b - 40) < 40) & (g > r)
        ys, xs = np.where(teal)
        if len(xs) == 0:
            raise SystemExit("wordmark not found -- is this a Customer Details PDF?")
        box = (xs.min() - PAD, ys.min() - PAD, xs.max() + PAD + 1, ys.max() + PAD + 1)
        crop = np.array(im.crop(box)).astype(float)

    alpha = np.clip((255.0 - crop[:, :, 1]) / (255.0 - 40.0), 0, 1)
    h, w = alpha.shape
    out = np.zeros((h, w, 4), dtype=np.uint8)
    out[:, :, 0], out[:, :, 1], out[:, :, 2] = 28, 49, 50      # #1C3132
    out[:, :, 3] = (alpha * 255).astype(np.uint8)
    img = Image.fromarray(out, "RGBA").resize((int(w * SCALE), int(h * SCALE)), Image.LANCZOS)

    p = os.path.join(HERE, "moneyme_logo.png")
    img.save(p, optimize=True)
    chk = Image.open(p); chk.load()                            # fail loudly if truncated
    open(os.path.join(HERE, "logo_b64.txt"), "w").write(
        base64.b64encode(open(p, "rb").read()).decode())
    print(f"logo {img.size}  {os.path.getsize(p)} bytes  -> moneyme_logo.png + logo_b64.txt")


if __name__ == "__main__":
    main(sys.argv[1])
