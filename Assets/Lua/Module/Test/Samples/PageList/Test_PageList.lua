--
-- PageList 组件测试范例
-- 2019/2/28
-- Author LOLO
--

local Test_PageNum = require("Module.Test.Samples.ViewPager.Test_PageNum")


--
---@class Test.Samples.PageList.Test_PageList : View
---@field New fun():Test.Samples.PageList.Test_PageList
---
local Test_PageList = class("Test.Samples.PageList.Test_PageList", View)


--
function Test_PageList:OnInitialize()
    Test_PageList.super.OnInitialize(self)

    self.pageList = PageList.New(
            self.transform:Find("PageList").gameObject,
            require("Module.Test.Samples.BaseList.Test_BaseListItem")
    )
    self.pl = self.pageList.pageList
    Test_PageNum.New(self.transform:Find("PageNum").gameObject, self.pageList)

    local tra = self.transform:Find("Transformer")
    self.tScroll = GetComponent.Toggle(tra:Find("Scroll").gameObject)
    self.tFade = GetComponent.Toggle(tra:Find("Fade").gameObject)
    self.tZoomOut = GetComponent.Toggle(tra:Find("ZoomOut").gameObject)
    self.tDepth = GetComponent.Toggle(tra:Find("Depth").gameObject)
    self.tCurrent = self.tScroll

    AddEventListener(self.tScroll.gameObject, PointerEvent.CLICK, self.ChangeTransformer, self, 0, self.tScroll)
    AddEventListener(self.tFade.gameObject, PointerEvent.CLICK, self.ChangeTransformer, self, 0, self.tFade)
    AddEventListener(self.tZoomOut.gameObject, PointerEvent.CLICK, self.ChangeTransformer, self, 0, self.tZoomOut)
    AddEventListener(self.tDepth.gameObject, PointerEvent.CLICK, self.ChangeTransformer, self, 0, self.tDepth)

    AddEventListener(self.transform:Find("IsVertical").gameObject, PointerEvent.CLICK, self.ChangeDirection, self)

    local data = MapList.New()
    for i = 1, math.random(20, 100) do
        data:Add(i)
    end
    self.pageList:SetData(data)
end



--
function Test_PageList:ChangeDirection(event)
    self.pl.isVertical = not self.pl.isVertical
end



--
function Test_PageList:ChangeTransformer(event, toTarget)
    if toTarget == self.tCurrent then
        self.tCurrent.isOn = true
        return
    end

    self.tCurrent.isOn = false
    self.tCurrent = toTarget
    self.tCurrent.isOn = true

    if toTarget == self.tScroll then
        self.pl.transformerType = ShibaInu.PageTransformerType.Scroll
    elseif toTarget == self.tFade then
        self.pl.transformerType = ShibaInu.PageTransformerType.Fade
    elseif toTarget == self.tZoomOut then
        self.pl.transformerType = ShibaInu.PageTransformerType.ZoomOut
    elseif toTarget == self.tDepth then
        self.pl.transformerType = ShibaInu.PageTransformerType.Depth
    end
end




--
return Test_PageList