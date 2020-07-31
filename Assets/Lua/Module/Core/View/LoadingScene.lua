--
-- 异步加载场景时显示的 Loading 场景
-- 2017/11/14
-- Author LOLO
--

local ProgressView = require("Module.Core.View.ProgressView")

local floor = math.floor


--
---@class Core.LoadingScene : Scene
---@field New fun():Core.LoadingScene
---
---@field progressView Core.ProgressView
---
local LoadingScene = class("Core.LoadingScene", Scene)
LoadingScene.NAME = "Loading"


--
function LoadingScene:Ctor()
    LoadingScene.super.Ctor(self, self.NAME)

    Stage.SetDontUnloadScene(self.NAME, true)
end


--
function LoadingScene:OnInitialize()
    LoadingScene.super.OnInitialize(self)

    self.progressView = ProgressView.GetInstance()
    self.progressView:Show()

    AddEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
end



--
--- 进度更新
function LoadingScene:UpdateHandler(event)
    local p = Stage.GetProgress()
    self.progressView.bar.fillAmount = p
    self.progressView.text.text = floor(p * 100) .. "%"
end



--
function LoadingScene:OnDestroy()
    LoadingScene.super.OnDestroy(self)

    RemoveEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
    self.progressView:Hide()
end



--
return LoadingScene
