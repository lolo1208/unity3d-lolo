--
-- 异步加载场景时显示的 Loading 场景
-- 2017/11/14
-- Author LOLO
--

local floor = math.floor
local tostring = tostring

---@class Loading.LoadingScene : Scene
---@field New fun():Loading.LoadingScene
local LoadingScene = class("Loading.LoadingScene", Scene)

local progressText ---@type UnityEngine.UI.Text
local barRect ---@type UnityEngine.RectTransform

function LoadingScene:Ctor()
    LoadingScene.super.Ctor(self, "Loading")
end

function LoadingScene:OnInitialize()
    LoadingScene.super.OnInitialize(self)

    local transform = GameObject.Find("SceneUICanvas").transform
    progressText = GetComponent.Text(transform:Find("progressText").gameObject)
    barRect = GetComponent.RectTransform(transform:Find("bar").gameObject)

    AddEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
    AddEventListener(Stage, LoadSceneEvent.COMPLETE, self.LoadSceneCompleteHandler, self)
end

--- 进度更新
function LoadingScene:UpdateHandler(event)
    local p = Stage.GetProgress()

    local size = barRect.sizeDelta
    size.x = 800 * p + 120
    barRect.sizeDelta = size

    progressText.text = tostring(floor(p * 100)) .. "%"
end

--- 加载完成
function LoadingScene:LoadSceneCompleteHandler(event)
    self:OnDestroy()
end

function LoadingScene:OnDestroy()
    LoadingScene.super.OnDestroy(self)
    RemoveEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
    RemoveEventListener(Stage, LoadSceneEvent.COMPLETE, self.LoadSceneCompleteHandler, self)
end

return LoadingScene