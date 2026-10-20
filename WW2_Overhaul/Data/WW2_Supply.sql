-- WW2 Overhaul: Supply is now city / regional focused
-- One strong Supply Depot per city (covers the whole city radius).
-- Supply Station improvement is secondary / optional field fortification.

-- =====================================================
-- Building: Supply Depot (one per city, regional effect)
-- =====================================================
INSERT OR IGNORE INTO Types (Type, Kind) VALUES
('BUILDING_WW2_SUPPLY_DEPOT', 'KIND_BUILDING');

INSERT OR IGNORE INTO Buildings (
  BuildingType, Name, Description,
  PrereqTech, Cost, MaxPlayerInstances,
  Maintenance, CitizenSlots, AdvisorType,
  RegionalRange
) VALUES (
  'BUILDING_WW2_SUPPLY_DEPOT',
  'LOC_BUILDING_WW2_SUPPLY_DEPOT_NAME',
  'LOC_BUILDING_WW2_SUPPLY_DEPOT_DESCRIPTION',
  'TECH_MILITARY_SCIENCE', 160, -1,   -- -1 = unlimited, one per city is natural
  2, 0, 'ADVISOR_CONQUEST',
  6                                 -- regional range covers typical city radius
);

INSERT OR IGNORE INTO Building_YieldChanges (BuildingType, YieldType, YieldChange) VALUES
('BUILDING_WW2_SUPPLY_DEPOT', 'YIELD_PRODUCTION', 3);

-- Units in the city (and regional range) heal faster
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_SUPPLY_DEPOT_HEAL', 'MODIFIER_PLAYER_UNITS_ADJUST_HEAL_PER_TURN');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_SUPPLY_DEPOT_HEAL', 'Amount', '8');
INSERT OR IGNORE INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_WW2_SUPPLY_DEPOT', 'WW2_SUPPLY_DEPOT_HEAL');

-- Small combat bonus while supplied (in owned territory with depot)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_SUPPLY_DEPOT_CS', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_SUPPLY_DEPOT_CS', 'Amount', '3');
INSERT OR IGNORE INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_WW2_SUPPLY_DEPOT', 'WW2_SUPPLY_DEPOT_CS');

-- =====================================================
-- Improvement: Supply Station (optional field supply)
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
  'PLUNDER_GOLD', 15,
  1, 0, 0
);

INSERT OR IGNORE INTO Improvement_ValidTerrains (ImprovementType, TerrainType) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_GRASS'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_PLAINS'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_DESERT'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_TUNDRA'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'TERRAIN_SNOW');

INSERT OR IGNORE INTO Improvement_ValidFeatures (ImprovementType, FeatureType) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'FEATURE_FOREST'),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'FEATURE_JUNGLE');

INSERT OR IGNORE INTO Improvement_ValidBuildUnits (ImprovementType, UnitType) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'UNIT_BUILDER');

INSERT OR IGNORE INTO Improvement_YieldChanges (ImprovementType, YieldType, YieldChange) VALUES
('IMPROVEMENT_WW2_SUPPLY_STATION', 'YIELD_PRODUCTION', 1),
('IMPROVEMENT_WW2_SUPPLY_STATION', 'YIELD_GOLD', 1);
