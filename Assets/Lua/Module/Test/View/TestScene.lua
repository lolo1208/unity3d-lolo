--
-- 测试场景
-- 2017/11/14
-- Author LOLO
--


---@class Test.TestScene : Scene
---@field New fun():Test.TestScene
local TestScene = class("Test.TestScene", Scene)


function TestScene:Ctor()
    self.moduleName = "Test"
    self.isAsync = true
    self.prefabPath = "Prefab/Test/TestUI.prefab"
end


function TestScene:OnInitialize()
    print(Stage.GetCurrentSceneName())

    local transform = self.gameObject.transform
    local bg = transform:Find("bg").gameObject
    local bar = transform:Find("bar").gameObject
    local Text = transform:Find("Text").gameObject
    local Cube = transform:Find("Cube").gameObject

    ---@param event PointerEvent
    local fn = function(event)
        print(event.currentTarget.gameObject.name, event.type, event.data.position.x, event.data.position.y)
    end

    AddEventListener(bg, PointerEvent.ENTER, fn)
    AddEventListener(bg, PointerEvent.EXIT, fn)
    AddEventListener(bg, PointerEvent.DOWN, fn)
    AddEventListener(bg, PointerEvent.UP, fn)
    AddEventListener(bg, PointerEvent.CLICK, fn)

    AddEventListener(bar, PointerEvent.ENTER, fn)
    AddEventListener(bar, PointerEvent.EXIT, fn)
    AddEventListener(bar, PointerEvent.DOWN, fn)
    AddEventListener(bar, PointerEvent.UP, fn)
    AddEventListener(bar, PointerEvent.CLICK, fn)

    AddEventListener(Cube, PointerEvent.ENTER, fn)
    AddEventListener(Cube, PointerEvent.EXIT, fn)
    AddEventListener(Cube, PointerEvent.DOWN, fn)
    AddEventListener(Cube, PointerEvent.UP, fn)
    AddEventListener(Cube, PointerEvent.CLICK, fn)

    AddEventListener(Text, PointerEvent.ENTER, fn)
    AddEventListener(Text, PointerEvent.EXIT, fn)
    AddEventListener(Text, PointerEvent.DOWN, fn)
    AddEventListener(Text, PointerEvent.UP, fn)
    AddEventListener(Text, PointerEvent.CLICK, fn)
end


function TestScene:OnDestroy()
    print("TestScene:OnDestroy")
end



return TestScene