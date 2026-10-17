/*
    Serbia Civilization Pack - Colors
    Only PlayerColors with columns that exist in all versions.
    Do NOT insert into Colors table from FrontEnd (it does not exist there).
*/

-- Civilization colors (Serbian red / blue)
INSERT OR REPLACE INTO PlayerColors (Type, Usage, PrimaryColor, SecondaryColor)
VALUES
    ('CIVILIZATION_SERBIA', 'Unique', '199,30,40,255', '10,50,140,255');

-- Leader colors
INSERT OR REPLACE INTO PlayerColors (Type, Usage, PrimaryColor, SecondaryColor)
VALUES
    ('LEADER_TITO',      'Unique', '199,30,40,255',  '200,160,50,255'),
    ('LEADER_DRAZA',     'Unique', '30,30,35,255',   '240,240,240,255'),
    ('LEADER_MILOSEVIC', 'Unique', '199,30,40,255',  '30,30,35,255'),
    ('LEADER_DUSAN',     'Unique', '200,160,50,255', '199,30,40,255');
