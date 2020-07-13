--
-- View / Window 打开关闭效果测试范例
-- 2019/3/30
-- Author LOLO
--


local MoveView = require("Effects.View.MoveView")
local ScaleView = require("Effects.View.ScaleView")
local FadeView = require("Effects.View.FadeView")


--
---@class Test.Samples.Test_ViewEffects : View
---@field New fun():Test.Samples.Test_ViewEffects
---
local Test_ViewEffects = class("Test.Samples.BaseList.Test_ViewEffects", View)


--
function Test_ViewEffects:OnInitialize()
    Test_ViewEffects.super.OnInitialize(self)

    -- MoveView
    local mvTra = self.transform:Find("MoveView")
    local viewsTra = mvTra:Find("Views")
    local btnsTra = mvTra:Find("Btns")
    local list = {
        { "LocalPosition", false, Vector3.zero, Vector3.New(100, 100) },
        { "Top", true, Vector2.New(0, -50), Vector2.New(0, 50) },
        { "Bottom", true, Vector2.New(0, 50), Vector2.New(0, -50) },
        { "Left", true, Vector2.New(50, 0), Vector2.New(-50, 0) },
        { "Right", true, Vector2.New(-50, 0), Vector2.New(50, 0) },
    }
    for i = 1, #list do
        local item = list[i]
        local name = item[1]
        local view = MoveView.New()
        view.isAnchored = item[2]
        view.show_position = item[3]
        view.hide_position = item[4]
        view.gameObject = viewsTra:Find(name).gameObject
        view.initShow = false
        view:OnInitialize()
        AddEventListener(btnsTra:Find(name).gameObject, PointerEvent.CLICK, self.ShowOrHideMoveView, self, 0, view)
    end


    -- ScaleView
    self.scaleView = ScaleView.New()
    self.scaleView.gameObject = self.transform:Find("ScaleView").gameObject
    self.scaleView.initShow = false
    self.scaleView:OnInitialize()
    AddEventListener(self.transform:Find("ScaleViewBtn").gameObject, PointerEvent.CLICK, self.ShowOrHideScaleView, self)


    -- FadeView
    self.fadeView = FadeView.New()
    self.fadeView.gameObject = self.transform:Find("FadeView").gameObject
    self.fadeView.initShow = false
    self.fadeView:OnInitialize()
    AddEventListener(self.transform:Find("FadeViewBtn").gameObject, PointerEvent.CLICK, self.ShowOrHideFadeView, self)

end


--
function Test_ViewEffects:ShowOrHideMoveView(event, view)
    --view:ToggleVisibility()
    if view.showed then
        view:Hide()
    else
        view:Show()
    end
end


--
function Test_ViewEffects:ShowOrHideScaleView(event)
    if self.scaleView.showed then
        self.scaleView:Hide()
    else
        self.scaleView:Show()
    end
end


--
function Test_ViewEffects:ShowOrHideFadeView(event)
    if self.fadeView.showed then
        self.fadeView:Hide()
    else
        self.fadeView:Show()
    end
end




--
return Test_ViewEffects
