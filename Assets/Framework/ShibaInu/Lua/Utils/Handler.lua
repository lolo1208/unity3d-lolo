--
-- 用于 指定执行域（self），携带参数 的情况下，执行回调函数
-- 2017/10/13
-- Author LOLO
--

local unpack = unpack or table.unpack
local remove = table.remove
local getOnlyID = GetOnlyID


--
---@class Handler @ 用于 指定执行域（self），携带参数 的情况下，执行回调函数
---@field New fun():Handler
---@field refID HandlerRef @ 当前对应的引用 ID
---
---@field callback fun() @ 回调函数
---@field caller any @ 执行域（self）
---@field args any[] @ 附带的参数
---@field once boolean @ 是否只执行一次，执行完毕后，将会自动回收到池中
---
---@field delayedTime number @ 延迟设定时间。使用 delayedCall() 创建时，才会存在该属性
---@field delayedStartTime number @ 延迟开始时间。使用 delayedCall() 创建时，才会存在该属性
---@field useDeltaTime boolean @ 是否使用 deltaTime 来计算延时
---
---@field delayedFrame number @ 延迟帧数。使用 delayedCall() 创建（指定延迟帧数的回调）时，才会存在该属性
---@field delayedStartFrame number @ 延迟开始帧号。使用 delayedCall() 创建（指定延迟帧数的回调）时，才会存在该属性
---
---@field lambda fun(...) @ CallHandler(self.refID, ...) 的匿名函数
local Handler = class("Handler")

---@type Handler[] @ 缓存池
local _pool = {}


--
function Handler:Ctor()
    self.lambda = function(...)
        return CallHandler(self.refID, ...)
    end
end


--
--- 执行回调
---@vararg any[] @ 附带的参数。在执行回调时，args 的值会添加到创建时传入的 args 之前。args.concat(self.args)
function Handler:Execute(...)
    local callback = self.callback
    local caller = self.caller
    local args = { ... } -- 连接参数，args 在前，self.args 在后
    local self_args = self.args
    if self_args then
        local argsCount = #args
        for i = 1, #self_args do
            args[argsCount + i] = self_args[i]
        end
    end

    if self.once then
        self:Clean()
    end

    if callback ~= nil then
        if caller ~= nil then
            return callback(caller, unpack(args))
        else
            return callback(unpack(args))
        end
    end
end

--- 清除引用（取消回调），并将 Handler 回收到池中。
function Handler:Clean()
    self.refID = nil
    self.callback = nil
    self.caller = nil
    self.args = nil

    local poolCount = #_pool
    if poolCount > 300 then
        if isEditor then
            logWarningCount(Constants.W1002, 20)
        end
        return
    end
    _pool[poolCount + 1] = self
end



-- [ static ] --

--- 获取一个 Handler 实例。
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@param once boolean @ -可选- 是否只用执行一次，默认：true
---@vararg any @ 附带的参数
---@return Handler
function Handler.Get(callback, caller, once, ...)
    ---@type Handler
    local handler = #_pool > 0 and remove(_pool) or Handler.New()
    handler.callback = callback
    handler.caller = caller
    handler.once = once ~= false
    handler.args = { ... }
    handler.refID = getOnlyID()
    return handler
end


--
return Handler



--
---@class HandlerRef @ 对 Handler 的引用 ID