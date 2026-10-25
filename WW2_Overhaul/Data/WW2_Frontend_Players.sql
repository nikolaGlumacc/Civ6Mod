-- ============================================================
-- 1) Soft Europe filter (never touches Serbia)
-- 2) Clone Serbia into every Players domain so it always shows
-- 3) MapLeaders: Serbia allowed on EVERY registered map
-- ============================================================

DELETE FROM Players
WHERE CivilizationType IN (
  'CIVILIZATION_AMERICA','CIVILIZATION_AZTEC','CIVILIZATION_BRAZIL',
  'CIVILIZATION_CANADA','CIVILIZATION_CREE','CIVILIZATION_GRAN_COLOMBIA',
  'CIVILIZATION_INCA','CIVILIZATION_MAPUCHE','CIVILIZATION_MAYA',
  'CIVILIZATION_AUSTRALIA','CIVILIZATION_MAORI','CIVILIZATION_JAPAN',
  'CIVILIZATION_CHINA','CIVILIZATION_KOREA','CIVILIZATION_MONGOLIA',
  'CIVILIZATION_KHMER','CIVILIZATION_INDONESIA','CIVILIZATION_VIETNAM',
  'CIVILIZATION_INDIA','CIVILIZATION_KONGO','CIVILIZATION_ZULU'
);

DELETE FROM Players WHERE LeaderType = 'LEADER_JULIUS_CAESAR';

-- Clone Serbia Expansion2 rows into Standard + Expansion1 domains
INSERT OR IGNORE INTO Players
SELECT
  'Players:StandardPlayers' AS Domain,
  CivilizationType, LeaderType, LeaderName, LeaderIcon,
  CivilizationName, CivilizationIcon,
  CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon,
  LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon,
  Portrait, PortraitBackground
FROM Players
WHERE CivilizationType = 'CIVILIZATION_STR_SERBIA'
  AND Domain = 'Players:Expansion2_Players';

INSERT OR IGNORE INTO Players
SELECT
  'Players:Expansion1_Players' AS Domain,
  CivilizationType, LeaderType, LeaderName, LeaderIcon,
  CivilizationName, CivilizationIcon,
  CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon,
  LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon,
  Portrait, PortraitBackground
FROM Players
WHERE CivilizationType = 'CIVILIZATION_STR_SERBIA'
  AND Domain = 'Players:Expansion2_Players';

-- Same for Dušan-as-Greece / Byzantium variants if present
INSERT OR IGNORE INTO Players
SELECT 'Players:StandardPlayers', CivilizationType, LeaderType, LeaderName, LeaderIcon,
  CivilizationName, CivilizationIcon,
  CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon,
  LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon,
  Portrait, PortraitBackground
FROM Players
WHERE LeaderType LIKE 'LEADER_STR_%DUSAN%'
  AND Domain = 'Players:Expansion2_Players';

INSERT OR IGNORE INTO Players
SELECT 'Players:Expansion1_Players', CivilizationType, LeaderType, LeaderName, LeaderIcon,
  CivilizationName, CivilizationIcon,
  CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon,
  LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon,
  Portrait, PortraitBackground
FROM Players
WHERE LeaderType LIKE 'LEADER_STR_%DUSAN%'
  AND Domain = 'Players:Expansion2_Players';

-- NUCLEAR: Serbia leader valid on every map that exists in the Maps table
INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps
WHERE File IS NOT NULL;

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_BYZANTIUM_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps WHERE File IS NOT NULL;

INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT File, 'LEADER_STR_GREECE_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM Maps WHERE File IS NOT NULL;

-- Also copy from any map that already allows Alexander / Matthias
INSERT OR IGNORE INTO MapLeaders (Map, LeaderType)
SELECT DISTINCT Map, 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
FROM MapLeaders
WHERE LeaderType IN ('LEADER_ALEXANDER','LEADER_MATTHIAS_CORVINUS','LEADER_PERICLES','LEADER_GORGO');
