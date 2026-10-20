/*
    Serbia Civilization Pack - Colors (InGame only)
*/

INSERT OR IGNORE INTO Colors (Type, Color) VALUES
    ('COLOR_PLAYER_SERBIA_PRIMARY',   '199,30,40,255'),
    ('COLOR_PLAYER_SERBIA_SECONDARY', '10,50,140,255'),


INSERT OR REPLACE INTO PlayerColors (Type, Usage, PrimaryColor, SecondaryColor)
VALUES
    ('CIVILIZATION_SERBIA', 'Unique', 'COLOR_PLAYER_SERBIA_PRIMARY', 'COLOR_PLAYER_SERBIA_SECONDARY'),

