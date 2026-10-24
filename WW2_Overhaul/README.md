# WW2 Overhaul v3.5

**Requires:** Rise & Fall + Gathering Storm  
**Compatible with:** Serbia Civilization Pack

## CRITICAL — How to start correctly

1. Enable **WW2 Overhaul** + **Serbia Civilization Pack** in Additional Content.
2. Create Game → **Advanced Setup**.
3. **Ruleset** must be set to **WW2 Overhaul** (this locks Industrial start + all WW2 systems).
4. **Map** — do **NOT** use the old "WW2 Huge Europe (Embedded)". That map is abandoned.

### Real Europe map (recommended)

Install **YnAMP** (Yet not Another Maps Pack):
- Steam Workshop: search "YnAMP" or "Yet (not) Another Maps Pack"
- Or GitHub: https://github.com/Gedemon/Civ6-YnAMP

Then in Advanced Setup pick one of:
- **Play Europe Again** (best pure Europe)
- **Greatest Earth Map** (whole Earth, Europe is large and detailed)

Enable True Starting Locations if YnAMP offers the option.

Without YnAMP you can still play on **Continents / Pangaea / any stock map** — the WW2 rules (army, techs, oil, alliances…) still work. Only the geography will not be Europe.

5. New game only. Load-screen scripts grant techs + starter army.

## What you should see on turn 1

- Industrial / early-Modern techs already unlocked (no nukes)
- **2 Tanks + 4 Infantry + 2 Artillery** near your capital
- If capital is coastal → **1 Battleship**
- Domination victory only

If you still spawn with settlers + scouts + crossbowmen, the **WW2 ruleset was not selected**. Go back to Advanced Setup and set Ruleset = WW2 Overhaul.

## Core systems

| System | Behavior |
|--------|----------|
| Victory | Domination only |
| Start | Industrial + WW2 techs |
| Starter army | 2 Tank / 4 Infantry / 2 Artillery (+ Battleship if coastal) |
| Science | Hard (nukes very late) |
| Oil | 0 Oil → modern units move 1 |
| Research Agreements | Full tech unlock for both sides |
| Open Borders | +4 CS, +1 Move, +3 Loyalty |
| Alliance | +10% Sci / Prod, +6 CS |
| Friendship | +8% Gold, +5% Sci |
| Join / Absorb | Firetuner helpers still available |

## Files

`Data/` = SQL, `Lua/` = scripts. Ruleset = `Data/WW2_Ruleset.xml`.
