-- WW2 Overhaul: Industrial / early-Modern start grants + starting army
-- Designed for RULESET_WW2 with GAME_START_ERA = ERA_INDUSTRIAL
-- Grants remaining late Industrial / early Modern techs quietly,
-- tries to move a capital off pure ice/snow, and spawns a WW2 starter army.

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

-- Starter army composition (WW2 flavor)
local STARTER_ARMY = {
  { unit = "UNIT_TANK",      count = 2 },
  { unit = "UNIT_INFANTRY",  count = 4 },
  { unit = "UNIT_ARTILLERY", count = 2 },
}
local COASTAL_NAVY = "UNIT_BATTLESHIP"  -- fallback to Ironclad if needed

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
  local f = plot:GetFeatureType()
  if f ~= -1 then
    local feat = GameInfo.Features[f]
    if feat and feat.FeatureType == "FEATURE_ICE" then
      return true
    end
  end
  return false
end

local function TryRescueBadStart(player)
  if player == nil or not player:IsAlive() then return end
  local playerID = player:GetID()
  local capital = player:GetCities():GetCapitalCity()
  local startPlot = nil
  if capital then
    startPlot = Map.GetPlot(capital:GetX(), capital:GetY())
  else
    for _, unit in player:GetUnits():Members() do
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
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local p = Map.GetPlot(x, y)
      if p and not PlotIsBadStart(p) and not p:IsCity() then
        local score = 0
        local terrain = GameInfo.Terrains[p:GetTerrainType()]
        if terrain then
          local tn = terrain.TerrainType
          if tn == "TERRAIN_GRASS" or tn == "TERRAIN_GRASS_HILLS" then score = score + 30 end
          if tn == "TERRAIN_PLAINS" or tn == "TERRAIN_PLAINS_HILLS" then score = score + 25 end
          if string.find(tn, "HILLS") then score = score + 5 end
        end
        local latBias = 1.0 - math.abs((y / math.max(h - 1, 1)) - 0.35)
        score = score + latBias * 20
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

  for _, unit in player:GetUnits():Members() do
    unit:SetXY(best:GetX(), best:GetY())
  end
  print("[WW2] Relocated player " .. tostring(playerID) .. " to " .. best:GetX() .. "," .. best:GetY())
end

-- Find a free land plot near (x,y) for unit placement
local function FindNearbyLandPlot(cx, cy, radius)
  radius = radius or 3
  for r = 0, radius do
    for dx = -r, r do
      for dy = -r, r do
        if math.abs(dx) == r or math.abs(dy) == r or r == 0 then
          local p = Map.GetPlot(cx + dx, cy + dy)
          if p and not p:IsWater() and not p:IsImpassable() and not p:IsCity() then
            local units = Map.GetUnitsAt(p)
            local occupied = units and units.GetCount and units:GetCount() > 0
            if not occupied then
              return p
            end
          end
        end
      end
    end
  end
  -- last resort: the city plot itself
  return Map.GetPlot(cx, cy)
end

local function FindNearbyWaterPlot(cx, cy, radius)
  radius = radius or 4
  for r = 1, radius do
    for dx = -r, r do
      for dy = -r, r do
        if math.abs(dx) == r or math.abs(dy) == r then
          local p = Map.GetPlot(cx + dx, cy + dy)
          if p and p:IsWater() and not p:IsLake() then
            local units = Map.GetUnitsAt(p)
            local occupied = units and units.GetCount and units:GetCount() > 0
            if not occupied then
              return p
            end
          end
        end
      end
    end
  end
  return nil
end

local function IsCoastalCity(city)
  if not city then return false end
  local cx, cy = city:GetX(), city:GetY()
  for dx = -1, 1 do
    for dy = -1, 1 do
      if not (dx == 0 and dy == 0) then
        local p = Map.GetPlot(cx + dx, cy + dy)
        if p and p:IsWater() and not p:IsLake() then
          return true
        end
      end
    end
  end
  return false
end

local function SpawnUnit(playerID, unitType, x, y)
  local unitInfo = GameInfo.Units[unitType]
  if not unitInfo then
    print("[WW2] Unknown unit type: " .. tostring(unitType))
    return nil
  end
  local ok, unit = pcall(function()
    return UnitManager.InitUnit(playerID, unitInfo.Index, x, y)
  end)
  if ok and unit then
    return unit
  end
  -- alternate API
  ok, unit = pcall(function()
    return UnitManager.InitUnitValidAdjacentHex(playerID, unitInfo.Index, x, y)
  end)
  if ok and unit then return unit end
  print("[WW2] Failed to spawn " .. unitType .. " at " .. x .. "," .. y)
  return nil
end

local function GiveStarterArmy(player)
  if player == nil or not player:IsAlive() or not player:IsMajor() then return end
  local playerID = player:GetID()
  local capital = player:GetCities():GetCapitalCity()
  if not capital then
    print("[WW2] No capital yet for player " .. playerID .. " — skipping starter army")
    return
  end

  local cx, cy = capital:GetX(), capital:GetY()
  print("[WW2] Spawning starter army for player " .. playerID .. " near " .. cx .. "," .. cy)

  for _, entry in ipairs(STARTER_ARMY) do
    for i = 1, entry.count do
      local plot = FindNearbyLandPlot(cx, cy, 4)
      if plot then
        SpawnUnit(playerID, entry.unit, plot:GetX(), plot:GetY())
      end
    end
  end

  -- Coastal capital → free battleship (or ironclad fallback)
  if IsCoastalCity(capital) then
    local water = FindNearbyWaterPlot(cx, cy, 5)
    if water then
      local navy = COASTAL_NAVY
      if not GameInfo.Units[navy] then
        navy = "UNIT_IRONCLAD"
      end
      SpawnUnit(playerID, navy, water:GetX(), water:GetY())
      print("[WW2] Coastal capital — granted " .. navy)
    else
      print("[WW2] Coastal capital but no free water plot found for navy")
    end
  end
end

local function OnStart()
  if ALREADY_RAN then return end
  ALREADY_RAN = true

  print("[WW2] Applying Industrial+ grants, start rescue, and starter armies...")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      for _, t in ipairs(TECHS_EXTRA) do GrantTech(p, t) end
      for _, c in ipairs(CIVICS_EXTRA) do GrantCivic(p, c) end
      TryRescueBadStart(p)
      GiveStarterArmy(p)
    end
  end

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

  print("[WW2] Start logic complete (Industrial base + WW2 extras + starter army; nuclear still locked).")
end

Events.LoadScreenClose.Add(OnStart)
print("[WW2] Start logic v2.0 loaded (Industrial ruleset + quiet grants + polar rescue + starter army)")
