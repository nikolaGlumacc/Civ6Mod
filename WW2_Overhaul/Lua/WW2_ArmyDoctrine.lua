-- WW2 Overhaul: Apply the selected Army Doctrine from Advanced Setup
-- Reads GameConfiguration value and gives every major player the matching combat bonus.

local DOCTRINE_MODIFIERS = {
  LIGHT  = "WW2_ARMY_LIGHT_CS",
  MEDIUM = "WW2_ARMY_MEDIUM_CS",
  HEAVY  = "WW2_ARMY_HEAVY_CS",
}

local function GetSelectedDoctrine()
  local value = GameConfiguration.GetValue("WW2_ARMY_DOCTRINE")
  if value == nil or value == "" then
    return "MEDIUM"   -- default
  end
  return string.upper(tostring(value))
end

local function ApplyDoctrineToPlayer(playerID, doctrine)
  local player = Players[playerID]
  if not player or not player:IsMajor() or not player:IsAlive() then return end

  local modifierId = DOCTRINE_MODIFIERS[doctrine]
  if not modifierId then
    print("[WW2_Overhaul] Unknown doctrine: " .. tostring(doctrine))
    return
  end

  -- Attach the modifier permanently to the player
  player:GetModifiers():AttachModifier(modifierId)
  print("[WW2_Overhaul] Applied " .. doctrine .. " Army Doctrine to player " .. playerID)
end

local function OnNewGameInitialized()
  local doctrine = GetSelectedDoctrine()
  print("[WW2_Overhaul] Selected Army Doctrine: " .. doctrine)

  for playerID = 0, 63 do
    ApplyDoctrineToPlayer(playerID, doctrine)
  end
end

-- Run once when the game starts
Events.LoadScreenClose.Add(function()
  OnNewGameInitialized()
end)

print("[WW2_Overhaul] Army Doctrine script loaded")
