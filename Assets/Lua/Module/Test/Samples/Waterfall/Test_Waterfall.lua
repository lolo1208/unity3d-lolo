--
-- Waterfall 组件测试范例
-- 2023/01/09
-- Author LOLO
--

---@class Test.Samples.Waterfall.Test_Waterfall : View
---@field New fun():Test.Samples.Waterfall.Test_Waterfall
---
local Test_Waterfall = class("Test.Samples.Waterfall.Test_Waterfall", View)

function Test_Waterfall:Ctor(...)
    Test_Waterfall.super.Ctor(self, ...)
end

function Test_Waterfall:OnInitialize()
    Test_Waterfall.super.OnInitialize(self)

    local transform = self.gameObject.transform
    local data


    -- 垂直 Waterfall 列表
    local vList = Waterfall.New(
            transform:Find("vList").gameObject,
            require("Module.Test.Samples.Waterfall.Test_WaterfallItem")
    )
    data = MapList.New()
    for i = 1, 999 do
        data:Add(MathUtil.RandomInt(1, 5))
    end
    vList:SetData(data)
    --vList:ScrollToItemIndex(500)
    --vList:ScrollToPosition(0.5)
    --vList:ScrollToBottom()
    --vList:ScrollToTop()


    -- 水平 Waterfall 列表
    local hList = Waterfall.New(
            transform:Find("hList").gameObject,
            require("Module.Test.Samples.Waterfall.Test_WaterfallItem")
    )
    data = MapList.New()
    for i = 1, 999 do
        data:Add(MathUtil.RandomInt(90, 300))
    end
    hList.itemSkeletonSize.width = 150
    hList:SetData(data)
end

return Test_Waterfall