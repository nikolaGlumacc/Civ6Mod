-- Serbia / Yugoslavia true start on Europe maps (official TSL Europe + anything else).
-- 1) Prefer plot next to Macedon/Hungary if those civs exist
-- 2) Else Belgrade-ish fraction of the map
-- 3) Move units + found Belgrade if no city yet

local RAN = false

local SERBIA_CIVS = {
  CIVILIZATION_STR_SERBIA = true,
  CIVILIZATION_SERBIA = true,
  CIVILIZATION_WW2_YUGOSLAVIA = true,
}

local ANCHOR_CIVS = {
  CIVILIZATION_MACEDON = true,
  CIVILIZATION_HUNGARY = true,
  CIVILIZATION_GREECE = true,
  CIVILIZATION_BYZANTIUM = true,
  CIVILIZATION_OTTOMAN = true,
  CIVILIZATION_ROME = true,
}

local BELGRADE_RX, BELGRADE_RY = 0.52, 0.42

local function CivName(player)
  local cfg = PlayerConfigurations[player:GetID()]
  return cfg and cfg:GetCivilizationTypeName()
end

local function IsSerbia(player)
  local c = CivName(player)
  return c and SERBIA_CIVS[c]
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
  for r = 0, (radius or 18) do
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

local function PlotOfPlayer(player)
  local cities = player:GetCities()
  if cities and cities:GetCount() > 0 then
    for _, c in cities:Members() do
      return Map.GetPlot(c:GetX(), c:GetY())
    end
  end
  for _, u in player:GetUnits():Members() do
    return Map.GetPlot(u:GetX(), u:GetY())
  end
  return nil
end

local function FindAnchorPlot()
  -- Prefer Macedon (closest to historical Serbia), then Hungary, etc.
  local order = {
    "CIVILIZATION_MACEDON",
    "CIVILIZATION_HUNGARY",
    "CIVILIZATION_GREECE",
    "CIVILIZATION_BYZANTIUM",
    "CIVILIZATION_OTTOMAN",
    "CIVILIZATION_ROME",
  }
  local found = {}
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      local c = CivName(p)
      if c and ANCHOR_CIVS[c] then
        local pl = PlotOfPlayer(p)
        if pl then found[c] = pl end
      end
    end
  end
  for _, key in ipairs(order) do
    if found[key] then return found[key], key end
  end
  return nil, nil
end

local function TryCity(playerID, x, y)
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

local function PlaceSerbia(player)
  local w, h = Map.GetGridSize()
  local target
  local anchor, anchorName = FindAnchorPlot()
  if anchor then
    -- Sit a few tiles north of Macedon / near Hungary = Balkans
    local ax, ay = anchor:GetX(), anchor:GetY()
    local ox, oy = 0, 3
    if anchorName == "CIVILIZATION_HUNGARY" then ox, oy = 2, -2 end
    if anchorName == "CIVILIZATION_GREECE" then ox, oy = 0, 5 end
    if anchorName == "CIVILIZATION_ROME" then ox, oy = 8, 2 end
    target = FindNear(ax + ox, ay + oy, 14)
    print(string.format("[WW2 Serbia] anchor %s at %d,%d", tostring(anchorName), ax, ay))
  end
  if not target then
    local tx = math.floor(BELGRADE_RX * (w - 1) + 0.5)
    local ty = math.floor(BELGRADE_RY * (h - 1) + 0.5)
    target = FindNear(tx, ty, 22)
  end
  if not target then
    print("[WW2 Serbia] no valid Belgrade plot")
    return
  end

  local pid = player:GetID()
  local x, y = target:GetX(), target:GetY()
  print(string.format("[WW2 Serbia] placing P%d at %d,%d", pid, x, y))

  for _, u in player:GetUnits():Members() do
    pcall(function() u:SetXY(x, y) end)
  end

  local cities = player:GetCities()
  if not cities or cities:GetCount() == 0 then
    local city = TryCity(pid, x, y)
    if city then
      pcall(function() if city.SetName then city:SetName("Belgrade") end end)
      print("[WW2 Serbia] founded Belgrade")
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
      if p and p:IsMajor() and p:IsAlive() and IsSerbia(p) then
        PlaceSerbia(p)
      end
    end
  end
  if Events.GameCoreEventPublishComplete then
    local n = 0
    local function once()
      n = n + 1
      if n >= 8 then
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
print("[WW2 Serbia] TSL Europe support — STR_SERBIA / SERBIA / YUGOSLAVIA → Belgrade")
