--
-- 异步加载场景时显示的 Loading 场景
-- 2017/11/14
-- Author LOLO
--

local floor = math.floor


--
---@class Loading.LoadingScene : Scene
---@field New fun():Loading.LoadingScene
---
---@field progressText UnityEngine.UI.Text
---@field barRect UnityEngine.RectTransform
---
local LoadingScene = class("Loading.LoadingScene", Scene)
LoadingScene.NAME = "Loading"


--
function LoadingScene:Ctor()
    LoadingScene.super.Ctor(self, self.NAME)
end


--
function LoadingScene:OnInitialize()
    LoadingScene.super.OnInitialize(self)
    Stage.SetDontUnloadScene(self.assetName, true)

    local transform = GameObject.Find("SceneUICanvas").transform
    self.progressText = GetComponent.Text(transform:Find("ProgressText").gameObject)
    self.barRect = GetComponent.RectTransform(transform:Find("Bar").gameObject)

    AddEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
    AddEventListener(Stage, LoadSceneEvent.COMPLETE, self.LoadSceneCompleteHandler, self)
end


--
--- 进度更新
function LoadingScene:UpdateHandler(event)
    local p = Stage.GetProgress()

    local size = self.barRect.sizeDelta
    size.x = 800 * p + 120
    self.barRect.sizeDelta = size

    self.progressText.text = floor(p * 100) .. "%"
end


--
--- 加载完成
function LoadingScene:LoadSceneCompleteHandler(event)
    self:OnDestroy()
end



--
function LoadingScene:OnDestroy()
    LoadingScene.super.OnDestroy(self)
    RemoveEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
    RemoveEventListener(Stage, LoadSceneEvent.COMPLETE, self.LoadSceneCompleteHandler, self)
end



--
return LoadingScene
