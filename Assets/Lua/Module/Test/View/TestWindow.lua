--
-- 测试窗口模块
-- 2017/12/4
-- Author LOLO
--

---@class Test.TestWindow : Window
---@field New fun():Test.TestWindow
local TestWindow = class("Test.TestWindow", Window)


function TestWindow:Ctor()
    TestWindow.super.Ctor(self, "TestWindow", "Prefabs/Test/TestWindow.prefab")
end


function TestWindow:OnInitialize()
    TestWindow.super.OnInitialize(self)


    local data = {
        [1] = { ["id"] = 101, ["name"] = "aaa", ["lv"] = 999 },
        [2] = { ["id"] = 202, ["name"] = "bbb", ["lv"] = 888 },
        [3] = { ["id"] = 303, ["name"] = "ccc", ["lv"] = 777 },
    }
    local ml = MapList.New(data, "id", "name")


    ml:Clean()
    for i = 1, 999 do
        ml:Add({ name = "no." .. i }, "key" .. i)
    end


    local listGO = self.gameObject.transform:Find("list").gameObject
    local list = ScrollList.New(listGO, require("Module.Test.View.TestItemRenderer"))
    list:SetData(ml)

    DelayedCall(2, function()
        list:SetViewportSize(350, 350)
        list:SelectItemByIndex(15)
    end)

    DelayedCall(8, function()
        list:SetIsVertical(false)
    end)

    LuaHelper.SendHttpRequest("http://www.adafsdf.com", handler(self.test, self).lambda, nil)
end

function TestWindow:test(statusCode, content)
    print(self.__classname)
    print(statusCode)
    print(content)
end


function TestWindow:OnShow()
    self:EnableDestroyListener()
end

function TestWindow:OnHide()
    Destroy(self.gameObject)
end


function TestWindow:OnDestroy()
end


return TestWindow