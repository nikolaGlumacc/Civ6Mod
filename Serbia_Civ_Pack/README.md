# Serbia Civilization Pack (Civ VI)

Adds **Serbia** with four leaders: **Josip Broz Tito**, **Draža Mihailović**, **Slobodan Milošević**, and **Stefan Dušan**.

**Version 22** — polished load path (art, agendas, units, frontend colors).

## Requirements
- Civilization VI with **Rise and Fall** and **Gathering Storm**

## Install (Epic / Windows)
1. Fully quit Civ 6.
2. Delete any old `Serbia_Civ_Pack` folder under:
   `Documents/My Games/Sid Meier's Civilization VI (Epic)/Mods/`
3. Copy the entire `Serbia_Civ_Pack` folder from this repo into that `Mods` folder.
4. **Important:** If your Documents folder is on **OneDrive**, copy the mod to a local path or pause sync while updating — stale files caused most icon/load bugs.
5. Optional leader faces: ensure `Art/LEADER_*_NEUTRAL.dds` and `Art/ICON_LEADER_*_*.dds` exist (from the face pack if you use one).
6. Enable **Serbia Civilization Pack** in Additional Content → Mods.
7. Start a **new** game (not an old save).

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
- To disable for a clean playthrough, set `SERBIA_ENABLE_DEBUG = false` at the top of **both**:
  - `UI/SerbiaDebug.lua`
  - `Scripts/SerbiaCheats.lua`

## Known limits
- Custom **3D leader models** are not included (2D portraits + default body is normal for this pack).
- Unique unit **3D models** reuse closest base-game unit art via Units.artdef / icons.
- Nikola Tesla (Great Engineer) gains Electricity / Radio / Telecommunications eurekas on action.

## Troubleshooting
- Leaders missing on setup screen → ensure Rise & Fall + Gathering Storm are enabled; only `Players:Expansion2_Players` is registered.
- Pink/missing icons → re-copy `Art/` DDS files; avoid OneDrive partial sync.
- Database errors → delete the mod folder completely, re-copy, start a **new** game.
- Check `Documents/.../Logs/Database.log` and `Modding.log` if something fails to load.

## Version
See `Serbia_Civ_Pack.modinfo` `version` attribute (currently **22**).
