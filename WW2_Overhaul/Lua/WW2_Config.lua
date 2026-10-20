-- WW2 Overhaul: Read Advanced Setup options (when available)
-- Defaults to everything enabled so the mod works even without full Frontend parameters.

local function GetOption(key, default)
  -- Placeholder: real implementation would read from GameConfiguration
  -- GameConfiguration.GetValue(key)
  return default
end

WW2_Config = {
  EnableOil          = GetOption("WW2_OPTION_ENABLE_OIL", true),
  EnableSupply       = GetOption("WW2_OPTION_ENABLE_SUPPLY", true),
  EnableArmyDoctrine = GetOption("WW2_OPTION_ENABLE_ARMY_DOCTRINE", true),
  EnableWarWeariness = GetOption("WW2_OPTION_ENABLE_WAR_WEARINESS", true),
  EnableIdeology     = GetOption("WW2_OPTION_ENABLE_IDEOLOGY", true),
  EnablePolicies     = GetOption("WW2_OPTION_ENABLE_POLICIES", true),
}

print("[WW2_Overhaul] Config loaded (all features default ON)")
