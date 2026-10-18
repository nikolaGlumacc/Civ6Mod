-- Runs in GAMEPLAY context (full Players API).
-- UI panel calls ExposedMembers.SerbiaDebug.Apply(cheatName)

print("SerbiaCheats (gameplay) loaded")

local function GetPlayer()
  local id = Game.GetLocalPlayer()
  if id == nil or id < 0 then return nil, nil end
  return id, Players[id]
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

  elseif cheat == "faith" then
    p:GetReligion():ChangeFaithBalance(1000)
    print("SerbiaCheats: +1000 Faith")

  elseif cheat == "science" then
    local techs = p:GetTechs()
    if techs then
      techs:ChangeCurrentResearchProgress(500)
      print("SerbiaCheats: +500 Science")
    end

  elseif cheat == "culture" then
    local culture = p:GetCulture()
    if culture then
      culture:ChangeCurrentCulturalProgress(500)
      print("SerbiaCheats: +500 Culture")
    end

  elseif cheat == "prod" then
    local city = p:GetCities():GetCapitalCity()
    if city then
      city:GetBuildQueue():AddProgress(500)
      print("SerbiaCheats: +500 Production")
    else
      print("SerbiaCheats: no capital yet")
    end

  elseif cheat == "erascore" then
    pcall(function()
      Game.GetEras():ChangePlayerEraScore(id, 10)
      print("SerbiaCheats: +10 Era Score")
    end)

  elseif cheat == "builder" or cheat == "settler" or cheat == "warrior" then
    local city = p:GetCities():GetCapitalCity()
    if not city then
      print("SerbiaCheats: settle a city first")
      return
    end
    local unitType = "UNIT_WARRIOR"
    if cheat == "builder" then unitType = "UNIT_BUILDER" end
    if cheat == "settler" then unitType = "UNIT_SETTLER" end
    local info = GameInfo.Units[unitType]
    if info then
      p:GetUnits():Create(info.Index, city:GetX(), city:GetY())
      print("SerbiaCheats: spawned " .. unitType)
    end

  else
    print("SerbiaCheats: unknown cheat " .. tostring(cheat))
  end
end

-- Bridge UI -> Gameplay
ExposedMembers.SerbiaDebug = ExposedMembers.SerbiaDebug or {}
ExposedMembers.SerbiaDebug.Apply = Apply

print("SerbiaCheats: ExposedMembers.SerbiaDebug.Apply ready")
