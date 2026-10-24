------------------------------------------------------------------------------
-- WW2 Embedded Huge Europe (ORIGINAL map for Epic / offline installs)
-- Size 106x66 = MAPSIZE_HUGE. Terrain forced tile-by-tile.
-- Not a copy of any Workshop map — original silhouette for this mod.
------------------------------------------------------------------------------
include("MapEnums")
include("MapUtilities")
include("FeatureGenerator")
include("ResourceGenerator")
include("AssignStartingPlots")

local W, H = 106, 66

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
    SortIndex = 1,
    CustomOptions = { world_age, temperature, rainfall, sea_level, resources },
  }
end

-- 53x33 land mask (scaled x2 → 106x66). Row 1 = NORTH. '1'=land '.'=ocean
-- Shape: Scandinavia, Britain, Iberia, Italy boot, Greece, main continent, Maghreb
local ROWS = {
".........................11111......................",
"........................1111111.....................",
".......................111111111....................",
"......................11111111111...................",
".....................1111111111111..................",
"..........11........11111111111111..................",
".........1111......111111111111111..................",
"........111111.....1111111111111111.................",
".......1111111....11111111111111111...11............",
"......11111111....11111111111111111..1111...........",
".....111111111....11111111111111111111111...........",
".....111111111....1111111111111111111111............",
"....1111111111....111111111111111111111.............",
"....1111.1111.....11111111111111111111..............",
"....111...11......1111111111111111111...............",
".....11...........111111111111111111................",
"..................11111111111111111.................",
"..................1111111111111111..................",
".................1111111111111111...................",
"......11.........111111111111111....................",
".....1111........11111111111111.....................",
"....111111.......1111111111111......................",
"....111111.......111111111111.......................",
"...1111111.......11111111111........................",
"...111111........1111111111.........................",
"...11111.........111111111..........................",
"....111...........1111111...........................",
"....................11..............................",
"....................................................",
"....................................................",
"....................................................",
"....................................................",
"....................................................",
}

local function Sample(x, y)
  local nx = x / math.max(W - 1, 1)
  local ny = y / math.max(H - 1, 1)

  -- Overlays for peninsulas / islands the coarse grid misses
  local function ell(cx, cy, rx, ry)
    return ((nx - cx) / rx) ^ 2 + ((ny - cy) / ry) ^ 2 <= 1
  end
  if ell(0.14, 0.70, 0.035, 0.05) then return 1 end -- Ireland
  if ell(0.22, 0.68, 0.06, 0.10) then return 1 end  -- Britain
  if ell(0.16, 0.38, 0.10, 0.11) then return 1 end  -- Iberia
  if ell(0.42, 0.40, 0.04, 0.12) then return 1 end  -- Italy
  if ell(0.44, 0.26, 0.03, 0.05) then return 1 end  -- south Italy
  if ell(0.44, 0.18, 0.025, 0.02) then return 1 end -- Sicily
  if ell(0.54, 0.30, 0.05, 0.07) then return 1 end  -- Greece
  if ell(0.42, 0.82, 0.08, 0.12) then return 1 end  -- Norway/Sweden
  if ell(0.52, 0.84, 0.06, 0.09) then return 1 end  -- Finland/east Scandi
  if ell(0.38, 0.70, 0.035, 0.04) then return 1 end -- Denmark
  -- North Africa strip
  if ny > 0.04 and ny < 0.12 and nx > 0.10 and nx < 0.68 then
    if ell(0.38, 0.08, 0.26, 0.035) then return 1 end
  end

  local cols = 53
  local rows = #ROWS
  local bx = math.floor(nx * (cols - 1)) + 1
  local by = math.floor((1.0 - ny) * (rows - 1)) + 1
  if by < 1 then by = 1 end
  if by > rows then by = rows end
  if bx < 1 then bx = 1 end
  if bx > cols then bx = cols end
  local row = ROWS[by]
  if not row then return 0 end
  local ch = string.sub(row, bx, bx)
  return (ch == "1") and 1 or 0
end

local function IsMtn(x, y)
  local nx, ny = x / (W - 1), y / (H - 1)
  local function ell(cx, cy, rx, ry)
    return ((nx - cx) / rx) ^ 2 + ((ny - cy) / ry) ^ 2 <= 1
  end
  if ell(0.18, 0.44, 0.06, 0.02) then return true end -- Pyrenees
  if ell(0.38, 0.48, 0.08, 0.03) then return true end -- Alps
  if ell(0.54, 0.52, 0.06, 0.03) then return true end -- Carpathians
  if ell(0.42, 0.80, 0.03, 0.10) then return true end -- Scandes
  if ell(0.42, 0.36, 0.015, 0.10) then return true end -- Apennines
  return false
end

local function IsHill(x, y)
  local nx, ny = x / (W - 1), y / (H - 1)
  if ny < 0.14 then return false end
  local function ell(cx, cy, rx, ry)
    return ((nx - cx) / rx) ^ 2 + ((ny - cy) / ry) ^ 2 <= 1
  end
  return ell(0.28, 0.50, 0.06, 0.04) or ell(0.50, 0.54, 0.05, 0.04) or ell(0.16, 0.38, 0.05, 0.04)
end

local function T(name)
  local r = GameInfo.Terrains[name]
  return r and r.Index or nil
end

function GenerateMap()
  print("[WW2 Europe Embedded] v3.2 106x66 — Epic offline map")
  local gw, gh = Map.GetGridSize()
  if gw and gh and gw > 0 then W, H = gw, gh end

  local ocean, coast = T("TERRAIN_OCEAN"), T("TERRAIN_COAST")
  local grass, grassH, grassM = T("TERRAIN_GRASS"), T("TERRAIN_GRASS_HILLS"), T("TERRAIN_GRASS_MOUNTAIN")
  local plains, plainsH = T("TERRAIN_PLAINS"), T("TERRAIN_PLAINS_HILLS")
  local desert = T("TERRAIN_DESERT")
  local tundra, tundraH, tundraM = T("TERRAIN_TUNDRA"), T("TERRAIN_TUNDRA_HILLS"), T("TERRAIN_TUNDRA_MOUNTAIN")
  local snow = T("TERRAIN_SNOW")

  if not ocean or not grass then
    print("[WW2 Europe Embedded] ERROR missing terrains")
    return
  end

  local landN = 0
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      local plot = Map.GetPlot(x, y)
      if plot then
        local land = Sample(x, y)
        local ny = y / math.max(H - 1, 1)
        local idx = ocean
        if land > 0 then
          landN = landN + 1
          if IsMtn(x, y) then
            idx = (ny > 0.65 and tundraM or grassM) or grass
          elseif IsHill(x, y) then
            if ny > 0.72 then idx = tundraH or grassH or grass
            elseif ny < 0.30 then idx = plainsH or grassH or grass
            else idx = grassH or grass end
          else
            if ny < 0.13 then idx = desert or plains or grass
            elseif ny > 0.85 then idx = snow or tundra or grass
            elseif ny > 0.75 then idx = tundra or grass
            elseif ny < 0.32 then idx = plains or grass
            else idx = grass end
          end
        end
        TerrainBuilder.SetTerrainType(plot, idx)
      end
    end
  end
  print("[WW2 Europe Embedded] land tiles: " .. tostring(landN))

  if coast then
    for y = 0, H - 1 do
      for x = 0, W - 1 do
        local plot = Map.GetPlot(x, y)
        if plot and plot:IsWater() then
          local near = false
          for dy = -1, 1 do
            for dx = -1, 1 do
              if not (dx == 0 and dy == 0) then
                local n = Map.GetPlot(x + dx, y + dy)
                if n and not n:IsWater() then near = true end
              end
            end
          end
          if near then TerrainBuilder.SetTerrainType(plot, coast) end
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
  pcall(function() AreaBuilder.Recalculate() end)
  pcall(function()
    ResourceGenerator.Create({ resources = MapConfiguration.GetValue("resources") or 2 })
  end)

  -- Africa oil / strategic
  pcall(function()
    local oil = GameInfo.Resources["RESOURCE_OIL"]
    if not oil then return end
    for y = 0, H - 1 do
      for x = 0, W - 1 do
        if y / math.max(H - 1, 1) < 0.13 then
          local plot = Map.GetPlot(x, y)
          if plot and not plot:IsWater() and not plot:IsMountain() and ((x * 11 + y) % 5) == 0 then
            if plot:GetResourceType() < 0 then ResourceBuilder.SetResourceType(plot, oil.Index, 1) end
          end
        end
      end
    end
  end)

  pcall(function()
    AssignStartingPlots.Create({
      MIN_MAJOR_CIV_FERTILITY = 40,
      MIN_MINOR_CIV_FERTILITY = 8,
      MIN_BARBARIAN_FERTILITY = 1,
      START_MIN_Y = 3, START_MAX_Y = 3,
      IGNORE_LANDMASS = true,
      START_CONFIG = MapConfiguration.GetValue("start") or 2,
    })
  end)
  pcall(function() AddGoodies(W, H) end)
  print("[WW2 Europe Embedded] done — map is inside the mod (Epic OK)")
end
