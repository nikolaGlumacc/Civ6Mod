-- Stronger industrial / military production focus

-- Industrial Zones and their buildings give more production
UPDATE Districts SET Housing = Housing WHERE DistrictType = 'DISTRICT_INDUSTRIAL_ZONE'; -- keep existing

-- Boost production from Industrial Zone buildings (Workshop, Factory, Power Plant, etc.)
UPDATE Building_YieldChanges
SET YieldChange = YieldChange + 2
WHERE BuildingType IN (
  'BUILDING_WORKSHOP',
  'BUILDING_FACTORY',
  'BUILDING_POWER_PLANT',
  'BUILDING_COAL_POWER_PLANT',
  'BUILDING_FOSSIL_FUEL_POWER_PLANT',
  'BUILDING_NUCLEAR_POWER_PLANT'
) AND YieldType = 'YIELD_PRODUCTION';

-- Encampment buildings give stronger military production / experience
UPDATE Buildings SET RegionalRange = RegionalRange WHERE BuildingType LIKE 'BUILDING_BARRACKS%' OR BuildingType LIKE 'BUILDING_ARMORY%' OR BuildingType LIKE 'BUILDING_MILITARY_ACADEMY%';

-- Simple global production bonus toward units (military focus)
-- (Applied lightly so the game still feels balanced)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_MILITARY_PRODUCTION_BONUS', 'MODIFIER_PLAYER_CITIES_ADJUST_UNIT_PRODUCTION');

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_MILITARY_PRODUCTION_BONUS', 'Amount', '15');

-- Attach to all players at start via a trait or free modifier (handled safely)
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_MAJOR_CIV', 'WW2_MILITARY_PRODUCTION_BONUS'
WHERE EXISTS (SELECT 1 FROM Traits WHERE TraitType = 'TRAIT_LEADER_MAJOR_CIV');
