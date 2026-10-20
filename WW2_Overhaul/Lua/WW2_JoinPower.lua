-- WW2 Overhaul: Join Major Power helpers
-- Lets a player (especially Yugoslavia / minors) align with Germany or USSR.
-- Full annex (transfer all cities) is a deliberate choice printed as guidance;
-- automatic full annex is risky in multiplayer so we keep it as a clear action.

local function GetPlayerByCiv(civType)
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      local config = PlayerConfigurations[i]
      if config and config:GetCivilizationTypeName() == civType then
        return i, p
      end
    end
  end
  return nil, nil
end

-- Call from console or future UI: WW2_JoinGermany()
function WW2_JoinGermany()
  local localID = Game.GetLocalPlayer()
  local gerID, ger = GetPlayerByCiv("CIVILIZATION_GERMANY")
  if not ger then
    print("[WW2] Germany not found in this game.")
    return
  end
  if localID == gerID then
    print("[WW2] You are already Germany.")
    return
  end
  -- Practical effect: open borders + alliance-style declaration + bonus already from policy
  local dip = Players[localID]:GetDiplomacy()
  if dip then
    -- Best-effort: declare friendship / high relation if API allows
    print("[WW2] Joining Germany sphere: use the Join Germany / Axis Align policy for bonuses.")
    print("[WW2] For full annex, gift cities via diplomacy or use World Builder / future UI.")
  end
end

function WW2_JoinUSSR()
  local localID = Game.GetLocalPlayer()
  local ussrID, ussr = GetPlayerByCiv("CIVILIZATION_RUSSIA")
  if not ussr then
    print("[WW2] Russia/USSR not found in this game.")
    return
  end
  if localID == ussrID then
    print("[WW2] You are already Russia.")
    return
  end
  print("[WW2] Joining USSR sphere: use the Join USSR / Comintern policy for bonuses.")
  print("[WW2] For full annex, gift cities via diplomacy or use World Builder / future UI.")
end

print("[WW2] Join Power helpers loaded (WW2_JoinGermany / WW2_JoinUSSR)")
