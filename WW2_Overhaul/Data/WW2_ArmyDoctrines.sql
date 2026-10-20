-- WW2 Overhaul: Light / Medium / Heavy Army doctrines
-- Applied to combat units (attackers). Heavy deals roughly twice the damage of Light.
-- Implemented as three Wildcard policies that set a global combat multiplier style bonus.

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

-- Light: +3 Combat Strength (cheap & fast doctrine feel)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_ARMY_LIGHT_CS', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_ARMY_LIGHT_CS', 'Amount', '3');
INSERT OR IGNORE INTO PolicyModifiers (PolicyType, ModifierId) VALUES
('POLICY_WW2_ARMY_LIGHT', 'WW2_ARMY_LIGHT_CS');

-- Medium: +7 Combat Strength
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_ARMY_MEDIUM_CS', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_ARMY_MEDIUM_CS', 'Amount', '7');
INSERT OR IGNORE INTO PolicyModifiers (PolicyType, ModifierId) VALUES
('POLICY_WW2_ARMY_MEDIUM', 'WW2_ARMY_MEDIUM_CS');

-- Heavy: +14 Combat Strength (roughly 2× Light)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_ARMY_HEAVY_CS', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_ARMY_HEAVY_CS', 'Amount', '14');
INSERT OR IGNORE INTO PolicyModifiers (PolicyType, ModifierId) VALUES
('POLICY_WW2_ARMY_HEAVY', 'WW2_ARMY_HEAVY_CS');

-- Note: These are mutually exclusive in practice because they occupy the same Wildcard slot.
-- Player picks one doctrine at a time.
