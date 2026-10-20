-- Only Domination victory is allowed
-- All other victory types are disabled

UPDATE Victories SET Enabled = 0 WHERE VictoryType != 'VICTORY_DOMINATION';
UPDATE Victories SET Enabled = 1 WHERE VictoryType = 'VICTORY_DOMINATION';
