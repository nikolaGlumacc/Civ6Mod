-- WW2 Overhaul: 1936-style start
-- Grants a large set of Industrial / early Modern techs and civics at game start
-- so the game feels like the late 1930s instead of Ancient era.

local function GrantTech(player, techType)
  local tech = GameInfo.Technologies[techType]
  if tech then
    local playerTechs = player:GetTechs()
    if playerTechs and not playerTechs:HasTech(tech.Index) then
      playerTechs:SetResearchProgress(tech.Index, playerTechs:GetResearchCost(tech.Index))
    end
  end
end

local function GrantCivic(player, civicType)
  local civic = GameInfo.Civics[civicType]
  if civic then
    local playerCulture = player:GetCulture()
    if playerCulture and not playerCulture:HasCivic(civic.Index) then
      playerCulture:SetCulturalProgress(civic.Index, playerCulture:GetCultureCost(civic.Index))
    end
  end
end

local INDUSTRIAL_TECHS = {
  "TECH_INDUSTRIALIZATION",
  "TECH_STEAM_POWER",
  "TECH_ELECTRICITY",
  "TECH_REPLACEABLE_PARTS",
  "TECH_FLIGHT",
  "TECH_REFINING",
  "TECH_COMBUSTION",
  "TECH_CHEMISTRY",
  "TECH_MILITARY_SCIENCE",
  "TECH_BALLISTICS",
  "TECH_RIFLING",
  "TECH_STEEL",
  "TECH_RADIO",
  "TECH_ADVANCED_BALLISTICS",
  "TECH_COMBINED_ARMS",
  "TECH_SYNTHETIC_MATERIALS",
}

local INDUSTRIAL_CIVICS = {
  "CIVIC_INDUSTRIALIZATION",          -- may not exist under this exact name
  "CIVIC_URBANIZATION",
  "CIVIC_NATIONALISM",
  "CIVIC_IDEOLOGY",
  "CIVIC_SUFFRAGE",
  "CIVIC_TOTALITARIANISM",
  "CIVIC_CLASS_STRUGGLE",
  "CIVIC_MOBILIZATION",
  "CIVIC_CONSERVATION",
  "CIVIC_CAPITALISM",
  "CIVIC_NUCLEAR_PROGRAM",
  "CIVIC_COLD_WAR",
}

local function OnNewGameInitialized()
  print("[WW2_Overhaul] Applying 1936-style start grants...")

  for playerID = 0, 63 do
    local player = Players[playerID]
    if player and player:IsMajor() and player:IsAlive() then
      -- Grant techs
      for _, techType in ipairs(INDUSTRIAL_TECHS) do
        GrantTech(player, techType)
      end
      -- Grant civics
      for _, civicType in ipairs(INDUSTRIAL_CIVICS) do
        GrantCivic(player, civicType)
      end
    end
  end

  print("[WW2_Overhaul] 1936-style start grants complete")
end

-- Run once when the game starts
Events.LoadScreenClose.Add(function()
  -- Small delay so the game is fully ready
  OnNewGameInitialized()
end)

print("[WW2_Overhaul] Start logic script loaded")
