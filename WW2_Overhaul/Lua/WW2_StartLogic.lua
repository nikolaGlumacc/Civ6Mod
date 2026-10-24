-- WW2 Overhaul: Industrial / early-Modern start grants + starting army
-- Works even if no cities exist yet (spawns near settler / first unit).

local ALREADY_RAN = false

local TECHS_EXTRA = {
  "TECH_STEAM_POWER", "TECH_SANITATION", "TECH_ECONOMICS", "TECH_RIFLING",
  "TECH_MILITARY_SCIENCE", "TECH_BALLISTICS", "TECH_STEEL", "TECH_REFINING",
  "TECH_ELECTRICITY", "TECH_RADIO", "TECH_REPLACEABLE_PARTS", "TECH_FLIGHT",
  "TECH_CHEMISTRY", "TECH_COMBUSTION",
  "TECH_ADVANCED_BALLISTICS", "TECH_COMBINED_ARMS", "TECH_SYNTHETIC_MATERIALS",
}

local CIVICS_EXTRA = {
  "CIVIC_CIVIL_ENGINEERING", "CIVIC_NATIONALISM", "CIVIC_OPERA_BALLET",
  "CIVIC_NATURAL_HISTORY", "CIVIC_URBANIZATION", "CIVIC_SCORCHED_EARTH",
  "CIVIC_COLONIALISM", "CIVIC_MOBILIZATION", "CIVIC_CONSERVATION",
  "CIVIC_MASS_MEDIA", "CIVIC_IDEOLOGY", "CIVIC_SUFFRAGE",
  "CIVIC_TOTALITARIANISM", "CIVIC_CLASS_STRUGGLE", "CIVIC_CAPITALISM",
}

local STARTER_ARMY = {
  { unit = "UNIT_TANK",      count = 2 },
  { unit = "UNIT_INFANTRY",  count = 4 },
  { unit = "UNIT_ARTILLERY", count = 2 },
}
local COASTAL_NAVY = "UNIT_BATTLESHIP"

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
    if feat and feat.FeatureType == "FEATURE_ICE" then return true end
  end
  return false
end

local function GetAnchorPlot(player)
  local capital = player:GetCities() and player:GetCities():GetCapitalCity()
  if capital then
    return Map.GetPlot(capital:GetX(), capital:GetY()), true
  end
  -- fallback: first unit (settler / warrior / whatever)
  for _, unit in player:GetUnits():Members() do
    return Map.GetPlot(unit:GetX(), unit:GetY()), false
  end
  return nil, false
end

local function FindNearbyLandPlot(cx, cy, radius)
  radius = radius or 4
  for r = 0, radius do
    for dx = -r, r do
      for dy = -r, r do
        if math.abs(dx) == r or math.abs(dy) == r or r == 0 then
          local p = Map.GetPlot(cx + dx, cy + dy)
          if p and not p:IsWater() and not p:IsImpassable() then
            local units = Map.GetUnitsAt(p)
            local occupied = units and units.GetCount and units:GetCount() > 0
            if not occupied then return p end
          end
        end
      end
    end
  end
  return Map.GetPlot(cx, cy)
end

local function FindNearbyWaterPlot(cx, cy, radius)
  radius = radius or 5
  for r = 1, radius do
    for dx = -r, r do
      for dy = -r, r do
        if math.abs(dx) == r or math.abs(dy) == r then
          local p = Map.GetPlot(cx + dx, cy + dy)
          if p and p:IsWater() and not p:IsLake() then
            local units = Map.GetUnitsAt(p)
            local occupied = units and units.GetCount and units:GetCount() > 0
            if not occupied then return p end
          end
        end
      end
    end
  end
  return nil
end

local function IsNearCoast(cx, cy)
  for dx = -2, 2 do
    for dy = -2, 2 do
      local p = Map.GetPlot(cx + dx, cy + dy)
      if p and p:IsWater() and not p:IsLake() then return true end
    end
  end
  return false
end

local function SpawnUnit(playerID, unitType, x, y)
  local unitInfo = GameInfo.Units[unitType]
  if not unitInfo then
    print("[WW2] Unknown unit: " .. tostring(unitType))
    return nil
  end
  local unit = nil
  pcall(function()
    if UnitManager and UnitManager.InitUnit then
      unit = UnitManager.InitUnit(playerID, unitInfo.Index, x, y)
    end
  end)
  if unit then return unit end
  pcall(function()
    if UnitManager and UnitManager.InitUnitValidAdjacentHex then
      unit = UnitManager.InitUnitValidAdjacentHex(playerID, unitInfo.Index, x, y)
    end
  end)
  if unit then return unit end
  -- last resort via player units create
  pcall(function()
    local p = Players[playerID]
    if p and p:GetUnits() and p:GetUnits().Create then
      unit = p:GetUnits():Create(unitInfo.Index, x, y)
    end
  end)
  return unit
end

local function TryFoundCapital(player)
  local anchor, hasCity = GetAnchorPlot(player)
  if hasCity or not anchor then return hasCity end
  local playerID = player:GetID()
  local x, y = anchor:GetX(), anchor:GetY()
  local plot = FindNearbyLandPlot(x, y, 2)
  if not plot then return false end
  local city = nil
  pcall(function()
    if CityManager and CityManager.CreateCity then
      city = CityManager.CreateCity(playerID, plot:GetX(), plot:GetY())
    end
  end)
  if not city then
    pcall(function()
      if WorldBuilder and WorldBuilder.CityManager then
        city = WorldBuilder.CityManager():CreateCity(playerID, plot:GetX(), plot:GetY())
      end
    end)
  end
  if city then
    print("[WW2] Founded emergency capital for P" .. playerID .. " at " .. plot:GetX() .. "," .. plot:GetY())
    -- kill settlers so they don't found extra cities
    pcall(function()
      for _, u in player:GetUnits():Members() do
        local info = GameInfo.Units[u:GetType()]
        if info and info.UnitType == "UNIT_SETTLER" then
          if UnitManager and UnitManager.Kill then UnitManager.Kill(u) else u:Kill() end
        end
      end
    end)
    return true
  end
  return false
end

local function GiveStarterArmy(player)
  if not player or not player:IsAlive() or not player:IsMajor() then return end
  local playerID = player:GetID()
  local anchor = GetAnchorPlot(player)
  if not anchor then
    print("[WW2] No anchor plot for P" .. playerID .. " — cannot spawn army")
    return
  end
  local cx, cy = anchor:GetX(), anchor:GetY()
  print("[WW2] Spawning starter army for P" .. playerID .. " near " .. cx .. "," .. cy)

  local spawned = 0
  for _, entry in ipairs(STARTER_ARMY) do
    for i = 1, entry.count do
      local plot = FindNearbyLandPlot(cx, cy, 5)
      if plot and SpawnUnit(playerID, entry.unit, plot:GetX(), plot:GetY()) then
        spawned = spawned + 1
      end
    end
  end

  if IsNearCoast(cx, cy) then
    local water = FindNearbyWaterPlot(cx, cy, 6)
    if water then
      local navy = COASTAL_NAVY
      if not GameInfo.Units[navy] then navy = "UNIT_IRONCLAD" end
      if SpawnUnit(playerID, navy, water:GetX(), water:GetY()) then
        spawned = spawned + 1
        print("[WW2] Coastal — granted " .. navy)
      end
    end
  end
  print("[WW2] Starter army spawned units: " .. tostring(spawned))
end

local function OnStart()
  if ALREADY_RAN then return end
  ALREADY_RAN = true

  print("[WW2] Applying Industrial+ grants + starter armies...")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      for _, t in ipairs(TECHS_EXTRA) do GrantTech(p, t) end
      for _, c in ipairs(CIVICS_EXTRA) do GrantCivic(p, c) end
      TryFoundCapital(p)
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

  print("[WW2] Start logic complete.")
end

-- Run after load screen, and also a bit later in case cities appear from TSL script
Events.LoadScreenClose.Add(OnStart)

-- Second pass a few turns of events later so TSL cities exist first
if Events.GameCoreEventPublishComplete then
  local n = 0
  local function secondPass()
    n = n + 1
    if n == 5 then
      for i = 0, 63 do
        local p = Players[i]
        if p and p:IsMajor() and p:IsAlive() then
          local cities = p:GetCities()
          if cities and cities:GetCount() > 0 then
            -- re-check army if somehow missing
            local hasTank = false
            for _, u in p:GetUnits():Members() do
              local info = GameInfo.Units[u:GetType()]
              if info and info.UnitType == "UNIT_TANK" then hasTank = true break end
            end
            if not hasTank then
              print("[WW2] Second-pass army for P" .. i)
              GiveStarterArmy(p)
            end
          end
        end
      end
      Events.GameCoreEventPublishComplete.Remove(secondPass)
    end
  end
  Events.GameCoreEventPublishComplete.Add(secondPass)
end

print("[WW2] Start logic v2.1 loaded (robust army + capital)")
