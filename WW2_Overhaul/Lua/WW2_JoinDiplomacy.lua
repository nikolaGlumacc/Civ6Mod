-- WW2 Overhaul v1.3: Join as a diplomacy-style action
-- When dealing with another major civ you can propose:
--   1) YOU join THEM  (keep land, no independent army)
--   2) THEY join YOU  (they are absorbed / treated as conquered until released)
-- Acceptance depends on: relationship, relative strength (cities + military), and war state.

local function GetCityCount(playerID)
  local p = Players[playerID]
  if not p then return 0 end
  local c = p:GetCities()
  return c and c:GetCount() or 0
end

local function GetMilitaryStrength(playerID)
  -- Rough proxy: number of combat units
  local p = Players[playerID]
  if not p then return 0 end
  local units = p:GetUnits()
  if not units then return 0 end
  local n = 0
  for _, u in units:Members() do
    local info = GameInfo.Units[u:GetType()]
    if info and (info.Combat or 0) > 0 then
      n = n + 1
    end
  end
  return n
end

local function GetRelationshipScore(fromID, toID)
  -- Simplified: use diplomacy state if available
  local p = Players[fromID]
  if not p then return 0 end
  local dip = p:GetDiplomacy()
  if not dip then return 0 end
  if dip:IsAtWarWith(toID) then return -100 end
  -- Friendship / alliance would be positive; we approximate
  return 0  -- baseline; real relation API varies by version
end

-- Will they accept YOU joining THEM?
-- Easier if they like you and they are stronger (or equal).
function WW2_CanJoinThem(youID, themID)
  if youID == themID then return false, "Same player" end
  local rel = GetRelationshipScore(themID, youID)
  local yourCities = GetCityCount(youID)
  local theirCities = GetCityCount(themID)
  local yourMil = GetMilitaryStrength(youID)
  local theirMil = GetMilitaryStrength(themID)

  if rel <= -50 then
    return false, "They hate you / at war"
  end
  -- Prefer joining a stronger or similar power
  if theirCities + theirMil < (yourCities + yourMil) * 0.6 then
    return false, "They are much weaker than you"
  end
  return true, "OK"
end

-- Will THEY accept joining YOU?
-- Needs high relation OR you much stronger (intimidation / defeat).
function WW2_CanTheyJoinYou(youID, themID)
  if youID == themID then return false, "Same player" end
  local rel = GetRelationshipScore(themID, youID)
  local yourCities = GetCityCount(youID)
  local theirCities = GetCityCount(themID)
  local yourMil = GetMilitaryStrength(youID)
  local theirMil = GetMilitaryStrength(themID)

  local youStronger = (yourCities + yourMil) > (theirCities + theirMil) * 1.4
  if rel > 30 or youStronger then
    return true, "OK"
  end
  if rel <= -50 then
    return false, "They refuse (hostile)"
  end
  return false, "Not friendly enough and not strong enough"
end

-- Apply: YOU join THEM (subordinate)
function WW2_DoJoinThem(youID, themID)
  local ok, reason = WW2_CanJoinThem(youID, themID)
  if not ok then
    print("[WW2] Cannot join them: " .. tostring(reason))
    return false
  end
  local you = Players[youID]
  if not you then return false end
  -- Attach the no-army + keep building modifiers
  you:AttachModifierByID("WW2_JOIN_NO_UNITS")
  you:AttachModifierByID("WW2_JOIN_BUILD_PROD")
  you:AttachModifierByID("WW2_JOIN_CS_DEF")
  print("[WW2] Player " .. youID .. " joined player " .. themID .. " (keep land, no independent army)")
  return true
end

-- Apply: THEY join YOU (absorb)
-- Practical effect: mark as defeated relationship; full city transfer is
-- left to the player via peace deals / conquest to avoid breaking the game.
function WW2_DoTheyJoinYou(youID, themID)
  local ok, reason = WW2_CanTheyJoinYou(youID, themID)
  if not ok then
    print("[WW2] They will not join you: " .. tostring(reason))
    return false
  end
  print("[WW2] Player " .. themID .. " agrees to join player " .. youID)
  print("[WW2] Treat as conquered: take cities in peace or they remain until you release / someone liberates.")
  return true
end

-- Debug helpers for local player
function WW2_TryJoinLocal(themID)
  return WW2_DoJoinThem(Game.GetLocalPlayer(), themID)
end

function WW2_TryAbsorbLocal(themID)
  return WW2_DoTheyJoinYou(Game.GetLocalPlayer(), themID)
end

print("[WW2] Join Diplomacy v1.3 loaded")
print("[WW2] Use WW2_TryJoinLocal(otherPlayerID) or WW2_TryAbsorbLocal(otherPlayerID) from Firetuner for now")
print("[WW2] Full in-diplomacy buttons need a UI addin (next step)")
