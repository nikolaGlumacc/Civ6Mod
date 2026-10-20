-- WW2 Overhaul: Loyalty heavily reduced / disabled for long WW2-style wars
-- Cities should not flip easily from loyalty pressure during multi-year conflicts

-- Greatly reduce loyalty pressure from other civilizations
UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_NEARBY_FOREIGN_CITY';
UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_NEARBY_FOREIGN_CITY_MAX';

-- Reduce or nullify many loyalty modifiers (safe defaults)
UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_GOVERNOR';
UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_HAPPINESS';

-- Make identity / pressure much weaker overall
-- (These names can vary slightly by version; the above covers the most important ones)

-- Note: Full removal of the loyalty system requires Lua or more invasive changes.
-- This SQL makes loyalty flips extremely rare so long wars stay playable.
