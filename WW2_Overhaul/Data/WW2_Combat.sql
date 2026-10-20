-- Stronger wars: more damage to cities, stronger navy & air, adjusted healing
-- Unit production costs are NOT increased.

-- City attack bonuses (units hit cities harder)
UPDATE GlobalParameters SET Value = 20 WHERE Name = 'COMBAT_CITY_ATTACK_BONUS';
UPDATE GlobalParameters SET Value = 15 WHERE Name = 'COMBAT_CITY_RANGED_ATTACK_BONUS';

-- Districts take more damage
UPDATE GlobalParameters SET Value = 50 WHERE Name = 'DISTRICT_DAMAGE_PERCENT';

-- Navy stronger
UPDATE Units SET Combat = Combat + 5 WHERE Domain = 'DOMAIN_SEA' AND Combat > 0;
UPDATE Units SET RangedCombat = RangedCombat + 5 WHERE Domain = 'DOMAIN_SEA' AND RangedCombat > 0;
UPDATE Units SET Bombard = Bombard + 5 WHERE Domain = 'DOMAIN_SEA' AND Bombard > 0;

-- Air stronger
UPDATE Units SET Combat = Combat + 5 WHERE Domain = 'DOMAIN_AIR' AND Combat > 0;
UPDATE Units SET RangedCombat = RangedCombat + 8 WHERE Domain = 'DOMAIN_AIR' AND RangedCombat > 0;
UPDATE Units SET Bombard = Bombard + 8 WHERE Domain = 'DOMAIN_AIR' AND Bombard > 0;

-- Healing: slower outside friendly territory (front lines matter)
UPDATE GlobalParameters SET Value = 5 WHERE Name = 'HEAL_RATE_OUTSIDE_FRIENDLY';
UPDATE GlobalParameters SET Value = 15 WHERE Name = 'HEAL_RATE_FRIENDLY';
