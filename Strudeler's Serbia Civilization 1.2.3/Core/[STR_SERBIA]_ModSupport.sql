-- [STR_SERBIA]_ModSupport
-- Author: Strudeler
-- DateCreated: 7/2/2022 3:24:20 PM
--------------------------------------------------------------
/*	TOMATEKH'S HISTORICAL RELIGIONS	*/
--Stefan Uros IV Dusan the Mighty Nemanjic (Serbia)
--DELETE FROM FavoredReligions WHERE LeaderType = 'LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
--AND EXISTS (SELECT * FROM Leaders WHERE ReligionType = 'RELIGION_ORTHODOXY');
--INSERT OR REPLACE INTO FavoredReligions
--			 (LeaderType,														ReligionType)
--	SELECT   ('LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'),	('RELIGION_ORTHODOXY')
--	WHERE EXISTS (SELECT * FROM Religions WHERE ReligionType = 'RELIGION_ORTHODOXY');

--Stefan Uros IV Dusan the Mighty Nemanjic (Byzantium)
--DELETE FROM FavoredReligions WHERE LeaderType = 'LEADER_STR_BYZANTIUM_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
--AND EXISTS (SELECT * FROM Leaders WHERE ReligionType = 'RELIGION_ORTHODOXY');
--INSERT OR REPLACE INTO FavoredReligions
--			 (LeaderType,														ReligionType)
--	SELECT   ('LEADER_STR_BYZANTIUM_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'),	('RELIGION_ORTHODOXY')
--	WHERE EXISTS (SELECT * FROM Religions WHERE ReligionType = 'RELIGION_ORTHODOXY');

--Stefan Uros IV Dusan the Mighty Nemanjic (Greece)
--DELETE FROM FavoredReligions WHERE LeaderType = 'LEADER_STR_GREECE_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'
--AND EXISTS (SELECT * FROM Leaders WHERE ReligionType = 'RELIGION_ORTHODOXY');
--DELETE FROM FavoredReligions WHERE LeaderType = 'LEADER_STR_GREECE_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC';
--INSERT OR REPLACE INTO FavoredReligions
--			 (LeaderType,														ReligionType)
--	SELECT   ('LEADER_STR_GREECE_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC'),	('RELIGION_ORTHODOXY')
--	WHERE EXISTS (SELECT * FROM Religions WHERE ReligionType = 'RELIGION_ORTHODOXY');