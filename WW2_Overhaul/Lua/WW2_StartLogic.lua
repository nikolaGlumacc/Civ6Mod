-- WW2 Overhaul: Industrial / early-Modern start grants
-- Designed for RULESET_WW2 with GAME_START_ERA = ERA_INDUSTRIAL
-- Grants remaining late Industrial / early Modern techs quietly and
-- tries to move a capital off pure ice/snow (Antarctica-style starts).

local ALREADY_RAN = false

-- Only the techs the Industrial era start does NOT already imply.
-- (Starting in Industrial already unlocks a large early tree; we fill WW2 gaps.)
local TECHS_EXTRA = {
  "TECH_STEAM_POWER", "TECH_SANITATION", "TECH_ECONOMICS", "TECH_RIFLING",
  "TECH_MILITARY_SCIENCE", "TECH_BALLISTICS", "TECH_STEEL", "TECH_REFINING",
  "TECH_ELECTRICITY", "TECH_RADIO", "TECH_REPLACEABLE_PARTS", "TECH_FLIGHT",
  "TECH_CHEMISTRY", "TECH_COMBUSTION",
  "TECH_ADVANCED_BALLISTICS", "TECH_COMBINED_ARMS", "TECH_SYNTHETIC_MATERIALS",
  -- Nuclear intentionally omitted
}

local CIVICS_EXTRA = {
  "CIVIC_CIVIL_ENGINEERING", "CIVIC_NATIONALISM", "CIVIC_OPERA_BALLET",
  "CIVIC_NATURAL_HISTORY", "CIVIC_URBANIZATION", "CIVIC_SCORCHED_EARTH",
  "CIVIC_COLONIALISM", "CIVIC_MOBILIZATION", "CIVIC_CONSERVATION",
  "CIVIC_MASS_MEDIA", "CIVIC_IDEOLOGY", "CIVIC_SUFFRAGE",
  "CIVIC_TOTALITARIANISM", "CIVIC_CLASS_STRUGGLE", "CIVIC_CAPITALISM",
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

-- Clear unlock spam after mass grants (best-effort; API varies by version)
local function ClearUnlockSpam()
  if NotificationManager == nil then return end
  pcall(function()
    if NotificationManager.DismissAllNotifications then
      NotificationManager.DismissAllNotifications()
    end
  end)
  -- Dismiss common tech/civic notification types if available
  pcall(function()
    local iLocal = Game.GetLocalPlayer()
    if iLocal == nil or iLocal < 0 then return end
    if NotificationManager.GetList then
      local list = NotificationManager.GetList(iLocal)
      if list then
        for _, id in ipairs(list) do
          NotificationManager.Dismiss(iLocal, id)
        end
      end
    end
  end)
end

local function PlotIsBadStart(plot)
  if plot == nil then return true end
  if plot:IsWater() or plot:IsImpassable() then return true end
  local t = plot:GetTerrainType()
  local terrain = GameInfo.Terrains[t]
  if terrain == nil then return false end
  local n = terrain.TerrainType
  if n == "TERRAIN_SNOW" or n == "TERRAIN_SNOW_HILLS"
      or n == "TERRAIN_TUNDRA" or n == "TERRAIN_TUNDRA_HILLS" then
    return true
  end
  -- Ice feature
  local f = plot:GetFeatureType()
  if f ~= -1 then
    local feat = GameInfo.Features[f]
    if feat and feat.FeatureType == "FEATURE_ICE" then
      return true
    end
  end
  return false
end

-- Find a passable non-polar land plot and move capital settler / city center units there.
-- This is a safety net when Continents still dumps someone on Antarctic fringe.
local function TryRescueBadStart(player)
  if player == nil or not player:IsAlive() then return end
  local playerID = player:GetID()
  local capital = player:GetCities():GetCapitalCity()
  local startPlot = nil
  if capital then
    startPlot = Map.GetPlot(capital:GetX(), capital:GetY())
  else
    -- Find first unit
    local units = player:GetUnits()
    if units then
      for i = 0, units:GetCount() - 1 do
        local u = units:FindID(i)
        if u == nil then
          -- iterate differently
        end
      end
    end
    for i, unit in player:GetUnits():Members() do
      startPlot = Map.GetPlot(unit:GetX(), unit:GetY())
      break
    end
  end
  if startPlot == nil or not PlotIsBadStart(startPlot) then
    return
  end

  print("[WW2] Bad polar start detected for player " .. tostring(playerID) .. " — searching for better land...")
  local best = nil
  local bestScore = -99999
  local w, h = Map.GetGridSize()
  -- Prefer mid-latitudes (rough "Europe belt" on many Continents rolls)
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local p = Map.GetPlot(x, y)
      if p and not PlotIsBadStart(p) and not p:IsCity() then
        local score = 0
        -- Prefer grass/plains
        local terrain = GameInfo.Terrains[p:GetTerrainType()]
        if terrain then
          local tn = terrain.TerrainType
          if tn == "TERRAIN_GRASS" or tn == "TERRAIN_GRASS_HILLS" then score = score + 30 end
          if tn == "TERRAIN_PLAINS" or tn == "TERRAIN_PLAINS_HILLS" then score = score + 25 end
          if string.find(tn, "HILLS") then score = score + 5 end
        end
        -- Mild preference for northern hemisphere mid-map (often more "Europe-like" land clusters)
        local latBias = 1.0 - math.abs((y / math.max(h - 1, 1)) - 0.35)
        score = score + latBias * 20
        -- Avoid occupied starts
        local unitsHere = Map.GetUnitsAt(p)
        if unitsHere and unitsHere.GetCount and unitsHere:GetCount() > 0 then
          score = score - 50
        end
        if score > bestScore then
          bestScore = score
          best = p
        end
      end
    end
  end

  if best == nil then
    print("[WW2] No better start plot found.")
    return
  end

  -- Move all player units to the rescue plot / adjacent
  for _, unit in player:GetUnits():Members() do
    unit:SetXY(best:GetX(), best:GetY())
  end
  print("[WW2] Relocated player " .. tostring(playerID) .. " to " .. best:GetX() .. "," .. best:GetY())
end

local function OnStart()
  if ALREADY_RAN then return end
  ALREADY_RAN = true

  print("[WW2] Applying Industrial+ grants and start rescue...")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      for _, t in ipairs(TECHS_EXTRA) do GrantTech(p, t) end
      for _, c in ipairs(CIVICS_EXTRA) do GrantCivic(p, c) end
      TryRescueBadStart(p)
    end
  end

  -- Defer notification clear so UI has finished stacking unlock toasts
  if Events.GameCoreEventPublishComplete then
    local fires = 0
    local function clearOnce()
      fires = fires + 1
      if fires >= 3 then
        ClearUnlockSpam()
        Events.GameCoreEventPublishComplete.Remove(clearOnce)
      end
    end
    Events.GameCoreEventPublishComplete.Add(clearOnce)
  else
    ClearUnlockSpam()
  end

  print("[WW2] Start logic complete (Industrial base + WW2 extras; nuclear still locked).")
end

Events.LoadScreenClose.Add(OnStart)
print("[WW2] Start logic v1.5 loaded (Industrial ruleset + quiet grants + polar rescue)")
