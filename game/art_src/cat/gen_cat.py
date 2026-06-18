#!/usr/bin/env python3
"""Procedural 64x64 cozy black-cat sprite generator.

Produces an original "cozy black cat" idle/sit sprite in the hi-fi modern
pixel-art style described in DESIGN.md (§15): not chunky retro, warm rim
light, soft shading. Output is a clean 64x64 RGBA PNG plus an 8x preview.

Run:  python3 gen_cat.py
"""

from PIL import Image, ImageDraw

W = H = 64

# --- palette (charcoal "black" cat, warm rim light, cozy not clinical) ---
TRANSPARENT = (0, 0, 0, 0)
OUTLINE     = (18, 16, 24, 255)   # near-black outline, slightly purple
FUR_DARK    = (33, 31, 42, 255)   # shadow fur
FUR         = (48, 45, 60, 255)   # base fur
FUR_LIGHT   = (66, 62, 82, 255)   # lit fur / rim
FUR_RIM     = (96, 84, 104, 255)  # warm highlight edge
BELLY       = (60, 56, 74, 255)   # chest/belly lighter patch
EAR_PINK    = (181, 107, 126, 255)
NOSE_PINK   = (214, 132, 150, 255)
EYE_GREEN   = (143, 217, 79, 255)
EYE_GREEN_D = (96, 168, 52, 255)
PUPIL       = (20, 22, 16, 255)
WHITE       = (242, 244, 238, 255)
WHISKER     = (150, 146, 162, 200)


def new_canvas():
    img = Image.new("RGBA", (W, H), TRANSPARENT)
    return img, ImageDraw.Draw(img)


def px(d, x, y, c):
    if 0 <= x < W and 0 <= y < H:
        d.point((x, y), fill=c)


def fill_ellipse(d, box, c):
    d.ellipse(box, fill=c)


def build():
    img, d = new_canvas()

    # ---- BODY (sitting, egg shaped) ----
    # outline pass slightly larger, then fill
    fill_ellipse(d, (17, 33, 47, 61), OUTLINE)
    fill_ellipse(d, (18, 34, 46, 61), FUR)
    # body shading: darker base, lit top-left
    fill_ellipse(d, (21, 36, 43, 58), FUR)
    fill_ellipse(d, (22, 46, 42, 60), FUR_DARK)        # lower body shadow
    # chest/belly lighter patch
    fill_ellipse(d, (26, 40, 38, 57), BELLY)
    # rim light upper-left of body
    d.arc((19, 35, 45, 60), 150, 250, fill=FUR_RIM)

    # ---- TAIL curling along the right side, resting beside the front paw ----
    fill_ellipse(d, (44, 41, 57, 55), OUTLINE)
    fill_ellipse(d, (45, 42, 56, 54), FUR_DARK)
    fill_ellipse(d, (46, 43, 54, 52), FUR)
    # tail tip sweeping toward the front
    fill_ellipse(d, (42, 52, 53, 62), OUTLINE)
    fill_ellipse(d, (43, 53, 52, 61), FUR_DARK)
    fill_ellipse(d, (44, 54, 50, 60), FUR)
    d.arc((46, 43, 54, 52), 150, 250, fill=FUR_LIGHT)   # tail rim light

    # ---- FRONT PAWS (two tidy, symmetric paws tucked at the front) ----
    for cx in (27, 38):
        fill_ellipse(d, (cx - 5, 54, cx + 5, 63), OUTLINE)
        fill_ellipse(d, (cx - 4, 55, cx + 4, 62), FUR)
        fill_ellipse(d, (cx - 4, 58, cx + 4, 62), FUR_DARK)
        d.arc((cx - 4, 55, cx + 4, 62), 150, 250, fill=FUR_LIGHT)
    # subtle toe seams
    px(d, 27, 60, FUR_DARK); px(d, 38, 60, FUR_DARK)

    # ---- HEAD (big, round, chibi) ----
    head_box = (13, 7, 51, 41)
    fill_ellipse(d, (12, 6, 52, 42), OUTLINE)
    fill_ellipse(d, head_box, FUR)
    # head shading: bottom darker, top-left lit
    fill_ellipse(d, (16, 22, 48, 41), FUR)
    fill_ellipse(d, (18, 30, 46, 41), FUR_DARK)
    d.arc((14, 8, 50, 40), 150, 260, fill=FUR_RIM)     # rim light
    fill_ellipse(d, (20, 11, 40, 26), FUR_LIGHT)       # forehead light

    # ---- EARS ----
    # left ear
    d.polygon([(16, 16), (13, 1), (29, 11)], fill=OUTLINE)
    d.polygon([(17, 15), (15, 4), (28, 12)], fill=FUR)
    d.polygon([(18, 14), (16, 7), (25, 12)], fill=EAR_PINK)
    # right ear
    d.polygon([(48, 16), (51, 1), (35, 11)], fill=OUTLINE)
    d.polygon([(47, 15), (49, 4), (36, 12)], fill=FUR)
    d.polygon([(46, 14), (48, 7), (39, 12)], fill=EAR_PINK)
    # ear rim light
    px(d, 14, 5, FUR_RIM); px(d, 15, 7, FUR_RIM)
    px(d, 50, 5, FUR_RIM); px(d, 49, 7, FUR_RIM)

    # ---- EYES (big, cozy, green) ----
    for ex in (25, 39):
        fill_ellipse(d, (ex - 5, 21, ex + 5, 33), OUTLINE)
        fill_ellipse(d, (ex - 4, 22, ex + 4, 32), EYE_GREEN)
        fill_ellipse(d, (ex - 4, 27, ex + 4, 32), EYE_GREEN_D)   # lower shade
        fill_ellipse(d, (ex - 2, 22, ex + 2, 32), PUPIL)         # pupil
        # highlights
        px(d, ex - 1, 24, WHITE); px(d, ex, 24, WHITE)
        px(d, ex - 1, 25, WHITE)
        px(d, ex + 2, 29, EYE_GREEN)

    # ---- NOSE + MOUTH ----
    d.polygon([(31, 33), (33, 33), (32, 35)], fill=NOSE_PINK)
    px(d, 32, 36, OUTLINE)
    # gentle smile
    px(d, 30, 37, OUTLINE); px(d, 31, 38, OUTLINE)
    px(d, 33, 38, OUTLINE); px(d, 34, 37, OUTLINE)

    # ---- WHISKERS ----
    for (sx, sy, ex, ey) in [
        (20, 34, 9, 32), (20, 36, 9, 37),
        (44, 34, 55, 32), (44, 36, 55, 37),
    ]:
        d.line((sx, sy, ex, ey), fill=WHISKER)

    return img


def save(img):
    base = "/home/user/Cat-game/game/assets/sprites/cat"
    img.save(f"{base}/cat_idle_64.png")
    big = img.resize((W * 8, H * 8), Image.NEAREST)
    big.save(f"{base}/cat_idle_64_preview_8x.png")
    print("saved cat_idle_64.png and 8x preview")


if __name__ == "__main__":
    save(build())
