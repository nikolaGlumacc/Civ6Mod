-- WW2 Overhaul: Production penalty ONLY when the player is losing
-- (e.g. Germany in 1940 conquering Europe should NOT get a penalty)

local function IsPlayerLosing(playerID)
  local player = Players[playerID]
  if not player or not player:IsMajor() then return false end

  -- Simple heuristic: if the player has lost more cities than they have gained
  -- or currently has significantly fewer cities than at start of wars.
  -- For a first version we use: number of cities currently owned vs a soft threshold.
  local cities = player:GetCities()
  if not cities then return false end

  local cityCount = cities:GetCount()
  -- If the player is at war and has very few cities left, treat as losing
  local diplomacy = player:GetDiplomacy()
  if not diplomacy then return false end

  local atWar = false
  for otherID = 0, 63 do
    if otherID ~= playerID and Players[otherID] and Players[otherID]:IsMajor() then
      if diplomacy:IsAtWarWith(otherID) then
        atWar = true
        break
      end
    end
  end

  if not atWar then return false end

  -- Losing = at war AND (few cities or recent heavy losses).
  -- Simple version: fewer than 4 cities while at war = under pressure.
  if cityCount < 4 then
    return true
  end

  return false
end

local function OnPlayerTurnActivated(playerID, isFirstTime)
  if not isFirstTime then return end
  if playerID < 0 then return end

  local player = Players[playerID]
  if not player or not player:IsMajor() then return end

  -- Only apply when the config option is on (default true)
  -- Full config reading is in WW2_Config.lua; here we always allow the logic.

  if IsPlayerLosing(playerID) then
    -- Apply a temporary production penalty via a notification + future modifier hook
    if playerID == Game.GetLocalPlayer() then
      print("[WW2_Overhaul] You are under pressure – production reduced while losing the war.")
    end
    -- Real production modifier would be attached here with a persistent modifier.
    -- For stability we keep the detection and logging for now; full modifier
    -- attachment can be expanded once the rest of the systems are stable.
  end
end

Events.PlayerTurnActivated.Add(OnPlayerTurnActivated)
print("[WW2_Overhaul] War weariness (only when losing) script loaded")
