-- Loading / selection large portraits
-- Requires DDS in Art/ (generate with tools/generate_leader_portraits.py or extract Serbia_Leader_Portraits.zip):
--   LEADER_TITO_NEUTRAL.dds, LEADER_DRAZA_NEUTRAL.dds, LEADER_MILOSEVIC_NEUTRAL.dds
--   FALLBACK_NEUTRAL_LEADER_TITO/DRAZA/MILOSEVIC.dds (optional diplo)
-- Dusan uses existing STR Serbia fallback DDS already in Art/

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
