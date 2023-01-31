--
-- ScrollList 组件测试范例
-- 2018/4/3
-- Author LOLO
--

---@class Test.Samples.ScrollList.Test_ScrollList : View
---@field New fun():Test.Samples.ScrollList.Test_ScrollList
---
local Test_ScrollList = class("Test.Samples.ScrollList.Test_ScrollList", View)

function Test_ScrollList:Ctor(...)
    Test_ScrollList.super.Ctor(self, ...)
end

function Test_ScrollList:OnInitialize()
    Test_ScrollList.super.OnInitialize(self)

    local transform = self.gameObject.transform
    local data = MapList.New()
    for i = 1, 999 do
        data:Add(i)
    end


    -- 垂直滚动列表
    local vList = ScrollList.New(
            transform:Find("vList").gameObject,
            require("Module.Test.Samples.ScrollList.Test_ScrollListItem")
    )
    vList:SetData(data)
    vList:ScrollToBottom()
    --vList:ScrollToTop()


    -- 水平滚动列表
    local hList = ScrollList.New(
            transform:Find("hList").gameObject,
            require("Module.Test.Samples.ScrollList.Test_ScrollListItem")
    )
    hList:SetData(data:Clone())
    hList:ScrollToItemIndex(40)
end

return Test_ScrollList