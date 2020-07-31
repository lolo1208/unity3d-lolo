--
-- 不会被 销毁/卸载 的显示进度界面
-- 2020/07/17
-- Author LOLO
--


--
---@class Core.ProgressView : View
---@field New fun():Core.ProgressView
---
---@field bar UnityEngine.UI.Image
---@field text UnityEngine.UI.Text
---@field dfcHide Handler
---
local ProgressView = class("Core.ProgressView", View)

local instance


--
--- 获取 ProgressView 的实例
---@return Core.ProgressView
function ProgressView.GetInstance()
    if instance == nil then
        instance = ProgressView.New()
    end
    return instance
end


--
function ProgressView:Ctor()
    self.initShow = false
    ProgressView.super.Ctor(self, "Prefabs/Core/Progress.prefab", Constants.LAYER_SCENE, Constants.ASSET_GROUP_CORE)
end


--
function ProgressView:OnInitialize()
    ProgressView.super.OnInitialize(self)

    Stage.AddDontDestroy(self.gameObject)
    self.bar = GetComponent.Image(self.transform:Find("Bar"))
    self.text = GetComponent.Text(self.transform:Find("Text"))
end


--
function ProgressView:Show()
    if not self.visible then
        ProgressView.super.Show(self)
        self.bar.fillAmount = 0
        self.text.text = ""
    end

    if self.dfcHide ~= nil then
        CancelDelayedCall(self.dfcHide)
        self.dfcHide = nil
    end
end


--
function ProgressView:Hide()
    -- debug 模式下需要延迟一帧隐藏，不然 Loading 切换过程会有空白
    if isDebug and self.dfcHide == nil then
        self.dfcHide = DelayedFrameCall(function()
            self.dfcHide = nil
            ProgressView.super.Hide(self)
        end)
    else
        ProgressView.super.Hide(self)
    end
end



--
return ProgressView
