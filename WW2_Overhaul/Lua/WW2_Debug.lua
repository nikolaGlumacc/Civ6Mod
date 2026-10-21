-- Temporary WW2 debug toolkit (same spirit as SerbiaCheats).
-- Firetuner / console:
--   ExposedMembers.WW2Debug.Apply("reveal")
--   ExposedMembers.WW2Debug.Apply("tsl")
--   ExposedMembers.WW2Debug.Apply("gold")
--   ExposedMembers.WW2Debug.Apply("godmode")
--   ExposedMembers.WW2Debug.Apply("dump_starts")

local ENABLE = true

if not ENABLE then
  ExposedMembers.WW2Debug = { Apply = function() end }
  print("[WW2 Debug] disabled")
  return
end

local function LP()
  local id = Game.GetLocalPlayer()
  if id == nil or id < 0 then return nil, nil end
  return id, Players[id]
end

local function CapXY(p)
  local c = p:GetCities():GetCapitalCity()
  if c then return c:GetX(), c:GetY(), c end
  for _, u in p:GetUnits():Members() do
    return u:GetX(), u:GetY(), nil
  end
  return nil
end

local function Spawn(p, unitType)
  local row = GameInfo.Units[unitType]
  local x, y = CapXY(p)
  if not row or not x then return end
  pcall(function() p:GetUnits():Create(row.Index, x, y) end)
end

local function Reveal(id)
  local vis = PlayersVisibility[id]
  if not vis then return end
  for i = 0, Map.GetPlotCount() - 1 do
    pcall(function() vis:ChangeVisibilityCount(i, 1) end)
  end
  print("[WW2 Debug] map revealed")
end

local function DumpStarts()
  print("===== WW2 START DUMP =====")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      local cfg = PlayerConfigurations[i]
      local civ = cfg and cfg:GetCivilizationTypeName() or "?"
      local cap = p:GetCities():GetCapitalCity()
      if cap then
        print(string.format("  P%d %s capital (%d,%d) cities=%d",
          i, civ, cap:GetX(), cap:GetY(), p:GetCities():GetCount()))
      else
        local ux, uy = CapXY(p)
        print(string.format("  P%d %s NO capital units@(%s,%s)", i, civ, tostring(ux), tostring(uy)))
      end
    end
  end
  print("===== END =====")
end

local function Apply(cheat)
  local id, p = LP()
  if not p then print("[WW2 Debug] no local player") return end

  if cheat == "gold" then
    p:GetTreasury():ChangeGoldBalance(5000)
  elseif cheat == "gold_mega" then
    p:GetTreasury():ChangeGoldBalance(100000)
  elseif cheat == "reveal" then
    Reveal(id)
  elseif cheat == "tsl" then
    if WW2_ApplyAllTSL then WW2_ApplyAllTSL() else print("WW2_TSL not loaded") end
  elseif cheat == "dump_starts" then
    DumpStarts()
  elseif cheat == "settler" then
    Spawn(p, "UNIT_SETTLER")
  elseif cheat == "builder" then
    Spawn(p, "UNIT_BUILDER")
  elseif cheat == "tank" then
    Spawn(p, "UNIT_TANK")
  elseif cheat == "infantry" then
    Spawn(p, "UNIT_INFANTRY")
  elseif cheat == "heal" then
    for _, u in p:GetUnits():Members() do
      pcall(function() u:SetDamage(0) end)
      pcall(function() u:ChangeDamage(-1000) end)
    end
  elseif cheat == "pop" then
    for _, c in p:GetCities():Members() do
      pcall(function() c:ChangePopulation(3) end)
    end
  elseif cheat == "finish_prod" then
    for _, c in p:GetCities():Members() do
      pcall(function() c:GetBuildQueue():FinishProgress() end)
    end
  elseif cheat == "godmode" then
    p:GetTreasury():ChangeGoldBalance(999999)
    Reveal(id)
    if WW2_ApplyAllTSL then WW2_ApplyAllTSL() end
    for _, c in p:GetCities():Members() do
      pcall(function() c:ChangePopulation(5) end)
      pcall(function() c:GetBuildQueue():FinishProgress() end)
    end
    Spawn(p, "UNIT_TANK")
    Spawn(p, "UNIT_TANK")
    Spawn(p, "UNIT_INFANTRY")
    Spawn(p, "UNIT_INFANTRY")
    Spawn(p, "UNIT_BUILDER")
    print("[WW2 Debug] GODMODE")
  else
    print("[WW2 Debug] unknown: " .. tostring(cheat))
    print("  gold | gold_mega | reveal | tsl | dump_starts | settler | builder | tank | infantry | heal | pop | finish_prod | godmode")
  end
end

ExposedMembers.WW2Debug = ExposedMembers.WW2Debug or {}
ExposedMembers.WW2Debug.Apply = Apply
ExposedMembers.WW2Debug.DumpStarts = DumpStarts

-- Shortcuts
function WW2_Debug(cmd) return Apply(cmd) end
function WW2_Reveal() return Apply("reveal") end
function WW2_TSL() return Apply("tsl") end
function WW2_DumpStarts() return Apply("dump_starts") end

print("[WW2 Debug] ready — Firetuner: WW2_Debug(\"reveal\"), WW2_Debug(\"tsl\"), WW2_Debug(\"godmode\")")
