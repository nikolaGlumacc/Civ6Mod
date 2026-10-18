-- Gameplay cheats. UI: ExposedMembers.SerbiaDebug.Apply / SetUnitFilter / GetCurrentUnitName

print("SerbiaCheats (gameplay) loaded")

local m_UnitList = {}
local m_Filtered = {}
local m_UnitIndex = 1
local m_Filter = ""

local function BuildUnitList()
  m_UnitList = {}
  for row in GameInfo.Units() do
    if row.UnitType and row.UnitType ~= "" then
      table.insert(m_UnitList, {
        Type = row.UnitType,
        Index = row.Index,
      })
    end
  end
  table.sort(m_UnitList, function(a, b) return a.Type < b.Type end)
  print("SerbiaCheats: units=" .. tostring(#m_UnitList))
end

local function ApplyFilter()
  m_Filtered = {}
  local f = string.upper(m_Filter or "")
  for _, u in ipairs(m_UnitList) do
    if f == "" or string.find(string.upper(u.Type), f, 1, true) then
      table.insert(m_Filtered, u)
    end
  end
  if m_UnitIndex < 1 then m_UnitIndex = 1 end
  if m_UnitIndex > #m_Filtered then m_UnitIndex = math.max(1, #m_Filtered) end
  if #m_Filtered == 0 then m_UnitIndex = 0 end
end

BuildUnitList()
ApplyFilter()

local function GetPlayer()
  local id = Game.GetLocalPlayer()
  if id == nil or id < 0 then return nil, nil end
  return id, Players[id]
end

local function GetCapitalXY(p)
  local city = p:GetCities():GetCapitalCity()
  if not city then return nil end
  return city:GetX(), city:GetY()
end

local function SpawnAt(p, unitIndex, x, y)
  pcall(function() p:GetUnits():Create(unitIndex, x, y) end)
end

local function CurrentUnit()
  if #m_Filtered == 0 then return nil end
  if m_UnitIndex < 1 or m_UnitIndex > #m_Filtered then return nil end
  return m_Filtered[m_UnitIndex]
end

local function RevealMap(id)
  local vis = PlayersVisibility[id]
  if not vis then return end
  for i = 0, Map.GetPlotCount() - 1 do
    pcall(function() vis:ChangeVisibilityCount(i, 1) end)
  end
  print("SerbiaCheats: map revealed")
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
end

local function SetUnitFilter(str)
  m_Filter = str or ""
  m_UnitIndex = 1
  ApplyFilter()
  print("SerbiaCheats: filter='" .. m_Filter .. "' matches=" .. tostring(#m_Filtered))
  return GetCurrentUnitName()
end

function GetCurrentUnitName()
  local u = CurrentUnit()
  if not u then
    return string.format("(0/%d matches)", #m_Filtered)
  end
  return string.format("[%d/%d] %s", m_UnitIndex, #m_Filtered, u.Type)
end

local function Apply(cheat)
  local id, p = GetPlayer()
  if not p then
    print("SerbiaCheats: no local player")
    return nil
  end

  if cheat == "gold" then
    p:GetTreasury():ChangeGoldBalance(1000)
  elseif cheat == "gold_mega" then
    p:GetTreasury():ChangeGoldBalance(100000)
  elseif cheat == "faith" then
    p:GetReligion():ChangeFaithBalance(1000)
  elseif cheat == "faith_mega" then
    p:GetReligion():ChangeFaithBalance(100000)
  elseif cheat == "science" then
    local t = p:GetTechs(); if t then t:ChangeCurrentResearchProgress(500) end
  elseif cheat == "culture" then
    local c = p:GetCulture(); if c then c:ChangeCurrentCulturalProgress(500) end
  elseif cheat == "prod" then
    local city = p:GetCities():GetCapitalCity()
    if city then city:GetBuildQueue():AddProgress(500) end
  elseif cheat == "erascore" then
    pcall(function() Game.GetEras():ChangePlayerEraScore(id, 10) end)
  elseif cheat == "builder" then
    local x, y = GetCapitalXY(p)
    local info = GameInfo.Units["UNIT_BUILDER"]
    if x and info then SpawnAt(p, info.Index, x, y) else print("SerbiaCheats: settle first") end
  elseif cheat == "settler" then
    local x, y = GetCapitalXY(p)
    local info = GameInfo.Units["UNIT_SETTLER"]
    if x and info then SpawnAt(p, info.Index, x, y) else print("SerbiaCheats: settle first") end
  elseif cheat == "warrior" then
    local x, y = GetCapitalXY(p)
    local info = GameInfo.Units["UNIT_WARRIOR"]
    if x and info then SpawnAt(p, info.Index, x, y) else print("SerbiaCheats: settle first") end
  elseif cheat == "reveal" then
    RevealMap(id)
  elseif cheat == "techs" then
    UnlockAllTechs(p)
  elseif cheat == "civics" then
    UnlockAllCivics(p)
  elseif cheat == "godmode" then
    p:GetTreasury():ChangeGoldBalance(999999)
    p:GetReligion():ChangeFaithBalance(999999)
    pcall(function() local t = p:GetTechs(); if t then t:ChangeCurrentResearchProgress(99999) end end)
    pcall(function() local c = p:GetCulture(); if c then c:ChangeCurrentCulturalProgress(99999) end end)
    pcall(function()
      local city = p:GetCities():GetCapitalCity()
      if city then city:GetBuildQueue():AddProgress(99999) end
    end)
    pcall(function() Game.GetEras():ChangePlayerEraScore(id, 100) end)
    UnlockAllTechs(p)
    UnlockAllCivics(p)
    RevealMap(id)
    print("SerbiaCheats: GODMODE")

  elseif cheat == "unit_next" then
    if #m_Filtered == 0 then return GetCurrentUnitName() end
    m_UnitIndex = m_UnitIndex + 1
    if m_UnitIndex > #m_Filtered then m_UnitIndex = 1 end
    return GetCurrentUnitName()

  elseif cheat == "unit_prev" then
    if #m_Filtered == 0 then return GetCurrentUnitName() end
    m_UnitIndex = m_UnitIndex - 1
    if m_UnitIndex < 1 then m_UnitIndex = #m_Filtered end
    return GetCurrentUnitName()

  elseif cheat == "unit_spawn" then
    local u = CurrentUnit()
    local x, y = GetCapitalXY(p)
    if not x then print("SerbiaCheats: settle first"); return GetCurrentUnitName() end
    if not u then print("SerbiaCheats: no unit"); return GetCurrentUnitName() end
    SpawnAt(p, u.Index, x, y)
    print("SerbiaCheats: spawned " .. u.Type)
    return GetCurrentUnitName()

  elseif cheat == "unit_all" then
    local x, y = GetCapitalXY(p)
    if not x then print("SerbiaCheats: settle first"); return nil end
    -- Spawn filtered list (or all if no filter)
    local list = m_Filtered
    if #list == 0 then list = m_UnitList end
    local n = 0
    for _, u in ipairs(list) do
      SpawnAt(p, u.Index, x, y)
      n = n + 1
    end
    print("SerbiaCheats: spawned " .. n .. " units")
    return tostring(n)

  elseif cheat == "unit_all_filtered" then
    return Apply("unit_all")

  else
    print("SerbiaCheats: unknown " .. tostring(cheat))
  end
  return nil
end

ExposedMembers.SerbiaDebug = ExposedMembers.SerbiaDebug or {}
ExposedMembers.SerbiaDebug.Apply = Apply
ExposedMembers.SerbiaDebug.SetUnitFilter = SetUnitFilter
ExposedMembers.SerbiaDebug.GetCurrentUnitName = GetCurrentUnitName
print("SerbiaCheats: ready")
