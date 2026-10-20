-- WW2 Overhaul v1.0: 1936-style start
-- Grants key Industrial / early Modern techs and civics so the game starts in the right era

local TECHS = {
  "TECH_INDUSTRIALIZATION", "TECH_STEAM_POWER", "TECH_ELECTRICITY",
  "TECH_REPLACEABLE_PARTS", "TECH_FLIGHT", "TECH_REFINING", "TECH_COMBUSTION",
  "TECH_CHEMISTRY", "TECH_MILITARY_SCIENCE", "TECH_BALLISTICS", "TECH_RIFLING",
  "TECH_STEEL", "TECH_RADIO", "TECH_ADVANCED_BALLISTICS", "TECH_COMBINED_ARMS",
}

local CIVICS = {
  "CIVIC_URBANIZATION", "CIVIC_NATIONALISM", "CIVIC_IDEOLOGY",
  "CIVIC_SUFFRAGE", "CIVIC_TOTALITARIANISM", "CIVIC_CLASS_STRUGGLE",
  "CIVIC_MOBILIZATION", "CIVIC_CONSERVATION", "CIVIC_CAPITALISM",
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
  print("[WW2] Applying 1936-style start grants...")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      for _, t in ipairs(TECHS) do GrantTech(p, t) end
      for _, c in ipairs(CIVICS) do GrantCivic(p, c) end
    end
  end
  print("[WW2] 1936-style start complete")
end

Events.LoadScreenClose.Add(OnStart)
print("[WW2] Start logic v1.0 loaded")
