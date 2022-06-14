--
-- 场景对象
-- 一个场景资源对应一个场景对象
-- 该类的实例只能由 SceneManager 创建
-- 2021/04/26
-- Author LOLO
--


--
---@class Scene : Module
---@field New fun(sceneName:string):Scene
---@field isScene boolean @ 给 View 拿来做判断，不添加 OnDestroy 事件侦听
---
---@field sceneName string @ 场景（资源）名称
---
--- 可以使用 initialized 判断异步加载（和初始化）是否已经完成
--- 可以设置 initShow 指定场景异步加载完成后，是否需要立即显示
---
local Scene = class("Scene", Module)
Scene.isScene = true


-- 加载场景完成后，创建到场景根节点名称。gameObject 属性 在 场景资源根节点中 对应的名称
local ROOT_NAME = "[Root]"


--
--- 构造函数
---@param sceneName string @ 场景资源名称
function Scene:Ctor(sceneName)
    Scene.super.Ctor(self)

    self.moduleName = sceneName
    self.sceneName = sceneName
    AddEventListener(SceneManager, SceneEvent.LOAD_COMPLETE, self.LoadSceneComplete, self)
end

--- 异步加载场景资源完成
---@param event SceneEvent
function Scene:LoadSceneComplete(event)
    if event.sceneName == self.sceneName then
        RemoveEventListener(SceneManager, SceneEvent.LOAD_COMPLETE, self.LoadSceneComplete, self)
        self.gameObject = LuaHelper.FindRootObjectInScene(self.sceneName, ROOT_NAME)
        self:OnInitialize()
    end
end



--
--- 在场景中根结点下创建（并返回）子节点
---@param name string
---@return UnityEngine.GameObject
function Scene:CreateGameObjectInRoot(name)
    return CreateGameObject(name, self.transform, true)
end


--
--- 获取根结点下名称为 "Main Camera" 的相机对象
---@return UnityEngine.Camera
function Scene:GetMainCamera()
    if self.transform ~= nil then
        local camTra = self.transform:Find("Main Camera")
        if camTra ~= nil then
            return GetComponent.Camera(camTra)
        end
    end
    return nil
end



--
--- 销毁（卸载）场景
function Scene:Destroy()
    SceneManager.UnloadScene(self.sceneName)
end


--
--- 该函数由 SceneManager 触发
function Scene:OnDestroy()
    Scene.super.OnDestroy(self)

    RemoveEventListener(SceneManager, SceneEvent.LOAD_COMPLETE, self.LoadSceneComplete, self)
end



--
return Scene
