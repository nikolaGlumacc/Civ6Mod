-- Avoid duplicate Europe tiles: only insert into StandardMaps if that File is not already there.
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
  (File LIKE '%Europe%' OR File LIKE '%EUROPE%' OR Name LIKE '%EUROPE%' OR Name LIKE '%TSL_EUROPE%'
   OR File LIKE '%Mediterranean%' OR Name LIKE '%MEDITERRANEAN%')
  AND Domain IS NOT 'StandardMaps'
  AND File NOT IN (SELECT File FROM Maps WHERE Domain = 'StandardMaps');
