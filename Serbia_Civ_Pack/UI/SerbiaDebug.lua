-- Serbia Civ Pack - temporary debug / cheat panel (F12)
-- For testing only. Remove or disable for release.

include("SupportFunctions")

local m_Panel = nil
local m_IsOpen = false

local function GetLocalPlayer()
  return Game.GetLocalPlayer()
end

local function AddYield(yieldType, amount)
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local player = Players[playerID]
  if player == nil then return end
  player:GetTreasury():ChangeGoldBalance(0) -- touch
  if yieldType == "GOLD" then
    player:GetTreasury():ChangeGoldBalance(amount)
  elseif yieldType == "FAITH" then
    player:GetReligion():ChangeFaithBalance(amount)
  end
end

local function AddCivicTechProgress(kind, amount)
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local player = Players[playerID]
  if kind == "SCIENCE" then
    player:GetTechs():ChangeCurrentResearchProgress(amount)
  elseif kind == "CULTURE" then
    player:GetCulture():ChangeCurrentCulturalProgress(amount)
  end
end

local function AddProductionToCapital(amount)
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local player = Players[playerID]
  local capital = player:GetCities():GetCapitalCity()
  if capital then
    capital:GetBuildQueue():AddProgress(amount)
  end
end

local function AddEraScore(amount)
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  -- Era score API varies; safe no-op if missing
  local ok, err = pcall(function()
    Game.GetEras():ChangePlayerEraScore(playerID, amount)
  end)
end

local function SpawnUnit(unitType)
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local player = Players[playerID]
  local capital = player:GetCities():GetCapitalCity()
  if capital == nil then return end
  local plot = Map.GetPlot(capital:GetX(), capital:GetY())
  if plot == nil then return end
  local unit = player:GetUnits():Create(GameInfo.Units[unitType].Index, plot:GetX(), plot:GetY())
end

local function TogglePanel()
  if m_Panel == nil then return end
  m_IsOpen = not m_IsOpen
  m_Panel:SetHide(not m_IsOpen)
end

local function OnInput(pInputStruct)
  local msg = pInputStruct:GetMessageType()
  if msg == KeyEvents.KeyUp then
    local key = pInputStruct:GetKey()
    -- F12
    if key == Keys.VK_F12 then
      TogglePanel()
      return true
    end
  end
  return false
end

function OnGold()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  Players[playerID]:GetTreasury():ChangeGoldBalance(1000)
end

function OnFaith()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  Players[playerID]:GetReligion():ChangeFaithBalance(1000)
end

function OnScience()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local techs = Players[playerID]:GetTechs()
  if techs then
    techs:ChangeCurrentResearchProgress(500)
  end
end

function OnCulture()
  local playerID = GetLocalPlayer()
  if playerID == -1 then return end
  local culture = Players[playerID]:GetCulture()
  if culture then
    culture:ChangeCurrentCulturalProgress(500)
  end
end

function OnProd()
  AddProductionToCapital(500)
end

function OnEraScore()
  AddEraScore(10)
end

function OnBuilder()
  SpawnUnit("UNIT_BUILDER")
end

function OnSettler()
  SpawnUnit("UNIT_SETTLER")
end

function OnWarrior()
  SpawnUnit("UNIT_WARRIOR")
end

function OnClose()
  m_IsOpen = false
  if m_Panel then m_Panel:SetHide(true) end
end

function Initialize()
  m_Panel = Controls.DebugPanel
  if m_Panel then
    m_Panel:SetHide(true)
  end

  Controls.BtnGold:RegisterCallback(Mouse.eLClick, OnGold)
  Controls.BtnFaith:RegisterCallback(Mouse.eLClick, OnFaith)
  Controls.BtnScience:RegisterCallback(Mouse.eLClick, OnScience)
  Controls.BtnCulture:RegisterCallback(Mouse.eLClick, OnCulture)
  Controls.BtnProd:RegisterCallback(Mouse.eLClick, OnProd)
  Controls.BtnEraScore:RegisterCallback(Mouse.eLClick, OnEraScore)
  Controls.BtnBuilder:RegisterCallback(Mouse.eLClick, OnBuilder)
  Controls.BtnSettler:RegisterCallback(Mouse.eLClick, OnSettler)
  Controls.BtnWarrior:RegisterCallback(Mouse.eLClick, OnWarrior)
  Controls.BtnClose:RegisterCallback(Mouse.eLClick, OnClose)

  ContextPtr:SetInputHandler(OnInput, true)
  print("SerbiaDebug: F12 cheat panel loaded")
end

Initialize()
