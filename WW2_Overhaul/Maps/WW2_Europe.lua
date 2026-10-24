------------------------------------------------------------------------------
-- DEPRECATED map script (kept so old saves don't hard-crash).
-- DO NOT USE. Subscribe to Workshop map instead:
--   TSL Huge Europe by Fidel Casserole
--   https://steamcommunity.com/sharedfiles/filedetails/?id=2784475643
-- Size 106x66 — real Europe with TSL.
------------------------------------------------------------------------------
include("Continents.lua")

function GetMapScriptInfo()
  return {
    Name = "LOC_MAP_WW2_EUROPE_NAME",
    Description = "LOC_MAP_WW2_EUROPE_DESCRIPTION",
    IsAdvancedMap = 0,
    IconIndex = 0,
    SortIndex = 99,
  }
end

-- Falls through to Continents generation if somehow selected.
print("[WW2] WARNING: deprecated WW2_Europe.lua loaded — select Workshop TSL Huge Europe instead")
