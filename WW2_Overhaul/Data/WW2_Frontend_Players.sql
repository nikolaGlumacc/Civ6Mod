-- Register Yugoslavia in the Create Game leader list (Gathering Storm domain)
-- so WW2 ruleset players can pick it like HOI4 nation select.

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
