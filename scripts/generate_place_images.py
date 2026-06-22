#!/usr/bin/env python3
"""
Generates a bundled "destination card" image for every sample place.

Each image is a layered, category-specific scene (gradient sky, soft sun/moon,
hazy far ridge, a silhouette skyline or rolling hills, optional water with a
reflection, a legibility scrim). Scenes are deterministic per place id, so a
place always looks the same and neighbouring places look distinct.

Output: Roamly/Assets.xcassets/photo-<id>.imageset/{Contents.json, photo-<id>.png}
The app shows these instantly, fully offline, via PlaceVisual's bundled-image
hook; a real Wikipedia photo loads on top wherever the network allows.
"""

import os, re, json, hashlib, math, random, glob
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAMPLE_GLOB = os.path.join(ROOT, "Roamly", "Resources", "SampleData+*.swift")
ASSETS = os.path.join(ROOT, "Roamly", "Assets.xcassets")

W, H = 1200, 800

# Primary intention -> scene archetype.
SCENE = {
    "natureParks": "nature", "hiddenGems": "nature",
    "nightlife": "night", "foodie": "night",
    "photography": "sunset",
    "sports": "urban", "architecture": "urban", "history": "urban",
    "artCulture": "urban", "religiousHeritage": "urban",
    "localClassics": "urban", "shopping": "urban", "familyFriendly": "urban",
}

# (sky_top, sky_bottom, far, mid, near) base colors per scene.
PALETTE = {
    "urban":  ((86, 150, 214), (192, 222, 244), (150, 178, 208), (74, 104, 150), (40, 60, 96)),
    "nature": ((96, 174, 196), (214, 238, 214), (150, 196, 160), (92, 150, 94), (54, 100, 62)),
    "night":  ((20, 22, 56), (92, 60, 120), (44, 40, 84), (26, 24, 56), (14, 14, 34)),
    "sunset": ((58, 42, 112), (250, 168, 96), (210, 120, 120), (96, 60, 96), (44, 30, 58)),
}

def parse_places():
    places = []
    for path in glob.glob(SAMPLE_GLOB):
        text = open(path, encoding="utf-8").read()
        for m in re.finditer(
            r'id:\s*"([^"]+)"\s*,\s*name:\s*"([^"]+)"\s*,\s*intentions:\s*\[([^\]]*)\]',
            text, re.DOTALL):
            pid, name, ints = m.group(1), m.group(2), m.group(3)
            first = re.findall(r'\.(\w+)', ints)
            primary = first[0] if first else "localClassics"
            places.append((pid, name, primary))
    return places

def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))

def shift_hue(c, deg):
    import colorsys
    r, g, b = [x / 255 for x in c]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    h = (h + deg / 360.0) % 1.0
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return (int(r * 255), int(g * 255), int(b * 255))

def vgradient(draw, top, bottom, y0, y1):
    span = max(1, y1 - y0)
    for y in range(y0, y1):
        draw.line([(0, y), (W, y)], fill=lerp(top, bottom, (y - y0) / span))

def soft_circle(size, color, radius, blur):
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    cx, cy = size[0] // 2, size[1] // 2
    d.ellipse([cx - radius, cy - radius, cx + radius, cy + radius],
              fill=color + (255,))
    return layer.filter(ImageFilter.GaussianBlur(blur))

def skyline(rng, color, base_y, band_h, signature):
    """A silhouette of buildings across the width, returns an RGBA layer."""
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    x = -20
    sig_x = rng.randint(int(W * 0.3), int(W * 0.62))
    while x < W + 20:
        bw = rng.randint(70, 150)
        bh = rng.randint(int(band_h * 0.30), int(band_h * 0.85))
        top = base_y - bh
        d.rectangle([x, top, x + bw, H], fill=color + (255,))
        # lit windows for night scenes
        if signature == "night":
            for wy in range(top + 16, H - 10, 34):
                for wx in range(x + 12, x + bw - 12, 26):
                    if rng.random() < 0.32:
                        d.rectangle([wx, wy, wx + 9, wy + 14],
                                    fill=(255, 214, 138, 220))
        x += bw + rng.randint(2, 10)
    # signature landmark element
    cx = sig_x
    if signature == "sports":
        d.ellipse([cx - 150, base_y - 110, cx + 150, base_y + 110], fill=color + (255,))
    elif signature in ("religiousHeritage", "architecture", "history"):
        sh = rng.randint(int(band_h * 0.9), int(band_h * 1.25))
        d.rectangle([cx - 36, base_y - sh, cx + 36, H], fill=color + (255,))
        d.polygon([(cx - 36, base_y - sh), (cx + 36, base_y - sh), (cx, base_y - sh - 90)],
                  fill=color + (255,))
    else:
        sh = rng.randint(int(band_h * 0.85), int(band_h * 1.15))
        d.rectangle([cx - 30, base_y - sh, cx + 30, H], fill=color + (255,))
    return layer

def hills(rng, color, base_y, amp):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    pts = [(0, H)]
    n = 6
    phase = rng.random() * math.tau
    for i in range(n + 1):
        x = int(W * i / n)
        y = base_y + int(math.sin(phase + i * 1.1) * amp) - rng.randint(0, amp // 2)
        pts.append((x, y))
    pts.append((W, H))
    d.polygon(pts, fill=color + (255,))
    return layer

def generate(pid, name, primary):
    scene = SCENE.get(primary, "urban")
    seed = int(hashlib.md5(pid.encode()).hexdigest(), 16)
    rng = random.Random(seed)
    hue = rng.uniform(-14, 14)
    sky_top, sky_bot, far, mid, near = (shift_hue(c, hue) for c in PALETTE[scene])

    img = Image.new("RGB", (W, H), sky_top)
    draw = ImageDraw.Draw(img)
    horizon = int(H * (0.66 if scene in ("nature", "sunset") else 0.62))
    vgradient(draw, sky_top, sky_bot, 0, horizon)
    draw.rectangle([0, horizon, W, H], fill=sky_bot)

    # Sun / moon
    sun_x = rng.randint(int(W * 0.18), int(W * 0.82))
    sun_y = int(horizon * rng.uniform(0.32, 0.62))
    if scene == "night":
        sun_col = (236, 238, 250)
        for wy in range(60):  # stars
            pass
        sd = ImageDraw.Draw(img)
        for _ in range(70):
            sx, sy = rng.randint(0, W), rng.randint(0, int(horizon * 0.8))
            r = rng.choice([1, 1, 2])
            sd.ellipse([sx, sy, sx + r, sy + r], fill=(240, 240, 255))
    elif scene == "sunset":
        sun_col = (255, 226, 150)
    elif scene == "nature":
        sun_col = (255, 244, 206)
    else:
        sun_col = (255, 250, 224)
    glow = soft_circle((W, H), sun_col, rng.randint(70, 110), 60)
    glow = glow.transform((W, H), Image.AFFINE,
                          (1, 0, -(W // 2 - sun_x), 0, 1, -(H // 2 - sun_y)))
    img = Image.alpha_composite(img.convert("RGBA"), glow)
    disc = soft_circle((W, H), sun_col, rng.randint(46, 64), 6)
    disc = disc.transform((W, H), Image.AFFINE,
                          (1, 0, -(W // 2 - sun_x), 0, 1, -(H // 2 - sun_y)))
    img = Image.alpha_composite(img, disc).convert("RGB")

    # Far hazy ridge
    img = Image.alpha_composite(img.convert("RGBA"),
                                hills(rng, lerp(far, sky_bot, 0.35), horizon + 8,
                                      30)).convert("RGB")

    water = scene in ("sunset", "night", "nature")
    base_y = int(H * (0.80 if water else 0.95))

    if scene == "nature":
        img = Image.alpha_composite(img.convert("RGBA"), hills(rng, mid, base_y - 40, 70)).convert("RGB")
        img = Image.alpha_composite(img.convert("RGBA"), hills(rng, near, base_y, 50)).convert("RGB")
    else:
        band_h = int(H * 0.42)
        img = Image.alpha_composite(img.convert("RGBA"),
                                    skyline(rng, mid, base_y - 26, int(band_h * 0.8), "city")).convert("RGB")
        img = Image.alpha_composite(img.convert("RGBA"),
                                    skyline(rng, near, base_y, band_h, primary if scene != "night" else "night")).convert("RGB")

    # Water band with a simple sun reflection
    if water:
        wd = ImageDraw.Draw(img)
        vg = Image.new("RGB", (W, H - base_y), sky_bot)
        vgd = ImageDraw.Draw(vg)
        vgradient_local(vgd, lerp(sky_bot, near, 0.3), lerp(near, (0, 0, 0), 0.2), 0, H - base_y)
        img.paste(vg, (0, base_y))
        refl = ImageDraw.Draw(img, "RGBA")
        refl.rectangle([sun_x - 26, base_y, sun_x + 26, H],
                       fill=sun_col + (90,))

    # Legibility scrim at the bottom (the card draws the place name below/over it)
    scrim = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(scrim)
    for i, y in enumerate(range(int(H * 0.6), H)):
        a = int(150 * (y - H * 0.6) / (H * 0.4))
        sd.line([(0, y), (W, y)], fill=(10, 14, 22, a))
    img = Image.alpha_composite(img.convert("RGBA"), scrim).convert("RGB")

    # Gentle vignette
    vig = Image.new("L", (W, H), 0)
    vd = ImageDraw.Draw(vig)
    vd.ellipse([-W * 0.2, -H * 0.2, W * 1.2, H * 1.2], fill=255)
    vig = vig.filter(ImageFilter.GaussianBlur(180))
    dark = Image.new("RGB", (W, H), (0, 0, 0))
    img = Image.composite(img, dark, vig)
    return img

def vgradient_local(draw, top, bottom, y0, y1):
    span = max(1, y1 - y0)
    for y in range(y0, y1):
        draw.line([(0, y), (W, y)], fill=lerp(top, bottom, (y - y0) / span))

def write_imageset(pid, img):
    name = f"photo-{pid}"
    d = os.path.join(ASSETS, f"{name}.imageset")
    os.makedirs(d, exist_ok=True)
    img.save(os.path.join(d, f"{name}.png"), optimize=True)
    json.dump(
        {"images": [{"filename": f"{name}.png", "idiom": "universal"}],
         "info": {"author": "xcode", "version": 1}},
        open(os.path.join(d, "Contents.json"), "w"), indent=2)

def main():
    places = parse_places()
    print(f"Found {len(places)} places")
    for pid, name, primary in places:
        img = generate(pid, name, primary)
        write_imageset(pid, img)
    print(f"Wrote {len(places)} imagesets to {ASSETS}")

if __name__ == "__main__":
    main()
