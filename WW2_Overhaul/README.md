# WW2 Overhaul (Civ 6)

Goal: Make Civilization VI feel more like a simplified HOI4 / WW2-focused game.
Wars and industry first. Domination is the only victory. Long wars are expected (loyalty disabled).

## What is implemented so far

### Core rules
- **Only Domination victory** is enabled. Culture, Science, Religion, Diplomatic, Score victories are disabled.
- **Loyalty system heavily reduced / effectively disabled** for long WW2-style wars (cities do not flip easily from loyalty pressure).
- **City combat** made much more dangerous: units deal significantly more damage to cities / districts.
- **Navy and Air** units receive strength and combat bonuses.
- **Unit promotions** and **Corps / Army formations** heavily buffed so a 2-star promoted unit (or formed unit) is roughly as strong as two regular units.
- **Oil maintenance concept** prepared (units that need oil will check for it; full Lua logic still TODO).
- Units do **not** have increased production costs.

### Start options (planned / partial)
- Game is intended to start in **1936** (Industrial/Modern era focus).
- Free choice of civilization / leader, including fictional or non-existing countries (Yugoslavia example, etc.).
- Custom starting locations support planned.

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
│   └── WW2_Start.sql          (placeholders for 1936 + free civ select)
└── Lua/                     (future oil maintenance, start logic, etc.)
```

## How to use
1. Copy the `WW2_Overhaul` folder into your Civ 6 Mods directory (or load via ModBuddy / Steam).
2. Enable **only** this mod (or carefully with compatible ones).
3. Start a new game. Domination is the only win condition.

## Next steps (TODO)
- [ ] Proper 1936 start year + era unlocks
- [ ] Free civilization / leader selection UI (including custom nations like Yugoslavia)
- [ ] Full oil maintenance Lua (units without oil get combat/movement penalties)
- [ ] More WW2 unit lines and promotions
- [ ] War weariness tweaks that do not use loyalty
- [ ] Stronger Industrial Zone / military production focus
- [ ] Custom governments / policies for Total War

Do not edit the other folders in this repository (Serbia_Civ_Pack, templates, etc.). This is a separate project.
