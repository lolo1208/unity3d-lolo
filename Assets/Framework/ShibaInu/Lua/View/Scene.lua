--
-- 场景模块
-- 2017/11/14
-- Author LOLO
--


---@class Scene : Module
---@field New fun():Scene
---
---@field moduleName string @ 场景（模块）名称。当 prefabPath 为 nil 时，该值作为 sceneName 来调用 C# SceneManager.LoadScene()
---@field prefabPath string @ 预设路径。该值默认：nil，表示该场景资源为独立的ab包。设置该值，表示场景为 prefab 场景，在 Empty 场景，Constants.LAYER_SCENE 层显示
---@field isAsync boolean @ 是否异步加载
local Scene = class("Scene", Module)


function Scene:Ctor()
end


--- 场景被销毁时
function Scene:OnDestroy()
end


return Scene