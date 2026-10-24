-- 1930: move every major civ onto historical Europe slots and found capital city.
-- Works on TSL Europe / Europe-shaped maps (fraction of grid).

local RAN = false

-- rx, ry = fraction across map (0-1). Tuned for Firaxis Europe silhouette.
local HOMELANDS = {
  CIVILIZATION_ENGLAND     = { rx = 0.18, ry = 0.62, city = "London" },
  CIVILIZATION_SCOTLAND    = { rx = 0.16, ry = 0.70, city = "Edinburgh" },
  CIVILIZATION_FRANCE      = { rx = 0.28, ry = 0.48, city = "Paris" },
  CIVILIZATION_GAUL        = { rx = 0.28, ry = 0.48, city = "Paris" },
  CIVILIZATION_GERMANY     = { rx = 0.42, ry = 0.58, city = "Berlin" },
  CIVILIZATION_ROME        = { rx = 0.40, ry = 0.32, city = "Rome" },
  CIVILIZATION_SPAIN       = { rx = 0.14, ry = 0.28, city = "Madrid" },
  CIVILIZATION_PORTUGAL    = { rx = 0.08, ry = 0.26, city = "Lisbon" },
  CIVILIZATION_NETHERLANDS = { rx = 0.32, ry = 0.60, city = "Amsterdam" },
  CIVILIZATION_RUSSIA      = { rx = 0.78, ry = 0.58, city = "Moscow" },
  CIVILIZATION_POLAND      = { rx = 0.52, ry = 0.58, city = "Warsaw" },
  CIVILIZATION_HUNGARY     = { rx = 0.50, ry = 0.44, city = "Budapest" },
  CIVILIZATION_GREECE      = { rx = 0.54, ry = 0.22, city = "Athens" },
  CIVILIZATION_MACEDON     = { rx = 0.52, ry = 0.30, city = "Skopje" },
  CIVILIZATION_STR_SERBIA  = { rx = 0.50, ry = 0.38, city = "Belgrade" },
  CIVILIZATION_SERBIA      = { rx = 0.50, ry = 0.38, city = "Belgrade" },
  CIVILIZATION_WW2_YUGOSLAVIA = { rx = 0.50, ry = 0.38, city = "Belgrade" },
  CIVILIZATION_NORWAY      = { rx = 0.38, ry = 0.78, city = "Oslo" },
  CIVILIZATION_SWEDEN      = { rx = 0.46, ry = 0.78, city = "Stockholm" },
  CIVILIZATION_OTTOMAN     = { rx = 0.62, ry = 0.28, city = "Ankara" },
  CIVILIZATION_BYZANTIUM   = { rx = 0.60, ry = 0.30, city = "Istanbul" },
  CIVILIZATION_GEORGIA     = { rx = 0.82, ry = 0.40, city = "Tbilisi" },
  CIVILIZATION_EGYPT       = { rx = 0.58, ry = 0.08, city = "Cairo" },
  CIVILIZATION_PHOENICIA   = { rx = 0.12, ry = 0.22, city = "Carthage" },
  CIVILIZATION_SCYTHIA     = { rx = 0.70, ry = 0.50, city = "Steppe" },
}

local function CivName(player)
  local cfg = PlayerConfigurations[player:GetID()]
  return cfg and cfg:GetCivilizationTypeName()
end

local function IsGood(plot)
  if not plot or plot:IsWater() or plot:IsImpassable() then return false end
  if plot:IsOwned() then return false end
  local t = GameInfo.Terrains[plot:GetTerrainType()]
  if t and (string.find(t.TerrainType, "SNOW") or string.find(t.TerrainType, "MOUNTAIN")) then
    return false
  end
  return true
end

local function FindNear(tx, ty, radius)
  local w, h = Map.GetGridSize()
  local best, bestD = nil, 99999
  for r = 0, (radius or 20) do
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

local function TryCity(pid, x, y)
  local city = nil
  pcall(function()
    if CityManager and CityManager.CreateCity then city = CityManager.CreateCity(pid, x, y) end
  end)
  if city then return city end
  pcall(function()
    if WorldBuilder and WorldBuilder.CityManager then
      city = WorldBuilder.CityManager():CreateCity(pid, x, y)
    end
  end)
  return city
end

local function PlaceNation(player)
  local civ = CivName(player)
  local home = civ and HOMELANDS[civ]
  if not home then return end

  local w, h = Map.GetGridSize()
  local tx = math.floor(home.rx * (w - 1) + 0.5)
  local ty = math.floor(home.ry * (h - 1) + 0.5)
  local plot = FindNear(tx, ty, 22)
  if not plot then return end

  local pid = player:GetID()
  local x, y = plot:GetX(), plot:GetY()
  print(string.format("[1930] %s → %s (%d,%d)", tostring(civ), home.city, x, y))

  for _, u in player:GetUnits():Members() do
    pcall(function() u:SetXY(x, y) end)
  end

  local cities = player:GetCities()
  if not cities or cities:GetCount() == 0 then
    local city = TryCity(pid, x, y)
    if city then
      pcall(function() if city.SetName then city:SetName(home.city) end end)
      pcall(function()
        for _, u in player:GetUnits():Members() do
          local info = GameInfo.Units[u:GetType()]
          if info and info.UnitType == "UNIT_SETTLER" then
            if UnitManager and UnitManager.Kill then UnitManager.Kill(u) else u:Kill() end
          end
        end
      end)
    end
  end
end

local function OnLoad()
  if RAN then return end
  RAN = true
  local function run()
    for i = 0, 63 do
      local p = Players[i]
      if p and p:IsMajor() and p:IsAlive() then PlaceNation(p) end
    end
  end
  if Events.GameCoreEventPublishComplete then
    local n = 0
    local function once()
      n = n + 1
      if n >= 6 then
        run()
        Events.GameCoreEventPublishComplete.Remove(once)
      end
    end
    Events.GameCoreEventPublishComplete.Add(once)
  else
    run()
  end
end

Events.LoadScreenClose.Add(OnLoad)
print("[1930] Nations — historical capitals on Europe map")
