-- Gameplay cheats. UI: ExposedMembers.SerbiaDebug.Apply(name)

print("SerbiaCheats (gameplay) loaded")

local m_UnitList = {}
local m_UnitIndex = 1

local function BuildUnitList()
  m_UnitList = {}
  for row in GameInfo.Units() do
    -- Skip invalid / test entries if any
    if row.UnitType and row.UnitType ~= "" then
      table.insert(m_UnitList, {
        Type = row.UnitType,
        Index = row.Index,
        Name = row.Name or row.UnitType,
      })
    end
  end
  table.sort(m_UnitList, function(a, b) return a.Type < b.Type end)
  m_UnitIndex = 1
  print("SerbiaCheats: unit list built, count=" .. tostring(#m_UnitList))
end

BuildUnitList()

local function GetPlayer()
  local id = Game.GetLocalPlayer()
  if id == nil or id < 0 then return nil, nil end
  return id, Players[id]
end

local function GetCapitalPlot(p)
  local city = p:GetCities():GetCapitalCity()
  if not city then return nil end
  return city:GetX(), city:GetY(), city
end

local function SpawnAt(p, unitIndex, x, y)
  pcall(function()
    p:GetUnits():Create(unitIndex, x, y)
  end)
end

local function CurrentUnit()
  if #m_UnitList == 0 then BuildUnitList() end
  if #m_UnitList == 0 then return nil end
  if m_UnitIndex < 1 then m_UnitIndex = 1 end
  if m_UnitIndex > #m_UnitList then m_UnitIndex = #m_UnitList end
  return m_UnitList[m_UnitIndex]
end

local function RevealMap(id)
  local vis = PlayersVisibility[id]
  if not vis then return end
  local n = Map.GetPlotCount()
  for i = 0, n - 1 do
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
    local x, y = GetCapitalPlot(p)
    if x then
      local info = GameInfo.Units["UNIT_BUILDER"]
      if info then SpawnAt(p, info.Index, x, y) end
    else print("SerbiaCheats: settle first") end
  elseif cheat == "settler" then
    local x, y = GetCapitalPlot(p)
    if x then
      local info = GameInfo.Units["UNIT_SETTLER"]
      if info then SpawnAt(p, info.Index, x, y) end
    else print("SerbiaCheats: settle first") end
  elseif cheat == "warrior" then
    local x, y = GetCapitalPlot(p)
    if x then
      local info = GameInfo.Units["UNIT_WARRIOR"]
      if info then SpawnAt(p, info.Index, x, y) end
    else print("SerbiaCheats: settle first") end

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

  -- Unit browser
  elseif cheat == "unit_next" then
    if #m_UnitList == 0 then BuildUnitList() end
    m_UnitIndex = m_UnitIndex + 1
    if m_UnitIndex > #m_UnitList then m_UnitIndex = 1 end
    local u = CurrentUnit()
    if u then
      print("SerbiaCheats: selected [" .. m_UnitIndex .. "/" .. #m_UnitList .. "] " .. u.Type)
      return u.Type
    end

  elseif cheat == "unit_prev" then
    if #m_UnitList == 0 then BuildUnitList() end
    m_UnitIndex = m_UnitIndex - 1
    if m_UnitIndex < 1 then m_UnitIndex = #m_UnitList end
    local u = CurrentUnit()
    if u then
      print("SerbiaCheats: selected [" .. m_UnitIndex .. "/" .. #m_UnitList .. "] " .. u.Type)
      return u.Type
    end

  elseif cheat == "unit_spawn" then
    local u = CurrentUnit()
    local x, y = GetCapitalPlot(p)
    if not x then
      print("SerbiaCheats: settle a city first")
      return nil
    end
    if not u then
      print("SerbiaCheats: no unit selected")
      return nil
    end
    SpawnAt(p, u.Index, x, y)
    print("SerbiaCheats: spawned " .. u.Type)
    return u.Type

  elseif cheat == "unit_info" then
    local u = CurrentUnit()
    if u then
      print("SerbiaCheats: current " .. u.Type .. " (" .. m_UnitIndex .. "/" .. #m_UnitList .. ")")
      return u.Type
    end
    return "(none)"

  elseif cheat == "unit_all" then
    local x, y = GetCapitalPlot(p)
    if not x then
      print("SerbiaCheats: settle a city first")
      return nil
    end
    if #m_UnitList == 0 then BuildUnitList() end
    local spawned = 0
    for _, u in ipairs(m_UnitList) do
      SpawnAt(p, u.Index, x, y)
      spawned = spawned + 1
    end
    print("SerbiaCheats: spawned ALL units (" .. spawned .. ") at capital")
    return tostring(spawned)

  else
    print("SerbiaCheats: unknown " .. tostring(cheat))
  end
  return nil
end

local function GetCurrentUnitName()
  local u = CurrentUnit()
  if not u then return "(none)" end
  return string.format("[%d/%d] %s", m_UnitIndex, #m_UnitList, u.Type)
end

ExposedMembers.SerbiaDebug = ExposedMembers.SerbiaDebug or {}
ExposedMembers.SerbiaDebug.Apply = Apply
ExposedMembers.SerbiaDebug.GetCurrentUnitName = GetCurrentUnitName
print("SerbiaCheats: ready, units=" .. tostring(#m_UnitList))
