--
-- 检查更新，以及下载更新场景
-- 2020/07/16
-- Author LOLO
--

local ProgressView = require("Module.Core.View.ProgressView")

local floor = math.floor


--
---@class Update.UpdateScene : Scene
---@field New fun():Update.UpdateScene
---
---@field progressView Core.ProgressView
---
local UpdateScene = class("Update.UpdateScene", Scene)
UpdateScene.NAME = "Update"


--
function UpdateScene:Ctor()
    UpdateScene.super.Ctor(self, self.NAME, "Prefabs/Core/UpdateScene.prefab")
end


--
function UpdateScene:OnInitialize()
    UpdateScene.super.OnInitialize(self)

    self.progressView = ProgressView.GetInstance()
    self.progressView:Show()

    --AddEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
end



--
--- 进度更新
function UpdateScene:UpdateHandler(event)
    --local p = Stage.GetProgress()
    --self.progressView.bar.fillAmount = p
    --self.progressView.text.text = floor(p * 100) .. "%"
end



--
function UpdateScene:OnDestroy()
    UpdateScene.super.OnDestroy(self)

    --RemoveEventListener(Stage, Event.UPDATE, self.UpdateHandler, self)
    self.progressView:Hide()
end



--
return UpdateScene
