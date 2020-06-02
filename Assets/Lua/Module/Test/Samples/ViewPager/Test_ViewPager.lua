--
-- ViewPager 组件测试范例
-- 2019/2/26
-- Author LOLO
--

local Test_PageNum = require("Module.Test.Samples.ViewPager.Test_PageNum")
local Test_CheckDragDirection = require("Module.Test.Samples.ViewPager.Test_CheckDragDirection")


--
---@class Test.Samples.ViewPager.Test_ViewPager : View
---@field New fun():Test.Samples.ViewPager.Test_ViewPager
---
local Test_ViewPager = class("Test.Samples.ViewPager.Test_ViewPager", View)


--
function Test_ViewPager:OnInitialize()
    Test_ViewPager.super.OnInitialize(self)

    self.viewPager = ViewPager.New(self.transform:Find("ViewPager").gameObject)
    Test_PageNum.New(self.transform:Find("PageNum").gameObject, self.viewPager)
    self.viewPager:DispatchCurrentViewPageEvent()

    local tra = self.transform:Find("Transformer")
    self.tScroll = GetComponent.Toggle(tra:Find("Scroll").gameObject)
    self.tFade = GetComponent.Toggle(tra:Find("Fade").gameObject)
    self.tZoomOut = GetComponent.Toggle(tra:Find("ZoomOut").gameObject)
    self.tDepth = GetComponent.Toggle(tra:Find("Depth").gameObject)
    self.tCurrent = self.tScroll

    local scrollListGO = self.transform:Find("ViewPager/page3/list").gameObject
    self.scrollList = ScrollList.New(scrollListGO, require("Module.Test.Samples.ScrollList.Test_ScrollListItem"))
    self.scrollListData = MapList.New()
    self.scrollList:SetData(self.scrollListData)
    self.cdd = Test_CheckDragDirection.New(
            self.transform:Find("CheckDragDirection").gameObject,
            self.viewPager.viewPager,
            GetComponent.ScrollRect(scrollListGO)
    )
    self.cdd:Hide()

    AddEventListener(self.tScroll.gameObject, PointerEvent.CLICK, self.ChangeTransformer, self, 0, self.tScroll)
    AddEventListener(self.tFade.gameObject, PointerEvent.CLICK, self.ChangeTransformer, self, 0, self.tFade)
    AddEventListener(self.tZoomOut.gameObject, PointerEvent.CLICK, self.ChangeTransformer, self, 0, self.tZoomOut)
    AddEventListener(self.tDepth.gameObject, PointerEvent.CLICK, self.ChangeTransformer, self, 0, self.tDepth)

    AddEventListener(self.transform:Find("IsVertical").gameObject, PointerEvent.CLICK, self.ChangeDirection, self)

    self.viewPager:AddEventListener(PageEvent.VISIBILITY_CHANGED, self.VisibilityChanged, self)
    self.viewPager:AddEventListener(PageEvent.SELECTION_CHANGED, self.SelectionChanged, self)
end


--
---@param event PageEvent
function Test_ViewPager:VisibilityChanged(event)
    if event.index ~= 2 then
        return
    end

    -- 设置数据或清理第三页的 ScrollList
    if event.value then
        for i = 1, math.random(23, 333) do
            self.scrollListData:Add(i)
        end
    else
        self.scrollListData:Clean()
    end
end


--
---@param event PageEvent
function Test_ViewPager:SelectionChanged(event)
    if event.value and event.index == 2 then
        self.cdd:Show()
    else
        self.cdd:Hide()
    end
end



--
---@param event PointerEvent
function Test_ViewPager:ChangeDirection(event)
    self.viewPager.viewPager.isVertical = not self.viewPager.viewPager.isVertical
end



--
---@param event PointerEvent
function Test_ViewPager:ChangeTransformer(event, toTarget)
    if toTarget == self.tCurrent then
        self.tCurrent.isOn = true
        return
    end

    self.tCurrent.isOn = false
    self.tCurrent = toTarget
    self.tCurrent.isOn = true

    if toTarget == self.tScroll then
        self.viewPager.viewPager.transformerType = ShibaInu.PageTransformerType.Scroll
    elseif toTarget == self.tFade then
        self.viewPager.viewPager.transformerType = ShibaInu.PageTransformerType.Fade
    elseif toTarget == self.tZoomOut then
        self.viewPager.viewPager.transformerType = ShibaInu.PageTransformerType.ZoomOut
    elseif toTarget == self.tDepth then
        self.viewPager.viewPager.transformerType = ShibaInu.PageTransformerType.Depth
    end
end




--
return Test_ViewPager