-- ============================================================
-- WW2 Frontend Players
-- ============================================================
-- NOTE: The old aggressive DELETE of non-European civs has been
-- disabled for now. It was causing the civilization list to break
-- (only Serbia showed up). Once the ruleset is stable we can
-- re-introduce a safer Europe filter.

-- DELETE FROM Players
-- WHERE CivilizationType IN (
--   'CIVILIZATION_AMERICA','CIVILIZATION_AZTEC','CIVILIZATION_BRAZIL',
--   'CIVILIZATION_CANADA','CIVILIZATION_CREE','CIVILIZATION_GRAN_COLOMBIA',
--   'CIVILIZATION_INCA','CIVILIZATION_MAPUCHE','CIVILIZATION_MAYA',
--   'CIVILIZATION_AUSTRALIA','CIVILIZATION_MAORI','CIVILIZATION_JAPAN',
--   'CIVILIZATION_CHINA','CIVILIZATION_KOREA','CIVILIZATION_MONGOLIA',
--   'CIVILIZATION_KHMER','CIVILIZATION_INDONESIA','CIVILIZATION_VIETNAM',
--   'CIVILIZATION_INDIA','CIVILIZATION_KONGO','CIVILIZATION_ZULU'
-- );

-- DELETE FROM Players WHERE LeaderType = 'LEADER_JULIUS_CAESAR';

-- ============================================================
-- Unlock Serbia leaders on EVERY map (MapLeaders drives TSL civ list)
-- Support both new clean IDs and legacy STR_ IDs
-- ============================================================

-- New leaders from Serbia_Civ_Pack
INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_TITO'
FROM Maps WHERE File IS NOT NULL AND File != '';

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_DRAZA'
FROM Maps WHERE File IS NOT NULL AND File != '';

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_MILOSEVIC'
FROM Maps WHERE File IS NOT NULL AND File != '';

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_DUSAN'
FROM Maps WHERE File IS NOT NULL AND File != '';

-- Legacy STR_ Dusan (and variants)
INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps WHERE File IS NOT NULL AND File != '';

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_BYZANTIUM_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps WHERE File IS NOT NULL AND File != '';

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_GREECE_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps WHERE File IS NOT NULL AND File != '';

-- Also place them next to common European leaders on maps that already have those
INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT Map, 'LEADER_DUSAN'
FROM MapLeaders
WHERE LeaderType IN (
  'LEADER_ALEXANDER',
  'LEADER_MATTHIAS_CORVINUS',
  'LEADER_PERICLES',
  'LEADER_GORGO',
  'LEADER_TRAJAN',
  'LEADER_BARBAROSSA'
);

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT Map, 'LEADER_TITO'
FROM MapLeaders
WHERE LeaderType IN (
  'LEADER_ALEXANDER',
  'LEADER_MATTHIAS_CORVINUS',
  'LEADER_PERICLES',
  'LEADER_GORGO',
  'LEADER_TRAJAN',
  'LEADER_BARBAROSSA'
);
