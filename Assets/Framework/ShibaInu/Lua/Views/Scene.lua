--
-- 场景模块
-- 2017/11/14
-- Author LOLO
--


---@class Scene : Module
---
---@field transitionEnabled boolean @ 是否启用转场效果（该属性会被静态访问，请定义成静态属性）。默认：true
---
---@field moduleName string @ 见构造函数参数
---@field prefabPath string @ 见构造函数参数
---@field isAsync boolean @ 见构造函数参数
---@field assetName string @ 见构造函数参数
local Scene = class("Scene", Module)

Scene.transitionEnabled = true



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


--- 场景被销毁时，由 Stage.lua 调用
function Scene:OnDestroy()
    Scene.super.OnDestroy(self)
end


return Scene