-- Make Firaxis Europe / TSL Europe selectable under RULESET_WW2
-- by copying their existing Map rows into Domain = StandardMaps.

-- Any map whose name or file mentions Europe / TSL Europe / Mediterranean
INSERT OR IGNORE INTO Maps (Domain, File, Name, Description, Image, StaticMap, RequiresUniqueLeaders, SortIndex)
SELECT
  'StandardMaps',
  File,
  Name,
  Description,
  Image,
  StaticMap,
  RequiresUniqueLeaders,
  SortIndex
FROM Maps
WHERE
  File LIKE '%Europe%'
  OR File LIKE '%EUROPE%'
  OR Name LIKE '%EUROPE%'
  OR Name LIKE '%TSL_EUROPE%'
  OR File LIKE '%Mediterranean%'
  OR Name LIKE '%MEDITERRANEAN%';

-- Also copy MapSizes for those files into StandardMaps domain key if needed
INSERT OR IGNORE INTO MapSizes
  (Domain, MapSizeType, Name, Description, MinPlayers, MaxPlayers, DefaultPlayers, MinCityStates, MaxCityStates, DefaultCityStates, SortIndex)
SELECT
  'StandardMaps',
  MapSizeType,
  Name,
  Description,
  MinPlayers,
  MaxPlayers,
  DefaultPlayers,
  MinCityStates,
  MaxCityStates,
  DefaultCityStates,
  SortIndex
FROM MapSizes
WHERE
  Domain LIKE '%Europe%'
  OR Domain LIKE '%EUROPE%'
  OR Domain LIKE '%Mediterranean%';
