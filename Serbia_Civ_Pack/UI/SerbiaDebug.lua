-- Serbia Civ Pack - debug / cheat panel
-- Open with the "DBG" button (top-right of screen). No hotkey needed.

local m_Panel = nil
local m_IsOpen = false

local function GetLocalPlayer()
  return Game.GetLocalPlayer()
end

local function TogglePanel()
  if m_Panel == nil then
    print("SerbiaDebug: panel control is nil")
    return
  end
  m_IsOpen = not m_IsOpen
  m_Panel:SetHide(not m_IsOpen)
  print("SerbiaDebug: panel open = " .. tostring(m_IsOpen))
end

function OnGold()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  Players[playerID]:GetTreasury():ChangeGoldBalance(1000)
  print("SerbiaDebug: +1000 Gold")
end

function OnFaith()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  Players[playerID]:GetReligion():ChangeFaithBalance(1000)
  print("SerbiaDebug: +1000 Faith")
end

function OnScience()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local techs = Players[playerID]:GetTechs()
  if techs then
    techs:ChangeCurrentResearchProgress(500)
    print("SerbiaDebug: +500 Science progress")
  end
end

function OnCulture()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local culture = Players[playerID]:GetCulture()
  if culture then
    culture:ChangeCurrentCulturalProgress(500)
    print("SerbiaDebug: +500 Culture progress")
  end
end

function OnProd()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local capital = Players[playerID]:GetCities():GetCapitalCity()
  if capital then
    capital:GetBuildQueue():AddProgress(500)
    print("SerbiaDebug: +500 Production on capital")
  end
end

function OnEraScore()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  pcall(function()
    Game.GetEras():ChangePlayerEraScore(playerID, 10)
    print("SerbiaDebug: +10 Era Score")
  end)
end

local function SpawnUnit(unitType)
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local player = Players[playerID]
  local capital = player:GetCities():GetCapitalCity()
  if capital == nil then return end
  local info = GameInfo.Units[unitType]
  if info == nil then
    print("SerbiaDebug: unknown unit " .. tostring(unitType))
    return
  end
  player:GetUnits():Create(info.Index, capital:GetX(), capital:GetY())
  print("SerbiaDebug: spawned " .. unitType)
end

function OnBuilder()  SpawnUnit("UNIT_BUILDER") end
function OnSettler()  SpawnUnit("UNIT_SETTLER") end
function OnWarrior()  SpawnUnit("UNIT_WARRIOR") end

function OnClose()
  m_IsOpen = false
  if m_Panel then m_Panel:SetHide(true) end
end

function Initialize()
  m_Panel = Controls.DebugPanel
  if m_Panel == nil then
    print("SerbiaDebug: ERROR - DebugPanel control not found")
  else
    m_Panel:SetHide(true)
    print("SerbiaDebug: panel found OK")
  end

  if Controls.BtnToggle then
    Controls.BtnToggle:RegisterCallback(Mouse.eLClick, TogglePanel)
    Controls.BtnToggle:SetHide(false)
    print("SerbiaDebug: DBG button registered (top-right)")
  else
    print("SerbiaDebug: ERROR - BtnToggle not found")
  end

  if Controls.BtnGold then Controls.BtnGold:RegisterCallback(Mouse.eLClick, OnGold) end
  if Controls.BtnFaith then Controls.BtnFaith:RegisterCallback(Mouse.eLClick, OnFaith) end
  if Controls.BtnScience then Controls.BtnScience:RegisterCallback(Mouse.eLClick, OnScience) end
  if Controls.BtnCulture then Controls.BtnCulture:RegisterCallback(Mouse.eLClick, OnCulture) end
  if Controls.BtnProd then Controls.BtnProd:RegisterCallback(Mouse.eLClick, OnProd) end
  if Controls.BtnEraScore then Controls.BtnEraScore:RegisterCallback(Mouse.eLClick, OnEraScore) end
  if Controls.BtnBuilder then Controls.BtnBuilder:RegisterCallback(Mouse.eLClick, OnBuilder) end
  if Controls.BtnSettler then Controls.BtnSettler:RegisterCallback(Mouse.eLClick, OnSettler) end
  if Controls.BtnWarrior then Controls.BtnWarrior:RegisterCallback(Mouse.eLClick, OnWarrior) end
  if Controls.BtnClose then Controls.BtnClose:RegisterCallback(Mouse.eLClick, OnClose) end

  print("SerbiaDebug: click the DBG button (top-right) to open cheats")
end

Initialize()
