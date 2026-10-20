-- WW2 Overhaul: Europe-oriented start biases + Serbia/Yugoslavia readiness
-- True pixel-perfect TSL needs YnAMP + a Europe map. Without that we:
--  1) Bias Serbia / Yugoslavia toward hills & temperate land (Balkan-like)
--  2) Prefer Continents + Large via ConfigurationUpdates (see WW2_Ruleset.xml)
--  3) Lua polar-start rescue if someone still lands on ice/snow

-- Serbia (from Serbia_Civ_Pack) — reinforce highland / temperate bias
INSERT OR IGNORE INTO StartBiasTerrains (CivilizationType, TerrainType, Tier) VALUES
('CIVILIZATION_SERBIA', 'TERRAIN_GRASS_HILLS', 1),
('CIVILIZATION_SERBIA', 'TERRAIN_PLAINS_HILLS', 1),
('CIVILIZATION_SERBIA', 'TERRAIN_GRASS', 2),
('CIVILIZATION_SERBIA', 'TERRAIN_PLAINS', 3);

-- Avoid snow/tundra starts when possible (Tier high = less preferred; game uses low Tier = stronger)
-- StartBias is "prefer"; polar avoidance is handled in Lua rescue.

-- Yugoslavia (WW2 pack)
INSERT OR IGNORE INTO StartBiasTerrains (CivilizationType, TerrainType, Tier) VALUES
('CIVILIZATION_WW2_YUGOSLAVIA', 'TERRAIN_GRASS_HILLS', 1),
('CIVILIZATION_WW2_YUGOSLAVIA', 'TERRAIN_PLAINS_HILLS', 1),
('CIVILIZATION_WW2_YUGOSLAVIA', 'TERRAIN_GRASS', 2),
('CIVILIZATION_WW2_YUGOSLAVIA', 'TERRAIN_PLAINS', 3);

-- Extra city names for Yugoslavia so it feels campaign-ready
INSERT OR IGNORE INTO CityNames (CivilizationType, CityName) VALUES
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_BELGRADE'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_ZAGREB'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_SARAJEVO'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_SKOPJE'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_LJUBLJANA'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_NOVI_SAD'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_NIS'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_SPLIT'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_DUBROVNIK'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_PODGORICA'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_PRISTINA'),
('CIVILIZATION_WW2_YUGOSLAVIA', 'LOC_CITY_NAME_BANJA_LUKA');
