------------------------------------------------------------------------------
-- WW2 Europe 96x60 — built from separate regions (NOT one big rectangle).
-- y=0 south (Africa), y=max north (Scandinavia). x=0 west (Atlantic).
------------------------------------------------------------------------------
include("MapEnums")
include("MapUtilities")
include("FeatureGenerator")
include("TerrainGenerator")
include("ResourceGenerator")
include("AssignStartingPlots")

local g_iW, g_iH = 96, 60

function GetMapInitData(MapSize)
  return { Width = 96, Height = 60, WrapX = false, WrapY = false }
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

local function NX(x) return x / math.max(g_iW - 1, 1) end
local function NY(y) return y / math.max(g_iH - 1, 1) end

local function Ell(nx, ny, cx, cy, rx, ry)
  local dx = (nx - cx) / rx
  local dy = (ny - cy) / ry
  return dx * dx + dy * dy <= 1.0
end

-- Only ADD land pieces. Default is ocean. No giant fill-rect.
local function IsLand(x, y)
  local nx, ny = NX(x), NY(y)

  -- Iberian Peninsula (Spain/Portugal)
  if Ell(nx, ny, 0.16, 0.32, 0.11, 0.12) then return true end

  -- France / Low Countries / west Germany body
  if Ell(nx, ny, 0.30, 0.48, 0.12, 0.14) then return true end

  -- Britain
  if Ell(nx, ny, 0.22, 0.62, 0.065, 0.11) then return true end
  -- Ireland
  if Ell(nx, ny, 0.15, 0.60, 0.035, 0.06) then return true end

  -- Central Europe (Germany, Poland, Czech, Austria, Hungary)
  if Ell(nx, ny, 0.46, 0.52, 0.14, 0.12) then return true end

  -- Italy boot
  if Ell(nx, ny, 0.40, 0.36, 0.045, 0.13) then return true end
  if Ell(nx, ny, 0.42, 0.24, 0.035, 0.055) then return true end
  if Ell(nx, ny, 0.43, 0.17, 0.03, 0.025) then return true end -- Sicily

  -- Balkans + Greece
  if Ell(nx, ny, 0.52, 0.38, 0.09, 0.11) then return true end
  if Ell(nx, ny, 0.54, 0.26, 0.05, 0.07) then return true end

  -- Scandinavia
  if Ell(nx, ny, 0.42, 0.80, 0.09, 0.14) then return true end -- Norway/Sweden west
  if Ell(nx, ny, 0.52, 0.82, 0.07, 0.10) then return true end -- Sweden/Finland
  if Ell(nx, ny, 0.38, 0.68, 0.04, 0.05) then return true end -- Denmark

  -- Baltics / Belarus bridge
  if Ell(nx, ny, 0.56, 0.64, 0.08, 0.07) then return true end

  -- European Russia
  if Ell(nx, ny, 0.72, 0.58, 0.16, 0.16) then return true end
  if Ell(nx, ny, 0.78, 0.70, 0.12, 0.10) then return true end

  -- Ukraine / south Russia steppe
  if Ell(nx, ny, 0.64, 0.48, 0.10, 0.08) then return true end

  -- North Africa strip (south of Med) — thin
  if Ell(nx, ny, 0.20, 0.09, 0.12, 0.045) then return true end -- Morocco/Algeria
  if Ell(nx, ny, 0.38, 0.08, 0.12, 0.04) then return true end  -- Tunisia/Libya
  if Ell(nx, ny, 0.56, 0.09, 0.10, 0.04) then return true end  -- Egypt

  return false
end

local function IsMountain(x, y)
  local nx, ny = NX(x), NY(y)
  if Ell(nx, ny, 0.18, 0.38, 0.07, 0.025) then return true end -- Pyrenees
  if Ell(nx, ny, 0.36, 0.44, 0.09, 0.035) then return true end -- Alps
  if Ell(nx, ny, 0.52, 0.48, 0.07, 0.04) then return true end  -- Carpathians
  if Ell(nx, ny, 0.50, 0.34, 0.05, 0.05) then return true end  -- Dinaric
  if Ell(nx, ny, 0.40, 0.78, 0.035, 0.11) then return true end -- Scandes
  if Ell(nx, ny, 0.40, 0.30, 0.02, 0.10) then return true end  -- Apennines
  return false
end

local function IsHills(x, y)
  if NY(y) < 0.14 then return false end
  local nx, ny = NX(x), NY(y)
  if Ell(nx, ny, 0.28, 0.46, 0.07, 0.05) then return true end
  if Ell(nx, ny, 0.48, 0.50, 0.06, 0.04) then return true end
  if Ell(nx, ny, 0.16, 0.32, 0.05, 0.04) then return true end
  if Ell(nx, ny, 0.54, 0.30, 0.04, 0.04) then return true end
  return false
end

function GeneratePlotTypes()
  print("[WW2 Europe] GeneratePlotTypes — region silhouette")
  local plotTypes = {}
  local O = g_PLOT_TYPE_OCEAN or 3
  local L = g_PLOT_TYPE_LAND or 1
  local H = g_PLOT_TYPE_HILLS or 2
  local M = g_PLOT_TYPE_MOUNTAIN or 0

  for i = 0, (g_iW * g_iH) - 1 do plotTypes[i] = O end

  local landCount = 0
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      if IsLand(x, y) then
        local i = y * g_iW + x
        if IsMountain(x, y) then plotTypes[i] = M
        elseif IsHills(x, y) then plotTypes[i] = H
        else plotTypes[i] = L end
        landCount = landCount + 1
      end
    end
  end
  print("[WW2 Europe] land tiles: " .. tostring(landCount))
  return plotTypes
end

function GenerateTerrain()
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local plot = Map.GetPlot(x, y)
      if plot and not plot:IsWater() then
        local ny = NY(y)
        local name
        if ny < 0.14 then
          name = ((x + y) % 4 == 0) and "TERRAIN_PLAINS" or "TERRAIN_DESERT"
        elseif plot:IsMountain() then
          name = ny > 0.6 and "TERRAIN_TUNDRA_MOUNTAIN" or "TERRAIN_GRASS_MOUNTAIN"
        elseif plot:IsHills() then
          if ny > 0.72 then name = "TERRAIN_TUNDRA_HILLS"
          elseif ny < 0.30 then name = "TERRAIN_PLAINS_HILLS"
          else name = "TERRAIN_GRASS_HILLS" end
        elseif ny > 0.84 then name = "TERRAIN_SNOW"
        elseif ny > 0.74 then name = "TERRAIN_TUNDRA"
        elseif ny < 0.30 then name = "TERRAIN_PLAINS"
        elseif ny < 0.58 then name = "TERRAIN_GRASS"
        else name = "TERRAIN_PLAINS" end
        local row = GameInfo.Terrains[name]
        if row then TerrainBuilder.SetTerrainType(plot, row.Index) end
      end
    end
  end
end

local function EnrichAfrica()
  local names = { "RESOURCE_OIL","RESOURCE_NITER","RESOURCE_IRON","RESOURCE_GOLD",
    "RESOURCE_ALUMINUM","RESOURCE_COPPER","RESOURCE_INCENSE","RESOURCE_COTTON" }
  local idx = {}
  for _, n in ipairs(names) do
    local r = GameInfo.Resources[n]
    if r then table.insert(idx, r.Index) end
  end
  if #idx == 0 then return end
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      if NY(y) < 0.14 then
        local plot = Map.GetPlot(x, y)
        if plot and not plot:IsWater() and not plot:IsMountain() and ((x * 13 + y * 7) % 5) == 0 then
          pcall(function()
            if plot:GetResourceType() < 0 then
              ResourceBuilder.SetResourceType(plot, idx[((x + y) % #idx) + 1], 1)
            end
          end)
        end
      end
    end
  end
end

function GenerateMap()
  print("[WW2 Europe] GenerateMap v2.8")
  local gw, gh = Map.GetGridSize()
  if gw and gh and gw > 0 then g_iW, g_iH = gw, gh end

  local plotTypes = GeneratePlotTypes()

  -- Paint ocean explicitly
  local oceanRow = GameInfo.Terrains["TERRAIN_OCEAN"]
  local coastRow = GameInfo.Terrains["TERRAIN_COAST"]
  local O = g_PLOT_TYPE_OCEAN or 3
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local plot = Map.GetPlot(x, y)
      local i = y * g_iW + x
      if plot and plotTypes[i] == O and oceanRow then
        TerrainBuilder.SetTerrainType(plot, oceanRow.Index)
      end
    end
  end

  pcall(function() AreaBuilder.Recalculate() end)
  GenerateTerrain()

  -- Coast ring for readable outline
  if coastRow then
    for y = 0, g_iH - 1 do
      for x = 0, g_iW - 1 do
        local plot = Map.GetPlot(x, y)
        if plot and plot:IsWater() then
          local near = false
          for dy = -1, 1 do
            for dx = -1, 1 do
              local n = Map.GetPlot(x + dx, y + dy)
              if n and not n:IsWater() then near = true end
            end
          end
          if near then TerrainBuilder.SetTerrainType(plot, coastRow.Index) end
        end
      end
    end
  end

  pcall(function() AreaBuilder.Recalculate() end)
  pcall(function() TerrainBuilder.AnalyzeChokepoints() end)
  pcall(function() TerrainBuilder.StampContinents() end)

  pcall(function()
    local fg = FeatureGenerator.Create({ rainfall = MapConfiguration.GetValue("rainfall") or 2 })
    if fg and fg.AddFeatures then fg:AddFeatures() end
  end)

  -- NO natural wonders (removes wonder discover popups at start)
  -- NaturalWonderGenerator intentionally skipped

  pcall(function() AreaBuilder.Recalculate() end)
  pcall(function()
    ResourceGenerator.Create({ resources = MapConfiguration.GetValue("resources") or 2 })
  end)
  EnrichAfrica()

  pcall(function()
    AssignStartingPlots.Create({
      MIN_MAJOR_CIV_FERTILITY = 50,
      MIN_MINOR_CIV_FERTILITY = 10,
      MIN_BARBARIAN_FERTILITY = 1,
      START_MIN_Y = 4, START_MAX_Y = 4,
      IGNORE_LANDMASS = true,
      START_CONFIG = MapConfiguration.GetValue("start") or 2,
    })
  end)

  pcall(function() AddGoodies(g_iW, g_iH) end)
  print("[WW2 Europe] map done (no natural wonders)")
end
