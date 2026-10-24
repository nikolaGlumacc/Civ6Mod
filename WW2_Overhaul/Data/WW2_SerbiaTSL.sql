-- YnAMP StartPosition table
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

-- Official TSL Europe / static maps: MapStartPositions uses Plot index.
-- Clone Macedon start (closest vanilla civ to Belgrade), fallback Hungary.
-- Type CIVILIZATION so any Serbia leader uses it.

INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'CIVILIZATION', 'CIVILIZATION_STR_SERBIA'
FROM MapStartPositions
WHERE Type = 'CIVILIZATION' AND Value = 'CIVILIZATION_MACEDON';

INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'CIVILIZATION', 'CIVILIZATION_SERBIA'
FROM MapStartPositions
WHERE Type = 'CIVILIZATION' AND Value = 'CIVILIZATION_MACEDON';

INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'CIVILIZATION', 'CIVILIZATION_WW2_YUGOSLAVIA'
FROM MapStartPositions
WHERE Type = 'CIVILIZATION' AND Value = 'CIVILIZATION_MACEDON';

-- If Macedon row missing on some maps, use Hungary
INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'CIVILIZATION', 'CIVILIZATION_STR_SERBIA'
FROM MapStartPositions
WHERE Type = 'CIVILIZATION' AND Value = 'CIVILIZATION_HUNGARY'
  AND NOT EXISTS (
    SELECT 1 FROM MapStartPositions m2
    WHERE m2.Map = MapStartPositions.Map
      AND m2.Value = 'CIVILIZATION_STR_SERBIA'
  );
