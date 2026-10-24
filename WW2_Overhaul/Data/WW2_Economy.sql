-- Heavy gold income so starter army never puts you in debt
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_START_GOLD_PER_TURN', 'MODIFIER_PLAYER_ADJUST_YIELD_CHANGE'),
('WW2_CITY_GOLD', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE');

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_START_GOLD_PER_TURN', 'YieldType', 'YIELD_GOLD'),
('WW2_START_GOLD_PER_TURN', 'Amount', '250'),
('WW2_CITY_GOLD', 'YieldType', 'YIELD_GOLD'),
('WW2_CITY_GOLD', 'Amount', '15');
