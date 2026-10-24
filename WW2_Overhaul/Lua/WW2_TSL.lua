-- WW2 Overhaul: Hard TSL for self-contained Europe map (100x64)
-- Places every major European civ on the correct region and founds cities.
-- CRITICAL: never kill settlers unless at least one city was successfully founded.

local RAN = false

local TERRITORIES = {
  TERRITORY_BRITAIN     = {{0.22,0.62},{0.20,0.58},{0.24,0.66}},
  TERRITORY_SCOTLAND    = {{0.20,0.70},{0.18,0.68}},
  TERRITORY_FRANCE      = {{0.28,0.50},{0.26,0.46},{0.30,0.52},{0.32,0.48}},
  TERRITORY_GERMANY     = {{0.40,0.56},{0.38,0.52},{0.42,0.58},{0.36,0.54}},
  TERRITORY_NETHERLANDS = {{0.32,0.60},{0.30,0.58}},
  TERRITORY_POLAND      = {{0.50,0.56},{0.48,0.52},{0.52,0.58}},
  TERRITORY_HUNGARY     = {{0.48,0.46},{0.46,0.44}},
  TERRITORY_ITALY       = {{0.40,0.38},{0.38,0.42},{0.42,0.32},{0.42,0.26}},
  TERRITORY_SPAIN       = {{0.18,0.38},{0.16,0.34},{0.22,0.40},{0.14,0.36}},
  TERRITORY_PORTUGAL    = {{0.12,0.34},{0.12,0.30}},
  TERRITORY_SERBIA      = {{0.50,0.40},{0.48,0.38},{0.52,0.42},{0.50,0.36}},
  TERRITORY_GREECE      = {{0.54,0.28},{0.52,0.26},{0.56,0.30}},
  TERRITORY_RUSSIA      = {{0.70,0.60},{0.66,0.56},{0.74,0.62},{0.68,0.52}},
  TERRITORY_NORWAY      = {{0.40,0.80},{0.38,0.76}},
  TERRITORY_SWEDEN      = {{0.48,0.80},{0.50,0.76}},
  TERRITORY_TURKEY      = {{0.64,0.36},{0.62,0.34},{0.66,0.38}},
  TERRITORY_GEORGIA     = {{0.78,0.42},{0.76,0.40}},
  TERRITORY_EGYPT       = {{0.62,0.12},{0.60,0.10},{0.64,0.14}},
}

-- Macedonia (Alexander) in WW2 context = Yugoslavia / Serbia region, not ancient Greece
local CIV_TO_TERR = {
  CIVILIZATION_GERMANY      = "TERRITORY_GERMANY",
  CIVILIZATION_ENGLAND      = "TERRITORY_BRITAIN",
  CIVILIZATION_SCOTLAND     = "TERRITORY_SCOTLAND",
  CIVILIZATION_FRANCE       = "TERRITORY_FRANCE",
  CIVILIZATION_GAUL         = "TERRITORY_FRANCE",
  CIVILIZATION_ROME         = "TERRITORY_ITALY",
  CIVILIZATION_SPAIN        = "TERRITORY_SPAIN",
  CIVILIZATION_PORTUGAL     = "TERRITORY_PORTUGAL",
  CIVILIZATION_RUSSIA       = "TERRITORY_RUSSIA",
  CIVILIZATION_SCYTHIA      = "TERRITORY_RUSSIA",
  CIVILIZATION_POLAND       = "TERRITORY_POLAND",
  CIVILIZATION_HUNGARY      = "TERRITORY_HUNGARY",
  CIVILIZATION_SERBIA       = "TERRITORY_SERBIA",
  CIVILIZATION_STR_SERBIA   = "TERRITORY_SERBIA",
  CIVILIZATION_WW2_YUGOSLAVIA = "TERRITORY_SERBIA",
  CIVILIZATION_MACEDON      = "TERRITORY_SERBIA",  -- WW2: part of Yugoslavia
  CIVILIZATION_GREECE       = "TERRITORY_GREECE",
  CIVILIZATION_BYZANTIUM    = "TERRITORY_TURKEY",
  CIVILIZATION_OTTOMAN      = "TERRITORY_TURKEY",
  CIVILIZATION_NETHERLANDS  = "TERRITORY_NETHERLANDS",
  CIVILIZATION_NORWAY       = "TERRITORY_NORWAY",
  CIVILIZATION_SWEDEN       = "TERRITORY_SWEDEN",
  CIVILIZATION_GEORGIA      = "TERRITORY_GEORGIA",
  CIVILIZATION_EGYPT        = "TERRITORY_EGYPT",
  CIVILIZATION_NUBIA        = "TERRITORY_EGYPT",
}

local claimed = {}

local function GridXY(rx, ry)
  local w, h = Map.GetGridSize()
  local x = math.floor(rx * (w - 1) + 0.5)
  local y = math.floor(ry * (h - 1) + 0.5)
  return math.max(0, math.min(w - 1, x)), math.max(0, math.min(h - 1, y))
end

local function IsGood(plot)
  if not plot or plot:IsWater() or plot:IsImpassable() then return false end
  if plot:IsCity() then return false end
  local t = GameInfo.Terrains[plot:GetTerrainType()]
  if t and (string.find(t.TerrainType, "SNOW") or string.find(t.TerrainType, "MOUNTAIN")) then
    return false
  end
  return true
end

local function FindNear(tx, ty, radius)
  radius = radius or 18
  local best, bestD = nil, 99999
  local w, h = Map.GetGridSize()
  for r = 0, radius do
    for dy = -r, r do
      for dx = -r, r do
        local x, y = tx + dx, ty + dy
        if x >= 0 and y >= 0 and x < w and y < h then
          local p = Map.GetPlot(x, y)
          if IsGood(p) then
            local d = dx * dx + dy * dy
            if d < bestD then bestD = d; best = p end
          end
        end
      end
    end
    if best then return best end
  end
  return nil
end

local function TryCreateCity(playerID, x, y)
  local city = nil
  pcall(function()
    if CityManager and CityManager.CreateCity then
      city = CityManager.CreateCity(playerID, x, y)
    end
  end)
  if city then return city end
  pcall(function()
    if WorldBuilder and WorldBuilder.CityManager then
      city = WorldBuilder.CityManager():CreateCity(playerID, x, y)
    end
  end)
  return city
end

local function MoveUnits(player, plot)
  if not player or not plot then return end
  for _, u in player:GetUnits():Members() do
    pcall(function() u:SetXY(plot:GetX(), plot:GetY()) end)
  end
end

local function KillSettlers(player)
  pcall(function()
    for _, u in player:GetUnits():Members() do
      local info = GameInfo.Units[u:GetType()]
      if info and info.UnitType == "UNIT_SETTLER" then
        if UnitManager and UnitManager.Kill then UnitManager.Kill(u) else u:Kill() end
      end
    end
  end)
end

local function SpawnNear(playerID, unitType, x, y)
  local info = GameInfo.Units[unitType]
  if not info then return end
  pcall(function()
    if UnitManager and UnitManager.InitUnit then
      UnitManager.InitUnit(playerID, info.Index, x, y)
    elseif Players[playerID] and Players[playerID]:GetUnits() then
      Players[playerID]:GetUnits():Create(info.Index, x, y)
    end
  end)
end

local function PlayerHasCity(player)
  local cities = player:GetCities()
  return cities and cities:GetCount() > 0
end

local function BuildTerritory(player, terrKey)
  local sites = TERRITORIES[terrKey]
  if not sites then return end
  local founded, capitalPlot = 0, nil
  local pid = player:GetID()

  for _, pair in ipairs(sites) do
    local tx, ty = GridXY(pair[1], pair[2])
    local plot = FindNear(tx, ty, 16)
    if plot then
      local city = TryCreateCity(pid, plot:GetX(), plot:GetY())
      if city then
        founded = founded + 1
        if not capitalPlot then capitalPlot = plot end
      elseif not capitalPlot then
        capitalPlot = plot
      end
    end
  end

  -- Fallback: if no city founded, try one more time on the best plot
  if founded == 0 and capitalPlot then
    local city = TryCreateCity(pid, capitalPlot:GetX(), capitalPlot:GetY())
    if city then founded = 1 end
  end

  if capitalPlot then
    MoveUnits(player, capitalPlot)
  end

  -- ONLY kill settlers if we actually have a city. Otherwise player is eliminated = instant defeat.
  if founded > 0 or PlayerHasCity(player) then
    KillSettlers(player)
    if capitalPlot then
      local x, y = capitalPlot:GetX(), capitalPlot:GetY()
      SpawnNear(pid, "UNIT_TANK", x, y)
      SpawnNear(pid, "UNIT_INFANTRY", x, y)
      SpawnNear(pid, "UNIT_INFANTRY", x, y)
    end
  else
    print(string.format("[WW2 Terr] WARNING P%d %s — 0 cities founded, KEEPING settlers", pid, terrKey))
  end

  print(string.format("[WW2 Terr] %s → P%d (%d cities)", terrKey, pid, founded))
end

local function CivOf(p)
  local cfg = PlayerConfigurations[p:GetID()]
  return cfg and cfg:GetCivilizationTypeName()
end

local function PreferredTerritory(player)
  if player:IsHuman() then
    local sel
    pcall(function() sel = GameConfiguration.GetValue("WW2_TERRITORY") end)
    if sel and sel ~= "TERRITORY_AUTO" and TERRITORIES[sel] then return sel end
  end
  local civ = CivOf(player)
  if civ and CIV_TO_TERR[civ] then return CIV_TO_TERR[civ] end
  return nil
end

function WW2_RevealAllFog()
  for pid = 0, 63 do
    local vis = PlayersVisibility[pid]
    if vis then
      for i = 0, Map.GetPlotCount() - 1 do
        pcall(function() vis:ChangeVisibilityCount(i, 1) end)
      end
    end
  end
end

function WW2_ApplyAllTSL()
  claimed = {}
  print("[WW2 Terr] Assigning European territories...")
  local order = {}
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then table.insert(order, p) end
  end
  table.sort(order, function(a, b)
    local ah, bh = a:IsHuman() and 0 or 1, b:IsHuman() and 0 or 1
    if ah ~= bh then return ah < bh end
    return a:GetID() < b:GetID()
  end)

  for _, p in ipairs(order) do
    local terr = PreferredTerritory(p)
    local civ = CivOf(p) or "?"
    if not terr then
      print(string.format("[WW2 Terr] P%d %s — no mapping (keeping default start)", p:GetID(), civ))
    elseif claimed[terr] then
      print(string.format("[WW2 Terr] P%d %s wanted %s (taken) — move only, keep settlers", p:GetID(), civ, terr))
      local sites = TERRITORIES[terr]
      if sites and sites[1] then
        local tx, ty = GridXY(sites[1][1], sites[1][2])
        local plot = FindNear(tx, ty, 18)
        if plot then MoveUnits(p, plot) end
      end
      -- do NOT kill settlers when territory was taken
    else
      claimed[terr] = p:GetID()
      print(string.format("[WW2 Terr] P%d %s → %s", p:GetID(), civ, terr))
      BuildTerritory(p, terr)
    end
  end
  WW2_RevealAllFog()
  print("[WW2 Terr] Done")
end

local function OnLoad()
  if RAN then return end
  RAN = true
  if Events.GameCoreEventPublishComplete then
    local n = 0
    local function once()
      n = n + 1
      if n >= 3 then
        WW2_ApplyAllTSL()
        Events.GameCoreEventPublishComplete.Remove(once)
      end
    end
    Events.GameCoreEventPublishComplete.Add(once)
  else
    WW2_ApplyAllTSL()
  end
end

Events.LoadScreenClose.Add(OnLoad)
print("[WW2 Terr] loaded — safe TSL (no settler wipe without city)")
