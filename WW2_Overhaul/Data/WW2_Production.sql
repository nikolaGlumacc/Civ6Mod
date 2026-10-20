-- WW2 Overhaul: Stronger Industrial Zones + military production focus

-- Boost production from Industrial Zone buildings
UPDATE Building_YieldChanges
SET YieldChange = YieldChange + 3
WHERE BuildingType IN (
  'BUILDING_WORKSHOP',
  'BUILDING_FACTORY',
  'BUILDING_POWER_PLANT',
  'BUILDING_COAL_POWER_PLANT',
  'BUILDING_FOSSIL_FUEL_POWER_PLANT',
  'BUILDING_NUCLEAR_POWER_PLANT'
) AND YieldType = 'YIELD_PRODUCTION';

-- Extra production from the Industrial Zone district itself
UPDATE District_YieldChanges
SET YieldChange = YieldChange + 2
WHERE DistrictType = 'DISTRICT_INDUSTRIAL_ZONE' AND YieldType = 'YIELD_PRODUCTION';

-- Global military production bonus
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_MILITARY_PRODUCTION_BONUS', 'MODIFIER_PLAYER_CITIES_ADJUST_UNIT_PRODUCTION');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_MILITARY_PRODUCTION_BONUS', 'Amount', '15');
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_MAJOR_CIV', 'WW2_MILITARY_PRODUCTION_BONUS'
WHERE EXISTS (SELECT 1 FROM Traits WHERE TraitType = 'TRAIT_LEADER_MAJOR_CIV');
