#!/usr/bin/env python3
"""Generate AnimeNook branding PNGs with no third-party dependencies.

Draws the AnimeNook mark — a rounded "nook" bookmark with a punched-out star —
as:
  <app_root>/assets/images/app_icon.png             (512, gradient background)
  <app_root>/assets/images/app_icon_foreground.png  (1024, transparent, adaptive)
  <app_root>/assets/images/splash_logo.png          (512, transparent)
  <app_root>/assets/images/play_icon_512.png        (512, Play Store icon)

Usage:
  python3 gen_icons.py [app_root]     (default: current directory)
"""
import math
import struct
import sys
import zlib
from pathlib import Path

APP_ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
OUT = APP_ROOT / "assets" / "images"
OUT.mkdir(parents=True, exist_ok=True)

BG = (0x0C, 0x12, 0x20)
BLUE = (0x5B, 0x8C, 0xFF)
TEAL = (0x35, 0xD0, 0xBA)


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def write_png(path, width, height, pixels):
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for r, g, b, a in row:
            raw += bytes((r, g, b, a))
    compressed = zlib.compress(bytes(raw), 9)

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data +
                struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) +
           chunk(b"IDAT", compressed) + chunk(b"IEND", b""))
    path.write_bytes(png)


def _edge(d):
    if d >= 0.5:
        return 1.0
    if d <= -0.5:
        return 0.0
    return d + 0.5


def rounded_square_bg(x, y, cx, cy, half, radius):
    dx = max(abs(x - cx) - (half - radius), 0.0)
    dy = max(abs(y - cy) - (half - radius), 0.0)
    return _edge(radius - math.hypot(dx, dy))


def _sign(p1, p2, p3):
    return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])


def in_triangle(x, y, a, b, c):
    d1 = _sign((x, y), a, b)
    d2 = _sign((x, y), b, c)
    d3 = _sign((x, y), c, a)
    neg = d1 < 0 or d2 < 0 or d3 < 0
    pos = d1 > 0 or d2 > 0 or d3 > 0
    return not (neg and pos)


def star_polygon(cx, cy, r, points=5):
    verts = []
    for i in range(points * 2):
        radius = r if i % 2 == 0 else r * 0.45
        ang = (math.pi / points) * i - math.pi / 2
        verts.append((cx + radius * math.cos(ang), cy + radius * math.sin(ang)))
    return verts


def in_polygon(x, y, verts):
    inside = False
    n = len(verts)
    j = n - 1
    for i in range(n):
        xi, yi = verts[i]
        xj, yj = verts[j]
        if ((yi > y) != (yj > y)) and (
            x < (xj - xi) * (y - yi) / (yj - yi + 1e-9) + xi
        ):
            inside = not inside
        j = i
    return inside


def point_seg_dist(x, y, ax, ay, bx, by):
    vx, vy = bx - ax, by - ay
    wx, wy = x - ax, y - ay
    seg = vx * vx + vy * vy
    t = 0.0 if seg == 0 else max(0.0, min(1.0, (wx * vx + wy * vy) / seg))
    return math.hypot(x - (ax + t * vx), y - (ay + t * vy))


def render(size, with_background, scale=1.0, supersample=2):
    pixels = [[(0, 0, 0, 0)] * size for _ in range(size)]
    cx = cy = size / 2.0

    box = (size / 2.0) * 0.78 * scale
    x0, y0, x1, y1 = cx - box, cy - box, cx + box, cy + box

    def nook_inside(x, y):
        # Bookmark body — narrower than tall so it reads as a bookmark.
        left, right = x0 + box * 0.30, x1 - box * 0.30
        top, bottom = y0 + box * 0.06, y1 - box * 0.02
        if x < left or x > right or y < top or y > bottom:
            return False
        notch_top = bottom - box * 0.30
        if y >= notch_top:
            # V notch cut from the bottom edge, pointing up into the bookmark.
            frac = (y - notch_top) / (bottom - notch_top + 1e-9)
            gap_half = (box * 0.30) * frac
            if abs(x - cx) <= gap_half:
                return False
        return True

    star = star_polygon(cx, y0 + box * 0.70, box * 0.22)
    star_bbox = (min(v[0] for v in star), min(v[1] for v in star),
                 max(v[0] for v in star), max(v[1] for v in star))

    ss = supersample
    n = ss * ss
    for py in range(size):
        for px in range(size):
            acc = [0.0, 0.0, 0.0, 0.0]
            for sy in range(ss):
                for sx in range(ss):
                    fx = px + (sx + 0.5) / ss
                    fy = py + (sy + 0.5) / ss

                    r = g = b = 0.0
                    a = 0.0

                    if with_background:
                        bg_a = rounded_square_bg(
                            fx, fy, cx, cy, size * 0.5, size * 0.24)
                        sheen = max(0.0, min(1.0, (fx + fy) / (2 * size)))
                        bg_rgb = lerp(BG, (0x15, 0x1E, 0x33), sheen * 0.95)
                        r, g, b, a = bg_rgb[0], bg_rgb[1], bg_rgb[2], bg_a

                    gt = max(0.0, min(1.0, ((fx - x0) + (fy - y0)) / (2 * box)))
                    mark_rgb = lerp(BLUE, TEAL, gt)

                    cov = 1.0 if nook_inside(fx, fy) else 0.0
                    # Punch out the star.
                    if cov > 0 and (
                        star_bbox[0] <= fx <= star_bbox[2]
                        and star_bbox[1] <= fy <= star_bbox[3]
                    ) and in_polygon(fx, fy, star):
                        cov = 0.0

                    if cov > 0:
                        ta = cov
                        r = r * (1 - ta) + mark_rgb[0] * ta
                        g = g * (1 - ta) + mark_rgb[1] * ta
                        b = b * (1 - ta) + mark_rgb[2] * ta
                        a = a * (1 - ta) + 1.0 * ta

                    acc[0] += r * a
                    acc[1] += g * a
                    acc[2] += b * a
                    acc[3] += a

            alpha = acc[3] / n
            if alpha <= 0.0001:
                pixels[py][px] = (0, 0, 0, 0)
            else:
                pixels[py][px] = (
                    int(round(min(255.0, acc[0] / acc[3]))),
                    int(round(min(255.0, acc[1] / acc[3]))),
                    int(round(min(255.0, acc[2] / acc[3]))),
                    int(round(alpha * 255)),
                )
    return pixels


def main():
    icon = render(512, with_background=True, scale=1.0)
    write_png(OUT / "app_icon.png", 512, 512, icon)
    write_png(OUT / "play_icon_512.png", 512, 512, icon)

    fg = render(1024, with_background=False, scale=0.82)
    write_png(OUT / "app_icon_foreground.png", 1024, 1024, fg)

    splash = render(512, with_background=False, scale=0.95)
    write_png(OUT / "splash_logo.png", 512, 512, splash)

    for name in ("app_icon.png", "app_icon_foreground.png",
                 "splash_logo.png", "play_icon_512.png"):
        p = OUT / name
        print(f"  {name}: {p.stat().st_size} bytes")


if __name__ == "__main__":
    main()
