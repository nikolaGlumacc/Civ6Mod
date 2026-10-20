-- National Stubbornness temporary surge modifiers
-- Attached/detached by Lua when the player loses territory

INSERT OR IGNORE INTO Types (Type, Kind) VALUES
('MODIFIER_WW2_STUBBORN_PROD', 'KIND_MODIFIER'),
('MODIFIER_WW2_STUBBORN_CS',   'KIND_MODIFIER');

INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
('WW2_STUBBORN_SURGE_PROD', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER', 0, 0),
('WW2_STUBBORN_SURGE_CS',   'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH', 0, 0);

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_STUBBORN_SURGE_PROD', 'YieldType', 'YIELD_PRODUCTION'),
('WW2_STUBBORN_SURGE_PROD', 'Amount', '25'),
('WW2_STUBBORN_SURGE_CS',   'Amount', '8');
