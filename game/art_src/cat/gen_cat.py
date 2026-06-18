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


def build_stand():
    """Black cat standing on all fours, 3/4 view, tail raised + curled."""
    img, d = new_canvas()

    # ---- FAR LEGS (drawn first, slightly darker, behind body) ----
    for cx in (28, 41):
        d.rectangle((cx - 2, 42, cx + 2, 57), fill=OUTLINE)
        d.rectangle((cx - 1, 43, cx + 1, 56), fill=FUR_DARK)
        fill_ellipse(d, (cx - 3, 54, cx + 3, 58), OUTLINE)
        fill_ellipse(d, (cx - 2, 55, cx + 2, 57), FUR_DARK)

    # ---- TAIL (rises from rear, sweeps up-right, tip curls) ----
    d.line([(45, 38), (52, 30), (55, 22), (53, 15), (47, 13)],
           fill=OUTLINE, width=6, joint="curve")
    d.line([(45, 38), (52, 30), (55, 22), (53, 15), (47, 13)],
           fill=FUR, width=4, joint="curve")
    d.line([(46, 36), (52, 29), (54, 22)], fill=FUR_LIGHT, width=1)
    fill_ellipse(d, (44, 11, 51, 18), OUTLINE)          # curled tip
    fill_ellipse(d, (45, 12, 50, 17), FUR)

    # ---- BODY (horizontal, angled down to the rear) ----
    fill_ellipse(d, (17, 28, 49, 50), OUTLINE)
    fill_ellipse(d, (18, 29, 48, 49), FUR)
    fill_ellipse(d, (20, 34, 46, 49), FUR_DARK)         # belly shadow
    d.arc((18, 29, 48, 48), 150, 280, fill=FUR_RIM)     # top rim light
    fill_ellipse(d, (21, 30, 41, 42), FUR_LIGHT)        # back lit
    fill_ellipse(d, (23, 39, 39, 49), BELLY)            # chest/belly

    # ---- NEAR LEGS (front of body, full tone) ----
    for cx in (24, 38):
        d.rectangle((cx - 3, 42, cx + 3, 57), fill=OUTLINE)
        d.rectangle((cx - 2, 43, cx + 2, 56), fill=FUR)
        d.rectangle((cx - 2, 51, cx + 2, 56), fill=FUR_DARK)
        d.line((cx - 2, 43, cx - 2, 54), fill=FUR_LIGHT)
        fill_ellipse(d, (cx - 4, 54, cx + 4, 59), OUTLINE)
        fill_ellipse(d, (cx - 3, 55, cx + 3, 58), FUR)
        px(d, cx, 57, FUR_DARK)                         # toe seam

    # ---- HEAD (up at the front-left, facing viewer) ----
    head_box = (8, 8, 34, 34)
    fill_ellipse(d, (7, 7, 35, 35), OUTLINE)
    fill_ellipse(d, head_box, FUR)
    fill_ellipse(d, (11, 22, 31, 34), FUR_DARK)         # lower face shadow
    d.arc((9, 9, 33, 33), 150, 270, fill=FUR_RIM)       # rim light
    fill_ellipse(d, (12, 11, 28, 23), FUR_LIGHT)        # forehead light

    # ---- EARS (upright, compact triangles) ----
    d.polygon([(11, 12), (12, 0), (22, 11)], fill=OUTLINE)
    d.polygon([(12, 11), (13, 3), (20, 11)], fill=FUR)
    d.polygon([(13, 10), (14, 6), (18, 11)], fill=EAR_PINK)
    d.polygon([(30, 12), (29, 0), (19, 11)], fill=OUTLINE)
    d.polygon([(29, 11), (28, 3), (21, 11)], fill=FUR)
    d.polygon([(28, 10), (27, 6), (23, 11)], fill=EAR_PINK)

    # ---- EYES (green, facing viewer) ----
    for ex in (16, 26):
        fill_ellipse(d, (ex - 3, 18, ex + 3, 27), OUTLINE)
        fill_ellipse(d, (ex - 2, 19, ex + 2, 26), EYE_GREEN)
        fill_ellipse(d, (ex - 2, 23, ex + 2, 26), EYE_GREEN_D)
        d.rectangle((ex - 1, 19, ex, 26), fill=PUPIL)
        px(d, ex - 1, 20, WHITE)

    # ---- NOSE + MOUTH ----
    d.polygon([(20, 27), (22, 27), (21, 29)], fill=NOSE_PINK)
    px(d, 21, 30, OUTLINE)
    px(d, 19, 31, OUTLINE); px(d, 20, 31, OUTLINE)
    px(d, 22, 31, OUTLINE); px(d, 23, 31, OUTLINE)

    # ---- WHISKERS ----
    for (sx, sy, ex, ey) in [
        (12, 28, 2, 26), (12, 30, 2, 31),
        (30, 28, 40, 26), (30, 30, 40, 31),
    ]:
        d.line((sx, sy, ex, ey), fill=WHISKER)

    return img


def save(img, name):
    base = "/home/user/Cat-game/game/assets/sprites/cat"
    img.save(f"{base}/{name}.png")
    img.resize((W * 8, H * 8), Image.NEAREST).save(f"{base}/{name}_preview_8x.png")
    print(f"saved {name}.png and 8x preview")


if __name__ == "__main__":
    save(build(), "cat_idle_64")
    save(build_stand(), "cat_stand_64")
