-- WW2 Overhaul: Advanced Setup / Game options
-- These appear in the Create Game → Advanced Setup menu so the player can toggle features.

INSERT OR IGNORE INTO Types (Type, Kind) VALUES
('WW2_OPTION_ENABLE_OIL',           'KIND_PARAMETER'),
('WW2_OPTION_ENABLE_SUPPLY',        'KIND_PARAMETER'),
('WW2_OPTION_ENABLE_ARMY_DOCTRINE', 'KIND_PARAMETER'),
('WW2_OPTION_ENABLE_WAR_WEARINESS', 'KIND_PARAMETER'),
('WW2_OPTION_ENABLE_IDEOLOGY',      'KIND_PARAMETER'),
('WW2_OPTION_ENABLE_POLICIES',      'KIND_PARAMETER');

-- Note: Full Parameter & DomainValues registration for the Advanced Setup UI
-- is more involved and often needs a Frontend config. For now the options are
-- declared so Lua can read them when present. Default = enabled.
