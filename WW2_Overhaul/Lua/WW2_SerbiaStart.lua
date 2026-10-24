-- Force Serbia / Yugoslavia onto the Balkans even when map TSL ignores custom civs
-- (Fidel Casserole WB maps, random starts, etc.)

local RAN = false

local SERBIA_CIVS = {
  CIVILIZATION_STR_SERBIA = true,
  CIVILIZATION_SERBIA = true,
  CIVILIZATION_WW2_YUGOSLAVIA = true,
}

-- Belgrade-ish fractions on a Europe-oriented map (x west→east, y south→north)
local BELGRADE_RX, BELGRADE_RY = 0.50, 0.40

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
  if plot:IsCity() then return false end
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
  local tx = math.floor(BELGRADE_RX * (w - 1) + 0.5)
  local ty = math.floor(BELGRADE_RY * (h - 1) + 0.5)
  local plot = FindNear(tx, ty, 24)
  if not plot then
    print("[WW2 Serbia] no good plot near Belgrade target")
    return
  end

  local pid = player:GetID()
  local x, y = plot:GetX(), plot:GetY()
  print(string.format("[WW2 Serbia] moving P%d to %d,%d (Belgrade target)", pid, x, y))

  for _, u in player:GetUnits():Members() do
    pcall(function() u:SetXY(x, y) end)
  end

  local cities = player:GetCities()
  if not cities or cities:GetCount() == 0 then
    local city = TryCity(pid, x, y)
    if city then
      pcall(function() if city.SetName then city:SetName("Belgrade") end end)
      print("[WW2 Serbia] founded Belgrade")
      -- kill default settler only after city exists
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
      if n >= 5 then
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
print("[WW2 Serbia] TSL force-load — CIVILIZATION_STR_SERBIA → Belgrade")
