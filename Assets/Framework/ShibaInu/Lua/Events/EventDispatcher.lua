--
-- 事件派发器，负责进行事件的发送和侦听
-- 2017/9/30
-- Author LOLO
--

local unpack = unpack
local table = table
local remove = table.remove
local insert = table.insert


---@class EventListenerInfo @ 事件注册者的信息
---@field type string
---@field callback fun()
---@field caller any
---@field priority number
---@field args any[]


---@class EventDispatcher
---@field New fun(go:UnityEngine.GameObject):EventDispatcher
---
---@field protected _eventMap table<string, EventListenerInfo[]>
---@field protected _go UnityEngine.GameObject
local EventDispatcher = class("EventDispatcher")


--- Ctor
---@param go UnityEngine.GameObject @ 对应的 GameObject（用于冒泡，没有go时，可以不用传）
function EventDispatcher:Ctor(go)
    self._eventMap = {}
    self._go = go
end


--- 注册事件
---@param type string @ 事件类型
---@param callback fun() @ 处理函数
---@param caller any @ 执行域（self）
---@param priority number @ 优先级 [default: 0]
---@param ... any[] @ 附带的参数
---@return void
function EventDispatcher:AddEventListener(type, callback, caller, priority, ...)
    priority = priority or 0
    if self._eventMap[type] == nil then
        self._eventMap[type] = {}
    end

    local index = -1
    local list = self._eventMap[type]
    ---@type EventListenerInfo
    local info
    local len = #list
    for i = 1, len do
        info = list[i]
        if info.callback == callback and info.caller == caller then
            return -- 已注册
        end
        if index == -1 and info.priority < priority then
            index = i
        end
    end

    info = { type = type, callback = callback, caller = caller, priority = priority, args = { ... } }
    if index ~= -1 then
        insert(list, index, info)
    else
        list[len + 1] = info
    end
end


--- 移除事件侦听
---@param type string @ 事件类型
---@param callback fun() @ 处理函数
---@param caller any @ 执行域（self）
---@return void
function EventDispatcher:RemoveEventListener(type, callback, caller)
    local list = self._eventMap[type]
    if list == nil then
        return
    end

    local len = #list
    if len == 0 then
        return
    end

    for i = 1, len do
        ---@type EventListenerInfo
        local info = list[i]
        if info.callback == callback and info.caller == caller then
            remove(list, i)
            return
        end
    end
end


--- 抛出事件
---@param event Event @ 事件对象
---@param bubbles boolean @ 是否冒泡 [default: false]
---@param recycle boolean @ 是否自动回收到池 [default: true]
---@return void
function EventDispatcher:DispatchEvent(event, bubbles, recycle)
    if recycle == nil then
        recycle = true
    end

    if event.target == nil then
        event.target = self
    end
    event.currentTarget = self

    local list = self._eventMap[event.type]
    if list ~= nil then
        -- 当前节点有侦听该事件
        local len = #list
        if len > 0 then
            list = ObjectUtil.copy(list)
            for i = 1, len do
                ---@type EventListenerInfo
                local info = list[i]
                if info.caller == nil then
                    info.callback(event, unpack(info.args))
                else
                    info.callback(info.caller, event, unpack(info.args))
                end

                if event.isPropagationStopped then
                    break -- 事件传播已被终止
                end
            end
        end
    end

    -- 需要继续冒泡、事件还没停止、有 GameObject
    if bubbles and not event.isPropagationStopped and self._go ~= nil then
        local parent = self._go.transform.parent
        if parent ~= nil then
            DispatchEvent(parent.gameObject, event, bubbles, recycle)
            return
        end
    end

    if recycle then
        Event.Recycle(event)
    end
end


--- 是否正在侦听指定类型的事件
---@param type string @ 事件类型
---@return boolean
function EventDispatcher:HasEventListener(type)
    local list = self._eventMap[type]
    if list == nil then
        return false
    end
    return #list > 0
end



return EventDispatcher