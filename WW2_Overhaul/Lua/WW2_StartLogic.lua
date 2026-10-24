-- WW2 start: techs, +250 GPT, ONE army only (2 tank / 3 inf / 2 art / 2 settler + coastal navy)
-- Scouts/warriors wiped. Does NOT spawn army if tanks already exist.

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
  { unit = "UNIT_INFANTRY",  count = 3 },
  { unit = "UNIT_ARTILLERY", count = 2 },
  { unit = "UNIT_SETTLER",   count = 2 },
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

local function AttachEconomy(player)
  pcall(function() player:AttachModifierByID("WW2_START_GOLD_PER_TURN") end)
  pcall(function() player:AttachModifierByID("WW2_CITY_GOLD") end)
end

local function CountUnitType(player, unitType)
  local n = 0
  for _, u in player:GetUnits():Members() do
    local info = GameInfo.Units[u:GetType()]
    if info and info.UnitType == unitType then n = n + 1 end
  end
  return n
end

local function GetAnchorPlot(player)
  local cities = player:GetCities()
  if cities then
    local capital = cities:GetCapitalCity()
    if capital then return Map.GetPlot(capital:GetX(), capital:GetY()) end
    for _, city in cities:Members() do
      return Map.GetPlot(city:GetX(), city:GetY())
    end
  end
  for _, unit in player:GetUnits():Members() do
    return Map.GetPlot(unit:GetX(), unit:GetY())
  end
  return nil
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
  for r = 1, (radius or 5) do
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
    local p = Players[playerID]
    if p and p:GetUnits() and p:GetUnits().Create then
      unit = p:GetUnits():Create(unitInfo.Index, x, y)
    end
  end)
  return unit
end

local function KillJunk(player)
  pcall(function()
    for _, u in player:GetUnits():Members() do
      local info = GameInfo.Units[u:GetType()]
      if info then
        local t = info.UnitType
        if t == "UNIT_SCOUT" or t == "UNIT_SKIRMISHER" or t == "UNIT_WARRIOR"
            or t == "UNIT_SLINGER" or t == "UNIT_BUILDER" or t == "UNIT_RANGER" then
          if UnitManager and UnitManager.Kill then UnitManager.Kill(u) else u:Kill() end
        end
      end
    end
  end)
end

local function GiveStarterArmy(player)
  if not player or not player:IsAlive() or not player:IsMajor() then return end
  -- Already has tanks from TSL or earlier pass → do not double-spawn
  if CountUnitType(player, "UNIT_TANK") >= 2 then
    print("[WW2] P" .. player:GetID() .. " already has tanks — skip army")
    KillJunk(player)
    return
  end

  local playerID = player:GetID()
  local anchor = GetAnchorPlot(player)
  if not anchor then return end
  local cx, cy = anchor:GetX(), anchor:GetY()
  KillJunk(player)

  for _, entry in ipairs(STARTER_ARMY) do
    local have = CountUnitType(player, entry.unit)
    local need = entry.count - have
    for i = 1, need do
      local plot = FindNearbyLandPlot(cx, cy, 5)
      if plot then SpawnUnit(playerID, entry.unit, plot:GetX(), plot:GetY()) end
    end
  end

  if IsNearCoast(cx, cy) and CountUnitType(player, "UNIT_BATTLESHIP") == 0
      and CountUnitType(player, "UNIT_IRONCLAD") == 0 then
    local water = FindNearbyWaterPlot(cx, cy, 6)
    if water then
      local navy = GameInfo.Units["UNIT_BATTLESHIP"] and "UNIT_BATTLESHIP" or "UNIT_IRONCLAD"
      SpawnUnit(playerID, navy, water:GetX(), water:GetY())
    end
  end
  print("[WW2] Army ensured for P" .. playerID)
end

local function OnStart()
  if ALREADY_RAN then return end
  ALREADY_RAN = true
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      for _, t in ipairs(TECHS_EXTRA) do GrantTech(p, t) end
      for _, c in ipairs(CIVICS_EXTRA) do GrantCivic(p, c) end
      AttachEconomy(p)
      -- army after TSL cities; small delay via second pass
    end
  end
  print("[WW2] Economy + techs applied (+250 GPT)")
end

Events.LoadScreenClose.Add(OnStart)

if Events.GameCoreEventPublishComplete then
  local n = 0
  local function later()
    n = n + 1
    if n == 8 then
      for i = 0, 63 do
        local p = Players[i]
        if p and p:IsMajor() and p:IsAlive() then
          AttachEconomy(p)
          GiveStarterArmy(p)
          KillJunk(p)
        end
      end
      Events.GameCoreEventPublishComplete.Remove(later)
    end
  end
  Events.GameCoreEventPublishComplete.Add(later)
end

print("[WW2] Start v2.4 — +250 GPT, single army, no scout spam")
