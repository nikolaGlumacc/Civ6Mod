-- Safe unit upgrades: only insert if the target unit exists in the Units table.
-- This prevents FOREIGN KEY failures when another mod (or ruleset) removes intermediate units
-- such as UNIT_CUIRASSIER / UNIT_LINE_INFANTRY (common with overhauls / WW2-style packs).

-- Partizani -> Mechanized Infantry
INSERT OR IGNORE INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_PARTIZANI', 'UNIT_MECHANIZED_INFANTRY'
WHERE EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_MECHANIZED_INFANTRY');

-- Chetnik -> Line Infantry (fallback: Infantry)
INSERT OR IGNORE INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_CHETNIK', 'UNIT_LINE_INFANTRY'
WHERE EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_LINE_INFANTRY');

INSERT OR IGNORE INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_CHETNIK', 'UNIT_INFANTRY'
WHERE NOT EXISTS (SELECT 1 FROM UnitUpgrades WHERE Unit = 'UNIT_CHETNIK')
  AND EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_INFANTRY');

-- Alemannic Guard -> Cuirassier (fallback: Tank — always present with GS)
INSERT OR IGNORE INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_ALEMANNIC_GUARD', 'UNIT_CUIRASSIER'
WHERE EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_CUIRASSIER');

INSERT OR IGNORE INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_ALEMANNIC_GUARD', 'UNIT_TANK'
WHERE NOT EXISTS (SELECT 1 FROM UnitUpgrades WHERE Unit = 'UNIT_ALEMANNIC_GUARD')
  AND EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_TANK');

-- Neva-M -> Rocket Artillery
INSERT OR IGNORE INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_NEVA_M', 'UNIT_ROCKET_ARTILLERY'
WHERE EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_ROCKET_ARTILLERY');
