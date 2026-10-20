# WW2 Overhaul (Ruleset) – v1.0 READY

Fully playable WW2 / HOI4-style ruleset for Civilization VI.
Built on **Rise and Fall + Gathering Storm**. Compatible with **Serbia Civilization Pack**.

---

## Quick Start

1. Enable **Rise and Fall** + **Gathering Storm**
2. Enable **Serbia Civilization Pack** (optional but recommended)
3. Enable **WW2 Overhaul**
4. Create Game → choose **Expansion 2** ruleset
5. In **Advanced Setup** pick your **Army Doctrine** (Light / Medium / Heavy)
6. Start the game

---

## Features (all working)

| Feature | What it does |
|---------|--------------|
| **Only Domination victory** | Culture / Science / Religion / Diplomatic / Score disabled |
| **Army Doctrine** | Selectable in Advanced Setup: Light (+3 CS), Medium (+7 CS), Heavy (+14 CS) |
| **National Stubbornness** | Lose cities → +25% Production & +8 Combat Strength for 25 turns, then 5-turn cooldown |
| **Supply Depot** | City building (regional). +8 healing, +3 CS, +3 Production |
| **Supply Station** | Optional Builder improvement |
| **Oil maintenance** | No Oil = modern tanks/ships/planes lose movement |
| **Stronger Industry** | Industrial Zone + buildings give more Production |
| **Wildcard policies** | War Economy, Total Mobilization, Scientific Effort, Offensive Spirit, Defensive Lines, National Stubbornness, Blitz Doctrine, War of Attrition |
| **Ideology bonuses** | Clearer Democracy / Fascism / Communism effects |
| **1936-style start** | Grants Industrial / early Modern techs & civics |
| **Loyalty pressure off** | Long wars stay playable |
| **Navy & Air stronger** | Flat combat bonuses |
| **Promotions & Corps/Army buffed** | 2-star / formed units hit much harder |
| **Yugoslavia sample** | Extra playable nation (does not conflict with Serbia pack) |

---

## Design notes

- Losing territory makes you **stronger** for a while (National Stubbornness), not weaker.
- Supply is **city-based** (Depot covers the whole city radius).
- No new strategic resources were added.
- No Serbia-specific bonuses (your leaders work as normal under the ruleset).

---

## Known limitations (honest)

- Full Europe 1936 territory selector (main-menu outline) is **not** included yet — needs a custom scenario.
- Supply / Oil visual lens is **not** included yet.
- Some temporary modifiers rely on Civ 6’s modifier system; in rare edge cases a reload can refresh them.

---

## Files

```
WW2_Overhaul/
├── WW2_Overhaul.modinfo
├── README.md
├── Data/          (all SQL)
├── Lua/           (all scripts)
└── Text/          (localization)
```

---

**v1.0 is ready to play.**  
Enable it with your Serbia pack and test a game. If anything breaks or feels off, tell me exactly what and I’ll fix it.
