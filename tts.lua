module(..., package.seeall)

require 'audio'

local TAG = 'TTS'

TTS_PRIORITY = 1
TTS_TYPE = 'TTS'

function Play(ttsStr, vol)
    audio.play(TTS_PRIORITY, TTS_TYPE, ttsStr, vol)
end