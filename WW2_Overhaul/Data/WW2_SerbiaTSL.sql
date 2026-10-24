-- YnAMP StartPosition table must exist before XML Replace rows load
CREATE TABLE IF NOT EXISTS StartPosition (
  MapName TEXT NOT NULL,
  Civilization TEXT,
  Leader TEXT,
  DisabledByCivilization TEXT,
  DisabledByLeader TEXT,
  AlternateStart INTEGER DEFAULT 0,
  X INTEGER DEFAULT 0,
  Y INTEGER DEFAULT 0
);

-- Also insert via SQL in case XML StartPosition is ignored without YnAMP schema fully present
INSERT OR IGNORE INTO StartPosition (MapName, Civilization, X, Y) VALUES
('LargeEurope', 'CIVILIZATION_STR_SERBIA', 47, 37),
('LargeEurope', 'CIVILIZATION_SERBIA', 47, 37),
('LargeEurope', 'CIVILIZATION_WW2_YUGOSLAVIA', 47, 37),
('PlayEuropeAgain', 'CIVILIZATION_STR_SERBIA', 57, 40),
('PlayEuropeAgain', 'CIVILIZATION_SERBIA', 57, 40),
('PlayEuropeAgain', 'CIVILIZATION_WW2_YUGOSLAVIA', 57, 40),
('GreatestEarthMap', 'CIVILIZATION_STR_SERBIA', 28, 48),
('GreatestEarthMap', 'CIVILIZATION_SERBIA', 28, 48),
('GreatestEarthMap', 'CIVILIZATION_WW2_YUGOSLAVIA', 28, 48),
('GiantEarth', 'CIVILIZATION_STR_SERBIA', 27, 58),
('GiantEarth', 'CIVILIZATION_SERBIA', 27, 58),
('GiantEarth', 'CIVILIZATION_WW2_YUGOSLAVIA', 27, 58);
