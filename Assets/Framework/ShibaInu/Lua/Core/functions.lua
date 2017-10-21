--
-- 全局函数定义
-- 2017/10/12
-- Author LOLO
--

local type = type
local unpack = unpack
local setmetatable = setmetatable
local pairs = pairs
local remove = table.remove
local sort = table.sort
local getpeer = tolua.getpeer
local setpeer = tolua.setpeer
local _isnull = tolua.isnull
local _typeof = tolua.typeof



--- 实现 lua class
--- 调用父类方法 self.super:Fn()
---@param className string @ 类名称
---@param optional superClass table @ 父类（不能继承 native class）
---@return table
function class(className, superClass)
    local cls = {}
    cls.__classname = className
    cls.__class = cls -- 用于 instanceof() 查询
    cls.__index = cls

    if superClass ~= nil then
        setmetatable(cls, superClass)
        cls.super = superClass
    else
        cls.Ctor = function()
        end
    end

    function cls.New(...)
        local instance = setmetatable({}, cls)
        instance:Ctor(...)
        return instance
    end

    return cls
end

--- instance 是否为 class 的实例
---@param instance any @ 实例
---@param class any @ 类
function instanceof(instance, class)
    if type(instance) == "userdata" then
        return _typeof(instance) == _typeof(class)
    else
        local instanceClass = instance.__class
        while instanceClass ~= nil do
            if instanceClass == class then
                return true
            end
            instanceClass = instanceClass.super
        end
        return false
    end
end

--- obj 对应的 C# 对象是否为 null
---@param obj any
---@return boolean
function isnull(obj)
    return _isnull(obj)
end




--- 创建并返回一个预设的实例
---@param prefab any @ 预设对象
---@param parent UnityEngine.GameObject @ 父节点。默认：nil，表示创建在根节点
---@return UnityEngine.GameObject
function Instantiate(prefab, parent)
    ---@type UnityEngine.GameObject
    local obj = GameObject.Instantiate(prefab)
    if parent ~= nil then
        local transform = obj.transform
        transform.localScale = Vector3.one
        transform.localPosition = Vector3.zero
        transform.localEulerAngles = Vector3.zero
        transform.parent = parent.transform
    end
end

--- 创建并返回一个 GameObject
---@param name string @ 名称
---@param parent UnityEngine.GameObject @ 父节点。默认：nil，表示创建在根节点
---@return UnityEngine.GameObject
function CreateGameObject(name, parent)
    local go = GameObject.New(name)
    if parent ~= nil then
        go.transform.parent = parent.transform
    end
    return go
end

--- 销毁指定的对象
---@param obj any @ 目标对象
---@param delay number @ 延时删除（秒）。默认：nil，表示立即删除
---@return void
function Destroy(go, delay)
    if delay == nil then
        GameObject.Destroy(go)
    else
        GameObject.Destroy(go, delay)
    end
end



--=-----------------------------[ EventDispatcher ]-----------------------------=--

--- 获取 target 对应的 EventDispatcher 对象
---@param target any
---@return EventDispatcher
local function GetEventDispatcher(target)
    local ed
    -- C# 对象
    if type(target) == "userdata" then
        local peer = getpeer(target)
        if peer == nil then
            peer = {}
            setpeer(target, peer)
        end
        ed = peer._ed
        if ed == nil then
            ed = EventDispatcher.New(instanceof(target, GameObject) and target or nil)
            peer._ed = ed
        end
    else
        ed = target._ed
        if ed == nil then
            ed = EventDispatcher.New()
            target._ed = ed
        end
    end
    return ed
end

--- 注册事件
---@param target EventDispatcher @ 要注册事件的目标
---@param type string @ 事件类型
---@param listener fun() @ 处理函数
---@param caller any @ self 对象
---@param priority number @ 优先级 [default: 0]
---@param ... any[] @ 附带的参数
---@return void
function AddEventListener(target, type, listener, caller, priority, ...)
    GetEventDispatcher(target):AddEventListener(type, listener, caller, priority, unpack({ ... }))
end

--- 移除事件侦听
---@param target EventDispatcher @ 要移除事件的目标
---@param type string @ 事件类型
---@param listener fun() @ 处理函数
---@param caller any @ self 对象
---@return void
function RemoveEventListener(target, type, listener, caller)
    GetEventDispatcher(target):RemoveEventListener(type, listener, caller)
end

--- 抛出事件
---@param target EventDispatcher @ 要抛出事件的目标
---@param event Event @ 事件对象
---@param bubbles boolean @ 是否冒泡 [default: false]
---@param recycle boolean @ 是否自动回收到池 [default: true]
---@return void
function DispatchEvent(target, event, bubbles, recycle)
    GetEventDispatcher(target):DispatchEvent(event, bubbles, recycle)
end


--- 是否正在侦听指定类型的事件
---@param target EventDispatcher @ 要查询事件的目标
---@param type string @ 事件类型
---@return boolean
function HasEventListener(target, type)
    return GetEventDispatcher(target):HasEventListener(type)
end

--=-----------------------------------------------------------------------------=--



--=---------------------[ DelayedCall / CancelDelayedCall ]---------------------=--

local _dc_list = {} ---@type table<number, Handler>
local _dc_addList = {} ---@type table<number, Handler>
local _dc_removeList = {} ---@type table<Handler, boolean>

-- Update 事件更新
local function UpdateDelayedCall(event)
    local num = #_dc_list

    -- 从 add 列表中取出，放到 call 列表中
    local addListNum = #_dc_addList
    for i = addListNum, 1, -1 do
        num = num + 1
        _dc_list[num] = remove(_dc_addList, i)
    end

    -- 没有 delayed call
    if num == 0 then
        RemoveEventListener(stage, Event.UPDATE, UpdateDelayedCall)
        return
    end

    -- 按 delayedTime 升序
    if addListNum > 0 then
        sort(_dc_list, function(a, b)
            return a.delayedTime > b.delayedTime
        end)
    end

    local trycall = trycall
    local time = TimeUtil.time
    local needClearRemoveList = false
    for i = num, 1, -1 do
        local handler = _dc_list[i]

        -- handler 在 remove 列表中
        if _dc_removeList[handler] then
            remove(_dc_list, i)
            handler:Recycle()
            needClearRemoveList = true

        elseif time - handler.delayedStartTime >= handler.delayedTime then
            -- 时间已满足，执行回调
            trycall(handler.Execute, handler)
            remove(_dc_list, i)
        end
    end

    -- 清空 remove 列表
    if needClearRemoveList then
        _dc_removeList = {}
    end
end


--- 延迟指定时间后，执行一次回调
---@param delay number @ 延迟时间，秒
---@param callback fun() @ 回调函数
---@param caller any @ 执行域（self）
---@param ... @ 附带的参数
---@return Handler
function DelayedCall(delay, callback, caller, ...)
    local handler = Handler.Once(callback, caller)
    handler.args = { ... }
    handler.delayedTime = delay
    handler.delayedStartTime = TimeUtil.time
    _dc_addList[#_dc_addList + 1] = handler
    AddEventListener(stage, Event.UPDATE, UpdateDelayedCall)
    return handler
end


--- 取消延迟回调
---@param handler Handler
---@return void
function CancelDelayedCall(handler)
    if handler.delayedTime == nil then
        return
    end
    handler.delayedTime = nil
    handler.delayedStartTime = nil
    handler.once = false -- 避免立即回收到池，由 UpdateDelayedCall() 来调用 Recycle() 回收

    -- handler 在 add 列表中
    for i = 1, #_dc_addList do
        if _dc_addList[i] == handler then
            remove(_dc_addList, i)
            return
        end
    end

    _dc_removeList[handler] = true -- 标记为需移除
end

--=-----------------------------------------------------------------------------=--
