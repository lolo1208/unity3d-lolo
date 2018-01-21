--
-- 测试场景模块
-- 2017/11/14
-- Author LOLO
--


---@class Test.TestScene : Scene
---@field New fun():Test.TestScene
local TestScene = class("Test.TestScene", Scene)





function TestScene:Ctor()
    TestScene.super.Ctor(self, "Test", "Prefabs/Test/TestUI.prefab", true)

    Stage.OpenWindow(require("Module.Test.View.TestWindow"))
end



function TestScene:OnInitialize()
    TestScene.super.OnInitialize(self)
end


function TestScene:OnDestroy()
end



return TestScene