-- True-ish starts for WW2 Europe map (96x60).
-- Runs AFTER load screen so units/cities exist. Seeds a capital if none yet.

local RAN = false

-- Relative coords 0..1 mapped onto current grid (works if size changes slightly)
local TSL = {
  CIVILIZATION_ENGLAND      = { 0.22, 0.64 }, -- London
  CIVILIZATION_SCOTLAND     = { 0.20, 0.72 },
  CIVILIZATION_FRANCE       = { 0.30, 0.50 }, -- Paris
  CIVILIZATION_SPAIN        = { 0.18, 0.36 }, -- Madrid
  CIVILIZATION_PORTUGAL     = { 0.12, 0.34 }, -- Lisbon
  CIVILIZATION_GERMANY      = { 0.42, 0.58 }, -- Berlin
  CIVILIZATION_POLAND       = { 0.52, 0.60 }, -- Warsaw
  CIVILIZATION_HUNGARY      = { 0.50, 0.50 }, -- Budapest
  CIVILIZATION_RUSSIA       = { 0.72, 0.68 }, -- Moscow belt
  CIVILIZATION_ROME         = { 0.42, 0.34 }, -- Rome / Italy (Trajan)
  CIVILIZATION_SERBIA       = { 0.50, 0.42 }, -- Belgrade
  CIVILIZATION_STR_SERBIA   = { 0.50, 0.42 },
  CIVILIZATION_WW2_YUGOSLAVIA = { 0.50, 0.42 },
  CIVILIZATION_GREECE       = { 0.54, 0.28 }, -- Athens
  CIVILIZATION_MACEDON      = { 0.53, 0.32 }, -- north of Greece, NOT Spain
  CIVILIZATION_NORWAY       = { 0.38, 0.80 },
  CIVILIZATION_SWEDEN       = { 0.46, 0.80 },
  CIVILIZATION_NETHERLANDS  = { 0.34, 0.60 },
  CIVILIZATION_GEORGIA      = { 0.78, 0.42 },
  CIVILIZATION_BYZANTIUM    = { 0.60, 0.34 }, -- Constantinople area
  CIVILIZATION_OTTOMAN      = { 0.62, 0.36 },
  CIVILIZATION_GAUL         = { 0.32, 0.52 },
  CIVILIZATION_SCYTHIA      = { 0.70, 0.55 },
  CIVILIZATION_PHOENICIA    = { 0.28, 0.10 }, -- North Africa / Carthage
  CIVILIZATION_EGYPT        = { 0.60, 0.10 },
  CIVILIZATION_ETHIOPIA     = { 0.64, 0.07 },
  CIVILIZATION_NUBIA        = { 0.58, 0.08 },
  CIVILIZATION_MALI         = { 0.20, 0.08 },
}

-- Extra city seeds (relative) for HOI4-ish territory feel — capital + 1-2 more
local EXTRA = {
  CIVILIZATION_ENGLAND = { {0.20,0.62}, {0.24,0.68} },
  CIVILIZATION_FRANCE  = { {0.28,0.46}, {0.34,0.48} },
  CIVILIZATION_GERMANY = { {0.40,0.54}, {0.44,0.60} },
  CIVILIZATION_SPAIN   = { {0.16,0.32}, {0.22,0.38} },
  CIVILIZATION_RUSSIA  = { {0.68,0.64}, {0.76,0.70} },
  CIVILIZATION_ROME    = { {0.40,0.30}, {0.44,0.36} },
  CIVILIZATION_SERBIA  = { {0.48,0.40}, {0.52,0.44} },
  CIVILIZATION_POLAND  = { {0.50,0.58}, {0.54,0.62} },
  CIVILIZATION_GREECE  = { {0.52,0.26} },
  CIVILIZATION_MACEDON = { {0.51,0.34} },
}

local function GridXY(rx, ry)
  local w, h = Map.GetGridSize()
  local x = math.floor(rx * (w - 1) + 0.5)
  local y = math.floor(ry * (h - 1) + 0.5)
  if x < 0 then x = 0 end
  if y < 0 then y = 0 end
  if x > w - 1 then x = w - 1 end
  if y > h - 1 then y = h - 1 end
  return x, y
end

local function IsGood(plot)
  if not plot or plot:IsWater() or plot:IsImpassable() then return false end
  if plot:IsCity() then return false end
  local t = GameInfo.Terrains[plot:GetTerrainType()]
  if t then
    local n = t.TerrainType
    if n == "TERRAIN_SNOW" or n == "TERRAIN_SNOW_HILLS" or n == "TERRAIN_SNOW_MOUNTAIN" then
      return false
    end
    if n == "TERRAIN_TUNDRA" or n == "TERRAIN_TUNDRA_HILLS" then return false end
  end
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

local function MoveUnits(player, plot)
  if not player or not plot then return end
  local units = player:GetUnits()
  if not units then return end
  for _, u in units:Members() do
    pcall(function() u:SetXY(plot:GetX(), plot:GetY()) end)
  end
end

local function TryCreateCity(playerID, x, y)
  -- Several API variants across builds
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

local function EnsureCapital(player, plot)
  if not player or not plot then return end
  local cities = player:GetCities()
  if cities and cities:GetCount() > 0 then
    -- Already has cities — leave them; still move units to capital area
    return
  end
  local city = TryCreateCity(player:GetID(), plot:GetX(), plot:GetY())
  if city then
    print(string.format("[WW2 TSL] Founded capital for P%d at %d,%d", player:GetID(), plot:GetX(), plot:GetY()))
    -- Kill settlers (already founded)
    pcall(function()
      for _, u in player:GetUnits():Members() do
        local info = GameInfo.Units[u:GetType()]
        if info and info.UnitType == "UNIT_SETTLER" then
          UnitManager.Kill(u)
        end
      end
    end)
  else
    -- Fallback: just park settlers on the plot so player founds manually
    MoveUnits(player, plot)
    print(string.format("[WW2 TSL] No CreateCity API — moved units for P%d to %d,%d", player:GetID(), plot:GetX(), plot:GetY()))
  end
end

local function SeedExtraCities(player, civ)
  local list = EXTRA[civ]
  if not list then return end
  local cities = player:GetCities()
  if not cities then return end
  -- Only seed if we already have at least a capital
  if cities:GetCount() < 1 then return end
  for _, pair in ipairs(list) do
    local tx, ty = GridXY(pair[1], pair[2])
    local plot = FindNear(tx, ty, 8)
    if plot then
      local c = TryCreateCity(player:GetID(), plot:GetX(), plot:GetY())
      if c then
        print(string.format("[WW2 TSL] Extra city P%d at %d,%d", player:GetID(), plot:GetX(), plot:GetY()))
      end
    end
  end
end

local function PlacePlayer(player)
  local cfg = PlayerConfigurations[player:GetID()]
  if not cfg then return end
  local civ = cfg:GetCivilizationTypeName()
  if not civ then return end
  local tsl = TSL[civ]
  if not tsl then
    print("[WW2 TSL] No TSL entry for " .. tostring(civ))
    return
  end
  local tx, ty = GridXY(tsl[1], tsl[2])
  local plot = FindNear(tx, ty, 14)
  if not plot then
    print("[WW2 TSL] No land near TSL for " .. civ)
    return
  end
  print(string.format("[WW2 TSL] %s -> target %d,%d (wanted %d,%d)", civ, plot:GetX(), plot:GetY(), tx, ty))
  EnsureCapital(player, plot)
  MoveUnits(player, plot)
  SeedExtraCities(player, civ)
end

function WW2_ApplyAllTSL()
  print("[WW2 TSL] Applying historical starts...")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      PlacePlayer(p)
    end
  end
  print("[WW2 TSL] Done")
end

local function OnLoad()
  if RAN then return end
  RAN = true
  -- Defer one tick so cities/units are fully initialized
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
print("[WW2 TSL] loaded — will place civs after LoadScreenClose")
