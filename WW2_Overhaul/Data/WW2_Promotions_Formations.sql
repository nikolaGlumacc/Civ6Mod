-- WW2 Overhaul: Promotions and Corps/Army formations heavily buffed
-- Goal: a unit with 2 promotion stars (or a Corps/Army) should feel roughly equal to two normal units

-- =====================================================
-- 1. Stronger promotion combat bonuses
-- =====================================================
-- Many promotions give +5 or +7 Combat Strength. We increase the most common ones.

-- Generic combat strength promotions (names can vary; these are the most common patterns)
UPDATE ModifierArguments
SET Value = CAST(CAST(Value AS INTEGER) * 2 AS TEXT)
WHERE Name = 'Amount'
  AND ModifierId IN (
    SELECT ModifierId FROM UnitPromotionModifiers
  )
  AND Value GLOB '[0-9]*';   -- only numeric amounts
  AND CAST(Value AS INTEGER) BETWEEN 1 AND 15;   -- safety: only small combat bonuses

-- =====================================================
-- 2. Corps and Army formation bonuses (big buff)
-- =====================================================
-- Default Corps is usually +10 Combat, Army +17 or similar.
-- We make them much stronger so one formed unit ≈ two regular units.

-- Corps combat bonus
UPDATE ModifierArguments
SET Value = '20'
WHERE ModifierId LIKE '%CORPS%' AND Name = 'Amount' AND Value GLOB '[0-9]*';

-- Army combat bonus
UPDATE ModifierArguments
SET Value = '35'
WHERE ModifierId LIKE '%ARMY%' AND Name = 'Amount' AND Value GLOB '[0-9]*';

-- Also boost the formation class itself if possible
UPDATE UnitFormations SET CombatBonus = CombatBonus + 10 WHERE FormationType LIKE '%CORPS%';
UPDATE UnitFormations SET CombatBonus = CombatBonus + 18 WHERE FormationType LIKE '%ARMY%';

-- =====================================================
-- Notes
-- =====================================================
-- The promotion update is broad on purpose so most existing promotions become stronger.
-- You can fine-tune specific promotions later by name if needed.
-- Formations are the main way a single unit becomes "worth two".
