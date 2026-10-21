-- WW2 Create Game: only European leaders + some Africans + Serbia pack + Yugoslavia sample.
-- No China, America, Japan, India, etc. Trajan (Rome) = Italy.

-- Yugoslavia sample (optional; Serbia pack leaders are the real Serbia)
INSERT OR REPLACE INTO Players
    (Domain, CivilizationType, CivilizationName, CivilizationIcon,
     CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon,
     LeaderType, LeaderName, LeaderIcon,
     LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon)
VALUES
    ('Players:Expansion2_Players',
     'CIVILIZATION_WW2_YUGOSLAVIA',
     'LOC_CIVILIZATION_WW2_YUGOSLAVIA_NAME',
     'ICON_CIVILIZATION_SERBIA',
     'LOC_TRAIT_CIVILIZATION_WW2_YUGOSLAVIA_NAME',
     'LOC_TRAIT_CIVILIZATION_WW2_YUGOSLAVIA_DESCRIPTION',
     'ICON_CIVILIZATION_SERBIA',
     'LEADER_WW2_TITO',
     'LOC_LEADER_WW2_TITO_NAME',
     'ICON_LEADER_TITO',
     'LOC_TRAIT_LEADER_WW2_TITO_NAME',
     'LOC_TRAIT_LEADER_WW2_TITO_DESCRIPTION',
     'ICON_LEADER_TITO');

-- Strip non-theatre civs from the leader picker (all player domains)
DELETE FROM Players
WHERE CivilizationType NOT IN (
  -- Core Europe / WW2 majors
  'CIVILIZATION_ENGLAND',
  'CIVILIZATION_FRANCE',
  'CIVILIZATION_GERMANY',
  'CIVILIZATION_SPAIN',
  'CIVILIZATION_PORTUGAL',
  'CIVILIZATION_RUSSIA',
  'CIVILIZATION_POLAND',
  'CIVILIZATION_HUNGARY',
  'CIVILIZATION_ROME',          -- Trajan = Italy
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
  -- North Africa (resource-rich, weak)
  'CIVILIZATION_EGYPT',
  'CIVILIZATION_ETHIOPIA',
  'CIVILIZATION_NUBIA',
  'CIVILIZATION_MALI',
  'CIVILIZATION_PHOENICIA',
  -- Serbia pack (whatever type string the pack uses) + WW2 sample
  'CIVILIZATION_SERBIA',
  'CIVILIZATION_STR_SERBIA',
  'CIVILIZATION_WW2_YUGOSLAVIA'
);

-- Prefer Trajan as Italy: drop other Rome leaders from picker if present
DELETE FROM Players
WHERE CivilizationType = 'CIVILIZATION_ROME'
  AND LeaderType NOT IN ('LEADER_TRAJAN', 'LEADER_JULIUS_CAESAR');
-- Keep Trajan; if both exist, leave both (Caesar optional). User asked Trajan specifically.
DELETE FROM Players
WHERE LeaderType = 'LEADER_JULIUS_CAESAR';
