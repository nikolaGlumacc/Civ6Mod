------------------------------------------------------------------------------
-- WW2 Overhaul — Europe map script
-- Regional (non-wrapping) Europe-shaped theatre: Atlantic west, Urals east,
-- Mediterranean south, Scandinavia north. Designed for WW2 ruleset play.
------------------------------------------------------------------------------
include("MapEnums")
include("MapUtilities")
include("MountainsCliffs")
include("RiversLakes")
include("FeatureGenerator")
include("TerrainGenerator")
include("NaturalWonderGenerator")
include("ResourceGenerator")
include("CoastalLowlands")
include("AssignStartingPlots")

local g_iW, g_iH
local g_iFlags = {}
local g_continentsFrac = nil

------------------------------------------------------------------------------
function GetMapInitData(MapSize)
  -- Fixed Europe theatre size (between Large and Huge)
  -- No X/Y wrap — ocean edges, not a full planet
  return {
    Width = 96,
    Height = 68,
    WrapX = false,
    WrapY = false,
  }
end

------------------------------------------------------------------------------
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

------------------------------------------------------------------------------
function GeneratePlotTypes(args)
  print("WW2 Europe: GeneratePlotTypes")
  local plotTypes = {}
  local grain = 3
  local hillsGrain = 4

  math.randomseed(Map.GetRandomSeed())

  -- Fractal for one primary landmass (Europe body)
  local fracFlags = { FRAC_POLAR = false }
  local continents = Fractal.Create(g_iW, g_iH, grain, fracFlags, -1, -1)
  local hills = Fractal.Create(g_iW, g_iH, hillsGrain, fracFlags, -1, -1)

  local iWaterThreshold = continents:GetHeight(58) -- ~42% land
  local iHillsThreshold = hills:GetHeight(70)

  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local i = y * g_iW + x
      local val = continents:GetHeight(x, y)
      local hx = x / math.max(g_iW - 1, 1)
      local hy = y / math.max(g_iH - 1, 1)

      -- Mask: force ocean on far edges (Atlantic / Arctic / desert south / deep east)
      local edgeOcean = (hx < 0.04) or (hx > 0.96) or (hy < 0.05) or (hy > 0.94)

      -- Mediterranean bite: southern band more water in the center-west
      local medBite = (hy < 0.28) and (hx > 0.15) and (hx < 0.75) and (val < continents:GetHeight(50))

      -- Baltic / North Sea cuts
      local northCut = (hy > 0.70) and (hx > 0.35) and (hx < 0.55) and (val < continents:GetHeight(52))

      if edgeOcean or medBite or northCut or val < iWaterThreshold then
        plotTypes[i] = g_PLOT_TYPE_OCEAN
      else
        if hills:GetHeight(x, y) >= iHillsThreshold then
          plotTypes[i] = g_PLOT_TYPE_HILLS
        else
          plotTypes[i] = g_PLOT_TYPE_LAND
        end
      end
    end
  end

  AreaBuilder.Recalculate()
  TerrainBuilder.ClearLandmarks()
  return plotTypes
end

------------------------------------------------------------------------------
function GenerateTerrain()
  print("WW2 Europe: GenerateTerrain")
  local terraArgs = {
    iW = g_iW,
    iH = g_iH,
    iFlags = g_iFlags,
    blendRidge = 5,
    blendFract = 5,
    temperature = MapConfiguration.GetValue("temperature") or 2,
  }
  local terrainTypes = TerrainGenerator.GenerateTerrainTypes(terraArgs)
  TerrainGenerator.ApplyTerrainTypes(terrainTypes)
end

------------------------------------------------------------------------------
function FeatureGenerator:AddFeatures()
  print("WW2 Europe: Features")
  local args = {
    rainfall = MapConfiguration.GetValue("rainfall") or 2
  }
  self:AddFeaturesFromArgs(args)
end

------------------------------------------------------------------------------
function StartPlotSystem()
  print("WW2 Europe: StartPlotSystem")
  local args = {}
  args.MIN_MAJOR_CIV_FERTILITY = 100
  args.MIN_MINOR_CIV_FERTILITY = 25
  args.MIN_BARBARIAN_FERTILITY = 1
  args.START_MIN_Y = 12
  args.START_MAX_Y = 12
  args.WATER = false
  args.LAND = false
  args.IGNORE_LANDMASS = true -- single theatre — pack civs on the Europe landmass

  local startConfig = MapConfiguration.GetValue("start") or 2
  args.START_CONFIG = startConfig

  local start_plot_database = AssignStartingPlots.Create(args)

  -- Prefer mid-latitude land for everyone (no Antarctica)
  -- AssignStartingPlots already ran; we do a soft pass for priority WW2 civs if they landed poorly.
  WW2_RepositionPriorityCivs()
end

------------------------------------------------------------------------------
-- Approximate TSL on our generated grid (x,y normalized to 96x68)
-- West = Atlantic, East = Russia, South = Med, North = Scandinavia
local TSL = {
  CIVILIZATION_ENGLAND   = { x = 22, y = 48 },
  CIVILIZATION_FRANCE    = { x = 30, y = 40 },
  CIVILIZATION_SPAIN     = { x = 24, y = 28 },
  CIVILIZATION_GERMANY   = { x = 42, y = 48 },
  CIVILIZATION_POLAND    = { x = 50, y = 48 },
  CIVILIZATION_HUNGARY   = { x = 50, y = 40 },
  CIVILIZATION_RUSSIA    = { x = 72, y = 50 },
  CIVILIZATION_ROME      = { x = 42, y = 32 }, -- Italy stand-in
  CIVILIZATION_SERBIA    = { x = 52, y = 36 },
  CIVILIZATION_WW2_YUGOSLAVIA = { x = 52, y = 36 },
  CIVILIZATION_GREECE    = { x = 54, y = 26 },
  CIVILIZATION_OTTOMAN   = { x = 60, y = 28 },
  CIVILIZATION_NORWAY    = { x = 40, y = 58 },
  CIVILIZATION_SWEDEN    = { x = 48, y = 58 },
  CIVILIZATION_NETHERLANDS = { x = 36, y = 50 },
  CIVILIZATION_SCOTLAND  = { x = 22, y = 54 },
  CIVILIZATION_PORTUGAL  = { x = 18, y = 28 },
  CIVILIZATION_BYZANTIUM = { x = 58, y = 30 },
}

local function IsPassableLand(plot)
  if plot == nil then return false end
  if plot:IsWater() or plot:IsImpassable() then return false end
  local t = plot:GetTerrainType()
  local terrain = GameInfo.Terrains[t]
  if terrain and (terrain.TerrainType == "TERRAIN_SNOW" or terrain.TerrainType == "TERRAIN_SNOW_HILLS") then
    return false
  end
  return true
end

local function FindNear(tx, ty)
  local best, bestD = nil, 99999
  for r = 0, 8 do
    for dy = -r, r do
      for dx = -r, r do
        local x, y = tx + dx, ty + dy
        if x >= 0 and y >= 0 and x < g_iW and y < g_iH then
          local p = Map.GetPlot(x, y)
          if IsPassableLand(p) then
            local d = dx * dx + dy * dy
            if d < bestD then
              bestD = d
              best = p
            end
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
          print(string.format("[WW2 Europe] TSL place %s at %d,%d", civ, target:GetX(), target:GetY()))
        end
      end
    end
  end
end

------------------------------------------------------------------------------
function GenerateMap()
  print("Generating WW2 Europe Map")
  local gridW, gridH = Map.GetGridSize()
  g_iW, g_iH = gridW, gridH
  g_iFlags = TerrainBuilder.GetFractalFlags()

  plotTypes = GeneratePlotTypes()
  terrainTypes = GenerateTerrain()

  AreaBuilder.Recalculate()
  TerrainBuilder.AnalyzeChokepoints()
  TerrainBuilder.StampContinents()

  local iW, iH = Map.GetGridSize()
  local args = {}
  args.world_age = MapConfiguration.GetValue("world_age") or 2
  if args.world_age == 1 then
    args.world_age = 3
  elseif args.world_age == 3 then
    args.world_age = 1
  end
  mountainRatio = 8 + args.world_age * 2
  args.iW = iW
  args.iH = iH
  args.iFlags = g_iFlags
  args.blendRidge = 10
  args.blendFract = 5
  args.extra = mountainRatio
  MountainsCliffs.AddMountains(args)

  local featuregen = FeatureGenerator.Create({ rainfall = MapConfiguration.GetValue("rainfall") or 2 })
  featuregen:AddFeatures()

  local nwGen = NaturalWonderGenerator.Create({ numberToPlace = 4 })
  AreaBuilder.Recalculate()
  TerrainBuilder.AnalyzeChokepoints()

  resourcesConfig = MapConfiguration.GetValue("resources") or 2
  local resGen = ResourceGenerator.Create({ resources = resourcesConfig })

  print("WW2 Europe: assigning starts")
  StartPlotSystem()

  local goodyGen = AddGoodies(g_iW, g_iH)
  print("WW2 Europe map done")
end
