-- ==============================================================================
-- SERBIA CIVILIZATION PACK: GREAT PEOPLE
-- ==============================================================================

-- ==============================================================================
-- STEP 1: TYPES
-- ==============================================================================
INSERT OR IGNORE INTO Types (Type, Kind) VALUES
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA_SCIENTIST', 'KIND_GREAT_PERSON_INDIVIDUAL'),
    ('GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC',           'KIND_GREAT_PERSON_INDIVIDUAL'),
    ('GREAT_PERSON_INDIVIDUAL_DESANKA_MAKSIMOVIC',     'KIND_GREAT_PERSON_INDIVIDUAL');

-- ==============================================================================
-- STEP 2: GREAT PERSON INDIVIDUALS
-- ==============================================================================
INSERT OR IGNORE INTO GreatPersonIndividuals
    (GreatPersonIndividualType, Name, GreatPersonClassType, EraType)
VALUES
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA_SCIENTIST',
     'LOC_GREATPERSON_NIKOLA_TESLA_NAME',
     'GREAT_PERSON_CLASS_SCIENTIST',
     'ERA_INDUSTRIAL'),
    ('GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC',
     'LOC_GREATPERSON_RATKO_MLADIC_NAME',
     'GREAT_PERSON_CLASS_GENERAL',
     'ERA_INDUSTRIAL'),
    ('GREAT_PERSON_INDIVIDUAL_DESANKA_MAKSIMOVIC',
     'LOC_GREATPERSON_DESANKA_MAKSIMOVIC_NAME',
     'GREAT_PERSON_CLASS_WRITER',
     'ERA_MODERN');

-- ==============================================================================
-- STEP 3: REGION PRIORITY
-- ==============================================================================
INSERT OR IGNORE INTO GreatPersonIndividualBirthModifiers
    (GreatPersonIndividualType, ModifierId)
VALUES
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA_SCIENTIST', 'GREATPERSON_TESLA_BIRTH'),
    ('GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC',           'GREATPERSON_MLADIC_BIRTH'),
    ('GREAT_PERSON_INDIVIDUAL_DESANKA_MAKSIMOVIC',     'GREATPERSON_DESANKA_BIRTH');

-- ==============================================================================
-- STEP 4: GREAT PERSON ACTIONS
-- ==============================================================================
INSERT OR IGNORE INTO GreatPersonIndividualActionModifiers
    (GreatPersonIndividualType, ModifierId, AttachmentTargetType)
VALUES
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA_SCIENTIST', 'GREATPERSON_TESLA_EUREKA_ELECTRICITY', 'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA_SCIENTIST', 'GREATPERSON_TESLA_EUREKA_RADIO',       'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA_SCIENTIST', 'GREATPERSON_TESLA_SCIENCE_BURST',      'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC',           'GREATPERSON_MLADIC_GRANT_UNIT',        'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_RATKO_MLADIC',           'GREATPERSON_MLADIC_COMBAT_BUFF',       'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_DESANKA_MAKSIMOVIC',     'GREATPERSON_DESANKA_WORK_1',           'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_DESANKA_MAKSIMOVIC',     'GREATPERSON_DESANKA_WORK_2',           'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER');

-- ==============================================================================
-- STEP 5: MODIFIERS
-- ==============================================================================
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) VALUES
    ('GREATPERSON_TESLA_BIRTH',              'MODIFIER_PLAYER_ADJUST_GREAT_PERSON_POINTS', NULL),
    ('GREATPERSON_MLADIC_BIRTH',             'MODIFIER_PLAYER_ADJUST_GREAT_PERSON_POINTS', NULL),
    ('GREATPERSON_DESANKA_BIRTH',            'MODIFIER_PLAYER_ADJUST_GREAT_PERSON_POINTS', NULL),
    ('GREATPERSON_TESLA_EUREKA_ELECTRICITY', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST', NULL),
    ('GREATPERSON_TESLA_EUREKA_RADIO',       'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST', NULL),
    ('GREATPERSON_TESLA_SCIENCE_BURST',      'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', NULL),
    ('GREATPERSON_MLADIC_GRANT_UNIT',        'MODIFIER_PLAYER_GRANT_UNIT_IN_CITY',        NULL),
    ('GREATPERSON_MLADIC_COMBAT_BUFF',       'MODIFIER_PLAYER_UNITS_ADJUST_COMBAT_STRENGTH', NULL),
    ('GREATPERSON_DESANKA_WORK_1',           'MODIFIER_PLAYER_GRANT_GREAT_WORK',          NULL),
    ('GREATPERSON_DESANKA_WORK_2',           'MODIFIER_PLAYER_GRANT_GREAT_WORK',          NULL);

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
    ('GREATPERSON_TESLA_BIRTH',              'Amount', '10'),
    ('GREATPERSON_MLADIC_BIRTH',             'Amount', '10'),
    ('GREATPERSON_DESANKA_BIRTH',            'Amount', '10'),
    ('GREATPERSON_TESLA_EUREKA_ELECTRICITY', 'TechType', 'TECH_ELECTRICITY'),
    ('GREATPERSON_TESLA_EUREKA_RADIO',       'TechType', 'TECH_RADIO'),
    ('GREATPERSON_TESLA_SCIENCE_BURST',      'YieldType', 'YIELD_SCIENCE'),
    ('GREATPERSON_TESLA_SCIENCE_BURST',      'Amount',    '250'),
    ('GREATPERSON_MLADIC_GRANT_UNIT',        'UnitType', 'UNIT_MECHANIZED_INFANTRY'),
    ('GREATPERSON_MLADIC_GRANT_UNIT',        'Amount',   '1'),
    ('GREATPERSON_MLADIC_COMBAT_BUFF',       'Amount',   '5'),
    ('GREATPERSON_DESANKA_WORK_1',           'GreatWorkType', 'GREATWORK_KRVAVA_BAJKA'),
    ('GREATPERSON_DESANKA_WORK_2',           'GreatWorkType', 'GREATWORK_TRAZIM_POMILOVANJE');

-- ==============================================================================
-- STEP 6: GREAT WORKS
-- ==============================================================================
INSERT OR IGNORE INTO GreatWorks (GreatWorkType, Name, Quote, GreatWorkObjectType, Tourism) VALUES
    ('GREATWORK_KRVAVA_BAJKA',
     'LOC_GREATWORK_KRVAVA_BAJKA_NAME',
     'LOC_GREATWORK_KRVAVA_BAJKA_QUOTE',
     'GREATWORKOBJECT_WRITING',
     2),
    ('GREATWORK_TRAZIM_POMILOVANJE',
     'LOC_GREATWORK_TRAZIM_POMILOVANJE_NAME',
     'LOC_GREATWORK_TRAZIM_POMILOVANJE_QUOTE',
     'GREATWORKOBJECT_WRITING',
     2);