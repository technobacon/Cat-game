# Cat sprite — placeholder hero art

A cozy black cat in the **hi-fi modern pixel-art** style (DESIGN.md §15): warm
rim light, soft shading, chibi proportions — not chunky retro. This is the
starter pet for the MVP vertical slice (DESIGN.md §16) and feeds milestone **M3**
(the cat: presence & roaming).

## Files

| File | Size | Purpose |
|------|------|---------|
| `cat_stand_64.png` | 64×64 RGBA | Standing 3/4-view pose, tail raised + curled (primary). |
| `cat_idle_64.png` | 64×64 RGBA | Seated idle pose. |
| `*_preview_8x.png` | 512×512 | Nearest-neighbour previews for review only (not shipped). |

## Regenerating

The sprite is generated procedurally so the palette/pose stay tweakable:

```bash
python3 ../../../art_src/cat/gen_cat.py   # requires Pillow
```

Source: [`game/art_src/cat/gen_cat.py`](../../../art_src/cat/gen_cat.py).

## Notes / next steps

- Original art, charcoal "black cat" palette with a warm highlight edge.
- When the Aseprite pipeline lands (DESIGN.md §15: `art_src/` → `assets/sprites/`
  as sheet + JSON, **animation tags = `SpriteFrames` animation names**), this
  idle becomes frame 0 of an `idle` tag; add `walk`, `sit`, `sleep`, `groom`
  tags for the M3 roaming + tells work.
