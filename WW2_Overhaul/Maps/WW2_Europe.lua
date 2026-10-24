------------------------------------------------------------------------------
-- WW2 Overhaul — Self-contained Europe map (120x72, denser land)
-- Aimed at: clear Britain, Iberia, France, Italy, Balkans, Scandinavia,
-- Central Europe belt, Russia, Anatolia, N.Africa
------------------------------------------------------------------------------
include("MapEnums")
include("MapUtilities")
include("FeatureGenerator")
include("ResourceGenerator")
include("AssignStartingPlots")

local W, H = 120, 72

function GetMapInitData(MapSize)
  return { Width = W, Height = H, WrapX = false, WrapY = false }
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

local function ell(nx, ny, cx, cy, rx, ry)
  return ((nx - cx) / rx) ^ 2 + ((ny - cy) / ry) ^ 2 <= 1
end

-- Much fatter land so it actually reads as Europe, not a peanut
local function IsLand(x, y)
  local nx = x / math.max(W - 1, 1)
  local ny = y / math.max(H - 1, 1)

  -- Core continent: Iberia through Russia (wide belt)
  if ell(nx, ny, 0.50, 0.52, 0.42, 0.28) then return true end
  -- Britain
  if ell(nx, ny, 0.20, 0.60, 0.08, 0.12) then return true end
  if ell(nx, ny, 0.13, 0.62, 0.04, 0.06) then return true end -- Ireland
  -- Iberia (explicit so it sticks out)
  if ell(nx, ny, 0.16, 0.36, 0.12, 0.13) then return true end
  -- Italy
  if ell(nx, ny, 0.38, 0.38, 0.06, 0.16) then return true end
  if ell(nx, ny, 0.40, 0.24, 0.04, 0.06) then return true end
  if ell(nx, ny, 0.41, 0.18, 0.035, 0.03) then return true end
  -- Balkans / Greece
  if ell(nx, ny, 0.50, 0.32, 0.09, 0.12) then return true end
  -- Scandinavia
  if ell(nx, ny, 0.40, 0.80, 0.09, 0.16) then return true end
  if ell(nx, ny, 0.50, 0.82, 0.08, 0.14) then return true end
  if ell(nx, ny, 0.36, 0.68, 0.05, 0.05) then return true end -- Denmark
  -- Anatolia
  if ell(nx, ny, 0.64, 0.34, 0.13, 0.09) then return true end
  -- Caucasus
  if ell(nx, ny, 0.78, 0.40, 0.07, 0.07) then return true end
  -- North Africa
  if ny > 0.05 and ny < 0.18 and nx > 0.10 and nx < 0.72 then
    if ell(nx, ny, 0.40, 0.11, 0.30, 0.05) then return true end
  end
  if ell(nx, ny, 0.62, 0.11, 0.07, 0.05) then return true end -- Egypt
  return false
end

local function IsMountain(x, y)
  local nx = x / math.max(W - 1, 1)
  local ny = y / math.max(H - 1, 1)
  if ell(nx, ny, 0.18, 0.40, 0.07, 0.025) then return true end -- Pyrenees
  if ell(nx, ny, 0.34, 0.48, 0.10, 0.04) then return true end  -- Alps
  if ell(nx, ny, 0.50, 0.50, 0.08, 0.035) then return true end -- Carpathians
  if ell(nx, ny, 0.40, 0.80, 0.03, 0.12) then return true end  -- Scandes
  if ell(nx, ny, 0.38, 0.34, 0.02, 0.12) then return true end  -- Apennines
  if ell(nx, ny, 0.64, 0.36, 0.07, 0.03) then return true end  -- Anatolia
  return false
end

local function IsHill(x, y)
  local nx = x / math.max(W - 1, 1)
  local ny = y / math.max(H - 1, 1)
  if ny < 0.18 then return false end
  return ell(nx, ny, 0.28, 0.52, 0.08, 0.06)
      or ell(nx, ny, 0.48, 0.54, 0.07, 0.06)
      or ell(nx, ny, 0.16, 0.38, 0.07, 0.06)
      or ell(nx, ny, 0.52, 0.34, 0.06, 0.06)
end

local function T(name)
  local r = GameInfo.Terrains[name]
  return r and r.Index or nil
end

function GenerateMap()
  print("[WW2 Europe] denser Europe " .. W .. "x" .. H)
  local gw, gh = Map.GetGridSize()
  if gw and gh and gw > 0 then W, H = gw, gh end

  local ocean, coast = T("TERRAIN_OCEAN"), T("TERRAIN_COAST")
  local grass, grassH, grassM = T("TERRAIN_GRASS"), T("TERRAIN_GRASS_HILLS"), T("TERRAIN_GRASS_MOUNTAIN")
  local plains, plainsH, plainsM = T("TERRAIN_PLAINS"), T("TERRAIN_PLAINS_HILLS"), T("TERRAIN_PLAINS_MOUNTAIN")
  local desert = T("TERRAIN_DESERT")
  local tundra, tundraH, tundraM = T("TERRAIN_TUNDRA"), T("TERRAIN_TUNDRA_HILLS"), T("TERRAIN_TUNDRA_MOUNTAIN")
  local snow = T("TERRAIN_SNOW")

  if not ocean or not grass then
    print("[WW2 Europe] ERROR missing terrains")
    return
  end

  local landN = 0
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      local plot = Map.GetPlot(x, y)
      if plot then
        local ny = y / math.max(H - 1, 1)
        local idx = ocean
        if IsLand(x, y) then
          landN = landN + 1
          if IsMountain(x, y) then
            if ny > 0.70 then idx = tundraM or grassM or grass
            elseif ny < 0.25 then idx = plainsM or grassM or grass
            else idx = grassM or plainsM or grass end
          elseif IsHill(x, y) then
            if ny > 0.75 then idx = tundraH or grassH or grass
            elseif ny < 0.28 then idx = plainsH or grassH or grass
            else idx = grassH or plainsH or grass end
          else
            if ny < 0.15 then idx = desert or plains or grass
            elseif ny > 0.88 then idx = snow or tundra or grass
            elseif ny > 0.78 then idx = tundra or grass
            elseif ny < 0.32 then idx = plains or grass
            else idx = grass end
          end
        end
        TerrainBuilder.SetTerrainType(plot, idx)
      end
    end
  end
  print("[WW2 Europe] land tiles: " .. tostring(landN))

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

  pcall(function()
    local oil = GameInfo.Resources["RESOURCE_OIL"]
    if not oil then return end
    for y = 0, H - 1 do
      for x = 0, W - 1 do
        local ny = y / math.max(H - 1, 1)
        local nx = x / math.max(W - 1, 1)
        local plot = Map.GetPlot(x, y)
        if plot and not plot:IsWater() and not plot:IsMountain() then
          if (ny < 0.16 and ((x * 13 + y) % 6) == 0)
              or (nx > 0.72 and ny > 0.35 and ny < 0.48 and ((x + y) % 7) == 0) then
            if plot:GetResourceType() < 0 then
              ResourceBuilder.SetResourceType(plot, oil.Index, 1)
            end
          end
        end
      end
    end
  end)

  pcall(function()
    AssignStartingPlots.Create({
      MIN_MAJOR_CIV_FERTILITY = 20,
      MIN_MINOR_CIV_FERTILITY = 5,
      MIN_BARBARIAN_FERTILITY = 1,
      START_MIN_Y = 2, START_MAX_Y = 2,
      IGNORE_LANDMASS = true,
      START_CONFIG = MapConfiguration.GetValue("start") or 2,
    })
  end)
  pcall(function() AddGoodies(W, H) end)
  print("[WW2 Europe] GenerateMap done — land should dominate the view")
end
