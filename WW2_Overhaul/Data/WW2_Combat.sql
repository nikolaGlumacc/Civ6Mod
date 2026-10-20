-- WW2 Overhaul: Stronger wars, more damage to cities, stronger navy & air
-- Units do NOT cost more production.

-- =====================================================
-- 1. Units deal more damage to cities / districts
-- =====================================================
-- Increase the combat strength bonus units get when attacking cities
-- (This makes sieges and city assaults much deadlier)

UPDATE GlobalParameters SET Value = 20 WHERE Name = 'COMBAT_CITY_ATTACK_BONUS';          -- was lower
UPDATE GlobalParameters SET Value = 15 WHERE Name = 'COMBAT_CITY_RANGED_ATTACK_BONUS';   -- ranged also stronger vs cities

-- Districts take more damage from bombardment / attacks
UPDATE GlobalParameters SET Value = 50 WHERE Name = 'DISTRICT_DAMAGE_PERCENT';            -- higher % damage to districts

-- =====================================================
-- 2. Navy stronger
-- =====================================================
-- Give all naval melee and ranged units a flat combat bonus
-- (Applied via a global modifier approach - simple and compatible)

-- Example strength bump for naval units (you can tune the numbers)
UPDATE Units SET Combat = Combat + 5 WHERE Domain = 'DOMAIN_SEA' AND Combat > 0;
UPDATE Units SET RangedCombat = RangedCombat + 5 WHERE Domain = 'DOMAIN_SEA' AND RangedCombat > 0;
UPDATE Units SET Bombard = Bombard + 5 WHERE Domain = 'DOMAIN_SEA' AND Bombard > 0;

-- =====================================================
-- 3. Air stronger
-- =====================================================
UPDATE Units SET Combat = Combat + 5 WHERE Domain = 'DOMAIN_AIR' AND Combat > 0;
UPDATE Units SET RangedCombat = RangedCombat + 8 WHERE Domain = 'DOMAIN_AIR' AND RangedCombat > 0;
UPDATE Units SET Bombard = Bombard + 8 WHERE Domain = 'DOMAIN_AIR' AND Bombard > 0;

-- =====================================================
-- 4. Healing changes (slower outside friendly territory for longer wars feel)
-- =====================================================
-- Units heal less when outside friendly territory (makes front lines matter more)
UPDATE GlobalParameters SET Value = 5 WHERE Name = 'HEAL_RATE_OUTSIDE_FRIENDLY';     -- lower than default
UPDATE GlobalParameters SET Value = 15 WHERE Name = 'HEAL_RATE_FRIENDLY';             -- keep decent healing at home

-- =====================================================
-- Notes
-- =====================================================
-- Production costs of units are intentionally left unchanged.
-- Oil maintenance is handled in WW2_Resources.sql + future Lua.
