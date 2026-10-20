-- Only Domination victory
UPDATE Victories SET Enabled = 0 WHERE VictoryType != 'VICTORY_DOMINATION';
UPDATE Victories SET enabled = 1 WHERE VictoryType = 'VICTORY_DOMINATION';
