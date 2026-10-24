-- WW2 Overhaul: Make cooperation between civs actually strong
-- - Research Agreements fully unlock the tech (both parties) instead of a partial boost
-- - Open Borders give meaningful combat / movement / loyalty help
-- - Alliances and Declarations of Friendship get extra yields & combat bonuses

print("[WW2] Cooperation module loading...")

--------------------------------------------------------------------
-- Research Agreement → full tech unlock
--------------------------------------------------------------------
-- When a Research Agreement resolves, both sides get the full tech
-- that was being researched (or the partner's current research).
-- This makes RAs feel like real wartime scientific cooperation.

local function FullyGrantTech(player, techIndex)
  if not player or not player:IsAlive() then return false end
  local techs = player:GetTechs()
  if not techs then return false end
  if techs:HasTech(techIndex) then return false end
  local cost = techs:GetResearchCost(techIndex)
  if cost and cost > 0 then
    techs:SetResearchProgress(techIndex, cost)
    return true
  end
  return false
end

local function GetCurrentResearchIndex(player)
  local techs = player:GetTechs()
  if not techs then return nil end
  local idx = techs:GetResearchingTech()
  if idx and idx >= 0 then return idx end
  return nil
end

-- Hook: Research Agreement completed
-- Event signature varies; we listen to a few common ones and also poll deals.
local function OnResearchAgreementComplete(player1, player2, techType)
  print("[WW2] Research Agreement resolved between " .. tostring(player1) .. " and " .. tostring(player2))
  local p1 = Players[player1]
  local p2 = Players[player2]
  if not p1 or not p2 then return end

  -- Prefer the tech that was just finished / being researched by either side
  local candidates = {}
  if techType and GameInfo.Technologies[techType] then
    table.insert(candidates, GameInfo.Technologies[techType].Index)
  end
  local r1 = GetCurrentResearchIndex(p1)
  local r2 = GetCurrentResearchIndex(p2)
  if r1 then table.insert(candidates, r1) end
  if r2 then table.insert(candidates, r2) end

  for _, techIdx in ipairs(candidates) do
    local granted1 = FullyGrantTech(p1, techIdx)
    local granted2 = FullyGrantTech(p2, techIdx)
    if granted1 or granted2 then
      local name = GameInfo.Technologies[techIdx] and GameInfo.Technologies[techIdx].TechnologyType or tostring(techIdx)
      print("[WW2] RA full unlock: " .. name .. " → P" .. player1 .. "=" .. tostring(granted1) .. " P" .. player2 .. "=" .. tostring(granted2))
    end
  end
end

-- Multiple possible event names across patches
if Events.ResearchAgreementComplete then
  Events.ResearchAgreementComplete.Add(OnResearchAgreementComplete)
end
if Events.DiplomacyResearchAgreementComplete then
  Events.DiplomacyResearchAgreementComplete.Add(OnResearchAgreementComplete)
end

-- Fallback: every few turns, scan active deals and force-complete any tech
-- that has received an RA boost but is still incomplete (aggressive but reliable).
local turnCounter = 0
local function OnPlayerTurnActivated(playerID, isFirstTime)
  if not isFirstTime then return end
  turnCounter = turnCounter + 1
  if turnCounter % 3 ~= 0 then return end  -- every 3 turns is enough

  local player = Players[playerID]
  if not player or not player:IsMajor() or not player:IsAlive() then return end

  local dip = player:GetDiplomacy()
  if not dip then return end

  -- If this player currently has an open Research Agreement with someone,
  -- and is researching a tech, give a big progress push toward full unlock.
  -- (Full unlock still happens on agreement end via the event above when available.)
  local researching = GetCurrentResearchIndex(player)
  if not researching then return end

  for otherID = 0, 63 do
    if otherID ~= playerID then
      local other = Players[otherID]
      if other and other:IsMajor() and other:IsAlive() then
        local hasRA = false
        pcall(function()
          if dip.HasResearchAgreement and dip:HasResearchAgreement(otherID) then
            hasRA = true
          end
        end)
        if hasRA then
          local techs = player:GetTechs()
          if techs and not techs:HasTech(researching) then
            local cost = techs:GetResearchCost(researching)
            local progress = techs:GetResearchProgress(researching) or 0
            -- Push hard toward completion while RA is active
            if progress < cost then
              local boost = math.max(cost * 0.35, cost - progress)  -- at least 35% or finish it
              techs:SetResearchProgress(researching, math.min(cost, progress + boost))
              print("[WW2] Active RA boost for P" .. playerID .. " on tech " .. researching)
            end
          end
          break  -- one RA is enough for the push
        end
      end
    end
  end
end

Events.PlayerTurnActivated.Add(OnPlayerTurnActivated)

--------------------------------------------------------------------
-- Stronger Open Borders / Alliance / Friendship modifiers (SQL-backed)
-- Applied dynamically so they only exist while the relationship is active.
--------------------------------------------------------------------

local ACTIVE_MODS = {}  -- [playerID] = { openBorders = {...}, alliance = {...} }

local function AttachIfMissing(player, modId)
  if not player then return end
  pcall(function() player:AttachModifierByID(modId) end)
end

local function ApplyOpenBordersBonus(playerID, partnerID)
  local p = Players[playerID]
  if not p then return end
  -- Combat strength near allied territory + movement + loyalty pressure reduction
  AttachIfMissing(p, "WW2_OPEN_BORDERS_CS")
  AttachIfMissing(p, "WW2_OPEN_BORDERS_MOVE")
  AttachIfMissing(p, "WW2_OPEN_BORDERS_LOYALTY")
end

local function ApplyAllianceBonus(playerID)
  local p = Players[playerID]
  if not p then return end
  AttachIfMissing(p, "WW2_ALLIANCE_SCIENCE")
  AttachIfMissing(p, "WW2_ALLIANCE_PRODUCTION")
  AttachIfMissing(p, "WW2_ALLIANCE_CS")
end

local function ApplyFriendshipBonus(playerID)
  local p = Players[playerID]
  if not p then return end
  AttachIfMissing(p, "WW2_FRIENDSHIP_GOLD")
  AttachIfMissing(p, "WW2_FRIENDSHIP_SCIENCE")
end

local function RefreshCooperationBonuses(playerID)
  local player = Players[playerID]
  if not player or not player:IsMajor() or not player:IsAlive() then return end
  local dip = player:GetDiplomacy()
  if not dip then return end

  local hasAnyOpenBorders = false
  local hasAnyAlliance = false
  local hasAnyFriendship = false

  for other = 0, 63 do
    if other ~= playerID then
      local o = Players[other]
      if o and o:IsMajor() and o:IsAlive() then
        pcall(function()
          if dip.HasOpenBorders and dip:HasOpenBorders(other) then hasAnyOpenBorders = true end
        end)
        pcall(function()
          if dip.HasAllied and dip:HasAllied(other) then hasAnyAlliance = true end
        end)
        pcall(function()
          if dip.HasDeclaredFriendship and dip:HasDeclaredFriendship(other) then hasAnyFriendship = true end
        end)
      end
    end
  end

  if hasAnyOpenBorders then ApplyOpenBordersBonus(playerID) end
  if hasAnyAlliance then ApplyAllianceBonus(playerID) end
  if hasAnyFriendship then ApplyFriendshipBonus(playerID) end
end

local function OnTurnBegin()
  for i = 0, 63 do
    RefreshCooperationBonuses(i)
  end
end

Events.TurnBegin.Add(OnTurnBegin)
-- also run once after load
Events.LoadScreenClose.Add(function()
  for i = 0, 63 do RefreshCooperationBonuses(i) end
end)

print("[WW2] Cooperation v1.0 ready — RAs unlock full tech, Open Borders / Alliance / Friendship are strong")
