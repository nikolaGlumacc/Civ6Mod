-- Full debug toolkit (gameplay). UI calls ExposedMembers.SerbiaDebug.*

print("SerbiaCheats (gameplay) loaded")

local m_UnitList, m_Filtered, m_UnitIndex, m_Filter = {}, {}, 1, ""

local function BuildUnitList()
  m_UnitList = {}
  for row in GameInfo.Units() do
    if row.UnitType and row.UnitType ~= "" then
      table.insert(m_UnitList, { Type = row.UnitType, Index = row.Index })
    end
  end
  table.sort(m_UnitList, function(a, b) return a.Type < b.Type end)
end

local function ApplyFilter()
  m_Filtered = {}
  local f = string.upper(m_Filter or "")
  for _, u in ipairs(m_UnitList) do
    if f == "" or string.find(string.upper(u.Type), f, 1, true) then
      table.insert(m_Filtered, u)
    end
  end
  if #m_Filtered == 0 then m_UnitIndex = 0
  else
    if m_UnitIndex < 1 then m_UnitIndex = 1 end
    if m_UnitIndex > #m_Filtered then m_UnitIndex = #m_Filtered end
  end
end

BuildUnitList()
ApplyFilter()

local function LP()
  local id = Game.GetLocalPlayer()
  if id == nil or id < 0 then return nil, nil end
  return id, Players[id]
end

local function CapXY(p)
  local c = p:GetCities():GetCapitalCity()
  if not c then return nil end
  return c:GetX(), c:GetY(), c
end

local function SpawnAt(p, idx, x, y)
  pcall(function() p:GetUnits():Create(idx, x, y) end)
end

local function CurUnit()
  if m_UnitIndex < 1 or m_UnitIndex > #m_Filtered then return nil end
  return m_Filtered[m_UnitIndex]
end

function GetCurrentUnitName()
  local u = CurUnit()
  if not u then return string.format("(0/%d matches)", #m_Filtered) end
  return string.format("[%d/%d] %s", m_UnitIndex, #m_Filtered, u.Type)
end

local function SetUnitFilter(str)
  m_Filter = str or ""
  m_UnitIndex = 1
  ApplyFilter()
  return GetCurrentUnitName()
end

-- ===== REVEAL =====
local function RevealMap(id)
  local vis = PlayersVisibility[id]
  if not vis then return end
  for i = 0, Map.GetPlotCount() - 1 do
    pcall(function() vis:ChangeVisibilityCount(i, 1) end)
  end
  print("SerbiaCheats: MAP REVEALED")
end

local function RevealResources(id)
  -- Reveal every plot + ensure resource-seeing techs so resources show
  RevealMap(id)
  local _, p = LP()
  if p then
    local techs = p:GetTechs()
    if techs then
      -- Common resource-revealing techs
      local resourceTechs = {
        "TECH_MINING", "TECH_BRONZE_WORKING", "TECH_IRON_WORKING",
        "TECH_ANIMAL_HUSBANDRY", "TECH_POTTERY", "TECH_IRRIGATION",
        "TECH_SAILING", "TECH_CELESTIAL_NAVIGATION", "TECH_CURRENCY",
        "TECH_APPRENTICESHIP", "TECH_INDUSTRIALIZATION", "TECH_REFINING",
        "TECH_CHEMISTRY", "TECH_COMBINED_ARMS", "TECH_SYNTHETIC_MATERIALS",
      }
      for _, t in ipairs(resourceTechs) do
        local row = GameInfo.Technologies[t]
        if row then
          pcall(function()
            if techs.SetTech then techs:SetTech(row.Index, true)
            elseif techs.ResearchComplete then techs:ResearchComplete(row.Index) end
          end)
        end
      end
    end
  end
  -- Log all resource plots
  local count = 0
  for i = 0, Map.GetPlotCount() - 1 do
    local plot = Map.GetPlotByIndex(i)
    if plot and plot:GetResourceType() ~= -1 then
      count = count + 1
    end
  end
  print("SerbiaCheats: RESOURCES REVEALED (" .. count .. " resource plots on map)")
end

local function UnlockAllTechs(p)
  local techs = p:GetTechs()
  if not techs then return end
  for row in GameInfo.Technologies() do
    pcall(function()
      if techs.SetTech then techs:SetTech(row.Index, true)
      elseif techs.ResearchComplete then techs:ResearchComplete(row.Index) end
    end)
  end
  print("SerbiaCheats: all techs")
end

local function UnlockAllCivics(p)
  local culture = p:GetCulture()
  if not culture then return end
  for row in GameInfo.Civics() do
    pcall(function()
      if culture.SetCivic then culture:SetCivic(row.Index, true)
      elseif culture.CivicCompleted then culture:CivicCompleted(row.Index) end
    end)
  end
  print("SerbiaCheats: all civics")
end

local function FinishAllProduction(p)
  for _, city in p:GetCities():Members() do
    pcall(function() city:GetBuildQueue():FinishProgress() end)
    pcall(function() city:GetBuildQueue():AddProgress(99999) end)
  end
  print("SerbiaCheats: all city production finished")
end

local function HealAllUnits(p)
  for _, unit in p:GetUnits():Members() do
    pcall(function()
      local maxDmg = unit:GetMaxDamage and unit:GetMaxDamage() or 100
      if unit.SetDamage then unit:SetDamage(0) end
      if unit.SetMoves then unit:SetMoves(unit:GetMaxMoves()) end
    end)
    pcall(function()
      -- alternate API
      unit:ChangeDamage(-1000)
    end)
  end
  print("SerbiaCheats: healed + refreshed moves on all units")
end

local function AddPopAllCities(p, amount)
  amount = amount or 5
  for _, city in p:GetCities():Members() do
    pcall(function() city:ChangePopulation(amount) end)
  end
  print("SerbiaCheats: +" .. amount .. " pop all cities")
end

local function GrantResources(p)
  -- Grant large amounts of every strategic/luxury if API allows
  local res = p:GetResources()
  if not res then
    print("SerbiaCheats: no resource API")
    return
  end
  for row in GameInfo.Resources() do
    pcall(function()
      if res.ChangeResourceAmount then
        res:ChangeResourceAmount(row.Index, 50)
      end
    end)
  end
  print("SerbiaCheats: granted resources x50")
end

local function KillBarbs()
  local barbID = 63 -- often barbarian player; also try GameDefines
  pcall(function()
    for i = 0, 63 do
      local pl = Players[i]
      if pl and pl:IsBarbarian() then
        for _, unit in pl:GetUnits():Members() do
          pcall(function() UnitManager.Kill(unit) end)
          pcall(function() unit:Kill() end)
        end
      end
    end
  end)
  print("SerbiaCheats: barb units cleared")
end

local function DumpMapResources()
  print("===== RESOURCE DUMP =====")
  for i = 0, Map.GetPlotCount() - 1 do
    local plot = Map.GetPlotByIndex(i)
    if plot then
      local r = plot:GetResourceType()
      if r ~= -1 then
        local info = GameInfo.Resources[r]
        local name = info and info.ResourceType or tostring(r)
        print(string.format("  (%d,%d) %s", plot:GetX(), plot:GetY(), name))
      end
    end
  end
  print("===== END RESOURCE DUMP =====")
end

local function DumpAllUnits()
  print("===== ALL UNITS ON MAP =====")
  for i = 0, 63 do
    local pl = Players[i]
    if pl and pl:IsAlive() then
      for _, unit in pl:GetUnits():Members() do
        pcall(function()
          local ut = GameInfo.Units[unit:GetType()]
          local name = ut and ut.UnitType or "?"
          print(string.format("  P%d %s at (%d,%d)", i, name, unit:GetX(), unit:GetY()))
        end)
      end
    end
  end
  print("===== END UNIT DUMP =====")
end

local function DumpCities()
  print("===== ALL CITIES =====")
  for i = 0, 63 do
    local pl = Players[i]
    if pl and pl:IsAlive() then
      for _, city in pl:GetCities():Members() do
        pcall(function()
          print(string.format("  P%d %s pop=%s (%d,%d)", i, city:GetName(), tostring(city:GetPopulation()), city:GetX(), city:GetY()))
        end)
      end
    end
  end
  print("===== END CITY DUMP =====")
end

local function Apply(cheat)
  local id, p = LP()
  if not p then print("SerbiaCheats: no player"); return nil end

  if cheat == "gold" then p:GetTreasury():ChangeGoldBalance(1000)
  elseif cheat == "gold_mega" then p:GetTreasury():ChangeGoldBalance(100000)
  elseif cheat == "faith" then p:GetReligion():ChangeFaithBalance(1000)
  elseif cheat == "faith_mega" then p:GetReligion():ChangeFaithBalance(100000)
  elseif cheat == "science" then local t=p:GetTechs(); if t then t:ChangeCurrentResearchProgress(500) end
  elseif cheat == "culture" then local c=p:GetCulture(); if c then c:ChangeCurrentCulturalProgress(500) end
  elseif cheat == "prod" then local c=p:GetCities():GetCapitalCity(); if c then c:GetBuildQueue():AddProgress(500) end
  elseif cheat == "erascore" then pcall(function() Game.GetEras():ChangePlayerEraScore(id, 10) end)

  elseif cheat == "builder" then
    local x,y=CapXY(p); local i=GameInfo.Units["UNIT_BUILDER"]; if x and i then SpawnAt(p,i.Index,x,y) end
  elseif cheat == "settler" then
    local x,y=CapXY(p); local i=GameInfo.Units["UNIT_SETTLER"]; if x and i then SpawnAt(p,i.Index,x,y) end
  elseif cheat == "warrior" then
    local x,y=CapXY(p); local i=GameInfo.Units["UNIT_WARRIOR"]; if x and i then SpawnAt(p,i.Index,x,y) end

  elseif cheat == "reveal" then RevealMap(id)
  elseif cheat == "reveal_resources" then RevealResources(id)
  elseif cheat == "techs" then UnlockAllTechs(p)
  elseif cheat == "civics" then UnlockAllCivics(p)
  elseif cheat == "finish_prod" then FinishAllProduction(p)
  elseif cheat == "heal" then HealAllUnits(p)
  elseif cheat == "pop" then AddPopAllCities(p, 5)
  elseif cheat == "resources_grant" then GrantResources(p)
  elseif cheat == "kill_barbs" then KillBarbs()
  elseif cheat == "dump_resources" then DumpMapResources()
  elseif cheat == "dump_units" then DumpAllUnits()
  elseif cheat == "dump_cities" then DumpCities()

  elseif cheat == "godmode" then
    p:GetTreasury():ChangeGoldBalance(999999)
    p:GetReligion():ChangeFaithBalance(999999)
    pcall(function() local t=p:GetTechs(); if t then t:ChangeCurrentResearchProgress(99999) end end)
    pcall(function() local c=p:GetCulture(); if c then c:ChangeCurrentCulturalProgress(99999) end end)
    UnlockAllTechs(p)
    UnlockAllCivics(p)
    RevealResources(id)
    FinishAllProduction(p)
    HealAllUnits(p)
    GrantResources(p)
    pcall(function() Game.GetEras():ChangePlayerEraScore(id, 100) end)
    print("SerbiaCheats: FULL GODMODE")

  elseif cheat == "unit_next" then
    if #m_Filtered==0 then return GetCurrentUnitName() end
    m_UnitIndex = m_UnitIndex % #m_Filtered + 1
    return GetCurrentUnitName()
  elseif cheat == "unit_prev" then
    if #m_Filtered==0 then return GetCurrentUnitName() end
    m_UnitIndex = m_UnitIndex - 1; if m_UnitIndex < 1 then m_UnitIndex = #m_Filtered end
    return GetCurrentUnitName()
  elseif cheat == "unit_spawn" then
    local u=CurUnit(); local x,y=CapXY(p)
    if not x then print("settle first") return GetCurrentUnitName() end
    if not u then return GetCurrentUnitName() end
    SpawnAt(p, u.Index, x, y)
    print("spawned "..u.Type)
    return GetCurrentUnitName()
  elseif cheat == "unit_all" then
    local x,y=CapXY(p); if not x then print("settle first") return nil end
    local list = (#m_Filtered>0) and m_Filtered or m_UnitList
    local n=0; for _,u in ipairs(list) do SpawnAt(p,u.Index,x,y); n=n+1 end
    print("spawned "..n); return tostring(n)
  else
    print("unknown "..tostring(cheat))
  end
  return nil
end

ExposedMembers.SerbiaDebug = ExposedMembers.SerbiaDebug or {}
ExposedMembers.SerbiaDebug.Apply = Apply
ExposedMembers.SerbiaDebug.SetUnitFilter = SetUnitFilter
ExposedMembers.SerbiaDebug.GetCurrentUnitName = GetCurrentUnitName
print("SerbiaCheats: FULL toolkit ready")
