module(..., package.seeall)

require "cc"
require "io"
local function testCall()
    log.info('Test Call Start')
    local calRes = cc.dial('13235169679')
    log.info('Test Call Start', calRes)
end

local function onNetReady()
    log.info('Net ready')
    testCall()
end

local function tryLoadFile(filename)
    local filePath = '/ldata/' .. filename
    local file = io.open(filePath, 'rb')
    if file then
        local content = file:read('*a')
        file:close()
        return content
    else
        log.error("Error on read file", filePath)
    end
end

local function playAudio()
    local amaData = tryLoadFile('alipay.amr')
    if not amaData then
        return
    end
    cc.transVoice(amaData, true, nil)
end

local function callConnected()
    log.info('Call connected')
    sys.timerLoopStart(playAudio, 5000)
end



local function initSystemListeners()
    sys.subscribe("NET_STATE_REGISTERED", onNetReady)
    sys.subscribe("CALL_CONNECTED", callConnected)
end

initSystemListeners()
