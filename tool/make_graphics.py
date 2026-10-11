#!/usr/bin/env python3
"""Render AnimeNook Play Store graphics as HTML mockups, screenshotted with
headless Chrome. No third-party Python deps.

Writes:
  <app>/store_assets/graphics/feature_graphic_1024x500.png
  <app>/store_assets/screenshots/01..05_*.png            (1080x1920)

Usage:
  python3 make_graphics.py [app_root]
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

APP_ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
GRAPHICS = APP_ROOT / "store_assets" / "graphics"
SHOTS = APP_ROOT / "store_assets" / "screenshots"
for d in (GRAPHICS, SHOTS):
    d.mkdir(parents=True, exist_ok=True)

CHROME = (shutil.which("google-chrome-stable") or shutil.which("google-chrome")
          or shutil.which("brave") or shutil.which("chromium"))

CSS = """
*{margin:0;padding:0;box-sizing:border-box;-webkit-font-smoothing:antialiased}
body{font-family:'DejaVu Sans','Segoe UI',Roboto,sans-serif;background:#0C1220;color:#EDF2FF}
.screen{width:1080px;height:1920px;position:relative;display:flex;flex-direction:column;overflow:hidden}
.status{display:flex;justify-content:space-between;font-size:28px;color:#93A1C4;padding:24px 40px 0}
.hdr{display:flex;align-items:center;gap:18px;padding:18px 44px 14px}
.logo{width:72px;height:72px;display:flex;align-items:center;justify-content:center;position:relative}
.word{font-size:44px;font-weight:800;letter-spacing:-1px}
.word small{display:block;font-size:22px;font-weight:500;color:#93A1C4;letter-spacing:0}
.chip{margin-left:auto;display:flex;align-items:center;gap:10px;background:#151E33;border:2px solid #27324F;border-radius:40px;padding:14px 24px;font-size:24px;color:#93A1C4;font-weight:600}
.chip .d{color:#35D0BA}
.chips{display:flex;gap:14px;padding:8px 44px 14px;flex-wrap:wrap}
.gchip{background:#151E33;border:2px solid #27324F;border-radius:26px;padding:14px 28px;font-size:26px;color:#93A1C4;font-weight:700}
.gchip.on{background:#5B8CFF;border-color:#5B8CFF;color:#fff}
.center{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:0 90px}
.bigcircle{width:220px;height:220px;border-radius:50%;background:linear-gradient(135deg,#5B8CFF,#35D0BA);display:flex;align-items:center;justify-content:center;font-size:110px}
.h1{font-size:60px;font-weight:900;margin-top:44px}
.muted{color:#93A1C4;font-size:30px;line-height:1.5;margin-top:22px}
.btn{background:#5B8CFF;color:#fff;border-radius:22px;padding:32px;text-align:center;font-size:34px;font-weight:800;margin:0 60px 34px}
.card{margin:6px 44px 0;padding:40px;border-radius:30px;background:linear-gradient(135deg,rgba(91,140,255,.26),rgba(53,208,186,.18));border:2px solid rgba(91,140,255,.45)}
.pill{display:inline-block;background:rgba(255,180,84,.14);color:#FFB454;border:2px solid rgba(255,180,84,.4);border-radius:22px;padding:12px 26px;font-size:26px;font-weight:800}
.title{font-size:56px;font-weight:900;line-height:1.12;margin-top:26px}
.meta{display:flex;gap:30px;color:#93A1C4;font-size:28px;margin-top:22px}
.gtags{display:flex;gap:14px;flex-wrap:wrap;margin-top:26px}
.gtag{background:rgba(53,208,186,.14);color:#35D0BA;border:2px solid rgba(53,208,186,.4);border-radius:22px;padding:10px 22px;font-size:24px;font-weight:700}
.blurb{font-size:31px;line-height:1.55;margin-top:30px}
.out{display:flex;gap:14px;align-items:center;justify-content:center;border:2px solid #27324F;color:#EDF2FF;border-radius:22px;padding:30px;font-size:32px;font-weight:700;margin:30px 44px 0}
.rowhead{display:flex;justify-content:space-between;padding:6px 48px;color:#93A1C4;font-size:28px;font-weight:600}
.row{display:flex;gap:24px;padding:26px 44px;border-bottom:2px solid #1B2438;align-items:flex-start}
.ric{width:92px;height:92px;border-radius:22px;background:rgba(91,140,255,.18);border:2px solid rgba(91,140,255,.4);display:flex;align-items:center;justify-content:center;font-size:44px;flex:0 0 auto}
.rt{font-size:34px;font-weight:800}
.rs{color:#93A1C4;font-size:25px;margin-top:6px}
.rg{font-size:23px;font-weight:800;color:#35D0BA;margin-top:6px}
.nav{position:absolute;left:0;right:0;bottom:0;height:150px;background:#0A0F1C;border-top:2px solid #1B2438;display:flex;align-items:center;justify-content:space-around;padding-bottom:14px}
.nav .it{display:flex;flex-direction:column;align-items:center;gap:8px;color:#6F7DA0;font-size:20px}
.nav .it.on{color:#35D0BA}
.nav .ic{width:56px;height:56px;border-radius:16px;background:#161E30;display:flex;align-items:center;justify-content:center;font-size:30px}
.nav .on .ic{background:rgba(53,208,186,.18)}
.feature{width:1024px;height:500px;background:radial-gradient(120% 160% at 15% 10%,#12224A 0%,#0C1220 55%,#070A12 100%);position:relative;overflow:hidden;display:flex;align-items:center;padding:0 70px}
.fglow{position:absolute;right:-120px;top:-140px;width:560px;height:560px;border-radius:50%;background:radial-gradient(circle,rgba(91,140,255,.55),transparent 62%)}
.fglow2{position:absolute;right:120px;bottom:-220px;width:520px;height:520px;border-radius:50%;background:radial-gradient(circle,rgba(53,208,186,.4),transparent 62%)}
.fleft{z-index:2;display:flex;align-items:center;gap:34px}
.flogo{display:flex;align-items:center;justify-content:center;box-shadow:0 30px 70px rgba(91,140,255,.5);border-radius:46px}
.fname{font-size:88px;font-weight:900;letter-spacing:-3px}
.ftag{font-size:34px;color:#C3CEE8;margin-top:6px}
.fbadges{display:flex;gap:14px;margin-top:24px}
.fb{font-size:26px;font-weight:800;border-radius:16px;padding:12px 22px}
.fb1{color:#5B8CFF;background:rgba(91,140,255,.16);border:2px solid rgba(91,140,255,.5)}
.fb2{color:#35D0BA;background:rgba(53,208,186,.14);border:2px solid rgba(53,208,186,.45)}
.fb3{color:#FFB454;background:rgba(255,180,84,.13);border:2px solid rgba(255,180,84,.4)}
"""


def render_html(html, out, w, h):
    if CHROME is None:
        print("No Chrome found; skipping", out.name)
        return
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
        f.write(html)
        path = f.name
    subprocess.run(
        [CHROME, "--headless=new", "--no-sandbox", "--disable-gpu",
         "--hide-scrollbars", "--force-device-scale-factor=1",
         f"--window-size={w},{h}", f"--screenshot={out}", f"file://{path}"],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    Path(path).unlink(missing_ok=True)
    print(f"  {out.relative_to(APP_ROOT)}")


def page(body, w, h):
    return (f"<!DOCTYPE html><html><head><meta charset='utf-8'><style>"
            f"{CSS}\nhtml,body{{width:{w}px;height:{h}px}}</style></head>"
            f"<body>{body}</body></html>")


# Inline SVG bookmark mark matching the app icon (gradient bookmark + star).
def logomark(size):
    return (
        f"<svg width='{size}' height='{size}' viewBox='0 0 100 100'>"
        "<defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'>"
        "<stop offset='0' stop-color='#5B8CFF'/><stop offset='1' stop-color='#35D0BA'/>"
        "</linearGradient></defs>"
        "<rect x='0' y='0' width='100' height='100' rx='26' fill='url(#g)'/>"
        "<path d='M34 22 H66 V80 L50 66 L34 80 Z' fill='#0C1220'/>"
        "<path d='M50 33 l3.2 6.6 7.2 1 -5.2 5.1 1.2 7.2 -6.4 -3.4 -6.4 3.4 "
        "1.2 -7.2 -5.2 -5.1 7.2 -1 z' fill='#FFFFFF'/>"
        "</svg>"
    )


def status():
    return "<div class='status'><span>9:41</span><span>&#9679; &#9679; &#9679; &#9679;</span></div>"


def header():
    return ("<div class='hdr'><div class='logo'>" + logomark(72) + "</div>"
            "<div class='word'>AnimeNook<small>What should I watch?</small></div>"
            "<div class='chip'><span class='d'>&#10003;</span> Offline</div></div>")


def genre_chips(active):
    names = [("All", "&#127922;"), ("Action", "&#9876;"), ("Adventure", "&#128506;"),
             ("Comedy", "&#128514;"), ("Fantasy", "&#128009;"), ("Romance", "&#128151;"),
             ("Sci-Fi", "&#128640;"), ("Slice", "&#127861;")]
    out = []
    for n, e in names:
        cls = "gchip on" if n == active else "gchip"
        out.append(f"<div class='{cls}'>{e} {n}</div>")
    return f"<div class='chips'>{''.join(out)}</div>"


def nav(active):
    items = [("&#127922;", "Pick"), ("&#9638;", "Browse"), ("&#9432;", "About")]
    out = []
    for i, (ic, label) in enumerate(items):
        cls = "it on" if i == active else "it"
        out.append(f"<div class='{cls}'><div class='ic'>{ic}</div>{label}</div>")
    return f"<div class='nav'>{''.join(out)}</div>"


def screen_idle():
    body = (f"<div class='screen'>{status()}{header()}"
            + genre_chips("All") +
            "<div class='center'>"
            "<div class='bigcircle'>&#127916;</div>"
            "<div class='h1'>What should I watch?</div>"
            "<div class='muted'>Tap &ldquo;Pick for me&rdquo; and AnimeNook will choose from "
            "32 titles &mdash; all offline.</div></div>"
            "<div class='btn'>&#127922; Pick for me</div>"
            f"{nav(0)}</div>")
    return page(body, 1080, 1920)


def screen_pick():
    body = (f"<div class='screen'>{status()}{header()}"
            + genre_chips("All") +
            "<div class='card'>"
            "<div class='pill'>&#9733; Your pick</div>"
            "<div class='title'>Frieren: Beyond Journey's End</div>"
            "<div class='meta'><span>&#128197; 2023</span><span>&#127916; Madhouse</span></div>"
            "<div class='gtags'><span class='gtag'>&#128009; Fantasy</span>"
            "<span class='gtag'>&#128506; Adventure</span>"
            "<span class='gtag'>&#127861; Slice of Life</span></div>"
            "<div class='blurb'>An elf mage reflects on time and friendship long "
            "after the quest ends.</div></div>"
            "<div class='out'>&#9638; Browse all titles</div>"
            "<div class='btn'>&#127922; Spin again</div>"
            f"{nav(0)}</div>")
    return page(body, 1080, 1920)


def screen_genre():
    rows = [("&#128009;", "Frieren: Beyond Journey's End", "2023 · Madhouse", "Fantasy · Adventure"),
            ("&#9876;", "Demon Slayer: Kimetsu no Yaiba", "2019 · ufotable", "Action · Fantasy"),
            ("&#128640;", "Dr. Stone", "2019 · TMS Entertainment", "Sci-Fi · Adventure"),
            ("&#128151;", "Your Name", "2016 · CoMix Wave Films", "Romance · Fantasy")]
    body = (f"<div class='screen'>{status()}{header()}"
            + genre_chips("Fantasy") +
            "<div class='rowhead'><span>6 titles</span><span>Bundled offline</span></div>"
            "<div style='margin-top:14px'>")
    for ic, t, s, g in rows:
        body += (f"<div class='row'><div class='ric'>{ic}</div>"
                 f"<div><div class='rt'>{t}</div><div class='rs'>{s}</div>"
                 f"<div class='rg'>{g}</div></div></div>")
    body += f"</div>{nav(1)}</div>"
    return page(body, 1080, 1920)


def screen_browse():
    rows = [("&#128250;", "Oshi no Ko", "2023 · Doga Kobo", "Mystery · Slice of Life"),
            ("&#128250;", "Chainsaw Man", "2022 · MAPPA", "Action · Fantasy"),
            ("&#128250;", "Spy x Family", "2022 · Wit Studio &amp; CloverWorks", "Comedy · Action"),
            ("&#128250;", "Blue Lock", "2022 · 8bit", "Sports · Action"),
            ("&#128250;", "Jujutsu Kaisen", "2020 · MAPPA", "Action · Fantasy")]
    body = (f"<div class='screen'>{status()}{header()}"
            + genre_chips("All") +
            "<div class='rowhead'><span>32 titles</span><span>Bundled offline</span></div>"
            "<div style='margin-top:14px'>")
    for ic, t, s, g in rows:
        body += (f"<div class='row'><div class='ric'>{ic}</div>"
                 f"<div><div class='rt'>{t}</div><div class='rs'>{s}</div>"
                 f"<div class='rg'>{g}</div></div></div>")
    body += f"</div>{nav(1)}</div>"
    return page(body, 1080, 1920)


def screen_about():
    body = (f"<div class='screen'>{status()}{header()}"
            "<div style='text-align:center;padding:24px 44px 0'>"
            "<div style='margin:0 auto;width:150px;height:150px'>" + logomark(150) + "</div>"
            "<div style='font-size:56px;font-weight:900;letter-spacing:-1px;margin-top:26px'>AnimeNook</div>"
            "<div style='color:#93A1C4;font-size:28px;margin-top:6px'>What should I watch?</div>"
            "<div style='margin-top:20px'><span class='chip' style='margin:0;display:inline-flex'>v1.0.0 &middot; 32 titles</span></div></div>"
            "<div style='margin:44px;background:linear-gradient(135deg,rgba(91,140,255,.16),rgba(53,208,186,.10));"
            "border:2px solid rgba(91,140,255,.4);border-radius:28px;padding:34px'>"
            "<div style='font-size:34px;font-weight:800;color:#35D0BA'>&#128737; Private by design</div>"
            "<div style='color:#EDF2FF;font-size:28px;line-height:1.55;margin-top:14px'>"
            "No internet, no ads, no tracking. AnimeNook has nothing to collect and never connects to the network.</div></div>"
            "<div style='margin:0 44px'>"
            "<div class='row' style='border:2px solid #27324F;border-radius:20px;margin-bottom:18px'><div class='rt'>0 permissions requested</div></div>"
            "<div class='row' style='border:2px solid #27324F;border-radius:20px;margin-bottom:18px'><div class='rt'>No ads &middot; no analytics</div></div>"
            "<div class='row' style='border:2px solid #27324F;border-radius:20px'><div class='rt'>100% offline catalogue</div></div>"
            "</div></div>")
    return page(body, 1080, 1920)


def feature_graphic():
    body = ("<div class='feature'><div class='fglow'></div><div class='fglow2'></div>"
            "<div class='fleft'><div class='flogo'>" + logomark(170) + "</div>"
            "<div><div class='fname'>AnimeNook</div>"
            "<div class='ftag'>What should I watch? &mdash; offline</div>"
            "<div class='fbadges'><span class='fb fb1'>100% offline</span>"
            "<span class='fb fb2'>0 permissions</span>"
            "<span class='fb fb3'>No ads</span></div></div></div></div>")
    return page(body, 1024, 500)


def main():
    if CHROME is None:
        print("Chrome not found; cannot render graphics.")
        return
    render_html(feature_graphic(), GRAPHICS / "feature_graphic_1024x500.png", 1024, 500)
    shots = [
        ("01_home", screen_idle()),
        ("02_your_pick", screen_pick()),
        ("03_genre_filter", screen_genre()),
        ("04_browse", screen_browse()),
        ("05_about_privacy", screen_about()),
    ]
    for name, html in shots:
        render_html(html, SHOTS / f"{name}.png", 1080, 1920)


if __name__ == "__main__":
    main()
