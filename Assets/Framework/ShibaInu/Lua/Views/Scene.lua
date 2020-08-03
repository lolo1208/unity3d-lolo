--
-- 场景模块
-- 2017/11/14
-- Author LOLO
--


---@class Scene : Module
---
---@field isScene boolean
---@field transitionEnabled boolean @ 是否启用转场效果（该属性会被静态访问，请定义成静态属性）。默认：true
---
---@field moduleName string @ 见构造函数参数
---@field prefabPath string @ 见构造函数参数
---@field isAsync boolean @ 见构造函数参数
---@field assetName string @ 见构造函数参数
---
---@field asyncSubScenes string[] @ 需要异步加载的 Sub 场景名称列表
---@field asyncSubSceneIndex number @ 当前异步加载的 Sub 场景索引
local Scene = class("Scene", Module)

Scene.isScene = true
Scene.transitionEnabled = true



--
--- 构造函数
---@param moduleName string @ 场景（模块）名称。当 prefabPath 为 nil 时，该值作为参数 sceneName 来调用 C# SceneManager.LoadScene()
---@param prefabPath string @ -可选- 预设路径。该值默认：nil，表示该场景资源为独立的ab包。设置该值，表示场景为 prefab 场景，在 Empty 场景，Constants.LAYER_SCENE 层显示
---@param isAsync boolean @ -可选- 是否异步加载，默认：false
---@param assetName string @ -可选- 使用的场景资源名称。默认：nil，表示使用 moduleName
function Scene:Ctor(moduleName, prefabPath, isAsync, assetName)
    self.moduleName = moduleName
    self.prefabPath = prefabPath
    self.isAsync = isAsync or false
    self.assetName = assetName or moduleName

    Scene.super.Ctor(self)
end


--
function Scene:OnInitialize()
    Scene.super.OnInitialize(self)

    if self.asyncSubScenes ~= nil then
        self:LoadSubSceneAsync()
    end
end



--
--- 开始异步加载所有 Sub 场景
---@vararg string @ 需要异步加载的 Sub 场景名称列表
function Scene:LoadSubSceneAsync(...)
    local args = { ... }
    if #args > 0 then
        self.asyncSubScenes = args
    end
    if self.asyncSubScenes ~= nil then
        self.asyncSubSceneIndex = 0
        self:LoadNextSubSceneAsync()
    end
end


--
--- 异步加载下一个 SubScene
---@param event SceneEvent
function Scene:LoadNextSubSceneAsync(event)
    self.asyncSubSceneIndex = self.asyncSubSceneIndex + 1
    if self.asyncSubSceneIndex <= #self.asyncSubScenes then
        AddEventListener(Stage, SceneEvent.LOAD_SUB_COMPLETE, self.LoadNextSubSceneAsync, self)
        Stage.LoadSubSceneAsync(self.asyncSubScenes[self.asyncSubSceneIndex])
    else
        RemoveEventListener(Stage, SceneEvent.LOAD_SUB_COMPLETE, self.LoadNextSubSceneAsync, self)
    end
end


--
--- 获取异步加载 Sub 场景的总进度
---@return number @ [ 0~1 ]
function Scene:GetLoadSubSceneProgress()
    if self.asyncSubScenes == nil then
        return 1 -- 没有需要异步加载的 SubScene
    end
    local count = #self.asyncSubScenes
    local completed = self.asyncSubSceneIndex - 1
    if count == completed then
        return 1 -- 全部加载完成了
    end
    return completed / count
end



--
--- 场景被销毁时，由 Stage.lua 调用
function Scene:OnDestroy()
    Scene.super.OnDestroy(self)

    RemoveEventListener(Stage, SceneEvent.LOAD_SUB_COMPLETE, self.LoadNextSubSceneAsync, self)
end



--
return Scene
