------------------------------------------------------------------------------
-- WW2 Europe — 106x66 Europe + North Africa (no ClearLandmarks — that API is nil)
------------------------------------------------------------------------------
include("MapEnums")
include("MapUtilities")
include("FeatureGenerator")
include("TerrainGenerator")
include("NaturalWonderGenerator")
include("ResourceGenerator")
include("AssignStartingPlots")

local g_iW, g_iH = 106, 66

function GetMapInitData(MapSize)
  return { Width = 106, Height = 66, WrapX = false, WrapY = false }
end

function GetMapScriptInfo()
  local world_age, temperature, rainfall, sea_level, resources = GetCoreMapOptions()
  return {
    Name = "LOC_MAP_WW2_EUROPE_NAME",
    Description = "LOC_MAP_WW2_EUROPE_DESCRIPTION",
    IsAdvancedMap = 0,
    IconIndex = 1,
    SortIndex = 5,
    CustomOptions = { world_age, temperature, rainfall, sea_level, resources },
  }
end

local function N(x, y)
  return x / math.max(g_iW - 1, 1), y / math.max(g_iH - 1, 1)
end

local function InEllipse(nx, ny, cx, cy, rx, ry)
  local dx = (nx - cx) / rx
  local dy = (ny - cy) / ry
  return dx * dx + dy * dy <= 1.0
end

local function InBox(nx, ny, x0, y0, x1, y1)
  return nx >= x0 and nx <= x1 and ny >= y0 and ny <= y1
end

local function IsAfrica(x, y)
  local nx, ny = N(x, y)
  return ny < 0.16 and nx > 0.08 and nx < 0.72
end

local function IsEuropeLand(x, y)
  local nx, ny = N(x, y)
  if nx < 0.015 or nx > 0.985 or ny < 0.015 or ny > 0.98 then return false end
  local land = false
  if InEllipse(nx, ny, 0.18, 0.34, 0.12, 0.14) then land = true end
  if InEllipse(nx, ny, 0.30, 0.50, 0.14, 0.18) then land = true end
  if InEllipse(nx, ny, 0.22, 0.64, 0.07, 0.12) then land = true end
  if InEllipse(nx, ny, 0.16, 0.62, 0.035, 0.07) then land = true end
  if InEllipse(nx, ny, 0.45, 0.54, 0.16, 0.16) then land = true end
  if InEllipse(nx, ny, 0.42, 0.80, 0.10, 0.18) then land = true end
  if InEllipse(nx, ny, 0.55, 0.84, 0.07, 0.10) then land = true end
  if InEllipse(nx, ny, 0.42, 0.32, 0.05, 0.14) then land = true end
  if InEllipse(nx, ny, 0.44, 0.24, 0.035, 0.06) then land = true end
  if InEllipse(nx, ny, 0.44, 0.18, 0.03, 0.025) then land = true end
  if InEllipse(nx, ny, 0.52, 0.38, 0.10, 0.12) then land = true end
  if InEllipse(nx, ny, 0.54, 0.26, 0.05, 0.08) then land = true end
  if InEllipse(nx, ny, 0.70, 0.60, 0.22, 0.22) then land = true end
  if InEllipse(nx, ny, 0.40, 0.66, 0.04, 0.05) then land = true end
  if InEllipse(nx, ny, 0.58, 0.70, 0.08, 0.06) then land = true end
  if InEllipse(nx, ny, 0.26, 0.09, 0.18, 0.055) then land = true end
  if InEllipse(nx, ny, 0.48, 0.08, 0.14, 0.045) then land = true end
  if InEllipse(nx, ny, 0.62, 0.09, 0.08, 0.04) then land = true end

  if InBox(nx, ny, 0.18, 0.14, 0.70, 0.30) then
    local coast =
      InEllipse(nx, ny, 0.42, 0.32, 0.05, 0.14)
      or InEllipse(nx, ny, 0.54, 0.26, 0.05, 0.08)
      or InEllipse(nx, ny, 0.18, 0.34, 0.12, 0.14)
      or InEllipse(nx, ny, 0.52, 0.38, 0.10, 0.12)
      or InEllipse(nx, ny, 0.44, 0.18, 0.03, 0.025)
      or InEllipse(nx, ny, 0.26, 0.09, 0.18, 0.055)
      or InEllipse(nx, ny, 0.48, 0.08, 0.14, 0.045)
    if not coast and ny < 0.28 then land = false end
  end
  if InBox(nx, ny, 0.44, 0.30, 0.52, 0.44) and nx > 0.46 and nx < 0.50 then land = false end
  if nx > 0.28 and nx < 0.38 and ny > 0.58 and ny < 0.74 then
    if not InEllipse(nx, ny, 0.22, 0.64, 0.07, 0.12)
       and not InEllipse(nx, ny, 0.30, 0.50, 0.14, 0.18)
       and not InEllipse(nx, ny, 0.40, 0.66, 0.04, 0.05) then land = false end
  end
  if ny > 0.68 and nx > 0.44 and nx < 0.56 then
    if not InEllipse(nx, ny, 0.42, 0.80, 0.10, 0.18)
       and not InEllipse(nx, ny, 0.55, 0.84, 0.07, 0.10)
       and not InEllipse(nx, ny, 0.58, 0.70, 0.08, 0.06)
       and not InEllipse(nx, ny, 0.45, 0.54, 0.16, 0.16) then land = false end
  end
  if InEllipse(nx, ny, 0.66, 0.42, 0.10, 0.07) then land = false end
  if InBox(nx, ny, 0.24, 0.54, 0.30, 0.60) then land = false end
  if InBox(nx, ny, 0.12, 0.40, 0.22, 0.52) and nx < 0.18 then land = false end
  return land
end

local function IsMountain(x, y)
  local nx, ny = N(x, y)
  if InEllipse(nx, ny, 0.22, 0.40, 0.08, 0.025) then return true end
  if InEllipse(nx, ny, 0.38, 0.42, 0.10, 0.04) then return true end
  if InEllipse(nx, ny, 0.55, 0.48, 0.08, 0.05) then return true end
  if InEllipse(nx, ny, 0.50, 0.36, 0.06, 0.06) then return true end
  if InEllipse(nx, ny, 0.38, 0.80, 0.04, 0.14) then return true end
  if InEllipse(nx, ny, 0.42, 0.30, 0.02, 0.10) then return true end
  return false
end

local function IsHills(x, y)
  if IsAfrica(x, y) then return false end
  local nx, ny = N(x, y)
  if InEllipse(nx, ny, 0.30, 0.44, 0.08, 0.06) then return true end
  if InEllipse(nx, ny, 0.48, 0.52, 0.06, 0.05) then return true end
  if InEllipse(nx, ny, 0.20, 0.32, 0.06, 0.05) then return true end
  if InEllipse(nx, ny, 0.54, 0.32, 0.05, 0.05) then return true end
  return false
end

-- Classic Firaxis contract: build plotTypes table and return it
function GeneratePlotTypes()
  print("[WW2 Europe] GeneratePlotTypes")
  local plotTypes = {}
  local ocean = g_PLOT_TYPE_OCEAN or 3
  local land = g_PLOT_TYPE_LAND or 1
  local hills = g_PLOT_TYPE_HILLS or 2
  local mountain = g_PLOT_TYPE_MOUNTAIN or 0

  for i = 0, (g_iW * g_iH) - 1 do
    plotTypes[i] = ocean
  end

  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local i = y * g_iW + x
      if IsEuropeLand(x, y) then
        if IsMountain(x, y) then
          plotTypes[i] = mountain
        elseif IsHills(x, y) then
          plotTypes[i] = hills
        else
          plotTypes[i] = land
        end
      end
    end
  end

  pcall(function() AreaBuilder.Recalculate() end)
  return plotTypes
end

function GenerateTerrain()
  print("[WW2 Europe] GenerateTerrain")
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local plot = Map.GetPlot(x, y)
      if plot and not plot:IsWater() then
        local nx, ny = N(x, y)
        local terrain
        if IsAfrica(x, y) then
          terrain = ((x + y) % 5 == 0) and "TERRAIN_PLAINS" or "TERRAIN_DESERT"
        elseif plot:IsMountain() then
          terrain = ny > 0.55 and "TERRAIN_TUNDRA_MOUNTAIN" or "TERRAIN_GRASS_MOUNTAIN"
        elseif plot:IsHills() then
          if ny > 0.70 then terrain = "TERRAIN_TUNDRA_HILLS"
          elseif ny < 0.28 then terrain = "TERRAIN_PLAINS_HILLS"
          else terrain = "TERRAIN_GRASS_HILLS" end
        elseif ny > 0.82 then terrain = "TERRAIN_SNOW"
        elseif ny > 0.70 then terrain = "TERRAIN_TUNDRA"
        elseif ny < 0.28 then terrain = "TERRAIN_PLAINS"
        elseif ny < 0.55 then terrain = "TERRAIN_GRASS"
        else terrain = "TERRAIN_PLAINS" end
        local row = GameInfo.Terrains[terrain]
        if row then TerrainBuilder.SetTerrainType(plot, row.Index) end
      end
    end
  end
end

local function EnrichAfricaResources()
  local wants = {
    "RESOURCE_OIL", "RESOURCE_NITER", "RESOURCE_ALUMINUM",
    "RESOURCE_IRON", "RESOURCE_COPPER", "RESOURCE_GOLD",
    "RESOURCE_SILVER", "RESOURCE_DIAMONDS", "RESOURCE_INCENSE",
    "RESOURCE_COTTON", "RESOURCE_WINE", "RESOURCE_SUGAR",
  }
  local indices = {}
  for _, name in ipairs(wants) do
    local row = GameInfo.Resources[name]
    if row then table.insert(indices, row.Index) end
  end
  if #indices == 0 then return end
  local placed = 0
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      if IsAfrica(x, y) then
        local plot = Map.GetPlot(x, y)
        if plot and not plot:IsWater() and not plot:IsMountain() and ((x * 17 + y * 31) % 4) == 0 then
          local res = indices[((x + y) % #indices) + 1]
          pcall(function()
            if plot:GetResourceType() < 0 then
              ResourceBuilder.SetResourceType(plot, res, 1)
              placed = placed + 1
            end
          end)
        end
      end
    end
  end
  print("[WW2 Europe] Africa resources: " .. tostring(placed))
end

local TSL = {
  CIVILIZATION_ENGLAND = { x = 23, y = 42 },
  CIVILIZATION_SCOTLAND = { x = 21, y = 48 },
  CIVILIZATION_FRANCE = { x = 31, y = 33 },
  CIVILIZATION_SPAIN = { x = 19, y = 24 },
  CIVILIZATION_PORTUGAL = { x = 13, y = 22 },
  CIVILIZATION_GERMANY = { x = 43, y = 39 },
  CIVILIZATION_POLAND = { x = 53, y = 40 },
  CIVILIZATION_HUNGARY = { x = 51, y = 33 },
  CIVILIZATION_RUSSIA = { x = 74, y = 46 },
  CIVILIZATION_ROME = { x = 43, y = 22 },
  CIVILIZATION_SERBIA = { x = 53, y = 28 },
  CIVILIZATION_STR_SERBIA = { x = 53, y = 28 },
  CIVILIZATION_WW2_YUGOSLAVIA = { x = 53, y = 28 },
  CIVILIZATION_GREECE = { x = 57, y = 18 },
  CIVILIZATION_NORWAY = { x = 39, y = 53 },
  CIVILIZATION_SWEDEN = { x = 47, y = 53 },
  CIVILIZATION_NETHERLANDS = { x = 35, y = 40 },
  CIVILIZATION_PHOENICIA = { x = 29, y = 7 },
  CIVILIZATION_EGYPT = { x = 63, y = 7 },
  CIVILIZATION_ETHIOPIA = { x = 68, y = 5 },
  CIVILIZATION_MALI = { x = 22, y = 6 },
}

local function IsPassableLand(plot)
  if not plot or plot:IsWater() or plot:IsImpassable() then return false end
  local terrain = GameInfo.Terrains[plot:GetTerrainType()]
  if terrain then
    local n = terrain.TerrainType
    if n == "TERRAIN_SNOW" or n == "TERRAIN_SNOW_HILLS" or n == "TERRAIN_SNOW_MOUNTAIN" then return false end
  end
  return true
end

local function FindNear(tx, ty)
  local best, bestD = nil, 99999
  for r = 0, 10 do
    for dy = -r, r do
      for dx = -r, r do
        local x, y = tx + dx, ty + dy
        if x >= 0 and y >= 0 and x < g_iW and y < g_iH then
          local p = Map.GetPlot(x, y)
          if IsPassableLand(p) then
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

function WW2_RepositionPriorityCivs()
  for i = 0, PlayerManager.GetWasEverAliveCount() - 1 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      local cfg = PlayerConfigurations[i]
      local civ = cfg and cfg:GetCivilizationTypeName()
      local tsl = civ and TSL[civ]
      if tsl then
        local target = FindNear(tsl.x, tsl.y)
        if target then
          for _, unit in p:GetUnits():Members() do
            unit:SetXY(target:GetX(), target:GetY())
          end
          print(string.format("[WW2 Europe] TSL %s -> %d,%d", civ, target:GetX(), target:GetY()))
        end
      end
    end
  end
end

function StartPlotSystem()
  pcall(function()
    AssignStartingPlots.Create({
      MIN_MAJOR_CIV_FERTILITY = 80,
      MIN_MINOR_CIV_FERTILITY = 20,
      MIN_BARBARIAN_FERTILITY = 1,
      START_MIN_Y = 8, START_MAX_Y = 8,
      IGNORE_LANDMASS = true,
      START_CONFIG = MapConfiguration.GetValue("start") or 2,
    })
  end)
  WW2_RepositionPriorityCivs()
end

function GenerateMap()
  print("[WW2 Europe] GenerateMap 106x66")
  local gridW, gridH = Map.GetGridSize()
  if gridW and gridH and gridW > 0 then
    g_iW, g_iH = gridW, gridH
  end

  local plotTypes = GeneratePlotTypes()
  GenerateTerrain()

  pcall(function() AreaBuilder.Recalculate() end)
  pcall(function() TerrainBuilder.AnalyzeChokepoints() end)
  pcall(function() TerrainBuilder.StampContinents() end)

  pcall(function()
    FeatureGenerator.Create({ rainfall = MapConfiguration.GetValue("rainfall") or 2 }):AddFeatures()
  end)
  pcall(function() NaturalWonderGenerator.Create({ numberToPlace = 4 }) end)
  pcall(function() AreaBuilder.Recalculate() end)
  pcall(function() ResourceGenerator.Create({ resources = MapConfiguration.GetValue("resources") or 2 }) end)
  EnrichAfricaResources()
  StartPlotSystem()
  pcall(function() AddGoodies(g_iW, g_iH) end)
  print("[WW2 Europe] map done")
end
