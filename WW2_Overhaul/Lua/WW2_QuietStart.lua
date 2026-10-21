-- Quiet start: pre-meet all majors (skip first-meet leader banter) + no fog.
-- Natural wonders are disabled in the map script.

local RAN = false

local function MeetAllQuietly()
  print("[WW2 Quiet] Pre-meeting all major civs (no intro dialogue spam)...")
  local majors = {}
  for i = 0, 63 do
    local p = Players[i]
    if p and p:IsMajor() and p:IsAlive() then
      table.insert(majors, i)
    end
  end
  for a = 1, #majors do
    for b = a + 1, #majors do
      local i, j = majors[a], majors[b]
      pcall(function()
        local di = Players[i]:GetDiplomacy()
        local dj = Players[j]:GetDiplomacy()
        if di and di.Meet then di:Meet(j) end
        if dj and dj.Meet then dj:Meet(i) end
        -- Older / alternate APIs
        if di and di.SetHasMet then di:SetHasMet(j) end
        if dj and dj.SetHasMet then dj:SetHasMet(i) end
      end)
    end
  end
  print("[WW2 Quiet] Meet pass done (" .. tostring(#majors) .. " majors)")
end

local function RevealAll()
  for pid = 0, 63 do
    local vis = PlayersVisibility[pid]
    if vis then
      for i = 0, Map.GetPlotCount() - 1 do
        pcall(function() vis:ChangeVisibilityCount(i, 1) end)
      end
    end
  end
end

local function OnLoad()
  if RAN then return end
  RAN = true
  MeetAllQuietly()
  RevealAll()
end

Events.LoadScreenClose.Add(OnLoad)
print("[WW2 QuietStart] loaded")
