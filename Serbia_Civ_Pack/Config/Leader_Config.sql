/*
    Leader Configuration (Front-End)
    Serbia Civilization Pack
*/

-----------------------------------------------
-- Players (Gathering Storm - Expansion2)
-----------------------------------------------

INSERT INTO Players 
        (Domain, CivilizationType, CivilizationName, CivilizationIcon, CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon, LeaderType, LeaderName, LeaderIcon, LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon)
VALUES  
        -- Tito
        (
        'Players:Expansion2_Players',
        'CIVILIZATION_SERBIA',
        'LOC_CIVILIZATION_SERBIA_NAME',
        'ICON_CIVILIZATION_SERBIA',
        'LOC_TRAIT_CIVILIZATION_CROSSROADS_NAME',
        'LOC_TRAIT_CIVILIZATION_CROSSROADS_DESCRIPTION',
        'ICON_CIVILIZATION_SERBIA',
        'LEADER_TITO',
        'LOC_LEADER_TITO_NAME',
        'ICON_LEADER_TITO',
        'LOC_TRAIT_LEADER_BROTHERHOOD_UNITY_NAME',
        'LOC_TRAIT_LEADER_BROTHERHOOD_UNITY_DESCRIPTION',
        'ICON_LEADER_TITO'
        ),
        -- Draža
        (
        'Players:Expansion2_Players',
        'CIVILIZATION_SERBIA',
        'LOC_CIVILIZATION_SERBIA_NAME',
        'ICON_CIVILIZATION_SERBIA',
        'LOC_TRAIT_CIVILIZATION_CROSSROADS_NAME',
        'LOC_TRAIT_CIVILIZATION_CROSSROADS_DESCRIPTION',
        'ICON_CIVILIZATION_SERBIA',
        'LEADER_DRAZA',
        'LOC_LEADER_DRAZA_NAME',
        'ICON_LEADER_DRAZA',
        'LOC_TRAIT_LEADER_RAVNA_GORA_NAME',
        'LOC_TRAIT_LEADER_RAVNA_GORA_DESCRIPTION',
        'ICON_LEADER_DRAZA'
        ),
        -- Milošević
        (
        'Players:Expansion2_Players',
        'CIVILIZATION_SERBIA',
        'LOC_CIVILIZATION_SERBIA_NAME',
        'ICON_CIVILIZATION_SERBIA',
        'LOC_TRAIT_CIVILIZATION_CROSSROADS_NAME',
        'LOC_TRAIT_CIVILIZATION_CROSSROADS_DESCRIPTION',
        'ICON_CIVILIZATION_SERBIA',
        'LEADER_MILOSEVIC',
        'LOC_LEADER_MILOSEVIC_NAME',
        'ICON_LEADER_MILOSEVIC',
        'LOC_TRAIT_LEADER_RALLY_OF_THE_PEOPLE_NAME',
        'LOC_TRAIT_LEADER_RALLY_OF_THE_PEOPLE_DESCRIPTION',
        'ICON_LEADER_MILOSEVIC'
        );

-----------------------------------------------
-- PlayerItems (Gathering Storm - Expansion2)
-----------------------------------------------

INSERT INTO PlayerItems
        (Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
VALUES
        -- Shared Civ Items: Building & Improvement
        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_TITO',      'BUILDING_DOM_KULTURE',        'ICON_BUILDING_DOM_KULTURE',       'LOC_BUILDING_DOM_KULTURE_NAME',        'LOC_BUILDING_DOM_KULTURE_DESCRIPTION',        10),
        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_DRAZA',     'BUILDING_DOM_KULTURE',        'ICON_BUILDING_DOM_KULTURE',       'LOC_BUILDING_DOM_KULTURE_NAME',        'LOC_BUILDING_DOM_KULTURE_DESCRIPTION',        10),
        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_MILOSEVIC', 'BUILDING_DOM_KULTURE',        'ICON_BUILDING_DOM_KULTURE',       'LOC_BUILDING_DOM_KULTURE_NAME',        'LOC_BUILDING_DOM_KULTURE_DESCRIPTION',        10),

        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_TITO',      'IMPROVEMENT_SPOMENIK',        'ICON_IMPROVEMENT_SPOMENIK',       'LOC_IMPROVEMENT_SPOMENIK_NAME',        'LOC_IMPROVEMENT_SPOMENIK_DESCRIPTION',        20),
        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_DRAZA',     'IMPROVEMENT_SPOMENIK',        'ICON_IMPROVEMENT_SPOMENIK',       'LOC_IMPROVEMENT_SPOMENIK_NAME',        'LOC_IMPROVEMENT_SPOMENIK_DESCRIPTION',        20),
        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_MILOSEVIC', 'IMPROVEMENT_SPOMENIK',        'ICON_IMPROVEMENT_SPOMENIK',       'LOC_IMPROVEMENT_SPOMENIK_NAME',        'LOC_IMPROVEMENT_SPOMENIK_DESCRIPTION',        20),

        -- Unique Units per Leader
        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_TITO',      'UNIT_PARTIZANI',              'ICON_UNIT_PARTIZANI',             'LOC_UNIT_PARTIZANI_NAME',              'LOC_UNIT_PARTIZANI_DESCRIPTION',              30),
        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_DRAZA',     'UNIT_CETNICKI_ODRED',         'ICON_UNIT_CETNICKI_ODRED',        'LOC_UNIT_CETNICKI_ODRED_NAME',         'LOC_UNIT_CETNICKI_ODRED_DESCRIPTION',         30),
        ('Players:Expansion2_Players', 'CIVILIZATION_SERBIA', 'LEADER_MILOSEVIC', 'UNIT_GARDIJSKA_JEDINICA',     'ICON_UNIT_GARDIJSKA_JEDINICA',    'LOC_UNIT_GARDIJSKA_JEDINICA_NAME',     'LOC_UNIT_GARDIJSKA_JEDINICA_DESCRIPTION',     30);
