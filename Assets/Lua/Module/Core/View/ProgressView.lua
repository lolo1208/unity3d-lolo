--
-- 不会被 销毁/卸载 的显示进度界面
-- 2020/07/17
-- Author LOLO
--

--
---@class Core.ProgressView : Effects.View.FadeView
---@field New fun():Core.ProgressView
---
---@field bar UnityEngine.UI.Image
---@field text UnityEngine.UI.Text
---
local ProgressView = class("Core.ProgressView", FadeView)

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
    self.show_duration = 0
    ProgressView.super.Ctor(self, "Prefabs/Core/Progress.prefab", Constants.LAYER_UI_TOP, Constants.ASSET_GROUP_CORE)
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
        self.transform:SetAsLastSibling()
    end
end



--
return ProgressView
