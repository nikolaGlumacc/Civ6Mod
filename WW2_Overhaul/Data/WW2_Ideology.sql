-- WW2 Overhaul: Clearer ideology / government bonuses
-- Tuned for war focus. Uses existing governments from RF/GS.

-- Democracy-leaning (more production from districts, slightly less pure military)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_IDEO_DEMO_PROD', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_IDEO_DEMO_PROD', 'YieldType', 'YIELD_PRODUCTION'),
('WW2_IDEO_DEMO_PROD', 'Amount', '10');

-- Fascism / Autocracy leaning: pure military strength
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_IDEO_FASC_CS', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH'),
('WW2_IDEO_FASC_PROD', 'MODIFIER_PLAYER_CITIES_ADJUST_UNIT_PRODUCTION');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_IDEO_FASC_CS', 'Amount', '4'),
('WW2_IDEO_FASC_PROD', 'Amount', '15');

-- Communism / Order leaning: production + science
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_IDEO_COMM_PROD', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER'),
('WW2_IDEO_COMM_SCI', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_IDEO_COMM_PROD', 'YieldType', 'YIELD_PRODUCTION'),
('WW2_IDEO_COMM_PROD', 'Amount', '12'),
('WW2_IDEO_COMM_SCI', 'YieldType', 'YIELD_SCIENCE'),
('WW2_IDEO_COMM_SCI', 'Amount', '8');

-- Attach to existing governments where possible (safe inserts)
INSERT OR IGNORE INTO GovernmentModifiers (GovernmentType, ModifierId)
SELECT 'GOVERNMENT_DEMOCRACY', 'WW2_IDEO_DEMO_PROD'
WHERE EXISTS (SELECT 1 FROM Governments WHERE GovernmentType = 'GOVERNMENT_DEMOCRACY');

INSERT OR IGNORE INTO GovernmentModifiers (GovernmentType, ModifierId)
SELECT 'GOVERNMENT_FASCISM', 'WW2_IDEO_FASC_CS'
WHERE EXISTS (SELECT 1 FROM Governments WHERE GovernmentType = 'GOVERNMENT_FASCISM');

INSERT OR IGNORE INTO GovernmentModifiers (GovernmentType, ModifierId)
SELECT 'GOVERNMENT_FASCISM', 'WW2_IDEO_FASC_PROD'
WHERE EXISTS (SELECT 1 FROM Governments WHERE GovernmentType = 'GOVERNMENT_FASCISM');

INSERT OR IGNORE INTO GovernmentModifiers (GovernmentType, ModifierId)
SELECT 'GOVERNMENT_COMMUNISM', 'WW2_IDEO_COMM_PROD'
WHERE EXISTS (SELECT 1 FROM Governments WHERE GovernmentType = 'GOVERNMENT_COMMUNISM');

INSERT OR IGNORE INTO GovernmentModifiers (GovernmentType, ModifierId)
SELECT 'GOVERNMENT_COMMUNISM', 'WW2_IDEO_COMM_SCI'
WHERE EXISTS (SELECT 1 FROM Governments WHERE GovernmentType = 'GOVERNMENT_COMMUNISM');
