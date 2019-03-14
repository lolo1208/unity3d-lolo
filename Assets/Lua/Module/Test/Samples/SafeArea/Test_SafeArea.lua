--
-- SafeAreaLayout 测试范例
-- 2019/3/11
-- Author LOLO
--


--
---@class Test.Samples.SafeArea.Test_SafeArea : View
---@field New fun():Test.Samples.SafeArea.Test_SafeArea
---
local Test_SafeArea = class("Test.Samples.SafeArea.Test_SafeArea", View)


--
function Test_SafeArea:Ctor(...)
    Test_SafeArea.super.Ctor(self, ...)
end


--
function Test_SafeArea:OnInitialize()
    Test_SafeArea.super.OnInitialize(self)
    self.transform.sizeDelta = Vector2.zero
end




--
return Test_SafeArea
