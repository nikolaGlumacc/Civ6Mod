-- WW2 leader pool: Europe + some Africa + Serbia. Runs early; Serbia re-inserts after with higher LoadOrder.

DELETE FROM Players
WHERE CivilizationType NOT IN (
  'CIVILIZATION_ENGLAND',
  'CIVILIZATION_FRANCE',
  'CIVILIZATION_GERMANY',
  'CIVILIZATION_SPAIN',
  'CIVILIZATION_PORTUGAL',
  'CIVILIZATION_RUSSIA',
  'CIVILIZATION_POLAND',
  'CIVILIZATION_HUNGARY',
  'CIVILIZATION_ROME',
  'CIVILIZATION_GREECE',
  'CIVILIZATION_MACEDON',
  'CIVILIZATION_NETHERLANDS',
  'CIVILIZATION_NORWAY',
  'CIVILIZATION_SWEDEN',
  'CIVILIZATION_SCOTLAND',
  'CIVILIZATION_GEORGIA',
  'CIVILIZATION_BYZANTIUM',
  'CIVILIZATION_SCYTHIA',
  'CIVILIZATION_GAUL',
  'CIVILIZATION_OTTOMAN',
  'CIVILIZATION_EGYPT',
  'CIVILIZATION_ETHIOPIA',
  'CIVILIZATION_NUBIA',
  'CIVILIZATION_MALI',
  'CIVILIZATION_PHOENICIA',
  'CIVILIZATION_SERBIA',
  'CIVILIZATION_STR_SERBIA',
  'CIVILIZATION_WW2_YUGOSLAVIA'
);

DELETE FROM Players
WHERE LeaderType = 'LEADER_JULIUS_CAESAR';

-- Re-assert Serbia is playable if the pack already registered it
INSERT OR IGNORE INTO Players
    (Domain, CivilizationType, CivilizationName, CivilizationIcon,
     CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon,
     LeaderType, LeaderName, LeaderIcon,
     LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon)
SELECT Domain, CivilizationType, CivilizationName, CivilizationIcon,
       CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon,
       LeaderType, LeaderName, LeaderIcon,
       LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon
FROM Players WHERE CivilizationType = 'CIVILIZATION_SERBIA';
