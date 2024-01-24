--
-- 事件派发器，负责进行事件的发送和侦听
-- 2017/9/30
-- Author LOLO
--

local unpack = unpack or table.unpack
local remove = table.remove
local insert = table.insert
local error = error


---@class EventListenerInfo @ 事件注册者的信息
---@field type string
---@field callback fun()
---@field caller any
---@field priority number
---@field args any[]


---@class EventDispatcher
---@field New fun(go:UnityEngine.GameObject):EventDispatcher
---
---@field protected gameObject UnityEngine.GameObject @ 对应的 GameObject（用于冒泡，没有go时，构造函数可以不用传）
---
---@field protected _eventMap table<string, EventListenerInfo[]>
local EventDispatcher = class("EventDispatcher")


--
--- 构造函数
---@param go UnityEngine.GameObject @ -可选- 对应的 GameObject（用于冒泡，没有go时，可以不用传）
function EventDispatcher:Ctor(go)
    self._eventMap = {}
    self.gameObject = go
end


--
--- 注册事件
---@param type string @ 事件类型
---@param callback fun() @ 处理函数
---@param caller any @ 执行域（self）
---@param priority number @ 优先级 [default: 0]
---@vararg any @ 附带的参数
function EventDispatcher:AddEventListener(type, callback, caller, priority, ...)
    if callback == nil then
        error(Constants.E3005)
    end

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

    local go = self.gameObject
    if go ~= nil then
        if type == PointerEvent.CLICK or type == PointerEvent.UP or type == PointerEvent.DOWN
                or type == PointerEvent.ENTER or type == PointerEvent.EXIT then
            -- PointerEvent 相关事件，由 C# PointerEventDispatcher.cs 派发
            LuaHelper.AddPointerEvent(go, self)

        elseif type == DestroyEvent.DESTROY then
            -- Destroy 事件，由 C# DestroyEventDispatcher.cs 派发
            -- OnDestroy() 时，self.gameObject 已经是 null（C#）了，所以不能使用 gameObject.peer._ed 来派发
            LuaHelper.AddDestroyEvent(go, self)

        elseif type == DragDropEvent.BEGIN_DRAG or type == DragDropEvent.DRAG or type == DragDropEvent.END_DRAG
                or type == DragDropEvent.INITIALIZE_POTENTIAL_DRAG or type == DragDropEvent.DROP then
            -- DragDropEvent 事件，由 C# DragDropEventDispatcher.cs 派发
            LuaHelper.AddDragDropEvent(go, self)

        elseif type == TriggerEvent.ENTER or type == TriggerEvent.STAY or type == TriggerEvent.EXIT then
            -- TriggerEvent 事件，由 C# TriggerEventDispatcher.cs 派发
            LuaHelper.AddTriggerEvent(go, self)

        elseif type == AvailabilityEvent.CHANGED then
            -- AvailabilityEvent 相关事件，由 C# AvailabilityEventDispatcher.cs 派发
            LuaHelper.AddAvailabilityEvent(go, self)
        end
    end
end


--
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


--
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
            list = ObjectUtil.Copy(list)
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
    if bubbles and not event.isPropagationStopped and self.gameObject ~= nil then
        local parent = self.gameObject.transform.parent
        if parent ~= nil then
            DispatchEvent(parent.gameObject, event, bubbles, recycle)
            return
        end
    end

    if recycle then
        Event.Recycle(event)
    end
end


--
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



--
return EventDispatcher
