--
-- 舞台（UI 和 场景管理）
-- 2017/10/16
-- Author LOLO
--

local error = error
local format = string.format
local remove = table.remove


--
---@class Stage
---
---@field loadingSceneClass Scene @ Loading场景类
---
---@field AddDontDestroy fun(go:UnityEngine.GameObject):void @ 添加一个在清除场景时，不需被销毁的 GameObject
---@field RemoveDontDestroy fun(go:UnityEngine.GameObject):void @ 移除一个在清除场景时，不需被销毁的 GameObject
---@field GetProgress fun():number @ 获取当前异步加载进度 0~1
---
local Stage = {}

local event = Event.New()
local ed = EventDispatcher.New()

local _prevSceneClass ---@type Scene @ 上一个场景模块类
local _loadingScene ---@type Scene @ Loading场景实例
local _currentScene ---@type Scene @ 当前场景模块实例
local _windowList = {} ---@type table<number, Window> @ 当前已经显示的窗口列表


-- layers
local _sceneLayer, _uiLayer, _windowLayer, _uiTopLayer, _alertLayer, _guideLayer, _topLayer ---@type UnityEngine.RectTransform
---@type table<string, UnityEngine.Transform>
local _layers = {}

---@type UnityEngine.GameObject @ prebab 缓存池（不可见）。由 PrefabPool 维护
Stage.prefabPool = nil


--
local function UpdateLayers()
    _sceneLayer = ShibaInu.Stage.sceneLayer
    _uiLayer = ShibaInu.Stage.uiLayer
    _windowLayer = ShibaInu.Stage.windowLayer
    _uiTopLayer = ShibaInu.Stage.uiTopLayer
    _alertLayer = ShibaInu.Stage.alertLayer
    _guideLayer = ShibaInu.Stage.guideLayer
    _topLayer = ShibaInu.Stage.topLayer

    _layers[Constants.LAYER_SCENE] = _sceneLayer
    _layers[Constants.LAYER_UI] = _uiLayer
    _layers[Constants.LAYER_WINDOW] = _windowLayer
    _layers[Constants.LAYER_UI_TOP] = _uiTopLayer
    _layers[Constants.LAYER_ALERT] = _alertLayer
    _layers[Constants.LAYER_GUIDE] = _guideLayer
    _layers[Constants.LAYER_TOP] = _topLayer
end
UpdateLayers()

Stage._ed = ed
Stage.AddDontDestroy = ShibaInu.Stage.AddDontDestroy
Stage.RemoveDontDestroy = ShibaInu.Stage.RemoveDontDestroy
Stage.GetProgress = ShibaInu.Stage.GetProgress
Stage.uiCanvas = ShibaInu.Stage.uiCanvas
Stage.uiCanvasTra = ShibaInu.Stage.uiCanvasTra



--=-----------------------------[ 场景 ]-----------------------------=--

--
--- 异步加载场景完成
---@param event LoadSceneEvent
local function LoadSceneCompleteHandler(event)
    RemoveEventListener(Stage, LoadSceneEvent.COMPLETE, LoadSceneCompleteHandler)
    _loadingScene:OnDestroy()
    _loadingScene = nil

    --_currentScene:OnInitialize()
    DelayedFrameCall(_currentScene.OnInitialize, _currentScene)
end


--
--- 异步加载场景 perfab 完成
---@param event LoadResEvent
local function LoadResCompleteHandler(event)
    if event.assetPath == _currentScene.prefabPath then
        RemoveEventListener(Res, LoadResEvent.COMPLETE, LoadResCompleteHandler)
        _currentScene.gameObject = Instantiate(event.assetData, Constants.LAYER_SCENE)
        _currentScene:OnInitialize()
    end
end


--
--- 显示场景
---@param sceneClass any @ 场景类（不是类的实例）
function Stage.ShowScene(sceneClass)
    local prevScene = _currentScene
    if prevScene ~= nil and prevScene.__class == sceneClass.__class then
        return -- 正在该场景中
    end

    -- 清理当前场景
    Stage.Clean()
    if prevScene ~= nil then
        _prevSceneClass = prevScene.__class
        prevScene:OnDestroy()
    end

    RemoveEventListener(Stage, LoadSceneEvent.COMPLETE, LoadSceneCompleteHandler)
    RemoveEventListener(Res, LoadResEvent.COMPLETE, LoadResCompleteHandler)

    -- 显示新场景
    _currentScene = sceneClass.New()
    local sceneName = _currentScene.moduleName
    if sceneName == nil then
        error(format(Constants.E2002, _currentScene.__classname))
    end

    -- 独立场景
    if _currentScene.prefabPath == nil then
        if _currentScene.isAsync then
            -- 先进入 Loading 场景
            _loadingScene = Stage.loadingSceneClass.New()
            ShibaInu.Stage.LoadScene(_loadingScene.moduleName)
            DelayedFrameCall(function()
                _loadingScene:OnInitialize()

                -- 异步加载目标场景
                AddEventListener(Stage, LoadSceneEvent.COMPLETE, LoadSceneCompleteHandler)
                ShibaInu.Stage.LoadSceneAsync(sceneName)
            end)
        else
            ShibaInu.Stage.LoadScene(sceneName)
            DelayedFrameCall(_currentScene.OnInitialize, _currentScene)
        end

        -- 预设场景（UICanvas）
    else
        -- 当前不在空场景中
        if prevScene == nil or prevScene.prefabPath == nil then
            ShibaInu.Stage.LoadScene("Empty")
        end

        if _currentScene.isAsync then
            AddEventListener(Res, LoadResEvent.COMPLETE, LoadResCompleteHandler)
            Res.LoadAssetAsync(_currentScene.prefabPath, sceneName)
        else
            _currentScene.gameObject = Instantiate(Res.LoadAsset(_currentScene.prefabPath, sceneName), Constants.LAYER_SCENE)
            _currentScene:OnInitialize()
        end
    end
end


--
--- 显示上一个场景
function Stage.ShowPrevScene()
    if _prevSceneClass ~= nil then
        Stage.ShowScene(_prevSceneClass)
    end
end


--
--- 获取当前场景名称
---@return string
function Stage.GetCurrentSceneName()
    return _currentScene.moduleName
end


--
--- 获取上一个场景类
---@return string
function Stage.GetPrevSceneClass()
    return _prevSceneClass
end


--
--- 清空场景
function Stage.Clean()
    ShibaInu.Stage.Clean()
    PrefabPool.Clean()
    UpdateLayers()
end


--=-----------------------------[ 窗口 ]-----------------------------=--

--- 打开指定的窗口
---@param windowClass any  @ 窗口类（不是类的实例）
---@param optional closeOthers boolean @ 是否关闭其他窗口，默认：true
---@param optional ... @ 创建实例时传递的参数
function Stage.OpenWindow(windowClass, closeOthers)
    closeOthers = closeOthers == nil and true or false

    local opened = false
    local window ---@type Window
    for i = 1, #_windowList do
        window = _windowList[i]
        if window.__class == windowClass then
            -- 窗口已打开，调整到最上层显示
            window.gameObject.transform:SetSiblingIndex(_windowLayer.childCount - 1)
            opened = true
        elseif closeOthers then
            Stage.CloseWindow(window) -- 关闭其他窗口
        end
    end

    -- 该窗口还没打开
    if not opened then
        window = windowClass.New()
        _windowList[#_windowList] = window
    end
end

--- 关闭某个窗口
---@param window Window
function Stage.CloseWindow(window)
    -- 在列表中删除
    for i = 1, #_windowList do
        if _windowList[i] == window then
            remove(_windowList, i)
            break
        end
    end

    View.Hide(window) -- 调用 View:Hide()
end

--- 关闭已打开的所有窗口
function Stage.CloseAllWindow()
    for i = 1, #_windowList do
        local window = _windowList[i]
        View.Hide(window)
    end
    _windowList = {}
end


--=-----------------------------[ 图层 ]-----------------------------=--

--- 将 target 添加到指定图层中
---@param target UnityEngine.Transform
---@param layerName string @ 图层名称，见 Consants.LAYER_*** 系列常量
function Stage.AddToLayer(target, layerName)
    local layer = _layers[layerName]
    if layer == nil then
        error(format(Constants.E2001, layerName))
    end
    SetParent(target, layer)
end

--- 获取指定图层对象
---@param layerName string @ 图层名称，见 Consants.LAYER_*** 系列常量
---@return UnityEngine.Transform
function Stage.GetLayer(layerName)
    local layer = _layers[layerName]
    if layer == nil then
        error(format(Constants.E2001, layerName))
    end
    return layer
end


--=----------------------------[ 全屏模态 ]----------------------------=--

local _modal = Stage.uiCanvasTra:Find("MODAL").gameObject
local _modalTransform = _modal.transform
local _modalImage = GetComponent.Image(_modal)
Stage.AddDontDestroy(_modal)
_modal:SetActive(false)

--- 显示全屏模态
--- 模态对象为单例，就算调用该方法多次，也只会有一个模态实例存在
---@param optional layerName string @ 图层名称。默认：Constants.LAYER_TOP
---@param optional color Color @ 模态颜色。默认：Color.clear，完全透明显示
function Stage.ShowModal(layerName, color)
    layerName = layerName or Constants.LAYER_TOP
    color = color or Color.clear

    _modalImage.color = color
    SetParent(_modalTransform, _layers[layerName])
    if not _modal.activeSelf then
        _modal:SetActive(true)
    end
end

--- 隐藏已显示的全屏模态
function Stage.HideModal()
    if _modal.activeSelf then
        _modal:SetActive(false)
    end
end


--=----------------------------[ C#调用 ]----------------------------=--

--- Update / LateUpdate / FixedUpdate 回调。由 StageLooper.cs 调用
--- 在全局变量 Stage 上抛出 Event.UPDATE / Event.LATE_UPDATE  / Event.FIXED_UPDATE 事件
---@param type string
---@param time number
function Stage._loopHandler(type, time)
    TimeUtil.time = time
    if type == Event.UPDATE then
        TimeUtil.frameCount = Time.frameCount
    end

    event.data = nil
    event.target = nil
    event.isPropagationStopped = false

    event.type = type
    trycall(ed.DispatchEvent, ed, event, false, false)
end

return Stage