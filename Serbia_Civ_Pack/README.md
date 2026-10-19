# Serbia Civilization Pack (Civ VI)

Adds **Serbia** with four leaders: **Josip Broz Tito**, **Draža Mihailović**, **Slobodan Milošević**, and **Stefan Dušan**.

**Version 22+** — gameplay polish + custom portrait pipeline.

## Requirements
- Civilization VI with **Rise and Fall** and **Gathering Storm**

## Install (Epic / Windows)
1. Fully quit Civ 6.
2. Delete any old `Serbia_Civ_Pack` folder under:
   `Documents/My Games/Sid Meier's Civilization VI (Epic)/Mods/`
3. Copy the entire `Serbia_Civ_Pack` folder from this repo into that `Mods` folder.
4. **Leader portraits (required for faces):** extract the portrait DDS pack into `Serbia_Civ_Pack/Art/` **or** run:
   ```bash
   pip install pillow
   python3 tools/generate_leader_portraits.py
   ```
   (needs ImageMagick `convert`). See `Art/PORTRAITS_README.md`.
5. Enable **Serbia Civilization Pack** in Additional Content → Mods.
6. Start a **new** game (not an old save).

## Features

### Civilization — *Raskrsce Svetova*
- Domestic & international trade routes: +2 Gold, +1 Culture
- Mines: +1 Production, +1 Faith
- Walls: +1 Culture
- Unique building: **Manastir** (Temple replacement)
- Unique improvement: **Spomenik** (Hills, Civil Engineering)

### Leaders
| Leader | Ability | Unique Unit |
|--------|---------|-------------|
| **Tito** | IZ +2 Prod/+2 Sci; Campus +2 Prod; Communism +25% Prod & Sci | **Partizani** (Infantry) |
| **Draža** | +8 Faith/city; buy units/buildings/districts with Faith; **Gold equal to total Faith output** | **Chetnik** (Musketman) |
| **Milošević** | +2 Culture, +10 Loyalty, −50% war weariness, +10 CS all units | **Neva-M** (Artillery) |
| **Dušan** | +2 Culture, +2 Loyalty | **Almanska Garda** (Knight) |

### Debug panel (dev)
- Press **F8** or **F12** in-game (or **DBG** top-right).
- To disable: set `SERBIA_ENABLE_DEBUG = false` in both `UI/SerbiaDebug.lua` and `Scripts/SerbiaCheats.lua`.

## Known limits
- Portraits are **2D** (loading screen + icons). Full 3D animated leaders need Asset Editor / BLP packs.
- Unique unit models reuse closest base-game unit art.

## Troubleshooting
- Pink/missing leader faces → DDS files missing under `Art/`; run the generator or extract the portrait zip.
- Leaders missing on setup → enable R&F + GS; domain is `Players:Expansion2_Players`.
- Check `Logs/Database.log` and `Logs/Modding.log`.

## Version
See `Serbia_Civ_Pack.modinfo` `version` attribute.
