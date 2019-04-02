--
-- 舞台（UI 和 场景管理）
-- 2017/10/16
-- Author LOLO
--

local error = error
local format = string.format
local insert = table.insert
local remove = table.remove
local floor = math.floor

local stage = ShibaInu.Stage
local cleanUI = stage.CleanUI
local loadScene = stage.LoadScene
local loadSceneAsync = stage.LoadSceneAsync


--
---@class Stage
local Stage = {}

--- Loading场景类
Stage.loadingSceneClass = ""
--- 空场景名称
Stage.emptySceneName = "Empty"

local _event = Event.New()
local _ed = EventDispatcher.New()

local _currentSceneClass ---@type Scene @ 当前正要进入的场景模块类
local _prevSceneClass ---@type Scene @ 上一个场景模块类
local _loadingScene ---@type Scene @ Loading场景实例
local _currentScene ---@type Scene @ 当前场景模块实例
local _windowList = {} ---@type Window[] @ 当前已经显示的窗口列表

---@type UnityEngine.RectTransform[]
local _layers = {
    [Constants.LAYER_SCENE] = stage.sceneLayer,
    [Constants.LAYER_UI] = stage.uiLayer,
    [Constants.LAYER_WINDOW] = stage.windowLayer,
    [Constants.LAYER_UI_TOP] = stage.uiTopLayer,
    [Constants.LAYER_ALERT] = stage.alertLayer,
    [Constants.LAYER_GUIDE] = stage.guideLayer,
    [Constants.LAYER_TOP] = stage.topLayer
}

Stage._ed = _ed
Stage.LoadSubScene = stage.LoadSubScene
Stage.LoadSubSceneAsync = stage.LoadSubSceneAsync
Stage.GetProgress = stage.GetProgress
Stage.AddDontDestroy = stage.AddDontDestroy
Stage.RemoveDontDestroy = stage.RemoveDontDestroy
Stage.uiCanvas = stage.uiCanvas
Stage.uiCanvasTra = stage.uiCanvasTra



--=-----------------------------[ 场景 ]-----------------------------=--

--
--- 播放场景切换效果
---@param isStart boolean @ true：开始转场效果，false：结束转场效果
function Stage.PlaySceneTransition(isStart)
    if isStart then
        Stage.DoShowScene()
    end
end


--
--- 抛出场景有改变事件
---@param scene Scene
local function DispatchSceneChangedEvent(scene)
    if scene.transitionEnabled and scene ~= _loadingScene then
        Stage.PlaySceneTransition(false)
    end

    PrefabPool.Clean()
    scene:OnInitialize()
    _event.target = nil
    _event.isPropagationStopped = false

    _event.type = Event.SCENE_CHANGED
    _event.data = scene.moduleName
    trycall(_ed.DispatchEvent, _ed, _event, false, false)
end


--
--- 异步加载场景完成
---@param event LoadSceneEvent
local function LoadSceneCompleteHandler(event)
    RemoveEventListener(Stage, LoadSceneEvent.COMPLETE, LoadSceneCompleteHandler)
    _loadingScene:OnDestroy()
    _loadingScene = nil

    DelayedFrameCall(function()
        DispatchSceneChangedEvent(_currentScene)
    end)
end


--
--- 异步加载场景 perfab 完成
---@param event LoadResEvent
local function LoadResCompleteHandler(event)
    if event.assetPath == _currentScene.prefabPath then
        RemoveEventListener(Res, LoadResEvent.COMPLETE, LoadResCompleteHandler)
        _currentScene.gameObject = Instantiate(event.assetData, Constants.LAYER_SCENE)
        DispatchSceneChangedEvent(_currentScene)
    end
end


--
--- 显示场景
---@param sceneClass any @ 场景类（不是类的实例）
---@param reload boolean @ -可选- 如果当前正在该场景，是否需要重新加载该场景。默认：false
function Stage.ShowScene(sceneClass, reload)
    if not reload and _currentScene ~= nil and _currentScene.__class == sceneClass.__class then
        return -- 正在该场景中
    end

    _currentSceneClass = sceneClass
    if sceneClass.transitionEnabled then
        Stage.PlaySceneTransition(true)
    else
        Stage.DoShowScene()
    end
end

--
--- 显示当前场景（在切换效果完全遮盖住镜头时调用）
function Stage.DoShowScene()
    -- 清理当前场景
    Stage.Clean()
    if _currentScene ~= nil then
        _prevSceneClass = _currentScene.__class
        _currentScene:OnDestroy()
    end

    RemoveEventListener(Stage, LoadSceneEvent.COMPLETE, LoadSceneCompleteHandler)
    RemoveEventListener(Res, LoadResEvent.COMPLETE, LoadResCompleteHandler)

    -- 显示新场景
    _currentScene = _currentSceneClass.New()
    if _currentScene.moduleName == nil then
        error(format(Constants.E2002, _currentScene.__classname))
    end

    -- 独立场景
    if _currentScene.prefabPath == nil then
        if _currentScene.isAsync then
            -- 先进入 Loading 场景
            _loadingScene = Stage.loadingSceneClass.New()
            loadScene(_loadingScene.assetName)
            DelayedFrameCall(function()
                DispatchSceneChangedEvent(_loadingScene)

                -- 异步加载目标场景
                AddEventListener(Stage, LoadSceneEvent.COMPLETE, LoadSceneCompleteHandler)
                loadSceneAsync(_currentScene.assetName)
            end)
        else
            loadScene(_currentScene.assetName)
            DelayedFrameCall(function()
                DispatchSceneChangedEvent(_currentScene)
            end)
        end

        -- 预设场景（UICanvas）
    else
        -- 当前不在空场景中
        if prevScene == nil or prevScene.prefabPath == nil then
            loadScene(Stage.emptySceneName)
        end

        if _currentScene.isAsync then
            AddEventListener(Res, LoadResEvent.COMPLETE, LoadResCompleteHandler)
            Res.LoadAssetAsync(_currentScene.prefabPath, _currentScene.assetName)
        else
            _currentScene.gameObject = Instantiate(Res.LoadAsset(_currentScene.prefabPath, _currentScene.assetName), Constants.LAYER_SCENE)
            DispatchSceneChangedEvent(_currentScene)
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
--- 获取当前场景
---@return Scene
function Stage.GetCurrentScene()
    return _loadingScene ~= nil and _loadingScene or _currentScene
end


--
--- 获取当前场景名称
---@return string
function Stage.GetCurrentSceneName()
    return Stage.GetCurrentScene().moduleName
end


--
--- 获取当前场景 对应的 assetGroup 名称
---@return string
function Stage.GetCurrentAssetGroup()
    return _currentScene.assetName
end


--
--- 获取当前场景类
---@return Scene
function Stage.GetCurrentSceneClass()
    return _currentSceneClass
end


--
--- 获取上一个场景类
---@return Scene
function Stage.GetPrevSceneClass()
    return _prevSceneClass
end


--
--- 清空场景
function Stage.Clean()
    cleanUI()
    PrefabPool.Clean()
end


--=-----------------------------[ 窗口 ]-----------------------------=--

--- 打开指定的窗口
---@param window Window @ 窗口实例
---@param closeOthers boolean @ -可选- 是否关闭其他窗口，默认：true
function Stage.OpenWindow(window, closeOthers)
    if closeOthers == nil then
        closeOthers = true
    end

    -- 窗口已打开，调整到最上层显示
    if window.visible then
        window.transform:SetAsLastSibling()
    else
        window:Show()
    end

    -- 加入到 _windowList 中
    local hasWindow = false
    for i = 1, #_windowList do
        hasWindow = _windowList[i] == window
        if hasWindow then
            break
        end
    end
    if not hasWindow then
        insert(_windowList, window)
    end

    -- 关闭其他窗口
    if closeOthers then
        Stage.CloseAllWindow(window)
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
    window:Close()
end

--- 关闭已打开的所有窗口
---@param excludeWindow Window @ -可选- 除了这个窗口不关闭。默认：nil
function Stage.CloseAllWindow(excludeWindow)
    local windowList = _windowList
    _windowList = {}
    for i = 1, #windowList do
        local window = windowList[i]
        if window ~= excludeWindow then
            window:Close()
        end
    end
    if excludeWindow ~= nil then
        insert(_windowList, excludeWindow)
    end
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

local _modalGO = CreateGameObject("[Modal]", Stage.uiCanvasTra).gameObject
local _modalTra = _modalGO.transform
local _modalImg = AddOrGetComponent(_modalGO, UnityEngine.UI.Image)
_modalTra.anchorMin = Vector2.zero
_modalTra.anchorMax = Vector2.one
_modalTra.sizeDelta = Vector2.zero
_modalGO:SetActive(false)
Stage.AddDontDestroy(_modalGO)

--- 显示全屏模态
--- 模态对象为单例，就算调用该方法多次，也只会有一个模态实例存在
---@param layerName string @ -可选- 图层名称。默认：Constants.LAYER_TOP
---@param color Color @ -可选- 模态颜色。默认：Color.clear，完全透明显示
function Stage.ShowModal(layerName, color)
    layerName = layerName or Constants.LAYER_TOP
    color = color or Color.clear

    _modalImg.color = color
    SetParent(_modalTra, _layers[layerName])
    _modalTra:SetAsFirstSibling()
    if not _modalGO.activeSelf then
        _modalGO:SetActive(true)
    end
end

--- 隐藏已显示的全屏模态
function Stage.HideModal()
    if _modalGO.activeSelf then
        _modalGO:SetActive(false)
    end
end

--- 获取全屏模态对象
---@return UnityEngine.RectTransform
function Stage.GetModal()
    return _modalTra
end


--=----------------------------[ C#调用 ]----------------------------=--

--- Update / LateUpdate / FixedUpdate 回调。由 StageLooper.cs 调用
--- 在全局变量 Stage 上抛出 Event.UPDATE / Event.LATE_UPDATE  / Event.FIXED_UPDATE 事件
---@param type string
---@param time number
function Stage._loopHandler(type, time)
    TimeUtil.time = time
    TimeUtil.timeMsec = floor(time * 1000 + 0.5)

    if type == Event.UPDATE then
        TimeUtil.frameCount = Time.frameCount
        TimeUtil.deltaTime = Time.deltaTime
    end

    _event.data = nil
    _event.target = nil
    _event.isPropagationStopped = false

    _event.type = type
    trycall(_ed.DispatchEvent, _ed, _event, false, false)
end




--
return Stage
