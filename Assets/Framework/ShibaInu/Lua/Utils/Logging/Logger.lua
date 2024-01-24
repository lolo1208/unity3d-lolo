--
-- 日志
-- 2017/10/18
-- Author LOLO
--


local xpcall = xpcall
local traceback = debug.traceback
local unpack = unpack or table.unpack

local log = ShibaInu.Logger.Log
local logWarning = ShibaInu.Logger.LogWarning
local logError = ShibaInu.Logger.LogError
local logNet = ShibaInu.Logger.LogNet

local TYPE_TRACE = "Trace" -- 默认日志
local TYPE_ERROR = "Error" -- 报错日志
local TYPE_NET_SUCC = "NetSucc" -- 网络日志 - 通信成功
local TYPE_NET_FAIL = "NetFail" -- 网络日志 - 通信失败
local TYPE_NET_PUSH = "NetPush" -- 网络日志 - 主动推送


--
---@class Logger
local Logger = {}

---@type fun(type:string, msg:string, stackTrace:string)
local uncaughtExceptionHandler



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
    local stackTrace = traceback("", 2)
    logError(msg, stackTrace)
    if uncaughtExceptionHandler ~= nil then
        uncaughtExceptionHandler(TYPE_ERROR, msg, stackTrace)
    end
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

-- 确定是否可以使用新版本（lua5.2 or newer）的 xpcall
-- 使用新版本的 xpcall 可以减少一次匿名函数封装和 unpack() 调用
local isLatestXpcall
xpcall(function(isLatest)
    isLatestXpcall = isLatest == true
end, function()
end, true)

--
--- 调用 fn，并捕获出现的错误（ try ... catch ）
---@param fn fun() @ 传入的函数
---@param caller any @ -可选- self 对象，默认为 nil
---@vararg any @ -可选- 附带的参数
---@return boolean, any @ 调用函数是否成功（是否没有报错），以及 fn 函数返回值
if isLatestXpcall then
    Logger.TryCall = function(fn, caller, ...)
        if caller == nil then
            return xpcall(fn, errorHandler, ...)
        else
            return xpcall(fn, errorHandler, caller, ...)
        end
    end
else
    Logger.TryCall = function(fn, caller, ...)
        local args = { ... }
        if caller == nil then
            return xpcall(function()
                fn(unpack(args))
            end, errorHandler)
        else
            return xpcall(function()
                fn(caller, unpack(args))
            end, errorHandler)
        end
    end
end



--
--- 设置 Lua 或 C# 出现未捕获异常时的回调
---@param callback fun(type:string, msg:string, stackTrace:string) @ 报错时的回调，用于收集报错日志等
function Logger.SetUncaughtExceptionHandler(callback)
    uncaughtExceptionHandler = callback
    ShibaInu.Logger.SetUncaughtExceptionHandler(callback)
end



--
return Logger
