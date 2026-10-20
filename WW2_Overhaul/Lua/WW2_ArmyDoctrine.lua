-- WW2 Overhaul v1.0: Apply selected Army Doctrine from Advanced Setup

local MODIFIERS = {
  LIGHT  = "WW2_ARMY_LIGHT_CS",
  MEDIUM = "WW2_ARMY_MEDIUM_CS",
  HEAVY  = "WW2_ARMY_HEAVY_CS",
}

local function GetDoctrine()
  local v = GameConfiguration.GetValue("WW2_ARMY_DOCTRINE")
  if not v or v == "" then return "MEDIUM" end
  return string.upper(tostring(v))
end

local function Apply(playerID, doctrine)
  local p = Players[playerID]
  if not p or not p:IsMajor() or not p:IsAlive() then return end
  local mod = MODIFIERS[doctrine]
  if mod then
    p:AttachModifierByID(mod)
    print("[WW2] Army Doctrine " .. doctrine .. " applied to player " .. playerID)
  end
end

local function OnStart()
  local doctrine = GetDoctrine()
  print("[WW2] Selected Army Doctrine: " .. doctrine)
  for i = 0, 63 do
    Apply(i, doctrine)
  end
end

Events.LoadScreenClose.Add(OnStart)
print("[WW2] Army Doctrine v1.0 loaded")
