-- WW2 Overhaul v1.2: Unlock almost everything up to mid-Industrial / early Modern
-- Science is nerfed separately so nuclear path stays very slow

local TECHS = {
  -- Ancient → Renaissance (everything early)
  "TECH_POTTERY", "TECH_ANIMAL_HUSBANDRY", "TECH_MINING", "TECH_SAILING",
  "TECH_ASTROLOGY", "TECH_IRRIGATION", "TECH_WRITING", "TECH_MASONRY",
  "TECH_ARCHERY", "TECH_BRONZE_WORKING", "TECH_WHEEL",
  "TECH_CELESTIAL_NAVIGATION", "TECH_CURRENCY", "TECH_HORSEBACK_RIDING",
  "TECH_IRON_WORKING", "TECH_SHIPBUILDING", "TECH_MATHEMATICS",
  "TECH_CONSTRUCTION", "TECH_ENGINEERING", "TECH_MILITARY_TACTICS",
  "TECH_APPRENTICESHIP", "TECH_STIRRUPS", "TECH_MACHINERY", "TECH_EDUCATION",
  "TECH_MILITARY_ENGINEERING", "TECH_CASTLES", "TECH_PRINTING",
  "TECH_GUNPOWDER", "TECH_CARTOGRAPHY", "TECH_MASS_PRODUCTION",
  "TECH_BANKING", "TECH_ASTRONOMY", "TECH_METAL_CASTING", "TECH_SIEGE_TACTICS",
  "TECH_SQUARE_RIGGING", "TECH_EXPLORATION", "TECH_INDUSTRIALIZATION",
  -- Industrial core (unlocked)
  "TECH_STEAM_POWER", "TECH_SANITATION", "TECH_ECONOMICS", "TECH_RIFLING",
  "TECH_MILITARY_SCIENCE", "TECH_BALLISTICS", "TECH_STEEL", "TECH_REFINING",
  "TECH_ELECTRICITY", "TECH_RADIO", "TECH_REPLACEABLE_PARTS", "TECH_FLIGHT",
  "TECH_CHEMISTRY", "TECH_COMBUSTION",
  -- Early Modern (unlocked so WW2 units exist)
  "TECH_ADVANCED_BALLISTICS", "TECH_COMBINED_ARMS", "TECH_SYNTHETIC_MATERIALS",
  -- Intentionally NOT unlocked: TECH_NUCLEAR_FISSION, TECH_NUCLEAR_FUSION,
  -- TECH_NANOTECHNOLOGY, TECH_SMART_MATERIALS, etc. — science is slow so these stay late
}

local CIVICS = {
  "CIVIC_CODE_OF_LAWS", "CIVIC_CRAFTSMANSHIP", "CIVIC_FOREIGN_TRADE",
  "CIVIC_MILITARY_TRADITION", "CIVIC_STATE_WORKFORCE", "CIVIC_EARLY_EMPIRE",
  "CIVIC_MYSTICISM", "CIVIC_GAMES_RECREATION", "CIVIC_POLITICAL_PHILOSOPHY",
  "CIVIC_DRAMA_POETRY", "CIVIC_MILITARY_TRAINING", "CIVIC_DEFENSIVE_TACTICS",
  "CIVIC_RECORDED_HISTORY", "CIVIC_THEOLOGY", "CIVIC_NAVAL_TRADITION",
  "CIVIC_FEUDALISM", "CIVIC_CIVIL_SERVICE", "CIVIC_MERCENARIES",
  "CIVIC_MEDIEVAL_FAIRES", "CIVIC_GUILDS", "CIVIC_DIVINE_RIGHT",
  "CIVIC_EXPLORATION", "CIVIC_HUMANISM", "CIVIC_DIPLOMATIC_SERVICE",
  "CIVIC_REFORMED_CHURCH", "CIVIC_MERCANTILISM", "CIVIC_THE_ENLIGHTENMENT",
  "CIVIC_CIVIL_ENGINEERING", "CIVIC_NATIONALISM", "CIVIC_OPERA_BALLET",
  "CIVIC_NATURAL_HISTORY", "CIVIC_URBANIZATION", "CIVIC_SCORCHED_EARTH",
  "CIVIC_COLONIALISM", "CIVIC_MOBILIZATION", "CIVIC_CONSERVATION",
  "CIVIC_MASS_MEDIA", "CIVIC_IDEOLOGY", "CIVIC_SUFFRAGE",
  "CIVIC_TOTALITARIANISM", "CIVIC_CLASS_STRUGGLE", "CIVIC_CAPITALISM",
  -- Nuclear Program civic intentionally not granted — keep late
}

local function GrantTech(player, techType)
  local tech = GameInfo.Technologies[techType]
  if not tech then return end
  local techs = player:GetTechs()
  if techs and not techs:HasTech(tech.Index) then
    techs:SetResearchProgress(tech.Index, techs:GetResearchCost(tech.Index))
  end
end

local function GrantCivic(player, civicType)
  local civic = GameInfo.Civics[civicType]
  if not civic then return end
  local culture = player:GetCulture()
  if culture and not culture:HasCivic(civic.Index) then
    culture:SetCulturalProgress(civic.Index, culture:GetCultureCost(civic.Index))
  end
end

local function OnStart()
  print("[WW2] Unlocking techs/civics through mid-Industrial / early Modern...")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      for _, t in ipairs(TECHS) do GrantTech(p, t) end
      for _, c in ipairs(CIVICS) do GrantCivic(p, c) end
    end
  end
  print("[WW2] Start unlocks complete. Nuclear path remains locked behind slow science.")
end

Events.LoadScreenClose.Add(OnStart)
print("[WW2] Start logic v1.2 loaded")
