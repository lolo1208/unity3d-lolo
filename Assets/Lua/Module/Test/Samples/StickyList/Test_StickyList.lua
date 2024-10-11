--
-- StickyList 组件测试范例
-- 2024/10/11
-- Author LOLO
--

local Test_StickyItem = require("Module.Test.Samples.StickyList.Test_StickyItem")


--
---@class Test.Samples.StickyList.Test_StickyList : View
---@field New fun():Test.Samples.StickyList.Test_StickyList
---
local Test_StickyList = class("Test.Samples.StickyList.Test_StickyList", View)

function Test_StickyList:Ctor(...)
    Test_StickyList.super.Ctor(self, ...)
end

function Test_StickyList:OnInitialize()
    Test_StickyList.super.OnInitialize(self)

    local transform = self.gameObject.transform
    local data = MapList.New()
    for i = 1, 999 do
        data:Add(i)
    end

    -- 垂直粘性列表
    local vList = StickyList.New(
            transform:Find("vList").gameObject,
            Test_StickyItem
    )
    vList:SetData(data)
    vList:SetStickyItemIndex(50)

    -- 垂直单列
    local vList2 = StickyList.New(
            transform:Find("vList2").gameObject,
            Test_StickyItem
    )
    vList2:SetData(data)
    vList2:SetStickyItemIndex(52)


    -- 水平粘性列表
    local hList = StickyList.New(
            transform:Find("hList").gameObject,
            Test_StickyItem
    )
    hList:SetData(data:Clone())
    hList:SetStickyItemIndex(51)
end

return Test_StickyList