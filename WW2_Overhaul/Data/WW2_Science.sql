-- WW2 Overhaul: Science is deliberately hard
-- World did not unlock nuclear weapons until the end of the war

-- Strong global reduction to science from population
UPDATE GlobalParameters SET Value = 10 WHERE Name = 'SCIENCE_PERCENTAGE_YIELD_PER_POP';  -- was typically 50 or so

-- Campus and science buildings give less (safe updates)
UPDATE Building_YieldChanges
SET YieldChange = MAX(1, YieldChange - 2)
WHERE YieldType = 'YIELD_SCIENCE' AND YieldChange > 2;

-- Make nuclear techs much more expensive if the columns exist
UPDATE Technologies SET Cost = Cost * 3
WHERE TechnologyType IN (
  'TECH_NUCLEAR_FISSION',
  'TECH_NUCLEAR_FUSION',
  'TECH_NANOTECHNOLOGY',
  'TECH_SMART_MATERIALS',
  'TECH_PREDICTIVE_SYSTEMS'
);

-- Slightly increase cost of late modern military techs so the war lasts
UPDATE Technologies SET Cost = Cost * 2
WHERE TechnologyType IN (
  'TECH_ROCKETRY',
  'TECH_COMPUTERS',
  'TECH_SATELLITES',
  'TECH_GUIDANCE_SYSTEMS',
  'TECH_LASERS',
  'TECH_COMPOSITES',
  'TECH_STEALTH_TECHNOLOGY'
);
