--
-- 测试场景
-- 2018/3/14
-- Author LOLO
--


---@class Test.TestScene : Scene
---@field New fun():Test.TestScene
---
local TestScene = class("Test.TestScene", Scene)

function TestScene:Ctor(...)
    TestScene.super.Ctor(self, "Test")
end

function TestScene:OnInitialize()
    TestScene.super.OnInitialize(self)

end



--

function TestScene:OnDestroy()
end

return TestScene