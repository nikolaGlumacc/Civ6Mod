-- Loading / selection large portraits
-- Tito/Draza/Milosevic: LEADER_*_NEUTRAL.dds from Serbia_Leader_Face_Icons.zip
-- Dusan: existing STR fallback

INSERT OR REPLACE INTO LoadingInfo
    (LeaderType, ForegroundImage, BackgroundImage, PlayDawnOfManAudio)
VALUES
    ('LEADER_TITO',      'LEADER_TITO_NEUTRAL',      'LEADER_TITO_NEUTRAL',      0),
    ('LEADER_DRAZA',     'LEADER_DRAZA_NEUTRAL',     'LEADER_DRAZA_NEUTRAL',     0),
    ('LEADER_MILOSEVIC', 'LEADER_MILOSEVIC_NEUTRAL', 'LEADER_MILOSEVIC_NEUTRAL', 0),
    ('LEADER_DUSAN',
     'FALLBACK_NEUTRAL_LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC',
     'FALLBACK_NEUTRAL_LEADER_STR_SERBIA_STEFAN_UROS_IV_DUSAN_THE_MIGHTY_NEMANJIC',
     0);
