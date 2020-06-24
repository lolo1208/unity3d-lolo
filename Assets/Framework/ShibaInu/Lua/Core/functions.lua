--
-- 全局函数定义
-- 2017/10/12
-- Author LOLO
--

local type = type
local setmetatable = setmetatable
local remove = table.remove
local sort = table.sort
local getpeer = tolua.getpeer
local setpeer = tolua.setpeer
local _isnull = tolua.isnull
local _typeof = tolua.typeof
local _typeof_class = typeof



--[ Lua Class ]--

--- 实现 lua class
--- 调用父类方法 Class.super.Fn(self, ...)
---    不要使用 Class.super:Fn(...) 调用
---@param className string @ 类名称
---@param superClass table @ -可选- 父类（不能继承 native class）
---@return table
function class(className, superClass)
    local cls = {}
    cls.__classname = className
    cls.__class = cls -- 用于 instanceof() 查询等
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
---@param cls any @ 类
function instanceof(instance, cls)
    if type(instance) == "userdata" then
        local typeInstance = _typeof(instance)
        local typeClass = _typeof_class(cls)
        return typeInstance == typeClass and typeInstance ~= nil and typeClass ~= nil
    else
        local instanceClass = instance.__class
        while instanceClass ~= nil do
            if instanceClass == cls then
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
    if obj == nil then
        return true
    end
    return _isnull(obj)
end

--- Not a Number
---@param value any
---@return boolean
function isNaN(value)
    return value ~= value
end

--



--[ Prefab Instantiate / Destroy ]--

--- 创建并返回一个预设的实例
--- 使用范例：
---  > go = Instantiate(prefabObj)
---  > go = Instantiate("Prefabs/Test/Item2.prefab", nil, "MyModuleName")
---  > go = Instantiate(prefabObj, Constants.LAYER_UI)
---  > go = Instantiate(prefabObj, parentGO.transform, "MyModuleName")
---@param prefab UnityEngine.GameObject | string @ 预设对象 或 预设路径
---@param parent string | UnityEngine.Transform @ -可选- 图层名称 或 父节点(Transform)
---@param groupName string @ -可选- 资源组名称。参数 prefab 为预设路径时，默认值：nil，将会使用当前场景名称
---@return UnityEngine.GameObject
function Instantiate(prefab, parent, groupName)
    -- 传入的 prefab 是 预设路径
    if type(prefab) == "string" then
        if groupName == nil then
            groupName = Stage.GetCurrentAssetGroup()
        end
        prefab = Res.LoadAsset(prefab, groupName)
    end

    local go = GameObject.Instantiate(prefab) ---@type UnityEngine.GameObject
    if not go.activeSelf then
        go:SetActive(true) -- 默认可见
    end

    if parent ~= nil then
        SetParent(go.transform, parent)
    end
    return go
end

--- 异步加载预设对象，然后创建一个预设的实例，并在回调中传回
--- 提示：在异步加载预设的过程中，可以调用参数 handler.Clean() 取消创建预设实例，以及取消触发回调
--- 使用范例：
---  > function callback(go) self.gameObject = go end
---  > local handler = handler(callback, self)
---  > InstantiateAsync("Prefabs/Test/Item2.prefab", "MyModuleName", handler, parentGO.transform)
---@param prefabPath string @ 预设路径
---@param groupName string @ 资源组名称
---@param handler Handler @ 异步加载完成，并创建实例成功后的回调
---@param parent string | UnityEngine.Transform @ -可选- 图层名称 或 父节点(Transform)
function InstantiateAsync(prefabPath, groupName, handler, parent)
    ---@param event LoadResEvent
    local function loadResComplete(event)
        -- 加载预设资源完成
        if event.assetPath == prefabPath then
            RemoveEventListener(Res, LoadResEvent.COMPLETE, loadResComplete)

            -- 已经被取消了
            if handler.callback == nil then
                return
            end

            local go = GameObject.Instantiate(event.assetData) ---@type UnityEngine.GameObject
            if not go.activeSelf then
                go:SetActive(true) -- 默认可见
            end

            if parent ~= nil then
                SetParent(go.transform, parent)
            end

            handler:Execute(go)
        end
    end
    AddEventListener(Res, LoadResEvent.COMPLETE, loadResComplete)
    Res.LoadAssetAsync(prefabPath, groupName)
end

--- 创建并返回一个空 GameObject
---@param name string @ 名称
---@param parent string | UnityEngine.Transform @ -可选- 图层名称 或 父节点。例：Constants.LAYER_UI 或 parentGO.transform
---@param notUI boolean @ -可选- 是否不是 UI 对象，默认:false
---@return UnityEngine.GameObject
function CreateGameObject(name, parent, notUI)
    -- 传入的 parent 是 图层名称
    if type(parent) == "string" then
        parent = Stage.GetLayer(parent)
    end
    return LuaHelper.CreateGameObject(name, parent, notUI == true)
end

--- 设置 target 的父节点为 parent。
--- 并将 localScale, localPosition 属性重置
---@param target UnityEngine.Transform
---@param parent string | UnityEngine.Transform
function SetParent(target, parent)
    -- 传入的 parent 是 图层名称
    if type(parent) == "string" then
        parent = Stage.GetLayer(parent)
    end
    LuaHelper.SetParent(target, parent)
end

--- 销毁 GameObject 或 Component
---@param obj UnityEngine.Object @ 目标对象
---@param delay number @ -可选- 延时删除（秒）
function Destroy(obj, delay)
    if delay == nil then
        GameObject.Destroy(obj)
    else
        GameObject.Destroy(obj, delay)
    end
end

--



--[ Add / Get Component ]--

--- 添加或获取 GameObject 下的组件
---@param go UnityEngine.GameObject
---@param ComponentClass any @ 组件的类，如：UnityEngine.UI.Text
---@return any
function AddOrGetComponent(go, ComponentClass)
    local cType = _typeof_class(ComponentClass)
    local c = go:GetComponent(cType)
    if c == nil then
        c = go:AddComponent(cType)
    end
    return c
end

GetComponent = {}

--- 获取 gameObject 下的 UnityEngine.RectTransform 组件
---@param go UnityEngine.GameObject
---@return UnityEngine.RectTransform
function GetComponent.RectTransform(go)
    return go:GetComponent(_typeof_class(UnityEngine.RectTransform))
end

--- 获取 gameObject 下的 UnityEngine.CanvasGroup 组件
---@param go UnityEngine.GameObject
---@return UnityEngine.CanvasGroup
function GetComponent.CanvasGroup(go)
    return go:GetComponent(_typeof_class(UnityEngine.CanvasGroup))
end

--

--- 获取 gameObject 下的 ShibaInu.LocalizationText 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.LocalizationText
function GetComponent.LocalizationText(go)
    return go:GetComponent(_typeof_class(ShibaInu.LocalizationText))
end

--- 获取 gameObject 下的 ShibaInu.BaseList 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.BaseList
function GetComponent.BaseList(go)
    return go:GetComponent(_typeof_class(ShibaInu.BaseList))
end

--- 获取 gameObject 下的 ShibaInu.ScrollList 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.ScrollList
function GetComponent.ScrollList(go)
    return go:GetComponent(_typeof_class(ShibaInu.ScrollList))
end

--- 获取 gameObject 下的 ShibaInu.PageList 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.PageList
function GetComponent.PageList(go)
    return go:GetComponent(_typeof_class(ShibaInu.PageList))
end

--- 获取 gameObject 下的 ShibaInu.Picker 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.Picker
function GetComponent.Picker(go)
    return go:GetComponent(_typeof_class(ShibaInu.Picker))
end

--- 获取 gameObject 下的 ShibaInu.ViewPager 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.ViewPager
function GetComponent.ViewPager(go)
    return go:GetComponent(_typeof_class(ShibaInu.ViewPager))
end

--- 获取 gameObject 下的 ShibaInu.CircleImage 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.CircleImage
function GetComponent.CircleImage(go)
    return go:GetComponent(_typeof_class(ShibaInu.CircleImage))
end

--- 获取 gameObject 下的 ShibaInu.PointerScaler 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.PointerScaler
function GetComponent.PointerScaler(go)
    return go:GetComponent(_typeof_class(ShibaInu.PointerScaler))
end

--- 获取 gameObject 下的 ShibaInu.PointerEventPasser 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.PointerEventPasser
function GetComponent.PointerEventPasser(go)
    return go:GetComponent(_typeof_class(ShibaInu.PointerEventPasser))
end

--- 获取 gameObject 下的 ShibaInu.ThirdPersonCamera 组件
---@param go UnityEngine.GameObject
---@return ShibaInu.ThirdPersonCamera
function GetComponent.ThirdPersonCamera(go)
    return go:GetComponent(_typeof_class(ShibaInu.ThirdPersonCamera))
end

--



--[ EventDispatcher ]--

--- 获取 target 对应的 EventDispatcher 对象
---@param target table | UnityEngine.GameObject
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
            if instanceof(target, EventDispatcher) then
                ed = target
            else
                ed = EventDispatcher.New()
            end
            target._ed = ed
        end
    end
    return ed
end

--- 注册事件
---@param target table | UnityEngine.GameObject @ 要注册事件的目标
---@param type string @ 事件类型
---@param listener fun() @ 处理函数
---@param caller any @ -可选- self 对象
---@param priority number @ -可选- 优先级 [default: 0]
---@vararg any @ -可选- 附带的参数
---@return void
function AddEventListener(target, type, listener, caller, priority, ...)
    GetEventDispatcher(target):AddEventListener(type, listener, caller, priority, ...)
end

--- 移除事件侦听
---@param target table | UnityEngine.GameObject @ 要移除事件的目标
---@param type string @ 事件类型
---@param listener fun() @ 处理函数
---@param caller any @ -可选- self 对象
---@return void
function RemoveEventListener(target, type, listener, caller)
    GetEventDispatcher(target):RemoveEventListener(type, listener, caller)
end

--- 抛出事件
---@param target table | UnityEngine.GameObject @ 要抛出事件的目标
---@param eventOrType Event | string @ 事件对象 或 事件类型
---@param bubbles boolean @ -可选- 是否冒泡 [default: false]
---@param recycle boolean @ -可选- 是否自动回收到池 [default: true]
---@return void
function DispatchEvent(target, eventOrType, bubbles, recycle)
    if type(eventOrType) == "string" then
        eventOrType = Event.Get(Event, eventOrType)
    end
    GetEventDispatcher(target):DispatchEvent(eventOrType, bubbles, recycle)
end

--- 是否正在侦听指定类型的事件
---@param target table | UnityEngine.GameObject @ 要查询事件的目标
---@param type string @ 事件类型
---@return boolean
function HasEventListener(target, type)
    return GetEventDispatcher(target):HasEventListener(type)
end

--



--[ DelayedCall / CancelDelayedCall ]--

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
        RemoveEventListener(Stage, Event.UPDATE, UpdateDelayedCall)
        return
    end

    -- 按 delayedTime 升序
    if addListNum > 0 then
        sort(_dc_list, function(a, b)
            -- 被 cancel 了，目前还在 _dc_list 中
            if a.delayedTime == nil or b.delayedTime == nil then
                return false
            end
            return a.delayedTime > b.delayedTime
        end)
    end

    local time = TimeUtil.time
    local totalDeltaTime = TimeUtil.totalDeltaTime
    local frameCount = TimeUtil.frameCount
    for i = num, 1, -1 do
        local handler = _dc_list[i]

        -- handler 在 remove 列表中
        if _dc_removeList[handler] then
            _dc_removeList[handler] = nil
            remove(_dc_list, i)
            handler:Recycle()

        elseif handler.delayedFrame ~= nil then
            -- 帧数已满足，执行回调
            if frameCount - handler.delayedStartFrame >= handler.delayedFrame then
                remove(_dc_list, i)
                handler.delayedFrame = nil
                trycall(handler.Execute, handler)
            end

        else
            if handler.useDeltaTime then
                -- deltaTime 已满足，执行回调
                if totalDeltaTime - handler.delayedStartTime >= handler.delayedTime then
                    remove(_dc_list, i)
                    handler.delayedTime = nil
                    trycall(handler.Execute, handler)
                end
            else
                -- 时间已满足，执行回调
                if time - handler.delayedStartTime >= handler.delayedTime then
                    remove(_dc_list, i)
                    handler.delayedTime = nil
                    trycall(handler.Execute, handler)
                end
            end
        end
    end
end

--- 延迟指定时间后，执行一次回调
---@param delay number @ 延迟时间，秒
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@vararg any @ -可选- 附带的参数
---@return Handler
function DelayedCall(delay, callback, caller, ...)
    local handler = Handler.Once(callback, caller)
    handler.args = { ... }
    handler.delayedTime = delay
    handler.delayedStartTime = TimeUtil.time
    handler.useDeltaTime = false
    _dc_addList[#_dc_addList + 1] = handler
    AddEventListener(Stage, Event.UPDATE, UpdateDelayedCall)
    return handler
end

--- 延迟到下一帧后，执行一次回调
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@param frameCount number @ -可选- 延迟帧数，默认：1帧
---@vararg any @ -可选- 附带的参数
---@return Handler
function DelayedFrameCall(callback, caller, frameCount, ...)
    local handler = DelayedCall(0, callback, caller, ...)
    handler.delayedFrame = frameCount or 1
    handler.delayedStartFrame = TimeUtil.frameCount
    return handler
end

--- 延迟指定 deltaTime 后，执行一次回调。该时间会受到 timeScale，暂停，卡顿，切入后台 等因素等影响
---@param delay number @ 延迟时间，秒
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@vararg any @ -可选- 附带的参数
---@return Handler
function DelayedDeltaTimeCall(delay, callback, caller, ...)
    local handler = DelayedCall(delay, callback, caller, ...)
    handler.delayedStartTime = TimeUtil.totalDeltaTime
    handler.useDeltaTime = true
    return handler
end

--- 延迟指定 时间 或 deltaTime 后，如果 target 不为 null，执行一次回调（如果 target 为 null，将不会执行回调）
---@param delay number @ 延迟时间，秒
---@param callback fun() @ 回调函数
---@param target any @ C# 对象
---@param caller any @ -可选- 执行域（self）
---@param useDeltaTime boolean @ -可选- 是否使用 deltaTime 来计算延时，默认：false
---@vararg any @ -可选- 附带的参数
---@return Handler
function DelayedCallWithTarget(delay, callback, target, caller, useDeltaTime, ...)
    local oHandler = Handler.Once(callback, caller)
    oHandler.args = { ... }
    local checker = function()
        if not isnull(target) then
            trycall(oHandler.Execute, oHandler)
        end
    end

    local handler = DelayedCall(delay, checker)
    if useDeltaTime then
        handler.delayedStartTime = TimeUtil.totalDeltaTime
        handler.useDeltaTime = true
    end
    return handler
end

--- 取消延迟回调
---@param handler Handler
---@return void
function CancelDelayedCall(handler)
    if handler == nil or (handler.delayedTime == nil and handler.delayedFrame == nil) then
        return
    end
    handler.delayedTime = nil
    handler.delayedStartTime = nil
    handler.delayedFrame = nil
    handler.delayedStartFrame = nil
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

--- 快速创建一个 指定执行域（self），携带参数的 Handler 对象
---@param callback fun() @ 回调函数
---@param caller any @ 执行域（self）
---@param once boolean @ 是否只用执行一次，默认：true
---@vararg any @ 附带的参数
---@return Handler
function handler(callback, caller, once, ...)
    if once == nil then
        once = true
    end

    local handler = Handler.Once(callback, caller)
    handler.once = once
    handler.args = { ... }
    return handler
end

--



--
--- 使用当前时间来设置随机种子，并返回该种子值
---@return number
function SetRandomseedWithNowTime()
    local now = System.DateTime.Now
    local val = (now.Minute * 60 + now.Second) * 1000 + now.Millisecond
    math.randomseed(val)
    return val
end


--
--- 预加载资源（异步加载一堆资源的简化方法）
---@param paths string[] @ 要异步加载的资源路径列表
---@param groupName string @ -可选- 资源组名称。默认值为当前场景
function Preload(paths, groupName)
    groupName = groupName or Stage.GetCurrentAssetGroup()
    for i = 1, #paths do
        Res.LoadAssetAsync(paths[i], groupName)
    end
end
