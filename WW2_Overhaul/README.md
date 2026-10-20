# WW2 Overhaul v2 — HOI4-style Civ 6 ruleset

**Requires:** Rise & Fall + Gathering Storm  
**Compatible with:** Serbia Civilization Pack (does **not** break or redefine Serbia leaders)

## Goal

A stable, playable WW2 ruleset: Domination-only, deep Industrial start, hard science, oil, supply, army doctrine, stubbornness when losing land, and diplomacy Join (keep land / no army vs absorb).

## How to start

1. Enable **WW2 Overhaul** + **Serbia Civilization Pack**.
2. Create Game → **Advanced Setup**.
3. Set **Ruleset = WW2 Overhaul**.
   - Start era locked to **Industrial**.
   - Defaults: Continents + Large, no goody huts.
   - Victories forced to **Domination only**.
   - **Army Doctrine**: Light (+3 CS) / Medium (+7) / Heavy (+14).
4. Pick Serbia leaders (Tito, Draža, Milošević, Dušan) or base Germany / England / France / Russia / Poland / Spain / Hungary, or WW2 Yugoslavia.
5. New game only.

### Europe map

Stock game has no Europe TSL. Use **Continents Large**, or **YnAMP** Europe / Greatest Earth with TSL for real borders. Ruleset still applies.

## Core systems

| System | Behavior |
|--------|----------|
| Victory | Domination only |
| Loyalty | Foreign city pressure disabled; ages remain |
| Start | Industrial era + extra late Industrial / early Modern tech (nukes not granted) |
| Science | Low pop science, weaker campuses, nuclear 3×, late military 2× |
| Oil | 0 Oil → modern armor/ships/air drop to 1 movement (no extra unit cost) |
| Production | Stronger IZ + global military production |
| Combat | Stronger navy/air, harder city hits, slower heal outside friendly |
| Promotions / Corps / Army | Heavily buffed |
| Army Doctrine | Advanced Setup: Light / Medium / Heavy |
| Stubbornness | Policy base +4 CS / +3 heal; lose cities → +25% Prod +8 CS for 25 turns, 5-turn cooldown (save-safe) |
| Supply | Supply Depot building (regional heal/CS/prod); Supply Station builder improvement |
| Join | `WW2_TryJoinLocal(id)` keep land no army; `WW2_TryAbsorbLocal(id)` transfer/subordinate; Axis Align / Comintern soft coop |
| Ideology | Extra bonuses on Democracy / Fascism / Communism |

## Serbia pack

No Serbia-specific WW2 bonuses. Serbia leaders load under the same ruleset. Unit upgrades are FK-safe if intermediate units are missing.

## Not in v2 (by design)

- Full Europe country picker on main menu
- Custom oil/supply lens
- Guaranteed full AI annex UI inside the diplomacy panel (Firetuner helpers provided; full diplo UI add-in is a separate step)

## Files

Gameplay SQL under `Data/`, Lua under `Lua/`, ruleset registration in `Data/WW2_Ruleset.xml`.
