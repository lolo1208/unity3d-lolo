--
-- 场景模块
-- 2017/11/14
-- Author LOLO
--


---@class Scene : Module
---
---@field moduleName string @ 见构造函数参数
---@field prefabPath string @ 见构造函数参数
---@field isAsync boolean @ 见构造函数参数
local Scene = class("Scene", Module)


--- 构造函数
---@param moduleName string @ 场景（模块）名称。当 prefabPath 为 nil 时，该值作为参数 sceneName 来调用 C# SceneManager.LoadScene()
---@param optional prefabPath string @ 预设路径。该值默认：nil，表示该场景资源为独立的ab包。设置该值，表示场景为 prefab 场景，在 Empty 场景，Constants.LAYER_SCENE 层显示
---@param optional isAsync boolean @ 是否异步加载，默认：false
function Scene:Ctor(moduleName, prefabPath, isAsync)
    self.moduleName = moduleName
    self.prefabPath = prefabPath
    self.isAsync = isAsync or false

    Scene.super.Ctor(self)
end


--- 场景被销毁时，由 Stage.lua 调用
function Scene:OnDestroy()
end


return Scene