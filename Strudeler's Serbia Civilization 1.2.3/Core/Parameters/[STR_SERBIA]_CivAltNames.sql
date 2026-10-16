-- [STR_SERBIA]_CivAltNames
-- Author: Strudeler
-- DateCreated: 2/11/2024 7:34:33 PM
--------------------------------------------------------------
--Alt names tied to slider
INSERT INTO Parameters
			(ParameterId,			Name,								Description,							Domain,						DefaultValue,	ConfigurationGroup,	ConfigurationId,		GroupId,		SortIndex)
	VALUES	('STRSerbiaAltNames',	'LOC_STR_SERBIA_ALT_NAMES_NAME',	'LOC_STR_SERBIA_ALT_NAMES_DESCRIPTION',	'STRSerbiaAltNamesRange',	0,				'Game',				'STR_SERBIA_ALT_NAMES',	'GameOptions',	200);

INSERT INTO DomainRanges
			(Domain,					MinimumValue,	MaximumValue)
	VALUES	('STRSerbiaAltNamesRange',	0,				6);