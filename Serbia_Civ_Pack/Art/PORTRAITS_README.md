# Custom leader portraits

## What you need in this folder (`Art/`)

| Leader | Loading portrait | Icons |
|--------|------------------|-------|
| Tito | `LEADER_TITO_NEUTRAL.dds` | `ICON_LEADER_TITO_32/45/50/55/64/80/256.dds` |
| Draza | `LEADER_DRAZA_NEUTRAL.dds` | `ICON_LEADER_DRAZA_*.dds` |
| Milosevic | `LEADER_MILOSEVIC_NEUTRAL.dds` | `ICON_LEADER_MILOSEVIC_*.dds` |
| Dusan | `FALLBACK_NEUTRAL_LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC.dds` (already present) | `ICON_LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC_*.dds` (already present) |

Optional diplo names (same image as neutral):
- `FALLBACK_NEUTRAL_LEADER_TITO.dds`
- `FALLBACK_NEUTRAL_LEADER_DRAZA.dds`
- `FALLBACK_NEUTRAL_LEADER_MILOSEVIC.dds`

## Source PNGs (already in repo)
- `FALLBACK_NEUTRAL_TITO.png`
- `FALLBACK_NEUTRAL_DRAZA.png`
- `FALLBACK_NEUTRAL_MILOSEVIC.png`

## Generate DDS (recommended)

From the `Serbia_Civ_Pack` folder:

```bash
pip install pillow
# also install ImageMagick so `convert` is on PATH
python3 tools/generate_leader_portraits.py
```

Or extract the pre-built pack `Serbia_Leader_Portraits.zip` into this `Art/` folder (overwrite).

## After adding DDS
1. Quit Civ 6 fully
2. Refresh the mod folder
3. Start a **new** game
4. Confirm portraits on the leader select / loading screen
