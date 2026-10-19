# Serbia Civilization Pack (Civ VI)

Adds **Serbia** with four leaders: **Josip Broz Tito**, **Draža Mihailović**, **Slobodan Milošević**, and **Stefan Dušan**.

## Requirements
- Civilization VI with **Rise and Fall** and **Gathering Storm**

## Install (Epic / Windows)
1. Fully quit Civ 6.
2. Delete any old `Serbia_Civ_Pack` folder under:
   `Documents/My Games/Sid Meier's Civilization VI (Epic)/Mods/`
3. Copy the entire `Serbia_Civ_Pack` folder from this repo into that `Mods` folder.
4. **Important:** If your Documents folder is on **OneDrive**, copy the mod to a local path or pause sync while updating — stale files caused most icon/load bugs.
5. Optional leader faces: extract `Serbia_Leader_Face_Icons.zip` DDS files into `Serbia_Civ_Pack/Art/` (Tito/Draža/Milošević portraits).
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
- To disable for a “clean” playthrough, set `SERBIA_ENABLE_DEBUG = false` at the top of `UI/SerbiaDebug.lua` and `Scripts/SerbiaCheats.lua`.

## Known limits
- Custom **3D leader models** are not included (default leader body is normal for icon/text packs).
- Unique unit **3D models** use closest base-game unit types via icons; full custom models need Asset Editor.
- Tesla keeps base Engineer class but gains Electricity / Radio / Telecommunications eurekas on action.

## Version
See `Serbia_Civ_Pack.modinfo` `version` attribute.
