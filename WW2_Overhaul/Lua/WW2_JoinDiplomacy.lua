-- Join / Leave / Absorb (annex)
-- Firetuner:
--   WW2_TryJoinLocal(themID)     -- you join them: keep land, no independent army
--   WW2_TryAbsorbLocal(themID)   -- they join you: transfer cities / subordinate
--   WW2_TryLeaveLocal()          -- leave subordination, restore unit production

local function GetCityCount(playerID)
  local p = Players[playerID]
  if not p then return 0 end
  local c = p:GetCities()
  return c and c:GetCount() or 0
end

local function GetMilitaryStrength(playerID)
  local p = Players[playerID]
  if not p then return 0 end
  local units = p:GetUnits()
  if not units then return 0 end
  local n = 0
  for _, u in units:Members() do
    local info = GameInfo.Units[u:GetType()]
    if info and (info.Combat or 0) > 0 then n = n + 1 end
  end
  return n
end

local function GetRelationshipScore(fromID, toID)
  local p = Players[fromID]
  if not p then return 0 end
  local dip = p:GetDiplomacy()
  if not dip then return 0 end
  if dip.IsAtWarWith and dip:IsAtWarWith(toID) then return -100 end
  local score = 0
  pcall(function()
    if dip.HasAllied and dip:HasAllied(toID) then score = score + 50 end
  end)
  pcall(function()
    if dip.HasDeclaredFriendship and dip:HasDeclaredFriendship(toID) then score = score + 30 end
  end)
  return score
end

local function Power(id)
  return GetCityCount(id) + GetMilitaryStrength(id)
end

function WW2_CanJoinThem(youID, themID)
  if youID == themID then return false, "Same player" end
  if not Players[themID] or not Players[themID]:IsAlive() then return false, "Target dead" end
  local rel = GetRelationshipScore(themID, youID)
  if rel <= -50 then return false, "Hostile / at war" end
  if Power(themID) < Power(youID) * 0.55 then return false, "They are much weaker" end
  return true, "OK"
end

function WW2_CanTheyJoinYou(youID, themID)
  if youID == themID then return false, "Same player" end
  if not Players[themID] or not Players[themID]:IsAlive() then return false, "Target dead" end
  local rel = GetRelationshipScore(themID, youID)
  local youStronger = Power(youID) > Power(themID) * 1.35
  if rel > 25 or youStronger then return true, "OK" end
  if rel <= -50 then return false, "Hostile" end
  return false, "Not friendly / not strong enough"
end

local function ApplySubordinate(playerID, masterID)
  local p = Players[playerID]
  if not p then return end
  p:AttachModifierByID("WW2_JOIN_NO_UNITS")
  p:AttachModifierByID("WW2_JOIN_BUILD_PROD")
  p:AttachModifierByID("WW2_JOIN_CS_DEF")
  GameConfiguration.SetValue("WW2_JOINED_UNDER_" .. tostring(playerID), masterID)
  GameConfiguration.SetValue("WW2_IS_SUBORDINATE_" .. tostring(playerID), 1)
end

function WW2_DoJoinThem(youID, themID)
  local ok, reason = WW2_CanJoinThem(youID, themID)
  if not ok then
    print("[WW2] Cannot join them: " .. tostring(reason))
    return false
  end
  ApplySubordinate(youID, themID)
  print("[WW2] Player " .. youID .. " JOINS " .. themID .. " (keep land, no independent army)")
  return true
end

local function TryTransferCities(fromID, toID)
  local from = Players[fromID]
  if not from then return 0 end
  local cities = from:GetCities()
  if not cities then return 0 end
  local targets = {}
  for _, city in cities:Members() do
    table.insert(targets, { x = city:GetX(), y = city:GetY() })
  end
  local n = 0
  for _, t in ipairs(targets) do
    pcall(function()
      local city = nil
      if CityManager and CityManager.GetCityAt then
        city = CityManager.GetCityAt(t.x, t.y)
      end
      if city == nil and Cities and Cities.GetCityInPlot then
        city = Cities.GetCityInPlot(t.x, t.y)
      end
      if city and CityManager and CityManager.TransferCity then
        CityManager.TransferCity(city, toID)
        n = n + 1
      elseif city and city.ChangeOwner then
        city:ChangeOwner(toID)
        n = n + 1
      end
    end)
  end
  return n
end

function WW2_DoTheyJoinYou(youID, themID)
  local ok, reason = WW2_CanTheyJoinYou(youID, themID)
  if not ok then
    print("[WW2] They will not join you: " .. tostring(reason))
    return false
  end
  local transferred = TryTransferCities(themID, youID)
  if transferred > 0 then
    GameConfiguration.SetValue("WW2_ABSORBED_" .. tostring(themID), youID)
    print("[WW2] ANNEX: transferred " .. transferred .. " cities from " .. themID .. " to " .. youID)
  else
    ApplySubordinate(themID, youID)
    print("[WW2] ANNEX fallback: subordinated player " .. themID .. " (no independent army)")
  end
  return true
end

-- Leave: clear subordinate flag. (Cannot always detach modifiers in Civ6; unit prod returns on new game / via opposite +100% if needed)
function WW2_DoLeave(youID)
  local under = GameConfiguration.GetValue("WW2_JOINED_UNDER_" .. tostring(youID))
  if under == nil and GameConfiguration.GetValue("WW2_IS_SUBORDINATE_" .. tostring(youID)) ~= 1 then
    print("[WW2] Not currently subordinate")
    return false
  end
  GameConfiguration.SetValue("WW2_JOINED_UNDER_" .. tostring(youID), nil)
  GameConfiguration.SetValue("WW2_IS_SUBORDINATE_" .. tostring(youID), 0)
  -- Compensating production so player can field an army again after leaving
  local p = Players[youID]
  if p then
    pcall(function() p:AttachModifierByID("WW2_JOIN_BUILD_PROD") end)
  end
  print("[WW2] Player " .. youID .. " LEFT subordination (was under " .. tostring(under) .. ")")
  return true
end

function WW2_TryJoinLocal(themID)
  return WW2_DoJoinThem(Game.GetLocalPlayer(), themID)
end

function WW2_TryAbsorbLocal(themID)
  return WW2_DoTheyJoinYou(Game.GetLocalPlayer(), themID)
end

function WW2_TryLeaveLocal()
  return WW2_DoLeave(Game.GetLocalPlayer())
end

print("[WW2] Join Diplomacy v2.2 — Join / Absorb / Leave")
print("[WW2] Firetuner: WW2_TryJoinLocal(id) | WW2_TryAbsorbLocal(id) | WW2_TryLeaveLocal()")
