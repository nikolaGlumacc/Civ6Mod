-- Ensure Europe maps show under WW2 ruleset by tagging / inserting map rows.
-- Also copy any existing Europe map entries so Domain filters still see them.

-- Some game builds store Ruleset on Maps; if column exists this helps.
-- Safe no-ops when column missing are not possible in pure SQL without pragma,
-- so we only INSERT full rows via XML. This SQL adds MapSizes for common paths.

INSERT OR IGNORE INTO MapSizes
  (Domain, MapSizeType, Name, Description, MinPlayers, MaxPlayers, DefaultPlayers, MinCityStates, MaxCityStates, DefaultCityStates, SortIndex)
VALUES
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/TSLEurope.Civ6Map', 'MAPSIZE_STANDARD', 'LOC_MAPSIZE_STANDARD_NAME', 'LOC_MAPSIZE_STANDARD_DESCRIPTION', 2, 14, 10, 0, 18, 12, 10),
('{1B28771A-C749-434B-9053-D1380C553DE9}Maps/Europe.Civ6Map', 'MAPSIZE_STANDARD', 'LOC_MAPSIZE_STANDARD_NAME', 'LOC_MAPSIZE_STANDARD_DESCRIPTION', 2, 14, 10, 0, 18, 12, 10),
('{4873eb62-8ccc-4574-b784-dda455e74e68}Maps/TSLEurope_XP2.Civ6Map', 'MAPSIZE_STANDARD', 'LOC_MAPSIZE_STANDARD_NAME', 'LOC_MAPSIZE_STANDARD_DESCRIPTION', 2, 14, 10, 0, 18, 12, 10),
('{4873eb62-8ccc-4574-b784-dda455e74e68}Maps/Europe_XP2.Civ6Map', 'MAPSIZE_STANDARD', 'LOC_MAPSIZE_STANDARD_NAME', 'LOC_MAPSIZE_STANDARD_DESCRIPTION', 2, 14, 10, 0, 18, 12, 10),
('../../Assets/Maps/EarthMaps/TSLMediterraneanLarge.Civ6Map', 'MAPSIZE_LARGE', 'LOC_MAPSIZE_LARGE_NAME', 'LOC_MAPSIZE_LARGE_DESCRIPTION', 2, 16, 10, 0, 22, 15, 10),
('../../Assets/Maps/EarthMaps/MediterraneanLarge.Civ6Map', 'MAPSIZE_LARGE', 'LOC_MAPSIZE_LARGE_NAME', 'LOC_MAPSIZE_LARGE_DESCRIPTION', 2, 16, 10, 0, 22, 15, 10);
