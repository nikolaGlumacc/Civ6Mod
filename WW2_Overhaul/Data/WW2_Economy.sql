-- Offset starter army maintenance: big flat gold per turn
-- + gold from cities so the early deficit disappears

INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_START_GOLD_PER_TURN', 'MODIFIER_PLAYER_ADJUST_YIELD_CHANGE');

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_START_GOLD_PER_TURN', 'YieldType', 'YIELD_GOLD'),
('WW2_START_GOLD_PER_TURN', 'Amount', '80');

-- Attach to all major players via trait-less free modifier on game start is done in Lua.
-- Also give every city +10 gold so expansion stays solvent.
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType) VALUES
('WW2_CITY_GOLD', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE');

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
('WW2_CITY_GOLD', 'YieldType', 'YIELD_GOLD'),
('WW2_CITY_GOLD', 'Amount', '10');
