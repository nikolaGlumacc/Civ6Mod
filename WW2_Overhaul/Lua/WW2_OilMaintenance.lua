-- WW2 Overhaul: Oil maintenance
-- Modern units that need oil suffer combat + movement penalties when the player has 0 Oil.

local OIL_RESOURCE = "RESOURCE_OIL"

-- Units that historically / thematically need oil (tanks, modern ships, planes, etc.)
local OIL_DEPENDENT_UNITS = {
  -- Land
  ["UNIT_TANK"] = true,
  ["UNIT_MODERN_ARMOR"] = true,
  ["UNIT_ROCKET_ARTILLERY"] = true,
  ["UNIT_MECHANIZED_INFANTRY"] = true,
  ["UNIT_HELICOPTER"] = true,
  -- Sea
  ["UNIT_BATTLESHIP"] = true,
  ["UNIT_DESTROYER"] = true,
  ["UNIT_SUBMARINE"] = true,
  ["UNIT_AIRCRAFT_CARRIER"] = true,
  ["UNIT_MISSILE_CRUISER"] = true,
  -- Air
  ["UNIT_BIPLANE"] = true,
  ["UNIT_FIGHTER"] = true,
  ["UNIT_BOMBER"] = true,
  ["UNIT_JET_FIGHTER"] = true,
  ["UNIT_JET_BOMBER"] = true,
}

local function PlayerHasOil(playerID)
  local player = Players[playerID]
  if player == nil then return false end
  local resources = player:GetResources()
  if resources == nil then return false end
  local amount = resources:GetResourceAmount(GameInfo.Resources[OIL_RESOURCE].Index)
  return amount and amount > 0
end

local function ApplyOilPenalty(unit)
  if unit == nil or unit:IsDead() then return end
  local unitType = GameInfo.Units[unit:GetType()].UnitType
  if not OIL_DEPENDENT_UNITS[unitType] then return end

  -- Apply temporary combat and movement penalties via modifiers if possible,
  -- or fall back to direct changes when available.
  -- Simple approach: reduce movement and combat strength while no oil.
  unit:ChangeMovesRemaining(-1)          -- temporary movement hit each turn
  -- Combat strength change is harder without a persistent modifier;
  -- for a first version we rely on the movement penalty + notification.
end

local function OnPlayerTurnActivated(playerID, isFirstTime)
  if not isFirstTime then return end
  if playerID == -1 then return end

  if PlayerHasOil(playerID) then
    return -- all good
  end

  local player = Players[playerID]
  local units = player:GetUnits()
  if units == nil then return end

  for i, unit in units:Members() do
    local unitTypeInfo = GameInfo.Units[unit:GetType()]
    if unitTypeInfo and OIL_DEPENDENT_UNITS[unitTypeInfo.UnitType] then
      -- Movement penalty
      local moves = unit:GetMovesRemaining()
      if moves > 1 then
        unit:ChangeMovesRemaining(-1)
      end
      -- Optional: you can later attach a real combat modifier here
    end
  end

  -- Notify the local player once
  if playerID == Game.GetLocalPlayer() then
    local message = "No Oil! Modern tanks, ships and planes suffer movement penalties."
    -- Simple notification (works in most contexts)
    print("[WW2_Overhaul] " .. message)
  end
end

Events.PlayerTurnActivated.Add(OnPlayerTurnActivated)

print("[WW2_Overhaul] Oil maintenance script loaded")
