-- Oil maintenance: 0 Oil → modern tanks/ships/planes nearly immobilized (no extra prod cost)

local OIL = "RESOURCE_OIL"

local NEEDS_OIL = {
  UNIT_TANK = true, UNIT_MODERN_ARMOR = true, UNIT_ROCKET_ARTILLERY = true,
  UNIT_MECHANIZED_INFANTRY = true, UNIT_HELICOPTER = true,
  UNIT_BATTLESHIP = true, UNIT_DESTROYER = true, UNIT_SUBMARINE = true,
  UNIT_AIRCRAFT_CARRIER = true, UNIT_MISSILE_CRUISER = true,
  UNIT_BIPLANE = true, UNIT_FIGHTER = true, UNIT_BOMBER = true,
  UNIT_JET_FIGHTER = true, UNIT_JET_BOMBER = true,
}

local function HasOil(playerID)
  local p = Players[playerID]
  if not p then return true end
  local res = p:GetResources()
  if not res then return true end
  local idx = GameInfo.Resources[OIL] and GameInfo.Resources[OIL].Index
  if not idx then return true end
  return (res:GetResourceAmount(idx) or 0) > 0
end

local function OnTurn(playerID, isFirstTime)
  if not isFirstTime or playerID < 0 then return end
  if HasOil(playerID) then return end

  local p = Players[playerID]
  if not p then return end
  local units = p:GetUnits()
  if not units then return end

  local hit = false
  for _, unit in units:Members() do
    local info = GameInfo.Units[unit:GetType()]
    if info and NEEDS_OIL[info.UnitType] then
      local moves = unit:GetMovesRemaining()
      if moves and moves > 1 then
        -- Leave at most 1 move so they are nearly stuck
        unit:ChangeMovesRemaining(-(moves - 1))
        hit = true
      end
    end
  end

  if hit and playerID == Game.GetLocalPlayer() then
    print("[WW2] NO OIL — modern armor, ships, and aircraft reduced to 1 movement.")
  end
end

Events.PlayerTurnActivated.Add(OnTurn)
print("[WW2] Oil maintenance v2 loaded")
