-- WW2-safe upgrades: never reference units that may be missing (Cuirassier, Line Infantry).
-- Prefer always-present GS units: Infantry, Mechanized Infantry, Tank, Rocket Artillery.

DELETE FROM UnitUpgrades WHERE Unit IN (
  'UNIT_PARTIZANI', 'UNIT_CHETNIK', 'UNIT_ALEMANNIC_GUARD', 'UNIT_NEVA_M'
);

INSERT INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_PARTIZANI', 'UNIT_MECHANIZED_INFANTRY'
WHERE EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_MECHANIZED_INFANTRY');

INSERT INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_CHETNIK', 'UNIT_INFANTRY'
WHERE EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_INFANTRY');

INSERT INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_ALEMANNIC_GUARD', 'UNIT_TANK'
WHERE EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_TANK');

INSERT INTO UnitUpgrades (Unit, UpgradeUnit)
SELECT 'UNIT_NEVA_M', 'UNIT_ROCKET_ARTILLERY'
WHERE EXISTS (SELECT 1 FROM Units WHERE UnitType = 'UNIT_ROCKET_ARTILLERY');
