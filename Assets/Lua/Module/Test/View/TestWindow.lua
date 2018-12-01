--
-- 测试窗口
-- 2018/11/17
-- Author LOLO
--


--
---@class Test.TestWindow : Window
---
local TestWindow = class("Test.TestWindow", Window)


--
function TestWindow:Ctor()
    TestWindow.super.Ctor(self, "TestWindow", "Prefabs/Test/TestWindow.prefab")
end




--
return TestWindow