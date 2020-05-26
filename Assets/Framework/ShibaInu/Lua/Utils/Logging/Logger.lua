--
-- 日志
-- 2017/10/18
-- Author LOLO
--


local xpcall = xpcall
local traceback = debug.traceback
local unpack = unpack

local isJIT = isJIT

local log = ShibaInu.Logger.Log
local logWarning = ShibaInu.Logger.LogWarning
local logError = ShibaInu.Logger.LogError
local logNet = ShibaInu.Logger.LogNet

local TYPE_TRACE = "Trace" -- 默认日志
local TYPE_NET_SUCC = "NetSucc" -- 网络日志 - 通信成功
local TYPE_NET_FAIL = "NetFail" -- 网络日志 - 通信失败
local TYPE_NET_PUSH = "NetPush" -- 网络日志 - 主动推送


--
---@class Logger
local Logger = {}



--
--- 添加一条普通日志
---@param msg string @ 日志内容
---@param type string @ -可选- 日志类型。默认："Trace"
---@param isStackTrace boolean @ -可选- 是否记录堆栈信息。默认：true
function Logger.Log(msg, type, isStackTrace)
    type = type or TYPE_TRACE

    if isStackTrace ~= false then
        log(msg, type, traceback("", 2)) -- 包含堆栈信息
    else
        log(msg, type)
    end
end


--
--- 添加一条警告日志
---@param msg string @ 日志内容
function Logger.LogWarning(msg)
    logWarning(msg, traceback("", 2))
end


--
--- 添加一条错误日志
---[Error Handler]
---@param msg string @ 日志内容
function Logger.LogError(msg)
    logError(msg, traceback("", 2))
end




--
--- 添加一条网络日志，通信成功
---@param msg string @ 标题
---@param info string @ 详情
function Logger.LogNetSucc(msg, info)
    logNet(msg, TYPE_NET_SUCC, info)
end

--
--- 添加一条网络日志，通信失败
---@param msg string @ 标题
---@param info string @ 详情
function Logger.LogNetFail(msg, info)
    logNet(msg, TYPE_NET_FAIL, info)
end

--
--- 添加一条网络日志，主动推送
---@param msg string @ 标题
---@param info string @ 详情
function Logger.LogNetPush(msg, info)
    logNet(msg, TYPE_NET_PUSH, info)
end





-- try call
local errorHandler = Logger.LogError

--
--- 调用 fn，并捕获出现的错误（ try ... catch ）
---@param fn fun() @ 传入的函数
---@param caller any @ -可选- self 对象，默认为 nil
---@vararg any @ -可选- 附带的参数
---@return boolean @ 调用函数是否成功（是否没有报错）
function Logger.TryCall(fn, caller, ...)
    local status
    if isJIT then
        if caller == nil then
            status = xpcall(fn, errorHandler, ...)
        else
            status = xpcall(fn, errorHandler, caller, ...)
        end
    else
        local args = { ... }
        if caller == nil then
            status = xpcall(function()
                fn(unpack(args))
            end, errorHandler)
        else
            status = xpcall(function()
                fn(caller, unpack(args))
            end, errorHandler)
        end
    end
    return status
end



--
return Logger
