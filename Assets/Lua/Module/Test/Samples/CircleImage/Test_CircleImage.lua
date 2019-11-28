--
-- CircleImage 组件测试范例
-- 2018/4/3
-- Author LOLO
--

---@class Test.Samples.CircleImage.Test_CircleImage : View
---@field New fun():Test.Samples.CircleImage.Test_CircleImage
---@field cdImg ShibaInu.CircleImage
---@field colorImg ShibaInu.CircleImage
---@field isAdd boolean
---
local Test_CircleImage = class("Test.Samples.CircleImage.Test_CircleImage", View)

function Test_CircleImage:Ctor(...)
    Test_CircleImage.super.Ctor(self, ...)
end

function Test_CircleImage:OnInitialize()
    Test_CircleImage.super.OnInitialize(self)

    local transform = self.gameObject.transform

    self.cdImg = GetComponent.CircleImage(transform:Find("circleImg4").gameObject)
    self.colorImg = GetComponent.CircleImage(transform:Find("circleImg6").gameObject)

    self.colTweener = self.colorImg:DOColor(Color.red, 1.5):SetLoops(-1, DOTween_Enum.LoopType.Yoyo)

    self:EnableDestroyListener()
    AddEventListener(Stage, Event.UPDATE, self.OnUpdate_Stage, self)
end

function Test_CircleImage:OnUpdate_Stage(event)
    local fan = self.cdImg.fan
    if self.isAdd then
        fan = fan + 0.01
        if fan >= 1 then
            fan = 1
            self.isAdd = false
        end

    else
        fan = fan - 0.01
        if fan <= 0 then
            fan = 0
            self.isAdd = true
        end
    end
    self.cdImg.fan = fan
end

function Test_CircleImage:OnDestroy()
    RemoveEventListener(Stage, Event.UPDATE, self.OnUpdate_Stage, self)
    self.colTweener:Kill()
end

return Test_CircleImage