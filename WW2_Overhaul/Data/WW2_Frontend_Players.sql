-- ============================================================
-- WW2 Frontend — Serbia unlock only
-- ============================================================
-- CRITICAL RULES:
--   1. NEVER DELETE FROM Players. That was the main reason only
--      Serbia appeared in the civ list.
--   2. Only INSERT OR IGNORE into MapLeaders so Serbia leaders
--      are selectable on every map (including TSL Europe).
--   3. Do not touch any other table.
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

-- Legacy STR_ names (compatibility with older map packs / YnAMP)
INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps WHERE File IS NOT NULL AND File != '';

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_BYZANTIUM_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps WHERE File IS NOT NULL AND File != '';

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_GREECE_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps WHERE File IS NOT NULL AND File != '';
