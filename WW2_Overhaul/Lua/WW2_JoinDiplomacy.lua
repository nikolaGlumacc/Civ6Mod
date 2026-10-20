-- Join diplomacy:
-- 1) YOU join THEM: keep land, -100% unit Production (no independent army)
-- 2) THEY join YOU: absorb (transfer cities when API allows; else subordinate them)
-- Acceptance = relationship + relative strength (cities + military).

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
  -- Best-effort friendship / alliance checks across API variants
  local score = 0
  pcall(function()
    if dip.HasAllied and dip:HasAllied(toID) then score = score + 50 end
  end)
  pcall(function()
    if dip.HasDeclaredFriendship and dip:HasDeclaredFriendship(toID) then score = score + 30 end
  end)
  return score
end

function WW2_CanJoinThem(youID, themID)
  if youID == themID then return false, "Same player" end
  local rel = GetRelationshipScore(themID, youID)
  local yourPower = GetCityCount(youID) + GetMilitaryStrength(youID)
  local theirPower = GetCityCount(themID) + GetMilitaryStrength(themID)
  if rel <= -50 then return false, "Hostile / at war" end
  if theirPower < yourPower * 0.6 then return false, "They are much weaker" end
  return true, "OK"
end

function WW2_CanTheyJoinYou(youID, themID)
  if youID == themID then return false, "Same player" end
  local rel = GetRelationshipScore(themID, youID)
  local yourPower = GetCityCount(youID) + GetMilitaryStrength(youID)
  local theirPower = GetCityCount(themID) + GetMilitaryStrength(themID)
  local youStronger = yourPower > theirPower * 1.4
  if rel > 30 or youStronger then return true, "OK" end
  if rel <= -50 then return false, "Hostile" end
  return false, "Not friendly enough / not strong enough"
end

function WW2_DoJoinThem(youID, themID)
  local ok, reason = WW2_CanJoinThem(youID, themID)
  if not ok then
    print("[WW2] Cannot join them: " .. tostring(reason))
    return false
  end
  local you = Players[youID]
  if not you then return false end
  you:AttachModifierByID("WW2_JOIN_NO_UNITS")
  you:AttachModifierByID("WW2_JOIN_BUILD_PROD")
  you:AttachModifierByID("WW2_JOIN_CS_DEF")
  GameConfiguration.SetValue("WW2_JOINED_UNDER_" .. tostring(youID), themID)
  print("[WW2] Player " .. youID .. " joined " .. themID .. " (keep land, no independent army)")
  return true
end

local function TryTransferCities(fromID, toID)
  local from = Players[fromID]
  if not from then return 0 end
  local cities = from:GetCities()
  if not cities then return 0 end
  local transferred = 0
  local targets = {}
  for _, city in cities:Members() do
    table.insert(targets, { x = city:GetX(), y = city:GetY() })
  end
  for _, t in ipairs(targets) do
    local ok = pcall(function()
      local city = CityManager.GetCityAt(t.x, t.y)
      if city == nil and Cities and Cities.GetCityInPlot then
        city = Cities.GetCityInPlot(t.x, t.y)
      end
      if city and CityManager.TransferCity then
        CityManager.TransferCity(city, toID)
        transferred = transferred + 1
      elseif city and city.ChangeOwner then
        city:ChangeOwner(toID)
        transferred = transferred + 1
      end
    end)
    if not ok then
      -- ignore single-city failures
    end
  end
  return transferred
end

function WW2_DoTheyJoinYou(youID, themID)
  local ok, reason = WW2_CanTheyJoinYou(youID, themID)
  if not ok then
    print("[WW2] They will not join you: " .. tostring(reason))
    return false
  end
  local n = TryTransferCities(themID, youID)
  if n > 0 then
    print("[WW2] Absorbed " .. n .. " cities from player " .. themID .. " into " .. youID)
  else
    -- Fallback: subordinate them (no army) until released by conquest/liberation elsewhere
    local them = Players[themID]
    if them then
      them:AttachModifierByID("WW2_JOIN_NO_UNITS")
      them:AttachModifierByID("WW2_JOIN_BUILD_PROD")
    end
    print("[WW2] City transfer unavailable — subordinated player " .. themID .. " (no independent army).")
  end
  GameConfiguration.SetValue("WW2_ABSORBED_" .. tostring(themID), youID)
  return true
end

function WW2_TryJoinLocal(themID)
  return WW2_DoJoinThem(Game.GetLocalPlayer(), themID)
end

function WW2_TryAbsorbLocal(themID)
  return WW2_DoTheyJoinYou(Game.GetLocalPlayer(), themID)
end

print("[WW2] Join Diplomacy v2 loaded")
print("[WW2] Firetuner: WW2_TryJoinLocal(id) / WW2_TryAbsorbLocal(id)")
print("[WW2] Soft coop without giving up army: Axis Align / Comintern policies")
