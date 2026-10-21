------------------------------------------------------------------------------
-- WW2 Europe 96x60
-- CRITICAL: TerrainBuilder.SetTerrainType on EVERY tile (plotTypes return alone
-- does nothing when GenerateMap is defined — that was the blob bug).
------------------------------------------------------------------------------
include("MapEnums")
include("MapUtilities")
include("FeatureGenerator")
include("ResourceGenerator")
include("AssignStartingPlots")

local W, H = 96, 60

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

-- 48x30 land bitmap (0=ocean 1=land 2=hills 3=mountain), scaled x2 → 96x60
-- Rows are NORTH → SOUTH so row 1 is Scandinavia, last rows are North Africa.
-- Designed to read as Europe on the minimap: Britain, Iberia, Italy boot, Greece,
-- Scandinavia, main continent, thin Maghreb.
local BITMAP = {
--                      1         2         3         4
--             123456789012345678901234567890123456789012345678
--[[01]] "..........................1111......................",
--[[02]] ".........................111111.....................",
--[[03]] "........................11111111....................",
--[[04]] ".......................1111111111...................",
--[[05]] "......................11111111111...................",
--[[06]] ".........11..........1111111111111..................",
--[[07]] "........1111........11111111111111..................",
--[[08]] ".......111111.......111111111111111.................",
--[[09]] "......1111111......1111111111111111...11............",
--[[10]] ".....11111111......1111111111111111..1111...........",
--[[11]] "....111111111......1111111111111111.11111...........",
--[[12]] "....111111111......1111111111111111111111...........",
--[[13]] "...1111111111......111111111111111111111............",
--[[14]] "...1111..111.......11111111111111111111.............",
--[[15]] "...111....11.......1111111111111111111..............",
--[[16]] "....11.............111111111111111111...............",
--[[17]] "...................11111111111111111................",
--[[18]] "...................1111111111111111.................",
--[[19]] "..................1111111111111111..................",
--[[20]] ".....11...........111111111111111...................",
--[[21]] "....1111..........11111111111111....................",
--[[22]] "...111111.........1111111111111.....................",
--[[23]] "...111111.........111111111111......................",
--[[24]] "..1111111.........11111111111.......................",
--[[25]] "..111111..........1111111111........................",
--[[26]] "..11111...........111111111.........................",
--[[27]] "...111.............1111111..........................",
--[[28]] ".....................11.............................",
--[[29]] "....................................................",
--[[30]] "....................................................",
}

-- Secondary overlays painted after base (Italy boot, Greece, Africa, Ireland, Sicily)
local function Overlay(nx, ny)
  -- Ireland (west of Britain)
  if (nx-0.14)^2/0.03^2 + (ny-0.72)^2/0.05^2 <= 1 then return 1 end
  -- Italy boot
  if (nx-0.42)^2/0.04^2 + (ny-0.42)^2/0.12^2 <= 1 then return 1 end
  if (nx-0.44)^2/0.03^2 + (ny-0.28)^2/0.05^2 <= 1 then return 1 end
  -- Sicily
  if (nx-0.44)^2/0.025^2 + (ny-0.20)^2/0.02^2 <= 1 then return 1 end
  -- Greece / south Balkans
  if (nx-0.54)^2/0.05^2 + (ny-0.32)^2/0.07^2 <= 1 then return 1 end
  -- Crimea-ish
  if (nx-0.68)^2/0.04^2 + (ny-0.48)^2/0.03^2 <= 1 then return 1 end
  -- North Africa thin strip
  if ny < 0.12 and ny > 0.04 and nx > 0.10 and nx < 0.70 then
    if (ny-0.08)^2 / 0.035^2 + ((nx-0.40)/0.28)^2 <= 1 then return 1 end
  end
  return nil
end

local function Sample(x, y)
  -- bitmap: row 1 = north = high y in Civ (y=H-1)
  local nx = x / math.max(W - 1, 1)
  local ny = y / math.max(H - 1, 1)

  local ov = Overlay(nx, ny)
  if ov then return ov end

  -- Map civ y (0=south) to bitmap row (1=north)
  local bx = math.floor(nx * 47) + 1
  local by = math.floor((1.0 - ny) * 29) + 1 -- flip: high ny → low row index
  if by < 1 then by = 1 end
  if by > 30 then by = 30 end
  if bx < 1 then bx = 1 end
  if bx > 48 then bx = 48 end

  local row = BITMAP[by]
  if not row then return 0 end
  local ch = string.sub(row, bx, bx)
  if ch == "1" then return 1 end
  return 0
end

local function IsMountain(x, y)
  local nx = x / math.max(W - 1, 1)
  local ny = y / math.max(H - 1, 1)
  -- Pyrenees
  if (nx-0.18)^2/0.06^2 + (ny-0.46)^2/0.02^2 <= 1 then return true end
  -- Alps
  if (nx-0.38)^2/0.08^2 + (ny-0.50)^2/0.03^2 <= 1 then return true end
  -- Carpathians
  if (nx-0.54)^2/0.06^2 + (ny-0.54)^2/0.035^2 <= 1 then return true end
  -- Scandes
  if (nx-0.42)^2/0.03^2 + (ny-0.82)^2/0.10^2 <= 1 then return true end
  -- Apennines
  if (nx-0.42)^2/0.015^2 + (ny-0.38)^2/0.10^2 <= 1 then return true end
  return false
end

local function IsHills(x, y)
  local nx = x / math.max(W - 1, 1)
  local ny = y / math.max(H - 1, 1)
  if ny < 0.14 then return false end
  if (nx-0.28)^2/0.06^2 + (ny-0.52)^2/0.04^2 <= 1 then return true end
  if (nx-0.50)^2/0.05^2 + (ny-0.56)^2/0.04^2 <= 1 then return true end
  if (nx-0.16)^2/0.05^2 + (ny-0.40)^2/0.04^2 <= 1 then return true end
  return false
end

local function TerrainIndex(name)
  local row = GameInfo.Terrains[name]
  return row and row.Index or nil
end

function GenerateMap()
  print("[WW2 Europe] v2.9 FORCE paint Europe bitmap")
  local gw, gh = Map.GetGridSize()
  if gw and gh and gw > 0 then W, H = gw, gh end
  print(string.format("[WW2 Europe] grid %dx%d", W, H))

  local ocean = TerrainIndex("TERRAIN_OCEAN")
  local coast = TerrainIndex("TERRAIN_COAST")
  local grass = TerrainIndex("TERRAIN_GRASS")
  local grassH = TerrainIndex("TERRAIN_GRASS_HILLS")
  local grassM = TerrainIndex("TERRAIN_GRASS_MOUNTAIN")
  local plains = TerrainIndex("TERRAIN_PLAINS")
  local plainsH = TerrainIndex("TERRAIN_PLAINS_HILLS")
  local desert = TerrainIndex("TERRAIN_DESERT")
  local tundra = TerrainIndex("TERRAIN_TUNDRA")
  local tundraH = TerrainIndex("TERRAIN_TUNDRA_HILLS")
  local tundraM = TerrainIndex("TERRAIN_TUNDRA_MOUNTAIN")
  local snow = TerrainIndex("TERRAIN_SNOW")

  if not ocean or not grass then
    print("[WW2 Europe] ERROR: missing terrain types")
    return
  end

  local landCount = 0
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      local plot = Map.GetPlot(x, y)
      if plot then
        local land = Sample(x, y)
        local ny = y / math.max(H - 1, 1)
        local idx = ocean

        if land > 0 then
          landCount = landCount + 1
          if IsMountain(x, y) then
            idx = (ny > 0.65 and tundraM or grassM) or grass
          elseif IsHills(x, y) then
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
  print("[WW2 Europe] painted land tiles: " .. tostring(landCount))

  -- Coast ring
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

  -- No natural wonders

  pcall(function() AreaBuilder.Recalculate() end)
  pcall(function()
    ResourceGenerator.Create({ resources = MapConfiguration.GetValue("resources") or 2 })
  end)

  -- Africa resources
  pcall(function()
    local oil = GameInfo.Resources["RESOURCE_OIL"]
    local iron = GameInfo.Resources["RESOURCE_IRON"]
    local gold = GameInfo.Resources["RESOURCE_GOLD"]
    for y = 0, H - 1 do
      for x = 0, W - 1 do
        local ny = y / math.max(H - 1, 1)
        if ny < 0.13 then
          local plot = Map.GetPlot(x, y)
          if plot and not plot:IsWater() and not plot:IsMountain() and ((x * 11 + y * 5) % 4) == 0 then
            local r = oil or iron or gold
            if r and plot:GetResourceType() < 0 then
              ResourceBuilder.SetResourceType(plot, r.Index, 1)
            end
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
  print("[WW2 Europe] v2.9 done — check minimap for Britain/Iberia/Italy")
end
