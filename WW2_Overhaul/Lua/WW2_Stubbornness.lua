-- National Stubbornness surge: lose cities → +25% Prod +8 CS for 25 turns, then 5-turn cooldown
-- State persisted in GameConfiguration for save/load.

local DURATION = 25
local COOLDOWN = 5

local function Key(playerID, field)
  return "WW2_STUB_" .. tostring(playerID) .. "_" .. field
end

local function GetNum(playerID, field, default)
  local v = GameConfiguration.GetValue(Key(playerID, field))
  if v == nil then return default end
  return tonumber(v) or default
end

local function SetNum(playerID, field, value)
  GameConfiguration.SetValue(Key(playerID, field), value)
end

local function GetCityCount(playerID)
  local p = Players[playerID]
  if not p then return 0 end
  local cities = p:GetCities()
  return cities and cities:GetCount() or 0
end

local function AttachSurge(playerID)
  local p = Players[playerID]
  if not p then return end
  p:AttachModifierByID("WW2_STUBBORN_SURGE_PROD")
  p:AttachModifierByID("WW2_STUBBORN_SURGE_CS")
  if playerID == Game.GetLocalPlayer() then
    print("[WW2] National Stubbornness ACTIVATED: +25% Production & +8 CS for 25 turns")
  end
end

local function OnTurn(playerID, isFirstTime)
  if not isFirstTime or playerID < 0 then return end
  local p = Players[playerID]
  if not p or not p:IsMajor() or not p:IsAlive() then return end

  local lastCities = GetNum(playerID, "LAST_CITIES", -1)
  local activeTurns = GetNum(playerID, "ACTIVE", 0)
  local cooldownTurns = GetNum(playerID, "COOLDOWN", 0)
  local cities = GetCityCount(playerID)

  if lastCities < 0 then
    SetNum(playerID, "LAST_CITIES", cities)
    return
  end

  if cooldownTurns > 0 then
    cooldownTurns = cooldownTurns - 1
    SetNum(playerID, "COOLDOWN", cooldownTurns)
  end

  if activeTurns > 0 then
    activeTurns = activeTurns - 1
    SetNum(playerID, "ACTIVE", activeTurns)
    if activeTurns <= 0 then
      SetNum(playerID, "COOLDOWN", COOLDOWN)
      if playerID == Game.GetLocalPlayer() then
        print("[WW2] National Stubbornness ended. 5-turn cooldown.")
      end
    end
  end

  if cities < lastCities and activeTurns <= 0 and cooldownTurns <= 0 then
    SetNum(playerID, "ACTIVE", DURATION)
    AttachSurge(playerID)
  end

  SetNum(playerID, "LAST_CITIES", cities)
end

Events.PlayerTurnActivated.Add(OnTurn)
print("[WW2] National Stubbornness v2 loaded (save-safe)")
