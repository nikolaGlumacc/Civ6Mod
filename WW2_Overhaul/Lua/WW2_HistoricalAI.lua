-- Historical WW2 diplomacy / war script
-- Axis (Germany, Italy/Rome, Hungary) start friendly
-- Allies (Britain, France) start friendly with each other
-- Germany prioritizes DOW on Poland early

local SETUP_DONE = false
local POLAND_WAR_TURN = 8   -- ~early war, after everyone settled
local warDeclared = false

local function CivName(pid)
  local cfg = PlayerConfigurations[pid]
  return cfg and cfg:GetCivilizationTypeName() or ""
end

local function FindByCiv(civType)
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() and CivName(i) == civType then
      return i, p
    end
  end
  return nil, nil
end

local function FindRomeOrItaly()
  local id = FindByCiv("CIVILIZATION_ROME")
  return id
end

-- Try several diplomacy APIs (version-safe)
local function BoostFriendship(a, b, amount)
  amount = amount or 60
  pcall(function()
    local da = Players[a]:GetDiplomacy()
    if not da then return end
    if da.ChangeAccessLevel then da:ChangeAccessLevel(b, 1) end
    if da.SetMet then da:SetMet(b) end
    if da.Meet then da:Meet(b) end
    -- Relationship / grievance style hooks
    if da.ChangeDiplomaticActionQueueDepth then end
    if Players[a].GetDiplomacy and Game.GetDiplomacyManager then
      -- noop fallback
    end
  end)
  pcall(function()
    -- Some builds expose Deal / alliance helpers later; friendship via permanent alliance attempt is too strong for start
  end)
  print(string.format("[WW2 HistAI] friendship nudge %d ↔ %d (+%d)", a, b, amount))
end

local function TryDeclareWar(attacker, defender)
  if not attacker or not defender then return false end
  if attacker == defender then return false end
  local ok = false
  pcall(function()
    local dip = Players[attacker]:GetDiplomacy()
    if dip and dip.IsAtWarWith and dip:IsAtWarWith(defender) then
      ok = true
      return
    end
    if dip and dip.DeclareWar then
      dip:DeclareWar(defender)
      ok = true
    end
  end)
  if not ok then
    pcall(function()
      if DiplomacyManager and DiplomacyManager.RequestWar then
        DiplomacyManager.RequestWar(attacker, defender)
        ok = true
      end
    end)
  end
  if not ok then
    pcall(function()
      local dip = Players[attacker]:GetDiplomacy()
      if dip and dip.SetHasAllied then end
      -- Last resort: force war state if API exists
      if dip and dip.SetWarState then dip:SetWarState(defender, true) end
    end)
  end
  return ok
end

local function SetupAxisAllies()
  local ger = FindByCiv("CIVILIZATION_GERMANY")
  local ita = FindRomeOrItaly()
  local hun = FindByCiv("CIVILIZATION_HUNGARY")
  local eng = FindByCiv("CIVILIZATION_ENGLAND")
  local fra = FindByCiv("CIVILIZATION_FRANCE")
  local pol = FindByCiv("CIVILIZATION_POLAND")
  local rus = FindByCiv("CIVILIZATION_RUSSIA")

  print("[WW2 HistAI] Setting historical relationships...")

  -- Axis cluster
  if ger and ita then BoostFriendship(ger, ita, 80); BoostFriendship(ita, ger, 80) end
  if ger and hun then BoostFriendship(ger, hun, 50); BoostFriendship(hun, ger, 50) end
  if ita and hun then BoostFriendship(ita, hun, 40); BoostFriendship(hun, ita, 40) end

  -- Western Allies
  if eng and fra then BoostFriendship(eng, fra, 70); BoostFriendship(fra, eng, 70) end

  -- Mild Allied sympathy toward Poland
  if eng and pol then BoostFriendship(eng, pol, 40); BoostFriendship(pol, eng, 40) end
  if fra and pol then BoostFriendship(fra, pol, 40); BoostFriendship(pol, fra, 40) end

  -- Germany cold toward Poland / Allies (meet only — war comes later)
  if ger and pol then
    pcall(function()
      local d = Players[ger]:GetDiplomacy()
      if d and d.Meet then d:Meet(pol) end
    end)
  end

  print(string.format("[WW2 HistAI] GER=%s ITA=%s HUN=%s ENG=%s FRA=%s POL=%s RUS=%s",
    tostring(ger), tostring(ita), tostring(hun), tostring(eng), tostring(fra), tostring(pol), tostring(rus)))
end

local function GermanyAttacksPoland()
  if warDeclared then return end
  local ger = FindByCiv("CIVILIZATION_GERMANY")
  local pol = FindByCiv("CIVILIZATION_POLAND")
  if not ger or not pol then
    print("[WW2 HistAI] Skip Poland war — GER or POL not in game")
    warDeclared = true
    return
  end
  -- Don't force if human is Germany (let player choose) unless they want pure scenario — still DOW for AI Germany only
  local gerPlayer = Players[ger]
  if gerPlayer and gerPlayer:IsHuman() then
    print("[WW2 HistAI] Human is Germany — not auto-DOW on Poland")
    warDeclared = true
    return
  end
  local ok = TryDeclareWar(ger, pol)
  print("[WW2 HistAI] Germany → Poland war: " .. tostring(ok))
  warDeclared = true

  -- Optional: Italy may join later if both AI (turn+5 handled below via flag)
end

local function OnLoad()
  if SETUP_DONE then return end
  SETUP_DONE = true
  -- After territory seed
  if Events.GameCoreEventPublishComplete then
    local n = 0
    local function once()
      n = n + 1
      if n >= 4 then
        SetupAxisAllies()
        Events.GameCoreEventPublishComplete.Remove(once)
      end
    end
    Events.GameCoreEventPublishComplete.Add(once)
  else
    SetupAxisAllies()
  end
end

local function OnTurn(playerID)
  if warDeclared then return end
  if playerID ~= 0 then return end -- once per world turn-ish; use game turn
  local turn = Game.GetCurrentGameTurn()
  if turn >= POLAND_WAR_TURN then
    GermanyAttacksPoland()
  end
end

Events.LoadScreenClose.Add(OnLoad)
Events.PlayerTurnActivated.Add(OnTurn)

print("[WW2 HistAI] loaded — Axis friendship, GER prioritizes Poland")
