-- Predefined WW2 nations: capital + secondary cities for every theatre civ.
-- Full map revealed (no fog). Runs after LoadScreenClose.

local RAN = false

-- Relative positions on Europe map (0..1). Capital first, then extra cities.
local NATIONS = {
  CIVILIZATION_ENGLAND = {
    {0.22, 0.64}, -- London
    {0.20, 0.60}, -- Portsmouth / south
    {0.24, 0.70}, -- York / north
    {0.18, 0.66}, -- Wales / west
  },
  CIVILIZATION_SCOTLAND = {
    {0.20, 0.74},
    {0.18, 0.70},
  },
  CIVILIZATION_FRANCE = {
    {0.30, 0.50}, -- Paris
    {0.28, 0.44}, -- Lyon
    {0.26, 0.52}, -- Normandy
    {0.34, 0.46}, -- east
    {0.32, 0.40}, -- Marseille area
  },
  CIVILIZATION_SPAIN = {
    {0.17, 0.36}, -- Madrid
    {0.14, 0.32}, -- Seville
    {0.20, 0.38}, -- Barcelona belt
    {0.12, 0.36}, -- west
  },
  CIVILIZATION_PORTUGAL = {
    {0.11, 0.34},
    {0.11, 0.30},
  },
  CIVILIZATION_GERMANY = {
    {0.42, 0.58}, -- Berlin
    {0.40, 0.52}, -- Munich / south
    {0.38, 0.58}, -- Ruhr / west
    {0.46, 0.56}, -- east
    {0.42, 0.62}, -- Hamburg / north
  },
  CIVILIZATION_POLAND = {
    {0.52, 0.60}, -- Warsaw
    {0.50, 0.56}, -- Krakow
    {0.54, 0.62}, -- north
  },
  CIVILIZATION_HUNGARY = {
    {0.50, 0.50}, -- Budapest
    {0.48, 0.48},
  },
  CIVILIZATION_RUSSIA = {
    {0.72, 0.66}, -- Moscow
    {0.68, 0.62}, -- southwest
    {0.76, 0.70}, -- north/east
    {0.70, 0.58}, -- Ukraine belt
    {0.78, 0.64},
  },
  CIVILIZATION_ROME = { -- Italy / Trajan
    {0.42, 0.34}, -- Rome
    {0.40, 0.38}, -- Milan / north
    {0.44, 0.28}, -- Naples
    {0.44, 0.18}, -- Sicily
  },
  CIVILIZATION_SERBIA = {
    {0.50, 0.42}, -- Belgrade
    {0.48, 0.40}, -- west
    {0.52, 0.40}, -- Nis
    {0.50, 0.44}, -- Novi Sad
  },
  CIVILIZATION_STR_SERBIA = {
    {0.50, 0.42}, {0.48, 0.40}, {0.52, 0.40},
  },
  CIVILIZATION_WW2_YUGOSLAVIA = {
    {0.50, 0.42}, {0.48, 0.44}, {0.52, 0.38}, {0.46, 0.42},
  },
  CIVILIZATION_GREECE = {
    {0.54, 0.26}, -- Athens
    {0.52, 0.28},
    {0.56, 0.24},
  },
  CIVILIZATION_MACEDON = {
    {0.53, 0.32}, -- Skopje / north Greece — NOT Spain
    {0.51, 0.34},
  },
  CIVILIZATION_NORWAY = {
    {0.38, 0.80},
    {0.36, 0.76},
  },
  CIVILIZATION_SWEDEN = {
    {0.46, 0.80},
    {0.48, 0.76},
  },
  CIVILIZATION_NETHERLANDS = {
    {0.34, 0.60},
    {0.34, 0.58},
  },
  CIVILIZATION_GEORGIA = {
    {0.78, 0.44},
    {0.76, 0.42},
  },
  CIVILIZATION_BYZANTIUM = {
    {0.60, 0.34}, -- Constantinople
    {0.58, 0.32},
  },
  CIVILIZATION_OTTOMAN = {
    {0.62, 0.36},
    {0.64, 0.34},
  },
  CIVILIZATION_GAUL = {
    {0.32, 0.52},
    {0.30, 0.48},
  },
  CIVILIZATION_SCYTHIA = {
    {0.70, 0.54},
    {0.72, 0.52},
  },
  CIVILIZATION_PHOENICIA = {
    {0.26, 0.10}, -- Carthage / Tunis
    {0.24, 0.10},
  },
  CIVILIZATION_EGYPT = {
    {0.60, 0.10}, -- Nile delta
    {0.58, 0.08},
    {0.62, 0.08},
  },
  CIVILIZATION_ETHIOPIA = {
    {0.64, 0.07},
    {0.62, 0.06},
  },
  CIVILIZATION_NUBIA = {
    {0.58, 0.08},
    {0.56, 0.07},
  },
  CIVILIZATION_MALI = {
    {0.18, 0.08},
    {0.20, 0.08},
  },
}

local function GridXY(rx, ry)
  local w, h = Map.GetGridSize()
  local x = math.floor(rx * (w - 1) + 0.5)
  local y = math.floor(ry * (h - 1) + 0.5)
  x = math.max(0, math.min(w - 1, x))
  y = math.max(0, math.min(h - 1, y))
  return x, y
end

local function IsGood(plot)
  if not plot or plot:IsWater() or plot:IsImpassable() then return false end
  if plot:IsCity() then return false end
  local t = GameInfo.Terrains[plot:GetTerrainType()]
  if t then
    local n = t.TerrainType
    if string.find(n, "SNOW") or n == "TERRAIN_TUNDRA" or n == "TERRAIN_TUNDRA_HILLS" then
      return false
    end
  end
  return true
end

local function FindNear(tx, ty, radius)
  radius = radius or 12
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
        if UnitManager and UnitManager.Kill then UnitManager.Kill(u)
        else u:Kill() end
      end
    end
  end)
end

local function BuildNation(player, civ)
  local sites = NATIONS[civ]
  if not sites then
    print("[WW2 Nation] No predefined country for " .. tostring(civ))
    return
  end

  local founded = 0
  local capitalPlot = nil

  for idx, pair in ipairs(sites) do
    local tx, ty = GridXY(pair[1], pair[2])
    local plot = FindNear(tx, ty, 10)
    if plot then
      local city = TryCreateCity(player:GetID(), plot:GetX(), plot:GetY())
      if city then
        founded = founded + 1
        if not capitalPlot then capitalPlot = plot end
        print(string.format("[WW2 Nation] %s city#%d at %d,%d", civ, founded, plot:GetX(), plot:GetY()))
      elseif not capitalPlot then
        capitalPlot = plot
      end
    end
  end

  if capitalPlot then
    MoveUnits(player, capitalPlot)
  end

  if founded > 0 then
    KillSettlers(player)
    -- Small starting army for HOI feel
    pcall(function()
      local tank = GameInfo.Units["UNIT_TANK"]
      local inf = GameInfo.Units["UNIT_INFANTRY"]
      local x, y = capitalPlot:GetX(), capitalPlot:GetY()
      if tank then player:GetUnits():Create(tank.Index, x, y) end
      if inf then player:GetUnits():Create(inf.Index, x, y) end
      if inf then player:GetUnits():Create(inf.Index, x, y) end
    end)
  end

  print(string.format("[WW2 Nation] %s founded %d cities", civ, founded))
end

function WW2_RevealAllFog()
  print("[WW2] Revealing entire map (no fog)...")
  for pid = 0, 63 do
    local vis = PlayersVisibility[pid]
    if vis then
      for i = 0, Map.GetPlotCount() - 1 do
        pcall(function() vis:ChangeVisibilityCount(i, 1) end)
      end
    end
  end
  print("[WW2] Map fully visible")
end

function WW2_ApplyAllTSL()
  print("[WW2 Nation] Building predefined countries...")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      local cfg = PlayerConfigurations[i]
      local civ = cfg and cfg:GetCivilizationTypeName()
      if civ then BuildNation(p, civ) end
    end
  end
  WW2_RevealAllFog()
  print("[WW2 Nation] Done")
end

local function OnLoad()
  if RAN then return end
  RAN = true
  if Events.GameCoreEventPublishComplete then
    local n = 0
    local function once()
      n = n + 1
      if n >= 2 then
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
print("[WW2 Nation/TSL] loaded — predefined countries + no fog after start")
