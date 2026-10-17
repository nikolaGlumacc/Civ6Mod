-- Serbia Great People
-- Nikola Tesla -> Scientist (was Engineer in base game)
-- Ratko Mladic -> Great General (+5 CS aura, no attack)
-- Desanka Maksimovic -> Great Writer

-- ===================== TESLA: Engineer -> Scientist =====================
-- Base game has GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA as Engineer.
-- Move him to Scientist class and give Electricity / Radio / Telecommunications eurekas.

UPDATE GreatPersonIndividuals
SET GreatPersonClassType = 'GREAT_PERSON_CLASS_SCIENTIST',
    ActionCharges = 1
WHERE GreatPersonIndividualType = 'GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA';

-- Clear old engineer action modifiers if any (safe if none)
DELETE FROM GreatPersonIndividualActionModifiers
WHERE GreatPersonIndividualType = 'GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA';

DELETE FROM GreatPersonIndividualBirthModifiers
WHERE GreatPersonIndividualType = 'GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA';

-- Tesla eureka modifiers
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
    ('TESLA_EUREKA_ELECTRICITY',       'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST', 1, 1),
    ('TESLA_EUREKA_RADIO',             'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST', 1, 1),
    ('TESLA_EUREKA_TELECOMMUNICATIONS','MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST', 1, 1);

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
    ('TESLA_EUREKA_ELECTRICITY',        'TechType', 'TECH_ELECTRICITY'),
    ('TESLA_EUREKA_RADIO',              'TechType', 'TECH_RADIO'),
    ('TESLA_EUREKA_TELECOMMUNICATIONS', 'TechType', 'TECH_TELECOMMUNICATIONS');

INSERT OR IGNORE INTO GreatPersonIndividualActionModifiers (GreatPersonIndividualType, ModifierId, AttachmentTargetType) VALUES
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA', 'TESLA_EUREKA_ELECTRICITY',        'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA', 'TESLA_EUREKA_RADIO',              'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA', 'TESLA_EUREKA_TELECOMMUNICATIONS', 'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER');

-- ===================== RATKO MLADIC - Great General =====================
INSERT OR IGNORE INTO Types (Type, Kind) VALUES
    ('GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC', 'KIND_GREAT_PERSON_INDIVIDUAL');

INSERT OR IGNORE INTO GreatPersonIndividuals (
    GreatPersonIndividualType, Name, GreatPersonClassType, EraType,
    ActionCharges, ActionRequiresOwnedTile, ActionNameTextOverride,
    ActionEffectTileHighlighting, AreaHighlightRadius
) VALUES (
    'GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC',
    'LOC_GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC_NAME',
    'GREAT_PERSON_CLASS_GENERAL',
    'ERA_INFORMATION',
    0,
    0,
    'LOC_GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC_ACTION',
    0,
    2
);

-- Passive aura +5 CS to land combat units within 2 tiles (passive via birth modifier on unit)
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) VALUES
    ('MLADIC_LAND_COMBAT_AURA', 'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH', 'MLADIC_NEAR_GENERAL');

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
    ('MLADIC_LAND_COMBAT_AURA', 'Amount', '5');

INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
    ('MLADIC_NEAR_GENERAL', 'REQUIREMENTSET_TEST_ALL');

INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
    ('MLADIC_NEAR_GENERAL', 'REQUIRES_LAND_UNIT'),
    ('MLADIC_NEAR_GENERAL', 'REQUIRES_UNIT_WITHIN_TWO_OF_OWNER');

-- Reuse base requirements if they exist; add safe fallbacks
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType) VALUES
    ('REQUIRES_UNIT_WITHIN_TWO_OF_OWNER', 'REQUIREMENT_PLOT_ADJACENT_TO_OWNER');

INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value) VALUES
    ('REQUIRES_UNIT_WITHIN_TWO_OF_OWNER', 'MinDistance', '0'),
    ('REQUIRES_UNIT_WITHIN_TWO_OF_OWNER', 'MaxDistance', '2');

INSERT OR IGNORE INTO GreatPersonIndividualBirthModifiers (GreatPersonIndividualType, ModifierId) VALUES
    ('GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC', 'MLADIC_LAND_COMBAT_AURA');

-- Tag as cannot attack: CLASS_RECON-like via ability is heavy; leave passive aura only.

-- ===================== DESANKA MAKSIMOVIC - Great Writer =====================
INSERT OR IGNORE INTO Types (Type, Kind) VALUES
    ('GREAT_PERSON_INDIVIDUAL_DESANKA_MAKSIMOVIC', 'KIND_GREAT_PERSON_INDIVIDUAL');

INSERT OR IGNORE INTO GreatPersonIndividuals (
    GreatPersonIndividualType, Name, GreatPersonClassType, EraType, ActionCharges
) VALUES (
    'GREAT_PERSON_INDIVIDUAL_DESANKA_MAKSIMOVIC',
    'LOC_GREAT_PERSON_INDIVIDUAL_DESANKA_MAKSIMOVIC_NAME',
    'GREAT_PERSON_CLASS_WRITER',
    'ERA_MODERN',
    1
);
