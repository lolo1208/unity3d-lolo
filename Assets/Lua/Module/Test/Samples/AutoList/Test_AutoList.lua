--
-- BaseList / ScrollList 组件使用 AutoSize, AutoItemCount, AutoItemGap 属性测试范例
-- 2020/05/08
-- Author LOLO
--

---@class Test.Samples.AutoList.Test_AutoList : View
---@field New fun():Test.Samples.AutoList.Test_AutoList
---
local Test_AutoList = class("Test.Samples.AutoList.Test_AutoList", View)

function Test_AutoList:Ctor(...)
    Test_AutoList.super.Ctor(self, ...)
end

function Test_AutoList:OnInitialize()
    Test_AutoList.super.OnInitialize(self)

    local transform = self.gameObject.transform
    local data = MapList.New()
    for i = 1, 99 do
        data:Add(i)
    end


    -- BaseList
    local baselist = BaseList.New(
            transform:Find("BaseList/List").gameObject,
            require("Module.Test.Samples.BaseList.Test_BaseListItem")
    )
    baselist:SetData(data)


    -- ScrollList
    local scrolllist = ScrollList.New(
            transform:Find("ScrollList/List").gameObject,
            require("Module.Test.Samples.ScrollList.Test_ScrollListItem")
    )
    scrolllist:SetData(data:Clone())
    scrolllist:ScrollToItemIndex(11)

end

return Test_AutoList