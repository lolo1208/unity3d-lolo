--
-- 异步加载场景时显示的 Loading 场景
-- 2017/11/14
-- Author LOLO
--

local floor = math.floor


--
---@class Coew.LoadingScene : Scene
---@field New fun():Coew.LoadingScene
---
local LoadingScene = class("Loading.LoadingScene", Scene)
LoadingScene.NAME = "Loading"

---@type View @ 不销毁的进度界面
local progressView
---@type UnityEngine.UI.Image
local bar
---@type UnityEngine.UI.Text
local text


--
function LoadingScene:Ctor()
    LoadingScene.super.Ctor(self, self.NAME)
end


--
function LoadingScene:OnInitialize()
    LoadingScene.super.OnInitialize(self)

    if progressView == nil then
        local go = Instantiate("Prefabs/Core/Progress.prefab", Constants.LAYER_SCENE, Constants.ASSET_GROUP_CORE)
        progressView = View.New()
        progressView.gameObject = go
        progressView:OnInitialize()
        bar = GetComponent.Image(progressView.transform:Find("Bar"))
        text = GetComponent.Text(progressView.transform:Find("Text"))

        Stage.AddDontDestroy(go)
        Stage.SetDontUnloadScene(self.assetName, true)
    else
        bar.fillAmount = 0
        text.text = ""
        progressView:Show()
    end

    AddEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
end



--
--- 进度更新
function LoadingScene:UpdateHandler(event)
    local p = Stage.GetProgress()
    bar.fillAmount = p
    --text.text = floor(p * 100) .. "%"
end



--
function LoadingScene:OnDestroy()
    LoadingScene.super.OnDestroy(self)

    RemoveEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
    if isDebug then
        DelayedFrameCall(progressView.Hide, progressView)
    else
        progressView:Hide()
    end
end



--
return LoadingScene
