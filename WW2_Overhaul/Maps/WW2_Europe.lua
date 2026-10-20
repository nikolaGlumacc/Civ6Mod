------------------------------------------------------------------------------
-- WW2 Overhaul — Realistic Europe map
-- Geographic landmask (not random continents): Iberia, Britain, France,
-- Germany, Poland, Scandinavia, Italy, Balkans, Anatolia fringe, European Russia.
-- Seas: Atlantic, Med, North Sea, Baltic, Black Sea, Adriatic.
-- Ranges: Pyrenees, Alps, Carpathians, Balkans, Caucasus fringe.
-- Grid ~ lon -10°..55° E, lat 34°..71° N  →  108 x 72, no wrap.
------------------------------------------------------------------------------
include("MapEnums")
include("MapUtilities")
include("MountainsCliffs")
include("RiversLakes")
include("FeatureGenerator")
include("TerrainGenerator")
include("NaturalWonderGenerator")
include("ResourceGenerator")
include("AssignStartingPlots")

local g_iW, g_iH = 108, 72
local g_iFlags = {}

------------------------------------------------------------------------------
function GetMapInitData(MapSize)
  return { Width = g_iW, Height = g_iH, WrapX = false, WrapY = false }
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

------------------------------------------------------------------------------
-- Normalized coords: nx 0..1 west→east, ny 0..1 south→north
local function N(x, y)
  return x / (g_iW - 1), y / (g_iH - 1)
end

-- Ellipse helper (center cx,cy radius rx,ry in normalized space)
local function InEllipse(nx, ny, cx, cy, rx, ry)
  local dx = (nx - cx) / rx
  local dy = (ny - cy) / ry
  return dx * dx + dy * dy <= 1.0
end

-- Axis-aligned box
local function InBox(nx, ny, x0, y0, x1, y1)
  return nx >= x0 and nx <= x1 and ny >= y0 and ny <= y1
end

------------------------------------------------------------------------------
-- Geographic land test (hand-tuned Europe silhouette)
local function IsEuropeLand(x, y)
  local nx, ny = N(x, y)

  -- Hard outer ocean frame
  if nx < 0.015 or nx > 0.985 or ny < 0.02 or ny > 0.98 then
    return false
  end

  local land = false

  -- Iberian Peninsula (Spain/Portugal)
  if InEllipse(nx, ny, 0.18, 0.32, 0.12, 0.14) then land = true end
  -- France + Benelux + western Germany
  if InEllipse(nx, ny, 0.30, 0.48, 0.14, 0.18) then land = true end
  -- British Isles
  if InEllipse(nx, ny, 0.22, 0.62, 0.07, 0.12) then land = true end -- Britain
  if InEllipse(nx, ny, 0.16, 0.60, 0.035, 0.07) then land = true end -- Ireland
  -- Central Europe (Germany, Poland, Czech, Hungary plain)
  if InEllipse(nx, ny, 0.45, 0.52, 0.16, 0.16) then land = true end
  -- Scandinavia (Norway/Sweden elongated north)
  if InEllipse(nx, ny, 0.42, 0.78, 0.10, 0.18) then land = true end
  -- Finland
  if InEllipse(nx, ny, 0.55, 0.82, 0.07, 0.10) then land = true end
  -- Italy boot
  if InEllipse(nx, ny, 0.42, 0.30, 0.05, 0.14) then land = true end
  if InEllipse(nx, ny, 0.44, 0.22, 0.035, 0.06) then land = true end -- southern tip / Sicily approach
  -- Sicily
  if InEllipse(nx, ny, 0.44, 0.16, 0.03, 0.025) then land = true end
  -- Balkans (Yugoslavia, Greece north)
  if InEllipse(nx, ny, 0.52, 0.36, 0.10, 0.12) then land = true end
  -- Greece peninsula
  if InEllipse(nx, ny, 0.54, 0.24, 0.05, 0.08) then land = true end
  -- Anatolia (western Turkey) — WW2 edge
  if InEllipse(nx, ny, 0.68, 0.28, 0.12, 0.08) then land = true end
  -- European Russia / Ukraine / Belarus broad plain
  if InEllipse(nx, ny, 0.72, 0.58, 0.22, 0.22) then land = true end
  -- Caucasus fringe / Black Sea east shore
  if InEllipse(nx, ny, 0.82, 0.38, 0.08, 0.08) then land = true end
  -- North Africa fringe (Maghreb coast only — for Med theatre)
  if InEllipse(nx, ny, 0.28, 0.08, 0.20, 0.05) then land = true end
  if InEllipse(nx, ny, 0.50, 0.07, 0.12, 0.04) then land = true end -- Libya coast
  -- Denmark / Jutland bridge
  if InEllipse(nx, ny, 0.40, 0.64, 0.04, 0.05) then land = true end
  -- Baltic states strip
  if InEllipse(nx, ny, 0.58, 0.68, 0.08, 0.06) then land = true end

  -- ---- SEAS (cut water out of land ellipses) ----
  -- Mediterranean basin
  if InBox(nx, ny, 0.20, 0.12, 0.72, 0.28) and not InEllipse(nx, ny, 0.42, 0.30, 0.05, 0.14)
     and not InEllipse(nx, ny, 0.54, 0.24, 0.05, 0.08)
     and not InEllipse(nx, ny, 0.18, 0.32, 0.12, 0.14)
     and not InEllipse(nx, ny, 0.52, 0.36, 0.10, 0.12)
     and not InEllipse(nx, ny, 0.68, 0.28, 0.12, 0.08)
     and not InEllipse(nx, ny, 0.44, 0.16, 0.03, 0.025) then
    -- keep only if clearly open Med (lower half of the box more aggressive)
    if ny < 0.26 then land = false end
  end

  -- Adriatic (between Italy and Balkans)
  if InBox(nx, ny, 0.44, 0.28, 0.52, 0.42) and nx > 0.46 and nx < 0.50 then
    land = false
  end

  -- North Sea
  if InBox(nx, ny, 0.26, 0.55, 0.40, 0.72) and not InEllipse(nx, ny, 0.22, 0.62, 0.07, 0.12)
     and not InEllipse(nx, ny, 0.30, 0.48, 0.14, 0.18)
     and not InEllipse(nx, ny, 0.40, 0.64, 0.04, 0.05) then
    if nx > 0.28 and nx < 0.38 and ny > 0.58 then land = false end
  end

  -- Baltic Sea
  if InBox(nx, ny, 0.42, 0.62, 0.58, 0.78) and not InEllipse(nx, ny, 0.42, 0.78, 0.10, 0.18)
     and not InEllipse(nx, ny, 0.55, 0.82, 0.07, 0.10)
     and not InEllipse(nx, ny, 0.58, 0.68, 0.08, 0.06)
     and not InEllipse(nx, ny, 0.45, 0.52, 0.16, 0.16) then
    if ny > 0.66 and nx > 0.44 and nx < 0.56 then land = false end
  end

  -- Black Sea
  if InEllipse(nx, ny, 0.68, 0.40, 0.10, 0.07) then land = false end

  -- English Channel
  if InBox(nx, ny, 0.24, 0.52, 0.30, 0.58) then land = false end

  -- Bay of Biscay
  if InBox(nx, ny, 0.12, 0.38, 0.22, 0.50) and nx < 0.18 then land = false end

  -- Caspian fringe (far east edge — keep mostly out)
  if nx > 0.92 and ny < 0.50 then land = false end

  return land
end

------------------------------------------------------------------------------
-- Mountain belts (normalized)
local function IsMountain(x, y)
  local nx, ny = N(x, y)
  -- Pyrenees
  if InEllipse(nx, ny, 0.22, 0.38, 0.08, 0.025) then return true end
  -- Alps
  if InEllipse(nx, ny, 0.38, 0.40, 0.10, 0.04) then return true end
  -- Carpathians
  if InEllipse(nx, ny, 0.55, 0.46, 0.08, 0.05) then return true end
  -- Dinaric / Balkan mountains
  if InEllipse(nx, ny, 0.50, 0.34, 0.06, 0.06) then return true end
  -- Caucasus
  if InEllipse(nx, ny, 0.84, 0.36, 0.08, 0.03) then return true end
  -- Norwegian mountains
  if InEllipse(nx, ny, 0.38, 0.78, 0.04, 0.14) then return true end
  -- Apennines
  if InEllipse(nx, ny, 0.42, 0.28, 0.02, 0.10) then return true end
  return false
end

local function IsHills(x, y)
  local nx, ny = N(x, y)
  if InEllipse(nx, ny, 0.30, 0.42, 0.08, 0.06) then return true end -- Massif Central / east France
  if InEllipse(nx, ny, 0.48, 0.50, 0.06, 0.05) then return true end -- Bohemia
  if InEllipse(nx, ny, 0.20, 0.30, 0.06, 0.05) then return true end -- Spanish interior
  if InEllipse(nx, ny, 0.54, 0.30, 0.05, 0.05) then return true end -- Greek hills
  return false
end

------------------------------------------------------------------------------
function GeneratePlotTypes()
  print("WW2 Realistic Europe: GeneratePlotTypes")
  local plotTypes = {}
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local i = y * g_iW + x
      if not IsEuropeLand(x, y) then
        plotTypes[i] = g_PLOT_TYPE_OCEAN
      elseif IsMountain(x, y) then
        plotTypes[i] = g_PLOT_TYPE_MOUNTAIN
      elseif IsHills(x, y) then
        plotTypes[i] = g_PLOT_TYPE_HILLS
      else
        plotTypes[i] = g_PLOT_TYPE_LAND
      end
    end
  end
  AreaBuilder.Recalculate()
  TerrainBuilder.ClearLandmarks()
  return plotTypes
end

------------------------------------------------------------------------------
function GenerateTerrain()
  print("WW2 Realistic Europe: GenerateTerrain")
  -- Latitude-based climate: south warm, north cold, Atlantic milder west
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local plot = Map.GetPlot(x, y)
      if plot and not plot:IsWater() then
        local nx, ny = N(x, y)
        local isHill = plot:IsHills()
        local isMtn = plot:IsMountain()
        local terrain

        if isMtn then
          if ny > 0.55 then
            terrain = isHill and "TERRAIN_TUNDRA_MOUNTAIN" or "TERRAIN_TUNDRA_MOUNTAIN"
          else
            terrain = "TERRAIN_GRASS_MOUNTAIN"
          end
        elseif ny > 0.82 then
          -- Far north Scandinavia / Arctic
          terrain = isHill and "TERRAIN_SNOW_HILLS" or "TERRAIN_SNOW"
        elseif ny > 0.70 then
          terrain = isHill and "TERRAIN_TUNDRA_HILLS" or "TERRAIN_TUNDRA"
        elseif ny < 0.18 and nx > 0.15 and nx < 0.75 then
          -- North Africa fringe + deep south Spain
          terrain = isHill and "TERRAIN_DESERT_HILLS" or "TERRAIN_DESERT"
        elseif ny < 0.28 then
          -- Mediterranean belt — plains / some desert inland Iberia
          if nx < 0.28 and ny < 0.30 then
            terrain = isHill and "TERRAIN_PLAINS_HILLS" or "TERRAIN_PLAINS"
          else
            terrain = isHill and "TERRAIN_GRASS_HILLS" or "TERRAIN_GRASS"
          end
        elseif ny < 0.55 then
          -- Temperate Europe core
          terrain = isHill and "TERRAIN_GRASS_HILLS" or "TERRAIN_GRASS"
        else
          -- Northern plains / mixed
          terrain = isHill and "TERRAIN_PLAINS_HILLS" or "TERRAIN_PLAINS"
        end

        local row = GameInfo.Terrains[terrain]
        if row then
          TerrainBuilder.SetTerrainType(plot, row.Index)
        end
      end
    end
  end
end

------------------------------------------------------------------------------
-- Historical TSL on this grid (tuned to landmask centers)
local TSL = {
  CIVILIZATION_ENGLAND      = { x = 24, y = 44 }, -- London area
  CIVILIZATION_SCOTLAND     = { x = 22, y = 50 },
  CIVILIZATION_FRANCE       = { x = 32, y = 34 }, -- Paris
  CIVILIZATION_SPAIN        = { x = 20, y = 24 }, -- Madrid
  CIVILIZATION_PORTUGAL     = { x = 14, y = 22 },
  CIVILIZATION_GERMANY      = { x = 44, y = 40 }, -- Berlin
  CIVILIZATION_POLAND       = { x = 54, y = 42 }, -- Warsaw
  CIVILIZATION_HUNGARY      = { x = 52, y = 34 }, -- Budapest
  CIVILIZATION_RUSSIA       = { x = 78, y = 48 }, -- Moscow area
  CIVILIZATION_ROME         = { x = 44, y = 22 }, -- Rome / Italy
  CIVILIZATION_SERBIA       = { x = 54, y = 28 }, -- Belgrade
  CIVILIZATION_WW2_YUGOSLAVIA = { x = 54, y = 28 },
  CIVILIZATION_GREECE       = { x = 58, y = 18 }, -- Athens
  CIVILIZATION_OTTOMAN      = { x = 70, y = 22 }, -- Anatolia / Istanbul approach
  CIVILIZATION_BYZANTIUM    = { x = 66, y = 24 },
  CIVILIZATION_NORWAY       = { x = 40, y = 56 },
  CIVILIZATION_SWEDEN       = { x = 48, y = 56 },
  CIVILIZATION_NETHERLANDS  = { x = 36, y = 42 },
  CIVILIZATION_PHOENICIA    = { x = 30, y = 8 },  -- North Africa fringe
}

local function IsPassableLand(plot)
  if plot == nil then return false end
  if plot:IsWater() or plot:IsImpassable() then return false end
  local t = plot:GetTerrainType()
  local terrain = GameInfo.Terrains[t]
  if terrain then
    local n = terrain.TerrainType
    if n == "TERRAIN_SNOW" or n == "TERRAIN_SNOW_HILLS" or n == "TERRAIN_SNOW_MOUNTAIN" then
      return false
    end
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
          print(string.format("[WW2 Europe] TSL %s → %d,%d", civ, target:GetX(), target:GetY()))
        end
      end
    end
  end
end

------------------------------------------------------------------------------
function StartPlotSystem()
  print("WW2 Realistic Europe: StartPlotSystem")
  local args = {
    MIN_MAJOR_CIV_FERTILITY = 80,
    MIN_MINOR_CIV_FERTILITY = 20,
    MIN_BARBARIAN_FERTILITY = 1,
    START_MIN_Y = 8,
    START_MAX_Y = 8,
    IGNORE_LANDMASS = true,
    START_CONFIG = MapConfiguration.GetValue("start") or 2,
  }
  AssignStartingPlots.Create(args)
  WW2_RepositionPriorityCivs()
end

------------------------------------------------------------------------------
function GenerateMap()
  print("Generating WW2 Realistic Europe")
  local gridW, gridH = Map.GetGridSize()
  g_iW, g_iH = gridW, gridH
  g_iFlags = TerrainBuilder.GetFractalFlags()

  GeneratePlotTypes()
  GenerateTerrain()

  AreaBuilder.Recalculate()
  TerrainBuilder.AnalyzeChokepoints()
  TerrainBuilder.StampContinents()

  -- Light extra hills noise only (mountains already placed)
  local args = {
    iW = g_iW, iH = g_iH, iFlags = g_iFlags,
    blendRidge = 5, blendFract = 5, extra = 4,
  }
  pcall(function() MountainsCliffs.AddMountains(args) end)

  local featuregen = FeatureGenerator.Create({ rainfall = MapConfiguration.GetValue("rainfall") or 2 })
  featuregen:AddFeatures()

  pcall(function()
    NaturalWonderGenerator.Create({ numberToPlace = 5 })
  end)

  AreaBuilder.Recalculate()
  TerrainBuilder.AnalyzeChokepoints()

  ResourceGenerator.Create({ resources = MapConfiguration.GetValue("resources") or 2 })

  StartPlotSystem()
  AddGoodies(g_iW, g_iH)
  print("WW2 Realistic Europe map done")
end
