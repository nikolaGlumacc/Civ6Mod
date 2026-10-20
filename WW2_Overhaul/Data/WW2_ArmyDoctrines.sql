-- WW2 Overhaul: Light / Medium / Heavy Army Doctrine
-- Now primarily controlled by a game setup option (Advanced Setup menu).
-- The old Wildcard policies are kept as optional extra cards if the player still wants them.

-- =====================================================
-- Game Setup Parameter (appears in Advanced Setup)
-- =====================================================
INSERT OR IGNORE INTO Types (Type, Kind) VALUES
('WW2_ARMY_DOCTRINE', 'KIND_PARAMETER');

-- Domain values for the dropdown
INSERT OR IGNORE INTO ParameterDomainValues (ParameterId, Domain, Name, Description, SortIndex, Value) VALUES
('WW2_ARMY_DOCTRINE', 'WW2_ARMY_DOCTRINE_DOMAIN', 'LOC_WW2_ARMY_LIGHT_NAME',  'LOC_WW2_ARMY_LIGHT_DESC',  1, 'LIGHT'),
('WW2_ARMY_DOCTRINE', 'WW2_ARMY_DOCTRINE_DOMAIN', 'LOC_WW2_ARMY_MEDIUM_NAME', 'LOC_WW2_ARMY_MEDIUM_DESC', 2, 'MEDIUM'),
('WW2_ARMY_DOCTRINE', 'WW2_ARMY_DOCTRINE_DOMAIN', 'LOC_WW2_ARMY_HEAVY_NAME',  'LOC_WW2_ARMY_HEAVY_DESC',  3, 'HEAVY');

INSERT OR IGNORE INTO Parameters (
  ParameterId, Name, Description,
  Domain, DefaultValue, GroupId, GroupIndex, SortIndex,
  ConfigurationGroup, ConfigurationId, Changeable
) VALUES (
  'WW2_ARMY_DOCTRINE',
  'LOC_WW2_ARMY_DOCTRINE_NAME',
  'LOC_WW2_ARMY_DOCTRINE_DESC',
  'WW2_ARMY_DOCTRINE_DOMAIN',
  'MEDIUM',
  'WW2_Options',
  1, 10,
  'Game',
  'WW2_ARMY_DOCTRINE',
  1
);

-- =====================================================
-- Keep the old Wildcard policies as optional extras
-- (player can still slot them if they want)
-- =====================================================
INSERT OR IGNORE INTO Types (Type, Kind) VALUES
('POLICY_WW2_ARMY_LIGHT',  'KIND_POLICY'),
('POLICY_WW2_ARMY_MEDIUM','KIND_POLICY'),
('POLICY_WW2_ARMY_HEAVY', 'KIND_POLICY');

INSERT OR IGNORE INTO Policies (PolicyType, Name, Description, PrereqCivic, GovernmentSlotType) VALUES
('POLICY_WW2_ARMY_LIGHT',
 'LOC_POLICY_WW2_ARMY_LIGHT_NAME',
 'LOC_POLICY_WW2_ARMY_LIGHT_DESCRIPTION',
 'CIVIC_MOBILIZATION',
 'SLOT_WILDCARD'),

('POLICY_WW2_ARMY_MEDIUM',
 'LOC_POLICY_WW2_ARMY_MEDIUM_NAME',
 'LOC_POLICY_WW2_ARMY_MEDIUM_DESCRIPTION',
 'CIVIC_MOBILIZATION',
 'SLOT_WILDCARD'),

('POLICY_WW2_ARMY_HEAVY',
 'LOC_POLICY_WW2_ARMY_HEAVY_NAME',
 'LOC_POLICY_WW2_ARMY_HEAVY_DESCRIPTION',
 'CIVIC_MOBILIZATION',
 'SLOT_WILDCARD');

-- Light: +3 CS
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_ARMY_LIGHT_CS', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_ARMY_LIGHT_CS', 'Amount', '3');
INSERT OR IGNORE INTO PolicyModifiers (PolicyType, ModifierId) VALUES
('POLICY_WW2_ARMY_LIGHT', 'WW2_ARMY_LIGHT_CS');

-- Medium: +7 CS
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_ARMY_MEDIUM_CS', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_ARMY_MEDIUM_CS', 'Amount', '7');
INSERT OR IGNORE INTO PolicyModifiers (PolicyType, ModifierId) VALUES
('POLICY_WW2_ARMY_MEDIUM', 'WW2_ARMY_MEDIUM_CS');

-- Heavy: +14 CS (≈ 2× Light)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_ARMY_HEAVY_CS', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_ARMY_HEAVY_CS', 'Amount', '14');
INSERT OR IGNORE INTO PolicyModifiers (PolicyType, ModifierId) VALUES
('POLICY_WW2_ARMY_HEAVY', 'WW2_ARMY_HEAVY_CS');
