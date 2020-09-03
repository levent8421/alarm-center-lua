module(..., package.seeall)
local TAG = 'PHONE'

require 'cc'
require 'fsio'
require 'sms'

local isReady = false
local isCalling = false
local isCallConnected = false
local callPhoneNumber = nil

local onReadyCallback = nil
local onCallConnectedCallback = nil
local onCallDisconnectedCallback = nil

local function onReady()
    isReady = true
    log.info(TAG, 'Phone ready!')
    onReadyCallback()
end

local function onCallConnected()
    log.info(TAG, 'Call connected!')
    isCallConnected = true
    onCallConnectedCallback()
end

local function onCallDisconnected()
    log.info(TAG, 'Call disconnected!')
    isCallConnected = false
    onCallDisconnectedCallback()
end

function Init(readyCallback)
    onReadyCallback = readyCallback
    sys.subscribe('NET_STATE_REGISTERED', onReady)
    sys.subscribe('CALL_CONNECTED', onCallConnected)
    sys.subscribe('CALL_DISCONNECTED', onCallDisconnected)
end

local function callTimeout()
    if isCallConnected then return end
    cc.hangUp(callPhoneNumber)
    isCalling = false
end

function Call(phone, callback, disconnectedCallback)
    onCallDisconnectedCallback = disconnectedCallback
    onCallConnectedCallback = callback
    if not isReady then return false end
    if isCalling or isCallConnected then return false end
    isCalling = true
    callPhoneNumber = phone
    sys.timerStart(callTimeout, 30 * 1000)
    return cc.dial(phone)
end

function PlayAudio(filePath, filename, loop)
    if not isCallConnected then
        return false
    end
    local audioContent = fsio.ReadBinaryFile(filePath, filename)
    return cc.transVoice(audioContent, loop, false)
end

function SendSms(phone, msg, callback)
    sms.send(phone, msg, callback)
end
