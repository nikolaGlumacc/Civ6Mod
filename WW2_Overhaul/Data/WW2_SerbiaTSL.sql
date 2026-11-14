-- Serbia Belgrade TSL on official Europe maps + YnAMP
-- Supports both new Serbia_Civ_Pack IDs and legacy STR_ IDs

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

-- New clean IDs from Serbia_Civ_Pack
INSERT OR IGNORE INTO StartPosition (MapName, Civilization, X, Y) VALUES
('LargeEurope', 'CIVILIZATION_SERBIA', 47, 37),
('PlayEuropeAgain', 'CIVILIZATION_SERBIA', 57, 40),
('GreatestEarthMap', 'CIVILIZATION_SERBIA', 28, 48),
('GiantEarth', 'CIVILIZATION_SERBIA', 27, 58);

-- Legacy STR_ IDs (old Strudeler-style)
INSERT OR IGNORE INTO StartPosition (MapName, Civilization, X, Y) VALUES
('LargeEurope', 'CIVILIZATION_STR_SERBIA', 47, 37),
('PlayEuropeAgain', 'CIVILIZATION_STR_SERBIA', 57, 40),
('GreatestEarthMap', 'CIVILIZATION_STR_SERBIA', 28, 48),
('GiantEarth', 'CIVILIZATION_STR_SERBIA', 27, 58);

-- Leader-specific starts (new IDs)
INSERT OR IGNORE INTO StartPosition (MapName, Leader, X, Y) VALUES
('LargeEurope', 'LEADER_TITO', 47, 37),
('LargeEurope', 'LEADER_DRAZA', 47, 37),
('LargeEurope', 'LEADER_MILOSEVIC', 47, 37),
('LargeEurope', 'LEADER_DUSAN', 47, 37),
('PlayEuropeAgain', 'LEADER_TITO', 57, 40),
('PlayEuropeAgain', 'LEADER_DRAZA', 57, 40),
('PlayEuropeAgain', 'LEADER_MILOSEVIC', 57, 40),
('PlayEuropeAgain', 'LEADER_DUSAN', 57, 40);

-- Legacy leader ID
INSERT OR IGNORE INTO StartPosition (MapName, Leader, X, Y) VALUES
('LargeEurope', 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC', 47, 37),
('PlayEuropeAgain', 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC', 57, 40);

-- Belgrade plot 1054 on TSL Europe XP2 (from Serbia pack)
-- New IDs
INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value) VALUES
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEuropeStandard_XP2.Civ6Map', 1054, 'LEADER', 'LEADER_TITO'),
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEuropeStandard_XP2.Civ6Map', 1054, 'LEADER', 'LEADER_DRAZA'),
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEuropeStandard_XP2.Civ6Map', 1054, 'LEADER', 'LEADER_MILOSEVIC'),
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEuropeStandard_XP2.Civ6Map', 1054, 'LEADER', 'LEADER_DUSAN'),
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEuropeStandard_XP2.Civ6Map', 1054, 'CIVILIZATION', 'CIVILIZATION_SERBIA'),
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEuropeStandard.Civ6Map', 1054, 'LEADER', 'LEADER_DUSAN'),
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEurope.Civ6Map', 1054, 'LEADER', 'LEADER_DUSAN'),
('{4873eb62-8ccc-4574-b784-dda455e74e68}Maps/TSLEuropeStandard_XP2.Civ6Map', 1054, 'LEADER', 'LEADER_DUSAN'),
('{4873eb62-8ccc-4574-b784-dda455e74e68}Maps/TSLEurope_XP2.Civ6Map', 1054, 'LEADER', 'LEADER_DUSAN');

-- Legacy STR_ still supported
INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value) VALUES
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEuropeStandard_XP2.Civ6Map', 1054, 'LEADER', 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'),
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEuropeStandard_XP2.Civ6Map', 1054, 'CIVILIZATION', 'CIVILIZATION_STR_SERBIA');

-- For every map that has Macedon TSL, give Serbia the same plot (civ + leaders)
INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'CIVILIZATION', 'CIVILIZATION_SERBIA'
FROM MapStartPositions WHERE Type='CIVILIZATION' AND Value='CIVILIZATION_MACEDON';

INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'CIVILIZATION', 'CIVILIZATION_STR_SERBIA'
FROM MapStartPositions WHERE Type='CIVILIZATION' AND Value='CIVILIZATION_MACEDON';

INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'LEADER', 'LEADER_DUSAN'
FROM MapStartPositions WHERE Type='CIVILIZATION' AND Value='CIVILIZATION_MACEDON';

INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'LEADER', 'LEADER_TITO'
FROM MapStartPositions WHERE Type='CIVILIZATION' AND Value='CIVILIZATION_MACEDON';

INSERT OR IGNORE INTO MapStartPositions (Map, Plot, Type, Value)
SELECT Map, Plot, 'LEADER', 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM MapStartPositions WHERE Type='CIVILIZATION' AND Value='CIVILIZATION_MACEDON';
