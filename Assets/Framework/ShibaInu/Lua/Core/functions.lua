--
-- 全局函数定义
-- 2017/10/12
-- Author LOLO
--

local type = type
local pairs = pairs
local next = next
local setmetatable = setmetatable
local tonumber = tonumber
local remove = table.remove
local concat = table.concat
local unpack = unpack or table.unpack
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

--- instance 是否为 class 的实例（或 class 子类的实例）
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

--- instance 是否为 class 的实例（不包括 class 子类的实例）
---@param instance any @ 实例
---@param cls any @ 类
function instanceis(instance, cls)
    if type(instance) == "userdata" then
        local typeInstance = _typeof(instance)
        local typeClass = _typeof_class(cls)
        return typeInstance == typeClass and typeInstance ~= nil and typeClass ~= nil
    else
        return instance.__classname == cls.__classname
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
--- 提示：在异步加载预设的过程中，可以调用参数 CancelHandler(handlerRef) 取消创建预设实例，以及取消触发回调
--- 使用范例：
---  > function callback(go) self.gameObject = go end
---  > local handlerID = handler(callback, self)
---  > InstantiateAsync("Prefabs/Test/Item2.prefab", "MyModuleName", handlerID, parentGO.transform)
---@param prefabPath string @ 预设路径
---@param groupName string @ 资源组名称
---@param handlerRef HandlerRef @ 异步加载完成，并创建实例成功后的回调引用
---@param parent string | UnityEngine.Transform @ -可选- 图层名称 或 父节点(Transform)
function InstantiateAsync(prefabPath, groupName, handlerRef, parent)
    ---@param event ResEvent
    local function loadResComplete(event)
        -- 加载预设资源完成
        if event.assetPath == prefabPath then
            RemoveEventListener(Res, ResEvent.LOAD_COMPLETE, loadResComplete)

            -- 已经被取消了
            if not HasHandler(handlerRef) then
                return
            end

            local go = GameObject.Instantiate(event.assetData) ---@type UnityEngine.GameObject
            if not go.activeSelf then
                go:SetActive(true) -- 默认可见
            end

            if parent ~= nil then
                SetParent(go.transform, parent)
            end

            CallHandler(handlerRef, go)
        end
    end
    AddEventListener(Res, ResEvent.LOAD_COMPLETE, loadResComplete)
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
---@param target UnityEngine.Transform
---@param parent string | UnityEngine.Transform
---@param worldPositionStays boolean @ -可选- 是否保留在世界坐标系中的状态（包括位置和旋转等）。默认：false
function SetParent(target, parent, worldPositionStays)
    -- 传入的 parent 是 图层名称
    if type(parent) == "string" then
        parent = Stage.GetLayer(parent)
    end
    target:SetParent(parent, worldPositionStays == true)
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

--- 销毁 target 的所有子节点（保留 target）
---@param target UnityEngine.Transform @ 目标对象
function DestroyChildren(target)
    LuaHelper.DestroyChildren(target)
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
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.RectTransform
function GetComponent.RectTransform(go)
    return go:GetComponent(_typeof_class(UnityEngine.RectTransform))
end

--- 获取 gameObject 下的 UnityEngine.CanvasGroup 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.CanvasGroup
function GetComponent.CanvasGroup(go)
    return go:GetComponent(_typeof_class(UnityEngine.CanvasGroup))
end

--

--- 获取 gameObject 下的 ShibaInu.LocalizationText 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.LocalizationText
function GetComponent.LocalizationText(go)
    return go:GetComponent(_typeof_class(ShibaInu.LocalizationText))
end

--- 获取 gameObject 下的 ShibaInu.BaseList 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.BaseList
function GetComponent.BaseList(go)
    return go:GetComponent(_typeof_class(ShibaInu.BaseList))
end

--- 获取 gameObject 下的 ShibaInu.ScrollList 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.ScrollList
function GetComponent.ScrollList(go)
    return go:GetComponent(_typeof_class(ShibaInu.ScrollList))
end

--- 获取 gameObject 下的 ShibaInu.PageList 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.PageList
function GetComponent.PageList(go)
    return go:GetComponent(_typeof_class(ShibaInu.PageList))
end

--- 获取 gameObject 下的 ShibaInu.Picker 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.Picker
function GetComponent.Picker(go)
    return go:GetComponent(_typeof_class(ShibaInu.Picker))
end

--- 获取 gameObject 下的 ShibaInu.ViewPager 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.ViewPager
function GetComponent.ViewPager(go)
    return go:GetComponent(_typeof_class(ShibaInu.ViewPager))
end

--- 获取 gameObject 下的 ShibaInu.CircleImage 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.CircleImage
function GetComponent.CircleImage(go)
    return go:GetComponent(_typeof_class(ShibaInu.CircleImage))
end

--- 获取 gameObject 下的 ShibaInu.RoundedImage 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.RoundedImage
function GetComponent.RoundedImage(go)
    return go:GetComponent(_typeof_class(ShibaInu.RoundedImage))
end

--- 获取 gameObject 下的 ShibaInu.PointerScaler 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.PointerScaler
function GetComponent.PointerScaler(go)
    return go:GetComponent(_typeof_class(ShibaInu.PointerScaler))
end

--- 获取 gameObject 下的 ShibaInu.PointerEventPasser 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return ShibaInu.PointerEventPasser
function GetComponent.PointerEventPasser(go)
    return go:GetComponent(_typeof_class(ShibaInu.PointerEventPasser))
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



-- [ Handler ] --

---@type Handler[] @ 当前被使用的 HandlerRef 与 Handler 映射列表
local _handlers = {}

---@return Handler
local function GetHandlerByRefID(refID)
    if refID == nil then
        return nil
    end
    local handler = _handlers[refID]
    if handler == nil or handler.refID ~= refID then
        _handlers[refID] = nil
        if isEditor then
            logWarning(Constants.W1003)
        end
    end
    return handler
end

--- 获取一个 [会多次使用] 的 Handler 实例（引用）。
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@vararg any @ 附带的参数
---@return HandlerRef
function NewHandler(callback, caller, ...)
    local handler = Handler.Get(callback, caller, false, ...)
    _handlers[handler.refID] = handler
    return handler.refID
end

--- 获取一个 [只会执行一次] 的 Handler 实例（引用）。
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@vararg any @ 附带的参数
---@return HandlerRef
function handler(callback, caller, ...)
    local handler = Handler.Get(callback, caller, true, ...)
    _handlers[handler.refID] = handler
    return handler.refID
end

---@return HandlerRef
function OnceHandler(callback, caller, ...)
    return handler(callback, caller, ...)
end

--- 执行回调。
---@param refID HandlerRef @ 创建 Handler 时返回的引用 ID
---@vararg any @ 附带的参数
---@return any
function CallHandler(refID, ...)
    local handler = GetHandlerByRefID(refID)
    if handler ~= nil then
        if handler.once then
            _handlers[refID] = nil
        end
        return handler:Execute(...)
    end
end

--- 执行回调，并捕获回调函数中产生的错误。返回：调用函数是否成功（是否没有报错），以及 callback 函数返回值。
---@param refID HandlerRef @ 创建 Handler 时返回的引用 ID
---@vararg any @ 附带的参数
---@return boolean, any
function TryCallHandler(refID, ...)
    local handler = GetHandlerByRefID(refID)
    if handler ~= nil then
        if handler.once then
            _handlers[refID] = nil
        end
        return trycall(handler.Execute, handler, ...)
    end
    return false
end

--- 取消回调，清除引用，并将对应的 Handler 回收到池中。
---@param refID HandlerRef @ 创建 Handler 时返回的引用 ID
function CancelHandler(refID)
    local handler = _handlers[refID]
    if handler ~= nil and handler.refID == refID then
        _handlers[refID] = nil
        handler:Clean()
    end
end

--- 回调是否可用（是否为 不是已被调用的单次回调，或没有被取消）。
---@param refID HandlerRef @ 创建 Handler 时返回的引用 ID
---@return boolean
function HasHandler(refID)
    local handler = _handlers[refID]
    return handler ~= nil and handler.refID == refID
end

--- 获取执行回调的匿名函数。
---@return fun()
function GetHandlerLambda(refID)
    local handler = GetHandlerByRefID(refID)
    if handler ~= nil then
        return handler.lambda
    end
    return nil
end

--



--[ DelayedCall ]--

local _dc_runningList = {} ---@type HandlerRef[]
local _dc_addList = {} ---@type table<HandlerRef, boolean>
local _dc_removeList = {} ---@type table<HandlerRef, boolean>

-- 更新延迟回调 Event.UPDATE
local function UpdateDelayedCall(event)
    local num = #_dc_runningList

    -- 将 add 列表中标记的回调放到 running 列表中
    for refID, flag in pairs(_dc_addList) do
        num = num + 1
        _dc_addList[refID] = nil
        _dc_runningList[num] = refID
    end

    -- 没有 delayed call
    if num == 0 then
        RemoveEventListener(Stage, Event.UPDATE, UpdateDelayedCall)
        return
    end

    local time = TimeUtil.time
    local totalDeltaTime = TimeUtil.totalDeltaTime
    local frameCount = TimeUtil.frameCount
    for i = num, 1, -1 do
        local refID = _dc_runningList[i]
        local handler = _handlers[refID]

        -- handler 在 remove 列表中 / handler 不存在 / refID 不匹配
        if _dc_removeList[refID] or handler == nil or handler.refID ~= refID then
            remove(_dc_runningList, i)
            _dc_removeList[refID] = nil
            CancelHandler(refID)

        elseif handler.delayedFrame ~= nil then
            -- 延迟帧数已满足，执行回调
            if frameCount - handler.delayedStartFrame >= handler.delayedFrame then
                remove(_dc_runningList, i)
                TryCallHandler(refID)
            end

        else
            if handler.useDeltaTime then
                -- 延迟游戏时间已满足，执行回调
                if totalDeltaTime - handler.delayedStartTime >= handler.delayedTime then
                    remove(_dc_runningList, i)
                    TryCallHandler(refID)
                end
            else
                -- 延迟真实时间已满足，执行回调
                if time - handler.delayedStartTime >= handler.delayedTime then
                    remove(_dc_runningList, i)
                    TryCallHandler(refID)
                end
            end
        end
    end
end

-- 更新 refID 对应的延迟回调在 add 或 remove 列表的标记
local function MarkDelayedCallState(refID, isAdd)
    if isAdd then
        _dc_addList[refID] = true
        _dc_removeList[refID] = nil
    else
        _dc_addList[refID] = nil
        _dc_removeList[refID] = true
    end
end

-- 创建一个延时回调
local function CreateDelayedCall(callback, caller, delay, useDeltaTime, frameCount, ...)
    local handler = Handler.Get(callback, caller, true, ...)
    _handlers[handler.refID] = handler

    handler.delayedFrame = frameCount
    if frameCount then
        handler.delayedStartFrame = TimeUtil.frameCount
    else
        handler.delayedTime = delay
        handler.delayedStartTime = useDeltaTime and TimeUtil.totalDeltaTime or TimeUtil.time
        handler.useDeltaTime = useDeltaTime
    end

    MarkDelayedCallState(handler.refID, true)
    AddEventListener(Stage, Event.UPDATE, UpdateDelayedCall, nil, Constants.PRIORITY_HIGH)
    return handler.refID
end

--- 在指定真实时间（自然时间）后执行回调。
--- 该时间不受 timeScale，暂停，卡顿，切入后台 等因素的影响。
---@param delay number @ 延迟时间，秒
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@vararg any @ -可选- 附带的参数
---@return HandlerRef
function DelayedRealTimeCall(delay, callback, caller, ...)
    return CreateDelayedCall(callback, caller, delay, false, nil, ...)
end

--- 在指定游戏时间（deltaTime）后执行回调。
--- 该时间是基于 UnityEngine.Time. deltaTime 的时间，与游戏进程一致。
---@param delay number @ 延迟时间，秒
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@vararg any @ -可选- 附带的参数
---@return HandlerRef
function DelayedCall(delay, callback, caller, ...)
    return CreateDelayedCall(callback, caller, delay, true, nil, ...)
end

---@return HandlerRef
function DelayedDeltaTimeCall(delay, callback, caller, ...)
    return DelayedCall(delay, callback, caller, ...)
end

--- 在指定游戏帧数后执行回调。
---@param callback fun() @ 回调函数
---@param caller any @ -可选- 执行域（self）
---@param frameCount number @ -可选- 延迟帧数，默认：1
---@vararg any @ -可选- 附带的参数
---@return HandlerRef
function DelayedFrameCall(callback, caller, frameCount, ...)
    return CreateDelayedCall(callback, caller, nil, nil, frameCount or 1, ...)
end

--- 在指定 游戏时间（默认） 或 真实时间 后执行回调。
--- 届时，如果指定的 target 值为 null，将会取消（不执行）回调。
---@param delay number @ 延迟时间，秒
---@param callback fun() @ 回调函数
---@param target any @ C# 对象
---@param caller any @ -可选- 执行域（self）
---@param useDeltaTime boolean @ -可选- 是否使用 deltaTime 来计算延时，默认：true
---@vararg any @ -可选- 附带的参数
---@return HandlerRef
function DelayedCallWithTarget(delay, callback, target, caller, useDeltaTime, ...)
    local args = { ... }
    local checker = function()
        if not isnull(target) then
            trycall(callback, caller, unpack(args))
        end
    end
    return CreateDelayedCall(checker, nil, delay, useDeltaTime ~= false, nil)
end

--- 取消延迟回调，清除引用，并将对应的 Handler 回收到池中。
---@param refID HandlerRef
function CancelDelayedCall(refID)
    local handler = _handlers[refID]
    if handler ~= nil and handler.refID == refID then
        _handlers[refID] = nil
        MarkDelayedCallState(refID, false)
        handler:Clean()
    end
end

--



--[ Request Permissions ]--

local _rp_handlers = {} ---@type HandlerRef[]
local RequestPermissionsResult
--- 获取本机权限（Android）的结果
---@param event NativeEvent
RequestPermissionsResult = function(event)
    if event.action == Constants.UN_ACT_REQUEST_PERMISSIONS then
        local results = StringUtil.Split(event.message, "|")
        local requestCode = tonumber(results[1])
        local isGranted = results[2] == "granted"
        local handlerRef = _rp_handlers[requestCode]
        _rp_handlers[requestCode] = nil
        if next(_rp_handlers) == nil then
            RemoveEventListener(Stage, NativeEvent.RECEIVE_MESSAGE, RequestPermissionsResult)
        end
        CallHandler(handlerRef, isGranted)
    end
end

--- 获取本机权限（Android）
---@param rationale string @ 当用户拒绝，第二次发起权限申请时显示的 申请权限的原因
---@param permissions string[] @ 要申请的权限列表
---@param handlerRef HandlerRef @ 申请权限结果回调 callback(isGranted:boolean)。默认值：nil
---@param dialogItems string @ 当存在永久拒绝权限时，将会弹出该参数内容生成的对话框，引导用户去设置界面开启权限。默认值：Language["android.permission.dialog"]
function RequestPermissions(rationale, permissions, handlerRef, dialogItems)
    -- 在非 Android 环境，申请的结果始终为成功 callback(true)
    if not isAndroid then
        CallHandler(handlerRef, true)
        return
    end

    dialogItems = dialogItems or Language["android.permission.dialog"]
    local requestCode = GetOnlyID()
    local msg = { requestCode, rationale, concat(permissions, ","), dialogItems }
    _rp_handlers[requestCode] = handlerRef
    AddEventListener(Stage, NativeEvent.RECEIVE_MESSAGE, RequestPermissionsResult)
    SendMessageToNative(Constants.UN_ACT_REQUEST_PERMISSIONS, concat(msg, "|"))
end

--



--[ Misc ]--

--
--- 预加载资源
---@param paths string | string[] @ 要异步加载的资源路径，或路径列表
---@param groupName string @ -可选- 资源组名称。默认值为当前场景
function PreloadAssets(paths, groupName)
    if type(paths) == "string" then
        Res.LoadAssetAsync(paths, groupName)
    else
        for i = 1, #paths do
            Res.LoadAssetAsync(paths[i], groupName)
        end
    end
end


--
--- 将 paths 对应的 AssetBundle 标记为永不卸载
---@param paths string | string[] @ 要标记为不卸载的资源路径，或路径列表
function DontUnloadAssets(paths)
    if type(paths) == "string" then
        Res.LoadAsset(paths, Constants.ASSET_GROUP_CORE)
    else
        for i = 1, #paths do
            Res.LoadAsset(paths[i], Constants.ASSET_GROUP_CORE)
        end
    end
end


--
--- 向 Native(Java/OC) 发送消息
---@param action string @ 指令
---@param msg string @ -可选- 指令附带的消息。默认：空字符串 ""
function SendMessageToNative(action, msg)
    LuaHelper.SendMessageToNative(action, msg or "")
end


--
--- 获取系统剪切板文本内容
---@return string
function GetClipboardText()
    return LuaHelper.ClipboardText
end
--- 设置系统剪切板文本内容
---@param text string
function SetClipboardText(text)
    LuaHelper.ClipboardText = text
end


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
local _onlyID = 0
--- 获取一个不重复的 ID
---@return number
function GetOnlyID()
    _onlyID = _onlyID + 1
    return _onlyID
end

