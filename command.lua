module(..., package.seeall)

require "pm"
require 'uart'


UART_1 = 1

local LOG_TAG = 'COMMAND'

local commandListener = nil

local uartRecvBuffer = ''

local function decodeCommand(data)
    jsonData, result, error = json.decode(data)
    log.debug(LOG_TAG, data, jsonData, result, error)
    if result and type(jsonData)=='table' then
        return true, jsonData
    else
        log.error(LOG_TAG, error)
        return false, nil
    end
end

local function appendData(data)
    charCode = string.byte(data)
    if charCode == 2 then
        log.debug(LOG_TAG, 'PACKAGE START')
        uartRecvBuffer = ''
    elseif charCode == 3 then
        log.debug(LOG_TAG, 'PACKAGE END', uartRecvBuffer)
        success, cmd = decodeCommand(uartRecvBuffer)
        if success then
            commandListener(cmd)
        end
        uartRecvBuffer = ''
    else
        uartRecvBuffer = uartRecvBuffer .. data
    end
end

local function onUartRecv()
    while true do
        local c = uart.getchar(UART_1)
        if not c or #c<=0 then
            break
        end
        appendData(c)
    end
end

local function initUART()
    uart.setup(UART_1, 115200, 8, uart.PAR_NONE, uart.STOP_1)
    uart.on(UART_1, 'receive', onUartRecv)
end

function Init(callback)
    commandListener = callback
    pm.wake("mcuart")
    initUART()
end

function SendData(uartId, data) uart.write(uartId, data) end
