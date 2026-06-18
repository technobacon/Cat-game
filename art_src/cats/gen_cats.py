#!/usr/bin/env python3
"""
Generate 5 base black-cat models at native 64x64 for the cozy habitat game.

Style target (DESIGN.md §15): hi-fi "modern" pixel art, warm golden-hour mood.
A "black" cat is rendered NOT as flat black but as a cool deep-charcoal fur
with a darker underside, a warm rim light along upper edges (golden-hour key
light from the upper-left), amber/green eyes, dusty-rose inner ears, and a
soft elliptical contact shadow. Drawn directly at 64x64 with aliased shapes so
every pixel is a real pixel (no anti-alias mush) -> true pixel art.

Outputs:
  cat_<n>_<pose>.png      transparent 64x64 sprites
  _contact_sheet.png      6x-scaled warm preview of all five
"""
from PIL import Image, ImageDraw

S = 64

# ---- warm golden-hour "black cat" palette -------------------------------
RIM      = (122,  98,  66, 255)   # warm golden rim light (top edges)
TOP      = ( 66,  62,  84, 255)   # lit upper fur (cool charcoal, slightly warm)
BASE     = ( 45,  42,  60, 255)   # main fur
MID      = ( 35,  33,  48, 255)   # shaded fur
DARK     = ( 24,  22,  34, 255)   # underside / deep shadow
INNEREAR = (110,  72,  80, 255)   # dusty rose
NOSE     = (208, 132, 132, 255)   # muted pink
SHADOW   = (  0,   0,   0,  70)   # contact shadow (on premultiplied warm bg)
EYE_AMBER = (242, 180,  65, 255)
EYE_GREEN = (150, 205,  95, 255)
PUPIL    = ( 20,  18,  26, 255)
GLINT    = (255, 244, 220, 255)


def shade(mask):
    """Take an L-mode silhouette mask -> shaded RGBA cat (no eyes/nose)."""
    px = mask.load()
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    out = img.load()
    # find vertical extent for gradient banding
    ys = [y for y in range(S) for x in range(S) if px[x, y] > 0]
    if not ys:
        return img
    top_y, bot_y = min(ys), max(ys)
    span = max(1, bot_y - top_y)
    for y in range(S):
        for x in range(S):
            if px[x, y] == 0:
                continue
            t = (y - top_y) / span  # 0 top .. 1 bottom
            if t < 0.30:
                c = TOP
            elif t < 0.62:
                c = BASE
            elif t < 0.82:
                c = MID
            else:
                c = DARK
            out[x, y] = c
    # rim light: a silhouette pixel whose up / up-left neighbour is empty,
    # in the upper 60% of the body, catches the warm key light.
    for y in range(S):
        for x in range(S):
            if px[x, y] == 0:
                continue
            t = (y - top_y) / span
            if t > 0.60:
                continue
            up    = px[x, y - 1] if y > 0 else 0
            upl   = px[x - 1, y - 1] if (x > 0 and y > 0) else 0
            left  = px[x - 1, y] if x > 0 else 0
            if up == 0 or (upl == 0 and left == 0):
                out[x, y] = RIM
    return img


def ear(d, cx, ty, w, h, inner=True):
    """Triangular ear with dusty-rose inner."""
    d.polygon([(cx - w, ty + h), (cx, ty), (cx + w, ty + h)], fill=255)


def eyes(img, pairs, color):
    """Small almond eyes: 3px-wide iris with clipped corners, 1px slit pupil."""
    for (ex, ey) in pairs:
        # iris (3x3 with top/bottom corners trimmed -> almond)
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                if abs(dx) == 1 and abs(dy) == 1:
                    continue  # trim corners
                if img.getpixel((ex + dx, ey + dy))[3] > 0:
                    img.putpixel((ex + dx, ey + dy), color)
        img.putpixel((ex, ey - 1), PUPIL)    # vertical slit pupil
        img.putpixel((ex, ey), PUPIL)
        img.putpixel((ex - 1, ey - 1), GLINT)  # tiny catch-light


def inner_ears(img, mask_inner):
    px = mask_inner.load()
    for y in range(S):
        for x in range(S):
            if px[x, y] > 0 and img.getpixel((x, y))[3] > 0:
                img.putpixel((x, y), INNEREAR)


def nose(img, x, y):
    img.putpixel((x, y), NOSE)
    img.putpixel((x + 1, y), NOSE)


def finalize(mask, build_extras):
    cat = shade(mask)
    build_extras(cat)
    return cat


# ---- pose builders -------------------------------------------------------
def m(funcs):
    mask = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(mask)
    funcs(d)
    return mask


def cat_sitting():
    """Classic upright sit, tail curled around the front paws."""
    def body(d):
        d.ellipse([20, 30, 44, 60], fill=255)        # seated body
        d.ellipse([22, 12, 42, 32], fill=255)        # head
        ear(d, 25, 8, 5, 9)                           # L ear
        ear(d, 39, 8, 5, 9)                           # R ear
        d.ellipse([16, 44, 30, 58], fill=255)         # tail curl front
        d.ellipse([12, 40, 22, 56], fill=255)
    mask = m(body)

    def inner():
        mi = Image.new("L", (S, S), 0)
        di = ImageDraw.Draw(mi)
        di.polygon([(24, 13), (25, 8), (28, 13)], fill=255)
        di.polygon([(36, 13), (39, 8), (40, 13)], fill=255)
        return mi
    ie = inner()

    def extras(cat):
        inner_ears(cat, ie)
        eyes(cat, [(28, 21), (36, 21)], EYE_AMBER)
        nose(cat, 31, 25)
    return finalize(mask, extras)


def cat_loaf():
    """Bread-loaf: paws tucked, compact, content."""
    def body(d):
        d.rounded_rectangle([16, 34, 48, 56], radius=10, fill=255)  # loaf
        d.ellipse([22, 16, 42, 36], fill=255)                        # head
        ear(d, 25, 12, 5, 9)
        ear(d, 39, 12, 5, 9)
        d.ellipse([44, 46, 54, 56], fill=255)                        # tail tip beside
    mask = m(body)

    def inner():
        mi = Image.new("L", (S, S), 0)
        di = ImageDraw.Draw(mi)
        di.polygon([(24, 17), (25, 12), (28, 17)], fill=255)
        di.polygon([(36, 17), (39, 12), (40, 17)], fill=255)
        return mi
    ie = inner()

    def extras(cat):
        inner_ears(cat, ie)
        eyes(cat, [(28, 25), (36, 25)], EYE_GREEN)
        nose(cat, 31, 29)
    return finalize(mask, extras)


def cat_walking():
    """Side profile, mid-stride, tail held high — alert and roaming."""
    def body(d):
        d.ellipse([14, 30, 46, 46], fill=255)         # body
        d.ellipse([40, 22, 56, 38], fill=255)         # head (right)
        ear(d, 45, 18, 4, 8)
        ear(d, 52, 18, 4, 8)
        # tail sweeping up-left
        d.line([(16, 38), (8, 24), (10, 14)], fill=255, width=5)
        # legs
        d.rectangle([18, 44, 22, 56], fill=255)
        d.rectangle([26, 44, 30, 56], fill=255)
        d.rectangle([34, 44, 38, 56], fill=255)
        d.rectangle([40, 44, 44, 56], fill=255)
    mask = m(body)

    def inner():
        mi = Image.new("L", (S, S), 0)
        di = ImageDraw.Draw(mi)
        di.polygon([(44, 23), (45, 18), (47, 23)], fill=255)
        di.polygon([(51, 23), (52, 18), (54, 23)], fill=255)
        return mi
    ie = inner()

    def extras(cat):
        inner_ears(cat, ie)
        eyes(cat, [(50, 30)], EYE_AMBER)
        nose(cat, 55, 33)
    return finalize(mask, extras)


def cat_curled():
    """Curled sleeping ball, nose-to-tail."""
    def body(d):
        d.ellipse([14, 30, 50, 56], fill=255)         # round body
        d.ellipse([16, 34, 30, 50], fill=255)         # head tucked left
        ear(d, 19, 32, 4, 7)
        ear(d, 26, 32, 4, 7)
        # tail wrapping over front
        d.arc([18, 34, 52, 58], start=300, end=120, fill=255, width=6)
    mask = m(body)

    def extras(cat):
        # sleeping: closed-eye curves
        d = ImageDraw.Draw(cat)
        d.line([(20, 42), (24, 43)], fill=DARK, width=1)
        d.line([(26, 42), (29, 43)], fill=DARK, width=1)
        nose(cat, 16, 44)
    return finalize(mask, extras)


def cat_playful():
    """Play-bow / pounce crouch: front low, rear up, tail flicking."""
    def body(d):
        d.ellipse([22, 36, 50, 52], fill=255)         # raised rear
        d.ellipse([12, 40, 30, 54], fill=255)         # lowered front/shoulders
        d.ellipse([8, 30, 26, 46], fill=255)          # head down-left, alert
        ear(d, 12, 26, 4, 8)
        ear(d, 20, 26, 4, 8)
        # tail flicking up from rear
        d.line([(48, 44), (56, 30), (52, 20)], fill=255, width=4)
        # front paws planted low
        d.rectangle([14, 50, 18, 58], fill=255)
        d.rectangle([22, 50, 26, 58], fill=255)
    mask = m(body)

    def inner():
        mi = Image.new("L", (S, S), 0)
        di = ImageDraw.Draw(mi)
        di.polygon([(11, 31), (12, 26), (14, 31)], fill=255)
        di.polygon([(19, 31), (20, 26), (22, 31)], fill=255)
        return mi
    ie = inner()

    def extras(cat):
        inner_ears(cat, ie)
        eyes(cat, [(15, 38), (22, 38)], EYE_GREEN)
        nose(cat, 11, 42)
    return finalize(mask, extras)


def add_shadow(cat):
    """Composite a soft elliptical contact shadow under the cat (transparent)."""
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sh = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(sh)
    # find horizontal extent at the feet
    px = cat.load()
    xs = [x for x in range(S) for y in range(S) if px[x, y][3] > 0]
    ys = [y for x in range(S) for y in range(S) if px[x, y][3] > 0]
    if xs:
        cx = (min(xs) + max(xs)) // 2
        by = max(ys)
        w = (max(xs) - min(xs)) // 2 + 2
        d.ellipse([cx - w, by - 3, cx + w, by + 3], fill=SHADOW)
    out = Image.alpha_composite(out, sh)
    out = Image.alpha_composite(out, cat)
    return out


CATS = [
    ("sitting", cat_sitting),
    ("loaf",    cat_loaf),
    ("walking", cat_walking),
    ("curled",  cat_curled),
    ("playful", cat_playful),
]


def main():
    sprites = []
    for i, (name, fn) in enumerate(CATS, 1):
        cat = add_shadow(fn())
        fn_out = f"cat_{i}_{name}.png"
        cat.save(fn_out)
        sprites.append((name, cat))
        print("wrote", fn_out)

    # contact sheet: 6x scaled, warm golden-hour backdrop, labels-free
    scale = 6
    pad = 8
    cell = S + pad * 2
    sheet = Image.new("RGBA", (cell * len(sprites), cell + 14),
                      (58, 44, 40, 255))  # warm dim
    for idx, (name, cat) in enumerate(sprites):
        sheet.alpha_composite(cat, (idx * cell + pad, pad))
    sheet = sheet.resize((sheet.width * scale, sheet.height * scale),
                         Image.NEAREST)
    sheet.save("_contact_sheet.png")
    print("wrote _contact_sheet.png", sheet.size)


if __name__ == "__main__":
    main()
