require 'phone'
require 'tts'

module(..., package.seeall)

LOG_TAG = 'COMMAND_HANDLER'

local commandHanlders = {}

local function isEmpty(text)
    if text and #text>0 then return false else return true end
end

local function onCallSuccess()
    phone.PlayAudio('/ldata/', 'alipay.amr', true)
end

local function onCallDisconnected()
    tts.Play('挂机', 7)
end

local function doCall(phNo)
    phone.Call(phNo, onCallSuccess, onCallDisconnected)
end

commandHanlders['call'] = function (packet)
    local phNo = packet['phone']
    local res = {}
    if isEmpty(phNo) then
        res['code'] = -1
        res['msg'] = 'phone is required!'
    else
        doCall(phNo)
        res['code'] = 0
        res['msg'] = phNo
    end
    return res
end

local function onSmsSendSuccess()
    log.info(LOG_TAG, 'sms send success!')
end

local function doSendSms(phNo, text)
    phone.SendSms(phNo, text, onSmsSendSuccess)
end

commandHanlders['send_sms'] = function(packet)
    local phNo = packet['phone']
    local text = packet['text']
    local res = {}
    if isEmpty(phNo) then
        res['code'] = -1
        res['msg'] = 'phone is required!'
    elseif isEmpty(text) then
        res['code'] = -1
        res['msg'] = 'text is required!'
    else
        doSendSms(phNo, text)
        res['code'] = 0
        res['msg'] = phNo
        res['text'] = text
    end
    return res
end

commandHanlders['tts_play'] = function(packet)
    local text = packet['text']
    local vol = packet['vol']
    local res = {}
    if isEmpty(text) then
        res['code'] = -1
        res['msg'] = 'text is required!'
    elseif not vol then 
        res['code'] = -1
        res['msg'] = 'vol is required!'
    else
        tts.Play(text, vol)
        res['code'] = 0
        res['msg'] = text
        res['vol'] = vol
    end
    return res
end

function Handle(command) 
    local action = command['action']
    if not action or #action<=0 then
        local res = {}
        res['code'] = -2
        res['msg'] = 'No Action!'
        return res
    else
        log.debug(LOG_TAG, 'Command action=', action)
        local handler = commandHanlders[action]
        if not handler then
            local res = {}
            res['code'] = -2
            res['msg'] = 'action not found!'
            return res
        end
        return handler(command)
    end
end