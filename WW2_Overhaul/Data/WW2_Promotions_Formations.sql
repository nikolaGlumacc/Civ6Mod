-- Promotions and Corps/Army formations heavily buffed
-- Goal: 2-star unit or formed unit ≈ two normal units

-- Double small numeric combat bonuses on promotions (safe range)
UPDATE ModifierArguments
SET Value = CAST(CAST(Value AS INTEGER) * 2 AS TEXT)
WHERE Name = 'Amount'
  AND ModifierId IN (SELECT ModifierId FROM UnitPromotionModifiers)
  AND Value GLOB '[0-9]*'
  AND CAST(Value AS INTEGER) BETWEEN 1 AND 15;

-- Corps / Army combat bonuses (big buff)
UPDATE ModifierArguments SET Value = '20' WHERE ModifierId LIKE '%CORPS%' AND Name = 'Amount' AND Value GLOB '[0-9]*';
UPDATE ModifierArguments SET Value = '35' WHERE ModifierId LIKE '%ARMY%' AND Name = 'Amount' AND Value GLOB '[0-9]*';

-- Formation class combat bonuses
UPDATE UnitFormations SET CombatBonus = CombatBonus + 10 WHERE FormationType LIKE '%CORPS%';
UPDATE UnitFormations SET CombatBonus = CombatBonus + 18 WHERE FormationType LIKE '%ARMY%';
