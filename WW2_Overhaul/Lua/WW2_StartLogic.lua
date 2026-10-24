-- WW2 Overhaul: grants + controlled starter army
-- Units: 2 Tank, 3 Infantry, 2 Artillery, 2 Settler, coastal Battleship
-- Kill default scouts. +80 GPT economy offset.

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

-- Exact composition requested
local STARTER_ARMY = {
  { unit = "UNIT_TANK",      count = 2 },
  { unit = "UNIT_INFANTRY",  count = 3 },
  { unit = "UNIT_ARTILLERY", count = 2 },
  { unit = "UNIT_SETTLER",   count = 2 },
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

local function AttachEconomy(player)
  pcall(function() player:AttachModifierByID("WW2_START_GOLD_PER_TURN") end)
  pcall(function() player:AttachModifierByID("WW2_CITY_GOLD") end)
end

local function GetAnchorPlot(player)
  local cities = player:GetCities()
  if cities then
    local capital = cities:GetCapitalCity()
    if capital then return Map.GetPlot(capital:GetX(), capital:GetY()), true end
    for _, city in cities:Members() do
      return Map.GetPlot(city:GetX(), city:GetY()), true
    end
  end
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
  if not unitInfo then return nil end
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
  pcall(function()
    local p = Players[playerID]
    if p and p:GetUnits() and p:GetUnits().Create then
      unit = p:GetUnits():Create(unitInfo.Index, x, y)
    end
  end)
  return unit
end

-- Remove default scouts (and any other junk the game gave)
local function KillDefaultJunk(player)
  pcall(function()
    for _, u in player:GetUnits():Members() do
      local info = GameInfo.Units[u:GetType()]
      if info then
        local t = info.UnitType
        if t == "UNIT_SCOUT" or t == "UNIT_SKIRMISHER" or t == "UNIT_WARRIOR"
            or t == "UNIT_SLINGER" or t == "UNIT_BUILDER" then
          if UnitManager and UnitManager.Kill then UnitManager.Kill(u) else u:Kill() end
        end
      end
    end
  end)
end

local function TryFoundCapital(player)
  local cities = player:GetCities()
  if cities and cities:GetCount() > 0 then return true end
  local anchor = GetAnchorPlot(player)
  if not anchor then return false end
  local playerID = player:GetID()
  local plot = FindNearbyLandPlot(anchor:GetX(), anchor:GetY(), 3)
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
  return city ~= nil
end

local function GiveStarterArmy(player)
  if not player or not player:IsAlive() or not player:IsMajor() then return end
  local playerID = player:GetID()
  local anchor = GetAnchorPlot(player)
  if not anchor then return end
  local cx, cy = anchor:GetX(), anchor:GetY()

  KillDefaultJunk(player)

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
        print("[WW2] Coastal navy granted")
      end
    end
  end
  print("[WW2] Starter units spawned: " .. tostring(spawned))
end

local function OnStart()
  if ALREADY_RAN then return end
  ALREADY_RAN = true
  print("[WW2] Start grants + economy + army...")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      for _, t in ipairs(TECHS_EXTRA) do GrantTech(p, t) end
      for _, c in ipairs(CIVICS_EXTRA) do GrantCivic(p, c) end
      AttachEconomy(p)
      TryFoundCapital(p)
      GiveStarterArmy(p)
    end
  end
  print("[WW2] Start complete (+80 GPT, no scouts)")
end

Events.LoadScreenClose.Add(OnStart)

if Events.GameCoreEventPublishComplete then
  local n = 0
  local function secondPass()
    n = n + 1
    if n == 6 then
      for i = 0, 63 do
        local p = Players[i]
        if p and p:IsMajor() and p:IsAlive() then
          AttachEconomy(p)
          local hasTank = false
          for _, u in p:GetUnits():Members() do
            local info = GameInfo.Units[u:GetType()]
            if info and info.UnitType == "UNIT_TANK" then hasTank = true break end
          end
          if not hasTank then GiveStarterArmy(p) end
          -- scouts sometimes reappear; wipe again
          KillDefaultJunk(p)
        end
      end
      Events.GameCoreEventPublishComplete.Remove(secondPass)
    end
  end
  Events.GameCoreEventPublishComplete.Add(secondPass)
end

print("[WW2] Start logic v2.3 — 2T/3I/2A/2S + navy, +80 GPT, no scouts")
