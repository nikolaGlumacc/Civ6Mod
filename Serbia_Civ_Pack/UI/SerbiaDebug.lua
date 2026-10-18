-- Serbia Civ Pack debug panel
-- Opens with F8 or F12, or the DBG button (top-right).
-- This file is auto-loaded with SerbiaDebug.xml via AddUserInterfaces (same base name).

print("========== SerbiaDebug.lua LOADED ==========")

local m_IsOpen = false

local function GetLocalPlayer()
  local id = Game.GetLocalPlayer()
  if id == nil or id < 0 then return nil end
  return id
end

local function TogglePanel()
  local panel = Controls.DebugPanel
  if panel == nil then
    print("SerbiaDebug: DebugPanel is nil")
    return
  end
  m_IsOpen = not m_IsOpen
  panel:SetHide(not m_IsOpen)
  print("SerbiaDebug: panel open = " .. tostring(m_IsOpen))
end

local function OnGold()
  local id = GetLocalPlayer(); if not id then return end
  Players[id]:GetTreasury():ChangeGoldBalance(1000)
  print("SerbiaDebug: +1000 Gold")
end

local function OnFaith()
  local id = GetLocalPlayer(); if not id then return end
  Players[id]:GetReligion():ChangeFaithBalance(1000)
  print("SerbiaDebug: +1000 Faith")
end

local function OnScience()
  local id = GetLocalPlayer(); if not id then return end
  local t = Players[id]:GetTechs()
  if t then t:ChangeCurrentResearchProgress(500); print("SerbiaDebug: +500 Science") end
end

local function OnCulture()
  local id = GetLocalPlayer(); if not id then return end
  local c = Players[id]:GetCulture()
  if c then c:ChangeCurrentCulturalProgress(500); print("SerbiaDebug: +500 Culture") end
end

local function OnProd()
  local id = GetLocalPlayer(); if not id then return end
  local city = Players[id]:GetCities():GetCapitalCity()
  if city then city:GetBuildQueue():AddProgress(500); print("SerbiaDebug: +500 Production") end
end

local function OnEraScore()
  local id = GetLocalPlayer(); if not id then return end
  pcall(function()
    Game.GetEras():ChangePlayerEraScore(id, 10)
    print("SerbiaDebug: +10 Era Score")
  end)
end

local function SpawnUnit(unitType)
  local id = GetLocalPlayer(); if not id then return end
  local city = Players[id]:GetCities():GetCapitalCity()
  if not city then
    print("SerbiaDebug: settle a city first")
    return
  end
  local info = GameInfo.Units[unitType]
  if not info then
    print("SerbiaDebug: unknown unit " .. tostring(unitType))
    return
  end
  Players[id]:GetUnits():Create(info.Index, city:GetX(), city:GetY())
  print("SerbiaDebug: spawned " .. unitType)
end

local function OnClose()
  m_IsOpen = false
  if Controls.DebugPanel then Controls.DebugPanel:SetHide(true) end
end

local function IsToggleKey(key)
  -- Try several key constants used across Civ 6 versions
  if Keys then
    if Keys.VK_F8 and key == Keys.VK_F8 then return true end
    if Keys.VK_F12 and key == Keys.VK_F12 then return true end
    if Keys.F8 and key == Keys.F8 then return true end
    if Keys.F12 and key == Keys.F12 then return true end
  end
  -- Numeric fallbacks (Windows VK codes: F8=119, F12=123)
  if key == 119 or key == 123 then return true end
  return false
end

function OnInputHandler(pInputStruct)
  local msg = pInputStruct:GetMessageType()
  if msg == KeyEvents.KeyUp or msg == KeyEvents.KeyDown then
    local key = pInputStruct:GetKey()
    if IsToggleKey(key) then
      if msg == KeyEvents.KeyUp then
        TogglePanel()
      end
      return true
    end
  end
  return false
end

function Initialize()
  print("SerbiaDebug: Initialize()")

  if Controls.DebugPanel then
    Controls.DebugPanel:SetHide(true)
  else
    print("SerbiaDebug: ERROR no DebugPanel")
  end

  if Controls.BtnToggle then
    Controls.BtnToggle:RegisterCallback(Mouse.eLClick, TogglePanel)
    Controls.BtnToggle:SetHide(false)
  end

  local map = {
    BtnGold = OnGold,
    BtnFaith = OnFaith,
    BtnScience = OnScience,
    BtnCulture = OnCulture,
    BtnProd = OnProd,
    BtnEraScore = OnEraScore,
    BtnBuilder = function() SpawnUnit("UNIT_BUILDER") end,
    BtnSettler = function() SpawnUnit("UNIT_SETTLER") end,
    BtnWarrior = function() SpawnUnit("UNIT_WARRIOR") end,
    BtnClose = OnClose,
  }
  for id, fn in pairs(map) do
    if Controls[id] then
      Controls[id]:RegisterCallback(Mouse.eLClick, fn)
    end
  end

  -- Receive keyboard even when other UI is focused
  ContextPtr:SetInputHandler(OnInputHandler, true)
  ContextPtr:SetHide(false)

  print("SerbiaDebug: READY - press F8 or F12 (or click DBG)")
end

-- Run now (AddUserInterfaces loads this with the XML context)
Initialize()
