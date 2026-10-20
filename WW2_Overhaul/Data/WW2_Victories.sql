-- WW2 Overhaul: Only Domination victory is allowed
-- Culture, Science, Religion, Diplomatic and Score victories are disabled

-- Disable all non-Domination victories
UPDATE Victories SET Enabled = 0 WHERE VictoryType != 'VICTORY_DOMINATION';

-- Make sure Domination is enabled
UPDATE Victories SET Enabled = 1 WHERE VictoryType = 'VICTORY_DOMINATION';

-- Optional: make Domination require fewer capitals if desired (uncomment to adjust)
-- UPDATE GlobalParameters SET Value = 60 WHERE Name = 'DOMINATION_VICTORY_PERCENT';  -- default is usually higher
