-- Gameplay cheats. UI calls ExposedMembers.SerbiaDebug.Apply(name)

print("SerbiaCheats (gameplay) loaded")

local function GetPlayer()
  local id = Game.GetLocalPlayer()
  if id == nil or id < 0 then return nil, nil end
  return id, Players[id]
end

local function RevealMap(id)
  local vis = PlayersVisibility[id]
  if not vis then
    print("SerbiaCheats: no PlayersVisibility")
    return
  end
  local n = Map.GetPlotCount()
  for i = 0, n - 1 do
    pcall(function() vis:ChangeVisibilityCount(i, 1) end)
  end
  print("SerbiaCheats: map revealed (" .. tostring(n) .. " plots)")
end

local function UnlockAllTechs(p)
  local techs = p:GetTechs()
  if not techs then return end
  local count = 0
  for row in GameInfo.Technologies() do
    local ok = pcall(function()
      if techs.SetTech then
        techs:SetTech(row.Index, true)
      elseif techs.ResearchComplete then
        techs:ResearchComplete(row.Index)
      end
    end)
    if ok then count = count + 1 end
  end
  print("SerbiaCheats: unlocked techs (~" .. count .. ")")
end

local function UnlockAllCivics(p)
  local culture = p:GetCulture()
  if not culture then return end
  local count = 0
  for row in GameInfo.Civics() do
    local ok = pcall(function()
      if culture.SetCivic then
        culture:SetCivic(row.Index, true)
      elseif culture.CivicCompleted then
        culture:CivicCompleted(row.Index)
      end
    end)
    if ok then count = count + 1 end
  end
  print("SerbiaCheats: unlocked civics (~" .. count .. ")")
end

local function SpawnUnit(p, unitType)
  local city = p:GetCities():GetCapitalCity()
  if not city then
    print("SerbiaCheats: settle a city first")
    return
  end
  local info = GameInfo.Units[unitType]
  if not info then
    print("SerbiaCheats: unknown unit " .. tostring(unitType))
    return
  end
  p:GetUnits():Create(info.Index, city:GetX(), city:GetY())
  print("SerbiaCheats: spawned " .. unitType)
end

local function Apply(cheat)
  local id, p = GetPlayer()
  if not p then
    print("SerbiaCheats: no local player")
    return
  end

  if cheat == "gold" then
    p:GetTreasury():ChangeGoldBalance(1000)
    print("SerbiaCheats: +1000 Gold")

  elseif cheat == "gold_mega" then
    p:GetTreasury():ChangeGoldBalance(100000)
    print("SerbiaCheats: +100000 Gold")

  elseif cheat == "faith" then
    p:GetReligion():ChangeFaithBalance(1000)
    print("SerbiaCheats: +1000 Faith")

  elseif cheat == "faith_mega" then
    p:GetReligion():ChangeFaithBalance(100000)
    print("SerbiaCheats: +100000 Faith")

  elseif cheat == "science" then
    local t = p:GetTechs()
    if t then t:ChangeCurrentResearchProgress(500) end
    print("SerbiaCheats: +500 Science")

  elseif cheat == "culture" then
    local c = p:GetCulture()
    if c then c:ChangeCurrentCulturalProgress(500) end
    print("SerbiaCheats: +500 Culture")

  elseif cheat == "prod" then
    local city = p:GetCities():GetCapitalCity()
    if city then city:GetBuildQueue():AddProgress(500) end
    print("SerbiaCheats: +500 Production")

  elseif cheat == "erascore" then
    pcall(function() Game.GetEras():ChangePlayerEraScore(id, 10) end)
    print("SerbiaCheats: +10 Era Score")

  elseif cheat == "builder" then
    SpawnUnit(p, "UNIT_BUILDER")
  elseif cheat == "settler" then
    SpawnUnit(p, "UNIT_SETTLER")
  elseif cheat == "warrior" then
    SpawnUnit(p, "UNIT_WARRIOR")

  elseif cheat == "reveal" then
    RevealMap(id)

  elseif cheat == "techs" then
    UnlockAllTechs(p)

  elseif cheat == "civics" then
    UnlockAllCivics(p)

  elseif cheat == "godmode" then
    -- Everything
    p:GetTreasury():ChangeGoldBalance(999999)
    p:GetReligion():ChangeFaithBalance(999999)
    pcall(function()
      local t = p:GetTechs()
      if t then t:ChangeCurrentResearchProgress(99999) end
    end)
    pcall(function()
      local c = p:GetCulture()
      if c then c:ChangeCurrentCulturalProgress(99999) end
    end)
    pcall(function()
      local city = p:GetCities():GetCapitalCity()
      if city then city:GetBuildQueue():AddProgress(99999) end
    end)
    pcall(function() Game.GetEras():ChangePlayerEraScore(id, 100) end)
    UnlockAllTechs(p)
    UnlockAllCivics(p)
    RevealMap(id)
    print("SerbiaCheats: GODMODE ON - techs, civics, map, resources")

  else
    print("SerbiaCheats: unknown " .. tostring(cheat))
  end
end

ExposedMembers.SerbiaDebug = ExposedMembers.SerbiaDebug or {}
ExposedMembers.SerbiaDebug.Apply = Apply
print("SerbiaCheats: ExposedMembers ready")
