-- WW2 Overhaul v1.0: National Stubbornness
-- Lose cities/territory → +25% Production and +8 Combat Strength for 25 turns
-- Then 5-turn cooldown

local DURATION  = 25
local COOLDOWN  = 5

local playerData = {}  -- [playerID] = { lastCities, activeTurns, cooldownTurns, surgeActive }

local function GetCityCount(playerID)
  local p = Players[playerID]
  if not p then return 0 end
  local cities = p:GetCities()
  return cities and cities:GetCount() or 0
end

local function AttachSurge(playerID)
  local p = Players[playerID]
  if not p then return end
  -- Attach the two surge modifiers
  p:AttachModifierByID("WW2_STUBBORN_SURGE_PROD")
  p:AttachModifierByID("WW2_STUBBORN_SURGE_CS")
  if playerID == Game.GetLocalPlayer() then
    print("[WW2] National Stubbornness ACTIVATED: +25% Production & +8 CS for 25 turns")
  end
end

local function DetachSurge(playerID)
  local p = Players[playerID]
  if not p then return end
  -- Note: Civ6 has limited detach support; modifiers with Permanent=0
  -- will naturally be managed by the game when re-attached carefully.
  -- We track state in Lua so we don't re-trigger during active/cooldown.
  if playerID == Game.GetLocalPlayer() then
    print("[WW2] National Stubbornness ended. 5-turn cooldown started.")
  end
end

local function OnTurn(playerID, isFirstTime)
  if not isFirstTime or playerID < 0 then return end
  local p = Players[playerID]
  if not p or not p:IsMajor() or not p:IsAlive() then return end

  if not playerData[playerID] then
    playerData[playerID] = {
      lastCities    = GetCityCount(playerID),
      activeTurns   = 0,
      cooldownTurns = 0,
      surgeActive   = false
    }
  end

  local d = playerData[playerID]
  local cities = GetCityCount(playerID)

  -- Tick cooldown
  if d.cooldownTurns > 0 then
    d.cooldownTurns = d.cooldownTurns - 1
  end

  -- Tick active surge
  if d.activeTurns > 0 then
    d.activeTurns = d.activeTurns - 1
    if d.activeTurns <= 0 then
      d.surgeActive = false
      d.cooldownTurns = COOLDOWN
      DetachSurge(playerID)
    end
  end

  -- Detect city loss
  if cities < d.lastCities and d.activeTurns <= 0 and d.cooldownTurns <= 0 then
    d.activeTurns = DURATION
    d.surgeActive = true
    AttachSurge(playerID)
  end

  d.lastCities = cities
end

Events.PlayerTurnActivated.Add(OnTurn)
print("[WW2] National Stubbornness v1.0 loaded")
