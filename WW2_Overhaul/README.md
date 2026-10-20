# WW2 Overhaul v1.3

## Join = diplomacy, not policy buttons

When you talk to another civ you (will) get two options:

1. **Join them**  
   You keep your territory and can build. You cannot raise an independent army.  
   They accept more easily if they like you and they are stronger/similar strength.

2. **They join you**  
   They are absorbed (treated as conquered until you release or someone liberates).  
   They accept if they like you a lot **or** you are much stronger.

Acceptance is based on:
- Relationship (friendship vs hostility / war)
- Relative strength (cities + military)

**Current status:** Logic is in `WW2_JoinDiplomacy.lua`. Full buttons inside the real diplomacy screen need a UI add-in (Civ 6 diplomacy UI is heavily protected). For testing use Firetuner:
- `WW2_TryJoinLocal(otherPlayerID)`
- `WW2_TryAbsorbLocal(otherPlayerID)`

Axis Align / Comintern policies remain as softer cooperation without giving up your army.

## Rest of the mod
Deep Industrial/Modern unlocks, hard science (nukes late), Europe + Yugoslavia, Army Doctrine, Stubbornness, Supply, Oil, Serbia pack compatible.
