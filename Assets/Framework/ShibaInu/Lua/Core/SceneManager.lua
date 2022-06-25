--
-- 场景管理
-- 创建/销毁，显示/隐藏 场景对象，场景集
-- 2021/04/15
-- Author LOLO
--

local SceneMgr = ShibaInu.SceneManager

local LoadScene = SceneMgr.LoadScene
local UnloadScene = SceneMgr.UnloadScene
local UnloadAllScenes = SceneMgr.UnloadAllScenes
local SetActiveScene = SceneMgr.SetActiveScene


--
---@class SceneManager
local SceneManager = {}

SceneManager.GetProgress = SceneMgr.GetProgress
SceneManager.SetDontUnloadAssetBundle = SceneMgr.SetDontUnloadAssetBundle


-- 已创建（加载）的场景列表
local _scenes = MapList.New()
-- 设置的，当前进入（激活）场景的名称
local _currentSceneName



--
--- 创建或获取场景对象
---@param sceneName string
---@param SceneClass Scene
---@return Scene
local function CreateOrGetScene(sceneName, SceneClass)
    local scene = _scenes:GetValueByKey(sceneName)

    -- 已被销毁了
    if scene ~= nil and scene.destroyed then
        _scenes:RemoveByKey(sceneName)
        scene = nil
    end

    if scene == nil then
        SceneClass = SceneClass or Scene
        scene = SceneClass.New(sceneName)
        _scenes:Add(scene, sceneName)
    end

    return scene
end

--
--- 加载场景，并返回 sceneName 对应的 Scene 实例
--- 如果 sceneName 对应的场景资源已加载过，将返回之前加载时创建的 Scene 实例
---@param sceneName string @ 场景（资源）名称
---@param SceneClass Scene @ -可选- 继承至 Scene，用于创建场景实例的 Lua 类。默认：Scene
---@param initShow boolean @ -可选- 如果还未加载，在加载完成后，是否显示该场景。默认：false
---@return Scene
function SceneManager.LoadScene(sceneName, SceneClass, initShow)
    local scene = CreateOrGetScene(sceneName, SceneClass)
    if not scene.initialized then
        scene.initShow = initShow == true
    end
    LoadScene(sceneName, false)
    return scene
end

--
--- 预加载场景，并返回 sceneName 对应的 Scene 实例
--- 如果 sceneName 对应的场景资源已加载过，将返回之前加载时创建的 Scene 实例
--- 场景加载完成后不会显示
--- 与 LoadScene() 的区别：该场景的加载进度不会被统计到总加载进度中
---@param sceneName string @ 场景（资源）名称
---@param SceneClass Scene @ -可选- 继承至 Scene，用于创建场景实例的 Lua 类。默认：Scene
---@return Scene
function SceneManager.PreloadScene(sceneName, SceneClass)
    local scene = CreateOrGetScene(sceneName, SceneClass)
    if not scene.initialized then
        scene.initShow = false
    end
    LoadScene(sceneName, true)
    return scene
end


--
--- 卸载场景
---@param sceneName string @ 场景（资源）名称
function SceneManager.UnloadScene(sceneName)
    if sceneName == _currentSceneName then
        _currentSceneName = nil
    end
    ---@type Scene
    local scene = _scenes:GetValueByKey(sceneName)
    if scene ~= nil then
        _scenes:RemoveByKey(sceneName)
        UnloadScene(scene.sceneName)
        scene:OnDestroy()
    end
end


--
--- 卸载所有场景
function SceneManager.UnloadAllScenes()
    _currentSceneName = nil
    UnloadAllScenes()
    for i = 1, _scenes:GetCount() do
        ---@type Scene
        local scene = _scenes:GetValueByIndex(i)
        scene:OnDestroy()
    end
    _scenes:Clean()
    Stage.Clean()
end


--
--- 隐藏所有场景
function SceneManager.HideAllScene()
    for i = 1, _scenes:GetCount() do
        ---@type Scene
        local scene = _scenes:GetValueByIndex(i)
        scene:Hide()
    end
end



--
--- 加载，显示指定场景，隐藏其他场景，并调用 SetCurrentSceneName(sceneName)
---@param sceneName string @ 场景（资源）名称
---@param SceneClass Scene @ -可选- 继承至 Scene， 用于创建场景实例的 Lua 类。默认：Scene
---@return Scene
function SceneManager.EnterScene(sceneName, SceneClass)
    ---@type Scene
    local scene
    for i = 1, _scenes:GetCount() do
        scene = _scenes:GetValueByIndex(i)
        if scene.sceneName ~= sceneName then
            scene:Hide()
        end
    end

    scene = SceneManager.LoadScene(sceneName, SceneClass)
    if not scene.initialized then
        scene.initShow = true
    else
        scene:Show()
    end
    SceneManager.SetCurrentSceneName(sceneName)
    return scene
end



--
--- 获取 sceneName 对应的 Scene 实例。如果未加载该场景，将返回 nil
---@param sceneName string @ 场景（资源）名称
---@return Scene
function SceneManager.GetScene(sceneName)
    return _scenes:GetValueByKey(sceneName)
end


--
--- sceneName 对应的场景是否已经加载（初始化）完成
---@return boolean
function SceneManager.IsLoaded(sceneName)
    ---@type Scene
    local scene = _scenes:GetValueByKey(sceneName)
    if scene == nil then
        return false
    end
    return scene.initialized and not scene.destroyed
end



--
---@param event SceneEvent
local function SceneLoadComplete(event)
    if event == nil or event.sceneName == _currentSceneName then
        RemoveEventListener(SceneManager, SceneEvent.LOAD_COMPLETE, SceneLoadComplete)
        SetActiveScene(_currentSceneName)
        PrefabPool.Clean()
        SceneEvent.DispatchEvent(SceneEvent.CHANGED, _currentSceneName)
    end
end

--
--- 设置当前进入（激活）场景的名称
--- 将默认 AssetGroup 设置为 sceneName
--- 在场景加载完成时，抛出 SceneEvent.CHANGED 事件
--- 将该场景设置成激活场景
---@param sceneName string
function SceneManager.SetCurrentSceneName(sceneName)
    if sceneName == _currentSceneName then
        return
    end
    _currentSceneName = sceneName
    Res.CurrentAssetGroup = sceneName

    if SceneManager.IsLoaded(sceneName) then
        SceneLoadComplete()
    else
        AddEventListener(SceneManager, SceneEvent.LOAD_COMPLETE, SceneLoadComplete)
    end
end

--- 获取当前进入（激活）场景名称
---@return string
function SceneManager.GetCurrentSceneName()
    return _currentSceneName
end

--- 获取当前进入（激活）的场景
---@return Scene
function SceneManager.GetCurrentScene()
    return SceneManager.GetScene(_currentSceneName)
end



--
return SceneManager
