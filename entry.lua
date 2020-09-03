require 'phone'
require 'tts'
require 'command'
require 'handler'

LOG_TAG = 'MAIN'

local function sendCommand(cmd)
    command.SendData(command.UART_1, string.char(2))
    command.SendData(command.UART_1, cmd)
    command.SendData(command.UART_1, string.char(2))
end

local function phoneReady()
    local commandJson = {}
    commandJson['action'] = 'phone_ready'
    local cmdStr = json.encode(commandJson)
    sendCommand(cmdStr)
end

local function onNewCommand(cmd)
    log.debug(LOG_TAG, 'cmd len=', #cmd)
    local res = handler.Handle(cmd)
    if not res then
        res = {}
    end
    res['seqNo'] = cmd['seqNo']
    local resPacket = json.encode(res)
    log.debug(LOG_TAG, 'command res=', resPacket)
    sendCommand(resPacket)
end

local function systemInit()
    command.Init(onNewCommand)
    phone.Init(phoneReady);
end

systemInit()
