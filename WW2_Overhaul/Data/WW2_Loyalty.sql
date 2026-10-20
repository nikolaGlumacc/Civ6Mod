-- Loyalty pressure off for long WW2 wars (RF ages still work)
UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_NEARBY_FOREIGN_CITY';
UPDATE GlobalParameters SET Value = 0 WHERE Name = 'LOYALTY_PER_TURN_FROM_NEARBY_FOREIGN_CITY_MAX';
