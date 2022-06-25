--
-- 全屏界面管理器
-- 根据全屏界面的显隐，自动开启和关闭各场景主相机
-- 2022/05/28
-- Author LOLO
--

local remove = table.remove


--
---@class FullScreenViewManager
local FullScreenViewManager = {}

---@type View[]
local _viewList = {}


--
--- 获取当前激活场景的主相机
---@return UnityEngine.Camera
local function GetCurrentSceneMainCamera()
    local scene = SceneManager.GetCurrentScene()
    if scene ~= nil then
        return scene:GetMainCamera()
    end
    return nil
end


--
--- 在当前（激活）场景有改变，或全屏界面显示或隐藏时，对应的启用或禁用当前场景的 "Main Camera"
---@param event SceneEvent | VisibilityEvent
local function SceneOrViewChanged(event)
    local camera = GetCurrentSceneMainCamera()
    if camera == nil then
        return
    end

    local hasShowed = false
    ---@type View
    local view
    for i = #_viewList, 1, -1 do
        view = _viewList[i]
        if view.isFullScreen and not view.destroyed then
            if view.showed then
                hasShowed = true
                break
            end
        else
            FullScreenViewManager.UnregisterFullScreenView(view)
        end
    end

    if hasShowed then
        if view.isCameraBlur then
            Stage.ShowCameraBlurModal()
        end
        if camera.enabled then
            camera.enabled = false
        end
    else
        if not camera.enabled then
            camera.enabled = true
        end
        Stage.HideCameraBlurModal()
    end
end

-- 关注场景切换（激活）事件
AddEventListener(SceneManager, SceneEvent.CHANGED, SceneOrViewChanged)


--
--- 全屏界面被销毁时
local function FullScreenViewDestroyed(view, event)
    FullScreenViewManager.UnregisterFullScreenView(view)
    SceneOrViewChanged()
end

--


--
--- 将一个界面注册为全屏界面
---@param view View
function FullScreenViewManager.RegisterFullScreenView(view)
    local count = #_viewList
    for i = 1, count do
        if _viewList[i] == view then
            return
        end
    end
    _viewList[count + 1] = view
    view:AddEventListener(VisibilityEvent.SHOWED, SceneOrViewChanged)
    view:AddEventListener(VisibilityEvent.HIDDEN, SceneOrViewChanged)
    AddEventListener(view.gameObject, DestroyEvent.DESTROY, FullScreenViewDestroyed, view)
    SceneOrViewChanged()
end


--
--- 将一个界面从全屏界面管理器中移除
---@param view View
function FullScreenViewManager.UnregisterFullScreenView(view)
    for i = 1, #_viewList do
        if _viewList[i] == view then
            remove(_viewList, i)
            view:RemoveEventListener(VisibilityEvent.SHOWED, SceneOrViewChanged)
            view:RemoveEventListener(VisibilityEvent.HIDDEN, SceneOrViewChanged)
            RemoveEventListener(view.gameObject, DestroyEvent.DESTROY, FullScreenViewDestroyed, view)
            SceneOrViewChanged()
            return
        end
    end
end



--
return FullScreenViewManager
