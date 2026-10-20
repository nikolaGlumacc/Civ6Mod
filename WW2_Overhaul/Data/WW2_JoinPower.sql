-- WW2 Overhaul v1.2: Join Major Power
--
-- PLAYER joins Germany/USSR:
--   You keep control of your territory and can build on it.
--   You cannot raise independent combat units (modifier blocks unit production).
--   You are economically autonomous but militarily subordinate.
--
-- AI joins YOU:
--   Treated as conquered: they stop existing as an independent power until
--   released (with your approval) or freed by another player taking the land.
--   (Full AI absorb is approximated by defeating them / taking cities;
--    the policies below support the player-side restriction.)

INSERT OR IGNORE INTO Types (Type, Kind) VALUES
('POLICY_WW2_JOIN_GERMANY', 'KIND_POLICY'),
('POLICY_WW2_JOIN_USSR',    'KIND_POLICY'),
('POLICY_WW2_AXIS_ALIGN',   'KIND_POLICY'),
('POLICY_WW2_COMINTERN',    'KIND_POLICY');

INSERT OR IGNORE INTO Policies (PolicyType, Name, Description, PrereqCivic, GovernmentSlotType) VALUES
('POLICY_WW2_JOIN_GERMANY',
 'LOC_POLICY_WW2_JOIN_GERMANY_NAME',
 'LOC_POLICY_WW2_JOIN_GERMANY_DESCRIPTION',
 'CIVIC_MOBILIZATION', 'SLOT_WILDCARD'),
('POLICY_WW2_JOIN_USSR',
 'LOC_POLICY_WW2_JOIN_USSR_NAME',
 'LOC_POLICY_WW2_JOIN_USSR_DESCRIPTION',
 'CIVIC_CLASS_STRUGGLE', 'SLOT_WILDCARD'),
('POLICY_WW2_AXIS_ALIGN',
 'LOC_POLICY_WW2_AXIS_ALIGN_NAME',
 'LOC_POLICY_WW2_AXIS_ALIGN_DESCRIPTION',
 'CIVIC_TOTALITARIANISM', 'SLOT_WILDCARD'),
('POLICY_WW2_COMINTERN',
 'LOC_POLICY_WW2_COMINTERN_NAME',
 'LOC_POLICY_WW2_COMINTERN_DESCRIPTION',
 'CIVIC_CLASS_STRUGGLE', 'SLOT_WILDCARD');

-- When you Join: strong building/economy, but unit production crushed
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_JOIN_NO_UNITS',     'MODIFIER_PLAYER_CITIES_ADJUST_UNIT_PRODUCTION'),
('WW2_JOIN_BUILD_PROD',   'MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_PRODUCTION'),
('WW2_JOIN_CS_DEF',       'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH'),
('WW2_AXIS_CS',           'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH'),
('WW2_AXIS_PROD',         'MODIFIER_PLAYER_CITIES_ADJUST_UNIT_PRODUCTION'),
('WW2_COMINTERN_SCI',     'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER'),
('WW2_COMINTERN_PROD',    'MODIFIER_PLAYER_CITIES_ADJUST_UNIT_PRODUCTION'),
('WW2_COMINTERN_CS',      'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH');

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_JOIN_NO_UNITS',   'Amount', '-100'),   -- cannot meaningfully produce combat units
('WW2_JOIN_BUILD_PROD', 'Amount', '25'),     -- still build on your land
('WW2_JOIN_CS_DEF',     'Amount', '3'),      -- leftover units defend a bit better
('WW2_AXIS_CS',         'Amount', '6'),
('WW2_AXIS_PROD',       'Amount', '15'),
('WW2_COMINTERN_SCI',   'YieldType', 'YIELD_SCIENCE'),
('WW2_COMINTERN_SCI',   'Amount', '10'),
('WW2_COMINTERN_PROD',  'Amount', '15'),
('WW2_COMINTERN_CS',    'Amount', '5');

-- Join Germany / Join USSR: economy yes, independent army no
INSERT OR IGNORE INTO PolicyModifiers (PolicyType, ModifierId) VALUES
('POLICY_WW2_JOIN_GERMANY', 'WW2_JOIN_NO_UNITS'),
('POLICY_WW2_JOIN_GERMANY', 'WW2_JOIN_BUILD_PROD'),
('POLICY_WW2_JOIN_GERMANY', 'WW2_JOIN_CS_DEF'),
('POLICY_WW2_JOIN_USSR',    'WW2_JOIN_NO_UNITS'),
('POLICY_WW2_JOIN_USSR',    'WW2_JOIN_BUILD_PROD'),
('POLICY_WW2_JOIN_USSR',    'WW2_JOIN_CS_DEF');

-- Axis / Comintern = cooperation without fully giving up your army
INSERT OR IGNORE INTO PolicyModifiers (PolicyType, ModifierId) VALUES
('POLICY_WW2_AXIS_ALIGN', 'WW2_AXIS_CS'),
('POLICY_WW2_AXIS_ALIGN', 'WW2_AXIS_PROD'),
('POLICY_WW2_COMINTERN',  'WW2_COMINTERN_SCI'),
('POLICY_WW2_COMINTERN',  'WW2_COMINTERN_PROD'),
('POLICY_WW2_COMINTERN',  'WW2_COMINTERN_CS');
