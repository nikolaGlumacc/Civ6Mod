-- Serbia debug panel (UI context)
-- Cheats run through ExposedMembers.SerbiaDebug.Apply (gameplay script)

print("========== SerbiaDebug.lua LOADED ==========")

local m_IsOpen = false

local function Apply(cheat)
  if ExposedMembers and ExposedMembers.SerbiaDebug and ExposedMembers.SerbiaDebug.Apply then
    ExposedMembers.SerbiaDebug.Apply(cheat)
  else
    print("SerbiaDebug: gameplay bridge not ready yet (ExposedMembers.SerbiaDebug missing)")
  end
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

  if Controls.DebugPanel then
    Controls.DebugPanel:SetHide(true)
  end

  if Controls.BtnToggle then
    Controls.BtnToggle:RegisterCallback(Mouse.eLClick, TogglePanel)
    Controls.BtnToggle:SetHide(false)
  end

  local map = {
    BtnGold     = function() Apply("gold") end,
    BtnFaith    = function() Apply("faith") end,
    BtnScience  = function() Apply("science") end,
    BtnCulture  = function() Apply("culture") end,
    BtnProd     = function() Apply("prod") end,
    BtnEraScore = function() Apply("erascore") end,
    BtnBuilder  = function() Apply("builder") end,
    BtnSettler  = function() Apply("settler") end,
    BtnWarrior  = function() Apply("warrior") end,
    BtnClose    = function()
      m_IsOpen = false
      if Controls.DebugPanel then Controls.DebugPanel:SetHide(true) end
    end,
  }
  for id, fn in pairs(map) do
    if Controls[id] then
      Controls[id]:RegisterCallback(Mouse.eLClick, fn)
    end
  end

  ContextPtr:SetInputHandler(OnInputHandler, true)
  ContextPtr:SetHide(false)
  print("SerbiaDebug: READY - F8/F12 or DBG button")
end

Initialize()
