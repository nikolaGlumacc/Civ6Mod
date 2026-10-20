-- Loyalty pressure disabled for long WW2-style wars
-- Dark Ages / Golden Ages and the rest of the RF loyalty framework still exist,
-- but foreign loyalty pressure is removed so cities do not flip easily.

UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_NEARBY_FOREIGN_CITY';
UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_NEARBY_FOREIGN_CITY_MAX';

-- Soften additional common loyalty sources that cause flips during long wars
UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_GOVERNOR' AND EXISTS (SELECT 1 FROM GlobalParameters WHERE Name = 'LOYALTY_PER_TURN_FROM_GOVERNOR');
