-- Serbia Great People (stable)
-- Tesla: keep as Engineer in base data but add scientist-style eureka action modifiers
-- Full class swap is risky; grant eurekas when his action is used.

DELETE FROM GreatPersonIndividualActionModifiers
WHERE GreatPersonIndividualType = 'GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA'
  AND ModifierId LIKE 'TESLA_%';

INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
    ('TESLA_EUREKA_ELECTRICITY',        'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST', 1, 1),
    ('TESLA_EUREKA_RADIO',              'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST', 1, 1),
    ('TESLA_EUREKA_TELECOMMUNICATIONS', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST', 1, 1);

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value) VALUES
    ('TESLA_EUREKA_ELECTRICITY',        'TechType', 'TECH_ELECTRICITY'),
    ('TESLA_EUREKA_RADIO',              'TechType', 'TECH_RADIO'),
    ('TESLA_EUREKA_TELECOMMUNICATIONS', 'TechType', 'TECH_TELECOMMUNICATIONS');

INSERT OR IGNORE INTO GreatPersonIndividualActionModifiers (GreatPersonIndividualType, ModifierId, AttachmentTargetType) VALUES
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA', 'TESLA_EUREKA_ELECTRICITY',        'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA', 'TESLA_EUREKA_RADIO',              'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER'),
    ('GREAT_PERSON_INDIVIDUAL_NIKOLA_TESLA', 'TESLA_EUREKA_TELECOMMUNICATIONS', 'GREAT_PERSON_ACTION_ATTACHMENT_TARGET_PLAYER');
