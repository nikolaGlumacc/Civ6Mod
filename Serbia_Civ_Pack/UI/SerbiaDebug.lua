-- Serbia debug panel (UI)

print("========== SerbiaDebug.lua LOADED ==========")

local m_IsOpen = false

local function Apply(cheat)
  if ExposedMembers and ExposedMembers.SerbiaDebug and ExposedMembers.SerbiaDebug.Apply then
    return ExposedMembers.SerbiaDebug.Apply(cheat)
  end
  print("SerbiaDebug: gameplay bridge missing")
  return nil
end

local function RefreshUnitLabel()
  if not Controls.UnitLabel then return end
  local name = "(none)"
  if ExposedMembers and ExposedMembers.SerbiaDebug and ExposedMembers.SerbiaDebug.GetCurrentUnitName then
    name = ExposedMembers.SerbiaDebug.GetCurrentUnitName() or name
  end
  Controls.UnitLabel:SetText("Unit: " .. tostring(name))
end

local function TogglePanel()
  local panel = Controls.DebugPanel
  if not panel then return end
  m_IsOpen = not m_IsOpen
  panel:SetHide(not m_IsOpen)
  if m_IsOpen then RefreshUnitLabel() end
  print("SerbiaDebug: panel open = " .. tostring(m_IsOpen))
end

local function IsToggleKey(key)
  if Keys then
    if Keys.VK_F8 and key == Keys.VK_F8 then return true end
    if Keys.VK_F12 and key == Keys.VK_F12 then return true end
    if Keys.F8 and key == Keys.F8 then return true end
    if Keys.F12 and key == Keys.F12 then return true end
  end
  if key == 119 or key == 123 then return true end
  return false
end

function OnInputHandler(pInputStruct)
  local msg = pInputStruct:GetMessageType()
  if msg == KeyEvents.KeyUp or msg == KeyEvents.KeyDown then
    local key = pInputStruct:GetKey()
    if IsToggleKey(key) then
      if msg == KeyEvents.KeyUp then TogglePanel() end
      return true
    end
  end
  return false
end

function Initialize()
  print("SerbiaDebug: Initialize()")
  if Controls.DebugPanel then Controls.DebugPanel:SetHide(true) end
  if Controls.BtnToggle then
    Controls.BtnToggle:RegisterCallback(Mouse.eLClick, TogglePanel)
    Controls.BtnToggle:SetHide(false)
  end

  local map = {
    BtnGod       = function() Apply("godmode") end,
    BtnReveal    = function() Apply("reveal") end,
    BtnTechs     = function() Apply("techs") end,
    BtnCivics    = function() Apply("civics") end,
    BtnGoldMega  = function() Apply("gold_mega") end,
    BtnFaithMega = function() Apply("faith_mega") end,
    BtnGold      = function() Apply("gold") end,
    BtnFaith     = function() Apply("faith") end,
    BtnScience   = function() Apply("science") end,
    BtnCulture   = function() Apply("culture") end,
    BtnProd      = function() Apply("prod") end,
    BtnEraScore  = function() Apply("erascore") end,
    BtnBuilder   = function() Apply("builder") end,
    BtnSettler   = function() Apply("settler") end,
    BtnWarrior   = function() Apply("warrior") end,
    BtnUnitPrev  = function() Apply("unit_prev"); RefreshUnitLabel() end,
    BtnUnitNext  = function() Apply("unit_next"); RefreshUnitLabel() end,
    BtnUnitSpawn = function() Apply("unit_spawn"); RefreshUnitLabel() end,
    BtnUnitAll   = function() Apply("unit_all") end,
    BtnClose     = function()
      m_IsOpen = false
      if Controls.DebugPanel then Controls.DebugPanel:SetHide(true) end
    end,
  }
  for id, fn in pairs(map) do
    if Controls[id] then Controls[id]:RegisterCallback(Mouse.eLClick, fn) end
  end

  ContextPtr:SetInputHandler(OnInputHandler, true)
  ContextPtr:SetHide(false)
  print("SerbiaDebug: READY")
end

Initialize()
