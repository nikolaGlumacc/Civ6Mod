-- Temporary WW2 debug (Serbia-style)
-- Firetuner: WW2_Debug("reveal") | "tsl" | "godmode" | "dump_starts"

local ENABLE = true
if not ENABLE then
  ExposedMembers.WW2Debug = { Apply = function() end }
  return
end

local function LP()
  local id = Game.GetLocalPlayer()
  if id == nil or id < 0 then return nil, nil end
  return id, Players[id]
end

local function CapXY(p)
  local c = p:GetCities():GetCapitalCity()
  if c then return c:GetX(), c:GetY() end
  for _, u in p:GetUnits():Members() do return u:GetX(), u:GetY() end
  return nil
end

local function Spawn(p, unitType)
  local row = GameInfo.Units[unitType]
  local x, y = CapXY(p)
  if row and x then pcall(function() p:GetUnits():Create(row.Index, x, y) end) end
end

local function DumpStarts()
  print("===== WW2 NATIONS =====")
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      local cfg = PlayerConfigurations[i]
      local civ = cfg and cfg:GetCivilizationTypeName() or "?"
      local n = p:GetCities():GetCount()
      local cap = p:GetCities():GetCapitalCity()
      if cap then
        print(string.format("  P%d %s cities=%d capital=(%d,%d)", i, civ, n, cap:GetX(), cap:GetY()))
      else
        print(string.format("  P%d %s cities=0 (no capital)", i, civ))
      end
    end
  end
  print("===== END =====")
end

local function Apply(cheat)
  local id, p = LP()
  if not p then print("[WW2 Debug] no player") return end

  if cheat == "gold" then p:GetTreasury():ChangeGoldBalance(5000)
  elseif cheat == "gold_mega" then p:GetTreasury():ChangeGoldBalance(100000)
  elseif cheat == "reveal" then
    if WW2_RevealAllFog then WW2_RevealAllFog()
    else
      local vis = PlayersVisibility[id]
      if vis then for i = 0, Map.GetPlotCount()-1 do pcall(function() vis:ChangeVisibilityCount(i,1) end) end end
    end
  elseif cheat == "tsl" or cheat == "nations" then
    if WW2_ApplyAllTSL then WW2_ApplyAllTSL() else print("WW2_TSL missing") end
  elseif cheat == "dump_starts" then DumpStarts()
  elseif cheat == "settler" then Spawn(p, "UNIT_SETTLER")
  elseif cheat == "builder" then Spawn(p, "UNIT_BUILDER")
  elseif cheat == "tank" then Spawn(p, "UNIT_TANK")
  elseif cheat == "infantry" then Spawn(p, "UNIT_INFANTRY")
  elseif cheat == "heal" then
    for _, u in p:GetUnits():Members() do pcall(function() u:SetDamage(0) end) end
  elseif cheat == "pop" then
    for _, c in p:GetCities():Members() do pcall(function() c:ChangePopulation(3) end) end
  elseif cheat == "godmode" then
    p:GetTreasury():ChangeGoldBalance(999999)
    if WW2_ApplyAllTSL then WW2_ApplyAllTSL() end
    Spawn(p, "UNIT_TANK"); Spawn(p, "UNIT_TANK")
    Spawn(p, "UNIT_INFANTRY"); Spawn(p, "UNIT_INFANTRY")
    Spawn(p, "UNIT_BUILDER")
    print("[WW2 Debug] GODMODE")
  else
    print("[WW2 Debug] cmds: gold gold_mega reveal tsl/nations dump_starts settler builder tank infantry heal pop godmode")
  end
end

ExposedMembers.WW2Debug = { Apply = Apply, DumpStarts = DumpStarts }
function WW2_Debug(cmd) return Apply(cmd) end
function WW2_Reveal() return Apply("reveal") end
function WW2_TSL() return Apply("tsl") end
function WW2_DumpStarts() return Apply("dump_starts") end

print("[WW2 Debug] ready")
