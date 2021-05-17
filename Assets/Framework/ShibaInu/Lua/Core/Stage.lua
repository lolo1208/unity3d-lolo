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

local Time = Time.uTime
local TimeUtil = TimeUtil
local stage = ShibaInu.Stage

local cleanUI = stage.CleanUI


--
---@class Stage
local Stage = {}


--
local _event = Event.New()
local _ed = EventDispatcher.New()

---@type Window[] @ 当前已经显示的窗口列表
local _windowList = {}

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
Stage.AddDontDestroy = stage.AddDontDestroy
Stage.RemoveDontDestroy = stage.RemoveDontDestroy
Stage.uiCanvas = stage.uiCanvas
Stage.uiCanvasTra = stage.uiCanvasTra



--=[ 窗口 ]=--

--- 打开指定的窗口
---@param window Window @ 窗口实例
---@param closeOthers boolean @ -可选- 是否关闭其他窗口，默认：true
function Stage.OpenWindow(window, closeOthers)
    if closeOthers == nil then
        closeOthers = true
    end

    -- 打开窗口，调整到最上层显示
    if not window.visible then
        window:Show()
    end
    window.transform:SetAsLastSibling()

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

--- 当前是否有 已经打开的窗口
---@return boolean
function Stage.HasWindowOpened()
    for i = 1, #_windowList do
        if _windowList[i].visible then
            return true
        end
    end
    return false
end

--- 获取已注册（已打开）的窗口列表
---@return Window[]
function Stage.GetWindowList()
    return ObjectUtil.Copy(_windowList)
end



--=[ 图层 ]=--

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


--=[ 全屏模态 ]=--

local _modalGO = CreateGameObject("[Modal]", Stage.uiCanvasTra)
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



--
--- 清空 UI 和 PrefabPool
function Stage.Clean()
    cleanUI()
    PrefabPool.Clean()
    GpuAnimation.Clean()
end



--=[ C#调用 ]=--

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
        TimeUtil.totalDeltaTime = TimeUtil.totalDeltaTime + TimeUtil.deltaTime
        TimeUtil.timeSinceLevelLoad = Time.timeSinceLevelLoad
    end

    _event.data = nil
    _event.target = nil
    _event.isPropagationStopped = false

    _event.type = type
    trycall(_ed.DispatchEvent, _ed, _event, false, false)
end



--
return Stage

