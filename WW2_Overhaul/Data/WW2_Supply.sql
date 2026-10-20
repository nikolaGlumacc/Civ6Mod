-- WW2 Overhaul: Supply Station
-- Can be built by Builders as an improvement, and also exists as a city building.
-- Provides healing and a small combat bonus to nearby friendly units.

-- =====================================================
-- Improvement: Supply Station (Builder can build)
-- =====================================================
INSERT OR IGNORE INTO Types (Type, Kind) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'KIND_IMPROVEMENT');

INSERT OR IGNORE INTO Improvements (
  ImprovementType, Name, Description,
  Icon, PlunderType, PlunderAmount,
  Buildable, Appeal, Housing
) VALUES (
  'IMPROVEMENT_WW2_SUPPLY_STATION',
  'LOC_IMPROVEMENT_WW2_SUPPLY_STATION_NAME',
  'LOC_IMPROVEMENT_WW2_SUPPLY_STATION_DESCRIPTION',
  'ICON_IMPROVEMENT_FORT',
  'PLUNDER_GOLD', 20,
  1, 0, 0
);

-- Valid terrains / features (open ground)
INSERT OR IGNORE INTO Improvement_ValidTerrains (ImprovementType, TerrainType) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_GRASS'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_PLAINS'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_DESERT'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_TUNDRA'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_SNOW');

INSERT OR IGNORE INTO Improvement_ValidFeatures (ImprovementType, FeatureType) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'FEATURE_FOREST'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'FEATURE_JUNGLE');

-- Builders can build it
INSERT OR IGNORE INTO Improvement_ValidBuildUnits (ImprovementType, UnitType) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'UNIT_BUILDER');

-- Yield: small production + gold so it feels useful
INSERT OR IGNORE INTO Improvement_YieldChanges (ImprovementType, YieldType, YieldChange) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'YIELD_PRODUCTION', 1),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'YIELD_GOLD', 1);

-- =====================================================
-- Building: Supply Depot (city can build)
-- =====================================================
INSERT OR IGNORE INTO Types (Type, Kind) VALUES
('BUILDING_WW2_SUPPLY_DEPOT', 'KIND_BUILDING');

INSERT OR IGNORE INTO Buildings (
  BuildingType, Name, Description,
  PrereqTech, Cost, MaxPlayerInstances,
  Maintenance, CitizenSlots, AdvisorType
) VALUES (
  'BUILDING_WW2_SUPPLY_DEPOT',
  'LOC_BUILDING_WW2_SUPPLY_DEPOT_NAME',
  'LOC_BUILDING_WW2_SUPPLY_DEPOT_DESCRIPTION',
  'TECH_MILITARY_SCIENCE', 180, 1,
  2, 0, 'ADVISOR_CONQUEST'
);

INSERT OR IGNORE INTO Building_YieldChanges (BuildingType, YieldType, YieldChange) VALUES
('BUILDING_WW2_SUPPLY_DEPOT', 'YIELD_PRODUCTION', 2);

-- Simple modifier: units in owned territory heal faster when you have a Supply Depot
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_SUPPLY_DEPOT_HEAL', 'MODIFIER_PLAYER_UNITS_ADJUST_HEAL_PER_TURN');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_SUPPLY_DEPOT_HEAL', 'Amount', '5');
INSERT OR IGNORE INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_WW2_SUPPLY_DEPOT', 'WW2_SUPPLY_DEPOT_HEAL');
