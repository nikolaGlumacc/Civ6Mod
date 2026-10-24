-- Every major gets a historical territory automatically.
-- Human: Advanced Setup "WW2 Starting Territory" overrides (or AUTO = from leader).
-- AI: always mapped from civilization (England→Britain, France→France, ...).
-- Each territory is only granted once (no double-stack on same land).

local RAN = false

local TERRITORIES = {
  TERRITORY_GERMANY = {
    {0.48, 0.58}, {0.46, 0.54}, {0.50, 0.56}, {0.44, 0.58}, {0.48, 0.62},
  },
  TERRITORY_BRITAIN = {
    {0.28, 0.64}, {0.26, 0.60}, {0.30, 0.68}, {0.24, 0.66},
  },
  TERRITORY_FRANCE = {
    {0.34, 0.50}, {0.32, 0.46}, {0.36, 0.48}, {0.30, 0.52}, {0.36, 0.42},
  },
  TERRITORY_ITALY = {
    {0.46, 0.36}, {0.44, 0.40}, {0.48, 0.30}, {0.48, 0.22},
  },
  TERRITORY_SPAIN = {
    {0.22, 0.36}, {0.18, 0.32}, {0.26, 0.38}, {0.16, 0.36},
  },
  TERRITORY_RUSSIA = {
    {0.72, 0.62}, {0.68, 0.58}, {0.76, 0.64}, {0.70, 0.54}, {0.78, 0.60},
  },
  TERRITORY_POLAND = {
    {0.54, 0.58}, {0.52, 0.54}, {0.56, 0.60},
  },
  TERRITORY_HUNGARY = {
    {0.52, 0.48}, {0.50, 0.46},
  },
  TERRITORY_SERBIA = {
    {0.52, 0.42}, {0.50, 0.40}, {0.54, 0.40}, {0.52, 0.44},
  },
  TERRITORY_GREECE = {
    {0.56, 0.28}, {0.54, 0.30}, {0.58, 0.26},
  },
  TERRITORY_NETHERLANDS = {
    {0.38, 0.60}, {0.38, 0.58},
  },
  TERRITORY_NORWAY = {
    {0.42, 0.78}, {0.40, 0.74},
  },
  TERRITORY_SWEDEN = {
    {0.50, 0.78}, {0.52, 0.74},
  },
  TERRITORY_PORTUGAL = {
    {0.14, 0.34}, {0.14, 0.30},
  },
  TERRITORY_EGYPT = {
    {0.62, 0.12}, {0.60, 0.10}, {0.64, 0.10},
  },
  TERRITORY_SCOTLAND = {
    {0.26, 0.72}, {0.24, 0.70},
  },
  TERRITORY_TURKEY = {
    {0.64, 0.36}, {0.66, 0.34},
  },
  TERRITORY_GEORGIA = {
    {0.78, 0.42}, {0.76, 0.40},
  },
}

-- Primary civ → territory (AI always use this)
local CIV_TO_TERR = {
  CIVILIZATION_GERMANY = "TERRITORY_GERMANY",
  CIVILIZATION_ENGLAND = "TERRITORY_BRITAIN",
  CIVILIZATION_SCOTLAND = "TERRITORY_SCOTLAND",
  CIVILIZATION_FRANCE = "TERRITORY_FRANCE",
  CIVILIZATION_GAUL = "TERRITORY_FRANCE",
  CIVILIZATION_ROME = "TERRITORY_ITALY",
  CIVILIZATION_SPAIN = "TERRITORY_SPAIN",
  CIVILIZATION_RUSSIA = "TERRITORY_RUSSIA",
  CIVILIZATION_SCYTHIA = "TERRITORY_RUSSIA",
  CIVILIZATION_POLAND = "TERRITORY_POLAND",
  CIVILIZATION_HUNGARY = "TERRITORY_HUNGARY",
  CIVILIZATION_SERBIA = "TERRITORY_SERBIA",
  CIVILIZATION_STR_SERBIA = "TERRITORY_SERBIA",
  CIVILIZATION_WW2_YUGOSLAVIA = "TERRITORY_SERBIA",
  CIVILIZATION_GREECE = "TERRITORY_GREECE",
  CIVILIZATION_MACEDON = "TERRITORY_GREECE",
  CIVILIZATION_BYZANTIUM = "TERRITORY_TURKEY",
  CIVILIZATION_OTTOMAN = "TERRITORY_TURKEY",
  CIVILIZATION_NETHERLANDS = "TERRITORY_NETHERLANDS",
  CIVILIZATION_NORWAY = "TERRITORY_NORWAY",
  CIVILIZATION_SWEDEN = "TERRITORY_SWEDEN",
  CIVILIZATION_PORTUGAL = "TERRITORY_PORTUGAL",
  CIVILIZATION_EGYPT = "TERRITORY_EGYPT",
  CIVILIZATION_PHOENICIA = "TERRITORY_EGYPT",
  CIVILIZATION_NUBIA = "TERRITORY_EGYPT",
  CIVILIZATION_ETHIOPIA = "TERRITORY_EGYPT",
  CIVILIZATION_MALI = "TERRITORY_EGYPT",
  CIVILIZATION_GEORGIA = "TERRITORY_GEORGIA",
}

-- Claimed territories this game (one owner each)
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
  if t and string.find(t.TerrainType, "SNOW") then return false end
  return true
end

local function FindNear(tx, ty, radius)
  radius = radius or 14
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

local function BuildTerritory(player, terrKey)
  local sites = TERRITORIES[terrKey]
  if not sites then return end
  local founded = 0
  local capitalPlot = nil
  for _, pair in ipairs(sites) do
    local tx, ty = GridXY(pair[1], pair[2])
    local plot = FindNear(tx, ty, 12)
    if plot then
      local city = TryCreateCity(player:GetID(), plot:GetX(), plot:GetY())
      if city then
        founded = founded + 1
        if not capitalPlot then capitalPlot = plot end
        print(string.format("[WW2 AI/Terr] %s city (%d,%d) P%d", terrKey, plot:GetX(), plot:GetY(), player:GetID()))
      elseif not capitalPlot then
        capitalPlot = plot
      end
    end
  end
  if capitalPlot then MoveUnits(player, capitalPlot) end
  if founded > 0 then
    KillSettlers(player)
    pcall(function()
      local tank = GameInfo.Units["UNIT_TANK"]
      local inf = GameInfo.Units["UNIT_INFANTRY"]
      local x, y = capitalPlot:GetX(), capitalPlot:GetY()
      if tank then player:GetUnits():Create(tank.Index, x, y) end
      if inf then player:GetUnits():Create(inf.Index, x, y) end
      if inf then player:GetUnits():Create(inf.Index, x, y) end
    end)
  end
  print(string.format("[WW2 AI/Terr] %s → P%d (%d cities)", terrKey, player:GetID(), founded))
end

local function CivOf(player)
  local cfg = PlayerConfigurations[player:GetID()]
  return cfg and cfg:GetCivilizationTypeName() or nil
end

-- Human may override via Advanced Setup; AI always uses civ mapping.
local function PreferredTerritory(player)
  if player:IsHuman() then
    local sel = nil
    pcall(function() sel = GameConfiguration.GetValue("WW2_TERRITORY") end)
    if sel and sel ~= "TERRITORY_AUTO" and TERRITORIES[sel] then
      return sel
    end
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
  print("[WW2 AI/Terr] Assigning historical territories to all majors...")
  local w, h = Map.GetGridSize()
  print(string.format("[WW2 AI/Terr] grid %dx%d", w or 0, h or 0))

  -- Humans first (so their picker wins the territory), then AI
  local order = {}
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      table.insert(order, p)
    end
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
      print(string.format("[WW2 AI/Terr] P%d %s — no territory mapping", p:GetID(), civ))
    elseif claimed[terr] then
      print(string.format("[WW2 AI/Terr] P%d %s wanted %s but already taken — skip seed", p:GetID(), civ, terr))
      -- Still move units near that region so they aren't in Antarctica
      local sites = TERRITORIES[terr]
      if sites and sites[1] then
        local tx, ty = GridXY(sites[1][1], sites[1][2])
        local plot = FindNear(tx, ty, 18)
        if plot then MoveUnits(p, plot) end
      end
    else
      claimed[terr] = p:GetID()
      print(string.format("[WW2 AI/Terr] P%d %s claims %s", p:GetID(), civ, terr))
      BuildTerritory(p, terr)
    end
  end

  WW2_RevealAllFog()
  print("[WW2 AI/Terr] Done")
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
print("[WW2 AI/Terr] loaded — AI auto-picks England/France/Germany/Poland/Serbia/... territories")
