require 'phone'
require 'tts'
require 'command'
require 'handler'

LOG_TAG = 'MAIN'

local function sendCommand(cmd)
    command.SendPacket(command.UART_1, cmd)
end

local function phoneReady()
    local commandJson = {}
    commandJson['action'] = 'phone_ready'
    command.SendNotify(command.UART_1, commandJson)
end

local function onNewCommand(cmd)
    log.debug(LOG_TAG, 'cmd len=', #cmd)
    local res = handler.Handle(cmd)
    if not res then
        res = {}
    end
    res['seqNo'] = cmd['seqNo']
    res['type'] = 1
    local resPacket = json.encode(res)
    log.debug(LOG_TAG, 'command res=', resPacket)
    sendCommand(resPacket)
end

local function systemInit()
    command.Init(onNewCommand)
    phone.Init(phoneReady);
end

systemInit()
