-- Predefined European cities with ~4-tile cultural borders
-- Territories get major historical cities only (most important).

local RAN = false

-- {name, rx, ry} fractions of map — denser Europe layout
local TERRITORY_CITIES = {
  TERRITORY_BRITAIN = {
    {"London", 0.22, 0.58}, {"Birmingham", 0.20, 0.62}, {"Manchester", 0.20, 0.66},
    {"Edinburgh", 0.18, 0.72}, {"Dublin", 0.12, 0.62},
  },
  TERRITORY_FRANCE = {
    {"Paris", 0.30, 0.50}, {"Lyon", 0.32, 0.44}, {"Marseille", 0.34, 0.38},
    {"Bordeaux", 0.24, 0.42}, {"Lille", 0.30, 0.56},
  },
  TERRITORY_GERMANY = {
    {"Berlin", 0.44, 0.58}, {"Hamburg", 0.40, 0.62}, {"Munich", 0.42, 0.48},
    {"Cologne", 0.36, 0.54}, {"Frankfurt", 0.38, 0.52},
  },
  TERRITORY_ITALY = {
    {"Rome", 0.40, 0.34}, {"Milan", 0.38, 0.44}, {"Naples", 0.42, 0.28},
    {"Venice", 0.42, 0.42}, {"Turin", 0.36, 0.44},
  },
  TERRITORY_SPAIN = {
    {"Madrid", 0.18, 0.36}, {"Barcelona", 0.24, 0.38}, {"Seville", 0.14, 0.30},
    {"Valencia", 0.20, 0.34},
  },
  TERRITORY_PORTUGAL = {
    {"Lisbon", 0.10, 0.32}, {"Porto", 0.10, 0.38},
  },
  TERRITORY_POLAND = {
    {"Warsaw", 0.52, 0.56}, {"Krakow", 0.50, 0.50}, {"Gdansk", 0.50, 0.62},
  },
  TERRITORY_HUNGARY = {
    {"Budapest", 0.50, 0.46}, {"Debrecen", 0.54, 0.46},
  },
  TERRITORY_SERBIA = {
    {"Belgrade", 0.50, 0.40}, {"Zagreb", 0.46, 0.42}, {"Sarajevo", 0.48, 0.38},
    {"Skopje", 0.52, 0.34}, {"Ljubljana", 0.44, 0.44},
  },
  TERRITORY_GREECE = {
    {"Athens", 0.54, 0.28}, {"Thessaloniki", 0.52, 0.32},
  },
  TERRITORY_RUSSIA = {
    {"Moscow", 0.70, 0.60}, {"Leningrad", 0.62, 0.68}, {"Kiev", 0.60, 0.50},
    {"Stalingrad", 0.74, 0.48}, {"Minsk", 0.58, 0.58},
  },
  TERRITORY_NETHERLANDS = {
    {"Amsterdam", 0.32, 0.60}, {"Rotterdam", 0.30, 0.58},
  },
  TERRITORY_NORWAY = {
    {"Oslo", 0.40, 0.76}, {"Bergen", 0.36, 0.78},
  },
  TERRITORY_SWEDEN = {
    {"Stockholm", 0.50, 0.78}, {"Goteborg", 0.44, 0.74},
  },
  TERRITORY_TURKEY = {
    {"Istanbul", 0.60, 0.36}, {"Ankara", 0.66, 0.34}, {"Izmir", 0.58, 0.32},
  },
  TERRITORY_GEORGIA = {
    {"Tbilisi", 0.78, 0.40},
  },
  TERRITORY_EGYPT = {
    {"Cairo", 0.62, 0.12}, {"Alexandria", 0.60, 0.14},
  },
  TERRITORY_SCOTLAND = {
    {"Edinburgh", 0.18, 0.72}, {"Glasgow", 0.16, 0.70},
  },
}

local CIV_TO_TERR = {
  CIVILIZATION_GERMANY = "TERRITORY_GERMANY",
  CIVILIZATION_ENGLAND = "TERRITORY_BRITAIN",
  CIVILIZATION_SCOTLAND = "TERRITORY_SCOTLAND",
  CIVILIZATION_FRANCE = "TERRITORY_FRANCE",
  CIVILIZATION_GAUL = "TERRITORY_FRANCE",
  CIVILIZATION_ROME = "TERRITORY_ITALY",
  CIVILIZATION_SPAIN = "TERRITORY_SPAIN",
  CIVILIZATION_PORTUGAL = "TERRITORY_PORTUGAL",
  CIVILIZATION_RUSSIA = "TERRITORY_RUSSIA",
  CIVILIZATION_SCYTHIA = "TERRITORY_RUSSIA",
  CIVILIZATION_POLAND = "TERRITORY_POLAND",
  CIVILIZATION_HUNGARY = "TERRITORY_HUNGARY",
  CIVILIZATION_SERBIA = "TERRITORY_SERBIA",
  CIVILIZATION_STR_SERBIA = "TERRITORY_SERBIA",
  CIVILIZATION_WW2_YUGOSLAVIA = "TERRITORY_SERBIA",
  CIVILIZATION_MACEDON = "TERRITORY_SERBIA",
  CIVILIZATION_GREECE = "TERRITORY_GREECE",
  CIVILIZATION_BYZANTIUM = "TERRITORY_TURKEY",
  CIVILIZATION_OTTOMAN = "TERRITORY_TURKEY",
  CIVILIZATION_NETHERLANDS = "TERRITORY_NETHERLANDS",
  CIVILIZATION_NORWAY = "TERRITORY_NORWAY",
  CIVILIZATION_SWEDEN = "TERRITORY_SWEDEN",
  CIVILIZATION_GEORGIA = "TERRITORY_GEORGIA",
  CIVILIZATION_EGYPT = "TERRITORY_EGYPT",
  CIVILIZATION_NUBIA = "TERRITORY_EGYPT",
}

local claimed = {}

local function GridXY(rx, ry)
  local w, h = Map.GetGridSize()
  return math.max(0, math.min(w - 1, math.floor(rx * (w - 1) + 0.5))),
         math.max(0, math.min(h - 1, math.floor(ry * (h - 1) + 0.5)))
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
  local best, bestD = nil, 99999
  local w, h = Map.GetGridSize()
  for r = 0, (radius or 12) do
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

-- Claim plots in a 4-tile radius around the city (border ~9 tiles across)
local function ExpandBorders(playerID, cx, cy, radius)
  radius = radius or 4
  for dy = -radius, radius do
    for dx = -radius, radius do
      if dx * dx + dy * dy <= radius * radius + 1 then
        local p = Map.GetPlot(cx + dx, cy + dy)
        if p and not p:IsWater() then
          pcall(function()
            if WorldBuilder and WorldBuilder.CityManager then
              -- set owner plot
            end
            local plotOwner = p:GetOwner()
            if plotOwner == -1 or plotOwner == nil then
              if p.SetOwner then p:SetOwner(playerID) end
            end
          end)
          pcall(function()
            if CityManager and CityManager.SetPlotOwner then
              CityManager.SetPlotOwner(p, playerID)
            end
          end)
        end
      end
    end
  end
end

local function RenameCity(city, name)
  if not city or not name then return end
  pcall(function()
    if city.SetName then city:SetName(name) end
  end)
  pcall(function()
    local loc = "LOC_CITY_NAME_" .. string.upper(name:gsub("[^%w]", "_"))
    if city.SetName then city:SetName(loc) end
  end)
end

local function BuildTerritory(player, terrKey)
  local list = TERRITORY_CITIES[terrKey]
  if not list then return end
  local pid = player:GetID()
  local founded = 0
  local capitalPlot = nil

  for _, entry in ipairs(list) do
    local name, rx, ry = entry[1], entry[2], entry[3]
    local tx, ty = GridXY(rx, ry)
    local plot = FindNear(tx, ty, 10)
    if plot then
      local city = TryCreateCity(pid, plot:GetX(), plot:GetY())
      if city then
        founded = founded + 1
        RenameCity(city, name)
        ExpandBorders(pid, plot:GetX(), plot:GetY(), 4)
        if not capitalPlot then capitalPlot = plot end
        print(string.format("[WW2 City] %s at %d,%d for P%d", name, plot:GetX(), plot:GetY(), pid))
      end
    end
  end

  if capitalPlot then
    for _, u in player:GetUnits():Members() do
      pcall(function() u:SetXY(capitalPlot:GetX(), capitalPlot:GetY()) end)
    end
  end

  -- Only remove settlers if we founded cities
  if founded > 0 then
    pcall(function()
      for _, u in player:GetUnits():Members() do
        local info = GameInfo.Units[u:GetType()]
        if info and info.UnitType == "UNIT_SETTLER" then
          if UnitManager and UnitManager.Kill then UnitManager.Kill(u) else u:Kill() end
        end
      end
    end)
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
    if sel and sel ~= "TERRITORY_AUTO" and TERRITORY_CITIES[sel] then return sel end
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
  print("[WW2 Terr] Building predefined European cities...")
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
      print("[WW2 Terr] no mapping for " .. civ)
    elseif claimed[terr] then
      print("[WW2 Terr] " .. terr .. " already taken")
    else
      claimed[terr] = p:GetID()
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
      if n >= 4 then
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
print("[WW2 Terr] predefined cities + 4-tile borders")
