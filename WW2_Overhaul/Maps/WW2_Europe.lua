------------------------------------------------------------------------------
-- WW2 Europe — 96x60 HUGE
-- Clearer Europe silhouette + North Africa. No wrap.
------------------------------------------------------------------------------
include("MapEnums")
include("MapUtilities")
include("FeatureGenerator")
include("TerrainGenerator")
include("NaturalWonderGenerator")
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

local function N(x, y)
  return x / math.max(g_iW - 1, 1), y / math.max(g_iH - 1, 1)
end

local function Ellipse(nx, ny, cx, cy, rx, ry)
  local dx = (nx - cx) / rx
  local dy = (ny - cy) / ry
  return dx * dx + dy * dy <= 1.0
end

local function Box(nx, ny, x0, y0, x1, y1)
  return nx >= x0 and nx <= x1 and ny >= y0 and ny <= y1
end

-- Solid continental Europe: wide body + peninsulas + islands + Maghreb
local function IsLand(x, y)
  local nx, ny = N(x, y)
  if nx < 0.02 or nx > 0.98 or ny < 0.02 or ny > 0.98 then return false end

  local land = false

  -- Main European plain (France → Poland → west Russia)
  if Box(nx, ny, 0.14, 0.28, 0.82, 0.72) then land = true end

  -- Iberia
  if Ellipse(nx, ny, 0.17, 0.34, 0.13, 0.15) then land = true end
  -- Britain
  if Ellipse(nx, ny, 0.22, 0.64, 0.08, 0.13) then land = true end
  -- Ireland
  if Ellipse(nx, ny, 0.15, 0.62, 0.04, 0.07) then land = true end
  -- Scandinavia
  if Ellipse(nx, ny, 0.42, 0.82, 0.11, 0.16) then land = true end
  if Ellipse(nx, ny, 0.54, 0.84, 0.08, 0.11) then land = true end
  -- Italy
  if Ellipse(nx, ny, 0.42, 0.34, 0.055, 0.16) then land = true end
  if Ellipse(nx, ny, 0.44, 0.22, 0.04, 0.07) then land = true end
  if Ellipse(nx, ny, 0.44, 0.16, 0.03, 0.03) then land = true end -- Sicily-ish
  -- Balkans / Greece
  if Ellipse(nx, ny, 0.52, 0.36, 0.11, 0.14) then land = true end
  if Ellipse(nx, ny, 0.54, 0.24, 0.06, 0.09) then land = true end
  -- East / Russia extension
  if Ellipse(nx, ny, 0.78, 0.58, 0.18, 0.20) then land = true end
  -- Denmark / low countries already in main box

  -- North Africa (Maghreb + Libya + Egypt strip) — resource-rich, weak
  if Ellipse(nx, ny, 0.22, 0.10, 0.16, 0.06) then land = true end
  if Ellipse(nx, ny, 0.42, 0.09, 0.14, 0.055) then land = true end
  if Ellipse(nx, ny, 0.60, 0.10, 0.12, 0.055) then land = true end

  -- ---- Water cuts ----
  -- Atlantic west of Iberia/France (keep coast)
  if nx < 0.08 and ny > 0.20 and ny < 0.55 then land = false end

  -- Bay of Biscay
  if Box(nx, ny, 0.12, 0.42, 0.22, 0.52) and ny > 0.44 then
    if not Ellipse(nx, ny, 0.17, 0.34, 0.13, 0.15)
       and not Box(nx, ny, 0.20, 0.48, 0.40, 0.72) then land = false end
  end

  -- English Channel / North Sea (keep Britain & France separate)
  if Box(nx, ny, 0.18, 0.52, 0.32, 0.60) then
    local keep =
      Ellipse(nx, ny, 0.22, 0.64, 0.08, 0.13)
      or Ellipse(nx, ny, 0.15, 0.62, 0.04, 0.07)
      or (ny < 0.54) -- French coast
    if not keep then land = false end
  end

  -- Baltic Sea
  if Box(nx, ny, 0.42, 0.66, 0.60, 0.78) then
    local keep =
      Ellipse(nx, ny, 0.42, 0.82, 0.11, 0.16)
      or Ellipse(nx, ny, 0.54, 0.84, 0.08, 0.11)
      or (ny < 0.68) -- south shore Poland/Germany
    if not keep then land = false end
  end

  -- Adriatic
  if Box(nx, ny, 0.44, 0.30, 0.50, 0.44) and nx > 0.45 and nx < 0.49 then
    land = false
  end

  -- Mediterranean core (between Europe and Africa)
  if Box(nx, ny, 0.16, 0.14, 0.72, 0.28) then
    local coast =
      Ellipse(nx, ny, 0.17, 0.34, 0.13, 0.15) -- Iberia south
      or Ellipse(nx, ny, 0.42, 0.34, 0.055, 0.16) -- Italy
      or Ellipse(nx, ny, 0.44, 0.22, 0.04, 0.07)
      or Ellipse(nx, ny, 0.44, 0.16, 0.03, 0.03)
      or Ellipse(nx, ny, 0.52, 0.36, 0.11, 0.14) -- Balkans
      or Ellipse(nx, ny, 0.54, 0.24, 0.06, 0.09) -- Greece
      or Ellipse(nx, ny, 0.22, 0.10, 0.16, 0.06) -- Maghreb
      or Ellipse(nx, ny, 0.42, 0.09, 0.14, 0.055)
      or Ellipse(nx, ny, 0.60, 0.10, 0.12, 0.055)
      or (ny > 0.26 and ny < 0.30 and nx > 0.20 and nx < 0.55) -- French/Italian Riviera fringe
    if not coast then land = false end
  end

  -- Black Sea
  if Ellipse(nx, ny, 0.66, 0.42, 0.10, 0.07) then land = false end

  -- No deep Anatolia / Middle East blob
  if nx > 0.72 and ny < 0.40 and ny > 0.20 then
    if not Ellipse(nx, ny, 0.78, 0.58, 0.18, 0.20) then land = false end
  end

  return land
end

local function IsMountain(x, y)
  local nx, ny = N(x, y)
  if Ellipse(nx, ny, 0.20, 0.40, 0.08, 0.03) then return true end -- Pyrenees
  if Ellipse(nx, ny, 0.38, 0.44, 0.11, 0.04) then return true end -- Alps
  if Ellipse(nx, ny, 0.54, 0.48, 0.08, 0.05) then return true end -- Carpathians
  if Ellipse(nx, ny, 0.50, 0.34, 0.06, 0.06) then return true end -- Dinaric / Balkan
  if Ellipse(nx, ny, 0.40, 0.80, 0.04, 0.12) then return true end -- Scandes
  if Ellipse(nx, ny, 0.42, 0.30, 0.025, 0.12) then return true end -- Apennines
  return false
end

local function IsHills(x, y)
  local nx, ny = N(x, y)
  if ny < 0.16 then return false end -- Africa flat
  if Ellipse(nx, ny, 0.28, 0.46, 0.08, 0.06) then return true end
  if Ellipse(nx, ny, 0.48, 0.52, 0.07, 0.05) then return true end
  if Ellipse(nx, ny, 0.18, 0.34, 0.06, 0.05) then return true end
  if Ellipse(nx, ny, 0.54, 0.30, 0.05, 0.05) then return true end
  return false
end

function GeneratePlotTypes()
  print("[WW2 Europe] GeneratePlotTypes")
  local plotTypes = {}
  local PT_OCEAN = g_PLOT_TYPE_OCEAN or 3
  local PT_LAND = g_PLOT_TYPE_LAND or 1
  local PT_HILLS = g_PLOT_TYPE_HILLS or 2
  local PT_MOUNTAIN = g_PLOT_TYPE_MOUNTAIN or 0

  for i = 0, (g_iW * g_iH) - 1 do plotTypes[i] = PT_OCEAN end

  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local i = y * g_iW + x
      if IsLand(x, y) then
        if IsMountain(x, y) then plotTypes[i] = PT_MOUNTAIN
        elseif IsHills(x, y) then plotTypes[i] = PT_HILLS
        else plotTypes[i] = PT_LAND end
      end
    end
  end
  return plotTypes
end

function GenerateTerrain()
  print("[WW2 Europe] GenerateTerrain")
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local plot = Map.GetPlot(x, y)
      if plot and not plot:IsWater() then
        local nx, ny = N(x, y)
        local name = "TERRAIN_GRASS"
        if ny < 0.16 then
          name = ((x + y) % 4 == 0) and "TERRAIN_PLAINS" or "TERRAIN_DESERT"
        elseif plot:IsMountain() then
          name = ny > 0.55 and "TERRAIN_TUNDRA_MOUNTAIN" or "TERRAIN_GRASS_MOUNTAIN"
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
  local wants = {
    "RESOURCE_OIL","RESOURCE_NITER","RESOURCE_ALUMINUM","RESOURCE_IRON",
    "RESOURCE_COPPER","RESOURCE_GOLD","RESOURCE_SILVER","RESOURCE_DIAMONDS",
    "RESOURCE_INCENSE","RESOURCE_COTTON","RESOURCE_WINE","RESOURCE_SUGAR",
  }
  local indices = {}
  for _, n in ipairs(wants) do
    local r = GameInfo.Resources[n]
    if r then table.insert(indices, r.Index) end
  end
  if #indices == 0 then return end
  local placed = 0
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local nx, ny = N(x, y)
      if ny < 0.16 then
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

function StartPlotSystem()
  pcall(function()
    AssignStartingPlots.Create({
      MIN_MAJOR_CIV_FERTILITY = 60,
      MIN_MINOR_CIV_FERTILITY = 15,
      MIN_BARBARIAN_FERTILITY = 1,
      START_MIN_Y = 5, START_MAX_Y = 5,
      IGNORE_LANDMASS = true,
      START_CONFIG = MapConfiguration.GetValue("start") or 2,
    })
  end)
end

function GenerateMap()
  print("[WW2 Europe] GenerateMap 96x60")
  local gw, gh = Map.GetGridSize()
  if gw and gh and gw > 0 then g_iW, g_iH = gw, gh end

  local plotTypes = GeneratePlotTypes()

  -- Force ocean terrain on ocean plots (engine sometimes ignores plotTypes alone)
  local ocean = GameInfo.Terrains["TERRAIN_OCEAN"]
  local coast = GameInfo.Terrains["TERRAIN_COAST"]
  for y = 0, g_iH - 1 do
    for x = 0, g_iW - 1 do
      local plot = Map.GetPlot(x, y)
      local i = y * g_iW + x
      if plot and plotTypes[i] == (g_PLOT_TYPE_OCEAN or 3) and ocean then
        TerrainBuilder.SetTerrainType(plot, ocean.Index)
      end
    end
  end

  pcall(function() AreaBuilder.Recalculate() end)
  GenerateTerrain()

  -- Coast ring: any ocean adjacent to land becomes coast (readable Europe outline)
  if coast then
    for y = 0, g_iH - 1 do
      for x = 0, g_iW - 1 do
        local plot = Map.GetPlot(x, y)
        if plot and plot:IsWater() then
          local nearLand = false
          for dy = -1, 1 do
            for dx = -1, 1 do
              local n = Map.GetPlot(x + dx, y + dy)
              if n and not n:IsWater() then nearLand = true end
            end
          end
          if nearLand then TerrainBuilder.SetTerrainType(plot, coast.Index) end
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
  pcall(function() NaturalWonderGenerator.Create({ numberToPlace = 3 }) end)
  pcall(function() AreaBuilder.Recalculate() end)
  pcall(function() ResourceGenerator.Create({ resources = MapConfiguration.GetValue("resources") or 2 }) end)
  EnrichAfrica()
  StartPlotSystem()
  pcall(function() AddGoodies(g_iW, g_iH) end)
  print("[WW2 Europe] done")
end
