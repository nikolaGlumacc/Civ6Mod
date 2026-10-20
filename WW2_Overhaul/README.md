# WW2 Overhaul (Ruleset) for Civilization VI

A WW2 / HOI4-style overhaul built **on top of** the official Rise and Fall + Gathering Storm ruleset.

You keep **everything** from Rise & Fall and Gathering Storm:
- Dark Ages & Golden Ages
- Governors
- Emergencies
- Loyalty system (pressure disabled so long wars stay playable)
- All other RF/GS features

## Compatibility with Serbia Civilization Pack

**Fully supported.**  
Enable both mods together:

1. **Serbia Civilization Pack** (your mod with Tito, Draza, Milosevic, Dusan)
2. **WW2 Overhaul**

Load order recommendation: Serbia first, then WW2 Overhaul.  
Your Serbian leaders work normally under the WW2 rules (Domination only, stronger combat, oil maintenance, 1936-style start, etc.).

The sample "Yugoslavia" nation in this mod is just an extra optional civ and does not conflict with your Serbia pack.

## Features

| Feature | Status |
|---------|--------|
| Only Domination victory | Done |
| Loyalty pressure disabled (long wars) | Done |
| Units deal much more damage to cities | Done |
| Navy & Air stronger | Done |
| Promotions + Corps/Army heavily buffed | Done |
| No extra unit production cost | Done |
| Oil maintenance (no oil = movement penalty) | Done (Lua) |
| Stronger Industrial / military production | Done |
| 1936-style start (era + tech/civic grants) | Done (Lua) |
| Free civ/leader choice | Supported |
| Sample extra nation: Yugoslavia | Done |
| Full Rise & Fall + Gathering Storm systems | Required & preserved |
| Works with Serbia Civ Pack | Done |

## Requirements
- Rise and Fall
- Gathering Storm

## How to use
1. Enable **Serbia Civilization Pack** (optional but recommended)
2. Enable **WW2 Overhaul**
3. Make sure you are using the **Expansion 2** ruleset (Gathering Storm)
4. Start a new game. The start logic pushes everyone into a late-Industrial / early-Modern feel
5. Play as any of your Serbian leaders or any other civ

## What else I would add (recommended next features)

These fit the HOI4 / WW2 feel while staying realistic for Civ 6:

1. **War Economy / National Focus style policies**  
   Simple military, industrial, and research "focus" cards that give big temporary bonuses (like HOI4 focuses but much lighter).

2. **Better strategic resource loop**  
   Oil, Rubber, Aluminium, Steel matter more. Cities can build synthetic plants or trade more aggressively.

3. **Front-line / supply feel**  
   Units far from your territory or from a supply depot heal slower and fight worse (simple distance or "out of supply" modifier).

4. **More WW2 unit lines**  
   Distinct light/medium/heavy tanks, better artillery, dedicated anti-tank, more plane types, troop transports.

5. **War Weariness that does not use loyalty**  
   Long wars raise amenity penalties or reduce production in non-core cities instead of flipping cities.

6. **Simple ideology / government lean**  
   Democracy / Fascism / Communism give different military and production bonuses (already partially in RF/GS, can be tuned).

7. **Custom Europe 1936 map support**  
   True-start locations for major powers + your Serbian leaders.

8. **Leader-specific WW2 flavor for Serbia**  
   Extra bonuses or agendas for Tito / Draza / etc. when the WW2 ruleset is active (optional).

Tell me which of these you want next and I will implement them.

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

Do not edit the other folders in this repository. This is a separate project that is designed to run alongside Serbia_Civ_Pack.
