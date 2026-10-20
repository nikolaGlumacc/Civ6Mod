-- WW2 Overhaul: Oil maintenance concept
-- Units do not cost more production.
-- If a player has Oil, modern units can be maintained properly.
-- Full enforcement (combat/movement penalties when no oil) will be done in Lua later.

-- Make Oil more visible / important as a strategic resource
-- (No production cost increase on units)

-- Example: ensure Oil is treated as a strategic resource that matters for late-game units
-- (Most modern tanks, planes, ships already reference Oil in the base game)

-- Placeholder: we can later attach a free maintenance modifier when Oil is available
-- and a penalty modifier when it is not (via Lua checking PlayerResources).

-- For now this file just documents the design and can hold future resource tweaks.

-- Example future direction (commented):
-- INSERT INTO Modifiers ... for "HasOil_MaintenanceBonus"
-- INSERT INTO Modifiers ... for "NoOil_CombatPenalty"
