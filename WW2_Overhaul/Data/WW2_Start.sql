-- WW2 Overhaul: 1936 start + free civilization / leader choice
-- This is the hardest part and is currently PLACEHOLDER only.

-- =====================================================
-- Goals
-- =====================================================
-- 1. Game starts in year 1936 (or equivalent Industrial/Modern era)
-- 2. Player can choose any civilization / leader, including ones that do not exist in 1936
--    (example: Yugoslavia, or completely custom nations)
-- 3. Player can choose starting location more freely

-- =====================================================
-- Current status
-- =====================================================
-- Full 1936 start usually requires either:
--   a) A custom World Builder scenario / map with pre-placed cities and tech grants, or
--   b) Heavy Lua that forces starting era, grants techs/civics, and sets the calendar year.

-- Free choice of non-existing countries requires adding new Civilization + Leader entries
-- (or using Unrestricted Leaders style mods + custom configs).

-- =====================================================
-- Safe starter changes we can do now
-- =====================================================

-- Make the game prefer later eras (player can still pick Ancient if they want,
-- but the mod is balanced for Industrial+)
-- (Actual forced 1936 start needs Lua or scenario)

-- Example: unlock more modern units earlier for testing (commented out for safety)
-- UPDATE Units SET PrereqTech = 'TECH_INDUSTRIALIZATION' WHERE UnitType LIKE '%TANK%';

-- =====================================================
-- Next steps for this file
-- =====================================================
-- - Add Lua script that sets Game.GetGameState() year / era on load
-- - Add config support for custom civs (Yugoslavia etc.)
-- - Optionally ship a simple Europe 1936 map later

-- For now this file exists so the mod structure is complete and ready to expand.
