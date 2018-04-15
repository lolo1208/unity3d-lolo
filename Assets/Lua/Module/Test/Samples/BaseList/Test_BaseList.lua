--
-- BaseList 组件测试范例
-- 2018/4/3
-- Author LOLO
--

---@class Test.Samples.BaseList.Test_BaseList : View
---@field New fun():Test.Samples.BaseList.Test_BaseList
---
local Test_BaseList = class("Test.Samples.BaseList.Test_BaseList", View)

function Test_BaseList:Ctor(...)
    Test_BaseList.super.Ctor(self, ...)
end

function Test_BaseList:OnInitialize()
    Test_BaseList.super.OnInitialize(self)

    local transform = self.gameObject.transform

    local list = BaseList.New(
            transform:Find("list").gameObject,
            require("Module.Test.Samples.BaseList.Test_BaseListItem")
    )

    local data = MapList.New()
    -- 这里添加了20条数据，但是根据 list row 和 column 的设置（3x3），只会显示前9条数据
    for i = 1, 20 do
        data:Add(i)
    end
    list:SetData(data)

end

return Test_BaseList