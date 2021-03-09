--
-- 用于 指定执行域（self），携带参数 的情况下，执行回调函数
-- 2017/10/13
-- Author LOLO
--

local unpack = unpack
local remove = table.remove


--
---@class Handler @ 用于 指定执行域（self），携带参数 的情况下，执行回调函数
---@field New fun(callback:fun(), caller:any, ...:any[]):Handler
---
---@field callback fun() @ 回调函数
---@field caller any @ 执行域（self）
---@field args any[] @ 附带的参数
---@field once boolean @ 是否只执行一次，执行完毕后，将会自动回收到池中
---@field inPool boolean @ 是否正在缓存池中
---
---@field delayedTime number @ 延迟设定时间。使用 delayedCall() 创建时，才会存在该属性
---@field delayedStartTime number @ 延迟开始时间。使用 delayedCall() 创建时，才会存在该属性
---@field useDeltaTime boolean @ 是否使用 deltaTime 来计算延时
---
---@field delayedFrame number @ 延迟帧数。使用 delayedCall() 创建（指定延迟帧数的回调）时，才会存在该属性
---@field delayedStartFrame number @ 延迟开始帧号。使用 delayedCall() 创建（指定延迟帧数的回调）时，才会存在该属性
---
---@field lambda fun(...) @ self:Execute(...) 的匿名函数
local Handler = class("Handler")


--
--- 创建一个 Handler 对象
--- 如果 Handler 只需要被执行一次，推荐使用 Handler.create() 创建
---@param callback fun()
---@param caller any
---@vararg any[] @ 附带的参数
function Handler:Ctor(callback, caller, ...)
    self:SetTo(callback, caller, { ... }, false)

    self.lambda = function(...)
        return self:Execute(...)
    end
end


--
--- 设置属性值
---@param callback fun()
---@param caller any
---@param args any[]
---@param once boolean
---@return void
function Handler:SetTo(callback, caller, args, once)
    self.callback = callback
    self.caller = caller
    self.args = args
    self.once = once
end


--
--- 执行回调
---@vararg any[] @ 附带的参数。在执行回调时，args 的值会添加到创建时传入的 args 之前。args.concat(self.args)
function Handler:Execute(...)
    if self.delayedTime ~= nil or self.delayedFrame ~= nil then
        CancelDelayedCall(self)
    end

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
        self:Recycle()
    end

    if callback ~= nil then
        if caller ~= nil then
            return callback(caller, unpack(args))
        else
            return callback(unpack(args))
        end
    end
end


--
--- 清除引用，并回收到池中。
--- 注意：手动调用该方法，一定要仔细检查上下文逻辑，避免缓存池混乱
---@return void
function Handler:Recycle()
    if self.inPool then
        return
    end
    self.inPool = true
    self:Clean()
    Handler._pool[#Handler._pool + 1] = self
end

--- 清除引用（不再执行 callback）
---@return void
function Handler:Clean()
    if self.delayedTime ~= nil or self.delayedFrame ~= nil then
        CancelDelayedCall(self)
    end
    self.callback = nil
    self.caller = nil
    self.args = nil
end




--=------------------------------[ static ]------------------------------=--

---@type table<number, Handler> @ 缓存池
Handler._pool = {}

--- 创建，或从池中获取一个 Handler 对象。
--- 注意：使用 Handler.once() 创建的 Handler 对象 once 属性默认为 true。
--- 如果不想执行完毕被回收（比如：timer.timerHandler），请使用 new Hander() 来创建。或设置 once=false
---@param callback fun()
---@param caller any
---@vararg any[] @ 附带的参数
---@return Handler
function Handler.Once(callback, caller, ...)
    local handler ---@type Handler
    if #Handler._pool > 0 then
        handler = remove(Handler._pool)
        handler.inPool = false
        handler:SetTo(callback, caller, { ... }, true)
    else
        handler = Handler.New(callback, caller)
        handler.args = { ... }
        handler.once = true
    end
    return handler
end

--=----------------------------------------------------------------------=--



return Handler