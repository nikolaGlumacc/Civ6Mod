# WW2 Overhaul (Ruleset) for Civilization VI

A WW2 / HOI4-style overhaul built **on top of** the official Rise and Fall + Gathering Storm ruleset.

You keep **everything** from Rise & Fall and Gathering Storm:
- Dark Ages & Golden Ages
- Governors
- Emergencies
- Loyalty system (but pressure is disabled so long wars stay playable)
- All other RF/GS features

## Features

| Feature | Status |
|---------|--------|
| Only Domination victory | Done |
| Loyalty pressure disabled (long wars) | Done |
| Units deal much more damage to cities | Done |
| Navy & Air stronger | Done |
| Promotions + Corps/Army heavily buffed | Done |
| No extra unit production cost | Done |
| Oil maintenance (no oil = combat/movement penalty) | Done (Lua) |
| Stronger Industrial / military production | Done |
| 1936-style start (era + tech/civic grants) | Done (Lua) |
| Free civ/leader choice | Supported (works with Unrestricted Leaders style mods) |
| Sample custom nation: Yugoslavia | Done |
| Full Rise & Fall + Gathering Storm systems | Required & preserved |

## Requirements
- Rise and Fall
- Gathering Storm

## How to use
1. Enable this mod.
2. Make sure you are using the **Expansion 2** ruleset (Gathering Storm).
3. Start a new game. The start logic will push you into a late Industrial / early Modern feel (1936 style).
4. You can pick any civilization/leader. For maximum freedom use an "Unrestricted Leaders" type mod together with this one.
5. Yugoslavia is available as a playable civilization.

## Folder structure
```
WW2_Overhaul/
├── WW2_Overhaul.modinfo
├── README.md
├── Data/
│   ├── WW2_Victories.sql
│   ├── WW2_Loyalty.sql
│   ├── WW2_Combat.sql
│   ├── WW2_Promotions_Formations.sql
│   ├── WW2_Resources.sql
│   ├── WW2_Production.sql
│   ├── WW2_Start.sql
│   └── WW2_Yugoslavia.sql
├── Lua/
│   ├── WW2_OilMaintenance.lua
│   └── WW2_StartLogic.lua
└── Text/
    └── WW2_Text.xml
```

## Design notes
- Loyalty pressure is turned off so multi-year wars do not cause constant city flipping (WW2 theme).
- Dark Ages / Golden Ages still work normally — they are part of the RF ruleset we require.
- Oil: modern land/sea/air units that historically need oil get a combat + movement penalty if the player has 0 Oil.
- 1936 start is approximated by granting a large set of Industrial/Modern techs and civics at game start and setting a late starting era.

## Future ideas
- More historical WW2 units and promotions
- Simple national focuses / war economy policies
- Better Europe 1936 map support
- More custom nations (Czechoslovakia, etc.)

Do not edit the other folders in this repository. This is a separate project.
