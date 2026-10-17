/*
    Serbia Civilization Pack - Colors
    Red / blue / white inspired by Serbian flag, with distinct leader variants
*/

INSERT OR IGNORE INTO Colors (Type, Color) VALUES
    ('COLOR_SERBIA_PRIMARY',      '199,30,40,255'),   -- Serbian red
    ('COLOR_SERBIA_SECONDARY',    '10,50,140,255'),   -- Serbian blue
    ('COLOR_SERBIA_WHITE',        '240,240,240,255'),
    ('COLOR_SERBIA_GOLD',         '200,160,50,255'),
    ('COLOR_SERBIA_DARK',         '30,30,35,255'),
    ('COLOR_SERBIA_GREEN',        '40,120,70,255');

-- Civilization default colors
INSERT OR IGNORE INTO PlayerColors
    (Type, Usage, PrimaryColor, SecondaryColor,
     Alt1PrimaryColor, Alt1SecondaryColor,
     Alt2PrimaryColor, Alt2SecondaryColor,
     Alt3PrimaryColor, Alt3SecondaryColor)
VALUES
    ('CIVILIZATION_SERBIA', 'Unique',
     'COLOR_SERBIA_PRIMARY', 'COLOR_SERBIA_SECONDARY',
     'COLOR_SERBIA_SECONDARY', 'COLOR_SERBIA_WHITE',
     'COLOR_SERBIA_DARK', 'COLOR_SERBIA_GOLD',
     'COLOR_SERBIA_WHITE', 'COLOR_SERBIA_PRIMARY');

-- Leader colors (each leader gets a distinct palette)
INSERT OR IGNORE INTO PlayerColors
    (Type, Usage, PrimaryColor, SecondaryColor,
     Alt1PrimaryColor, Alt1SecondaryColor,
     Alt2PrimaryColor, Alt2SecondaryColor,
     Alt3PrimaryColor, Alt3SecondaryColor)
VALUES
    -- Tito: red + gold (Yugoslav feel)
    ('LEADER_TITO', 'Unique',
     'COLOR_SERBIA_PRIMARY', 'COLOR_SERBIA_GOLD',
     'COLOR_SERBIA_SECONDARY', 'COLOR_SERBIA_WHITE',
     'COLOR_SERBIA_DARK', 'COLOR_SERBIA_PRIMARY',
     'COLOR_SERBIA_GOLD', 'COLOR_SERBIA_DARK'),

    -- Draza: dark + white (royalist / Chetnik)
    ('LEADER_DRAZA', 'Unique',
     'COLOR_SERBIA_DARK', 'COLOR_SERBIA_WHITE',
     'COLOR_SERBIA_PRIMARY', 'COLOR_SERBIA_SECONDARY',
     'COLOR_SERBIA_SECONDARY', 'COLOR_SERBIA_GOLD',
     'COLOR_SERBIA_WHITE', 'COLOR_SERBIA_DARK'),

    -- Milosevic: red + dark
    ('LEADER_MILOSEVIC', 'Unique',
     'COLOR_SERBIA_PRIMARY', 'COLOR_SERBIA_DARK',
     'COLOR_SERBIA_SECONDARY', 'COLOR_SERBIA_WHITE',
     'COLOR_SERBIA_GOLD', 'COLOR_SERBIA_PRIMARY',
     'COLOR_SERBIA_DARK', 'COLOR_SERBIA_GOLD'),

    -- Dusan: gold + red (imperial medieval)
    ('LEADER_DUSAN', 'Unique',
     'COLOR_SERBIA_GOLD', 'COLOR_SERBIA_PRIMARY',
     'COLOR_SERBIA_SECONDARY', 'COLOR_SERBIA_WHITE',
     'COLOR_SERBIA_DARK', 'COLOR_SERBIA_GOLD',
     'COLOR_SERBIA_WHITE', 'COLOR_SERBIA_SECONDARY');
