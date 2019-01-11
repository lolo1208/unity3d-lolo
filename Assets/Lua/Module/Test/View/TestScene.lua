--
-- 测试场景
-- 2018/3/14
-- Author LOLO
--


--
---@class Test.TestScene : Scene
---@field New fun():Test.TestScene
---
---@field samples UnityEngine.GameObject
---@field backBtn UnityEngine.GameObject
---@field curSample View
---
local TestScene = class("Test.TestScene", Scene)

function TestScene:Ctor()
    TestScene.super.Ctor(self, "Test")
end

function TestScene:OnInitialize()
    TestScene.super.OnInitialize(self)

    local uiCanvasTra = GameObject.Find("SceneUICanvas").transform
    local samplesTra = uiCanvasTra:Find("Samples")
    self.samples = samplesTra.gameObject


    --
    local sampleNames = { "Picker", "BaseList", "ScrollList", "CircleImage", "Network", "UIEffects" }
    for i = 1, #sampleNames do
        local sampleName = sampleNames[i]
        local btn = samplesTra:Find(sampleName).gameObject
        AddEventListener(btn, PointerEvent.CLICK, self.OnClick_ShowSample, self, 0, sampleName)
    end
    --


    local ioGameBtn = samplesTra:Find("ioGameBtn").gameObject
    AddEventListener(ioGameBtn, PointerEvent.CLICK, self.OnClick_ioGameBtn, self)

    local dungeonBtn = samplesTra:Find("dungeonBtn").gameObject
    AddEventListener(dungeonBtn, PointerEvent.CLICK, self.OnClick_dungeonBtn, self)

    self.backBtn = uiCanvasTra:Find("backBtn").gameObject
    self.backBtn.transform:SetParent(Stage.GetLayer(Constants.LAYER_UI_TOP))
    self.backBtn:SetActive(false)
    AddEventListener(self.backBtn, PointerEvent.CLICK, self.OnClick_backBtn, self)

end






--
function TestScene:OnClick_ShowSample(event, sampleName)
    self.curSample = require("Module.Test.Samples." .. sampleName .. ".Test_" .. sampleName).New(
            "Prefabs/Test/Samples/" .. sampleName .. ".prefab",
            Constants.LAYER_UI, self.moduleName
    )
    self.samples:SetActive(false)
    self.backBtn:SetActive(true)
end

--
function TestScene:OnClick_backBtn(event)
    self.curSample:Destroy()
    self.samples:SetActive(true)
    self.backBtn:SetActive(false)
end


--
function TestScene:OnClick_ioGameBtn(event)
    Stage.ShowScene(require("Module.IOGame.View.IOGameScene"))
end


--
function TestScene:OnClick_dungeonBtn(event)
    Stage.ShowScene(require("Module.Dungeon.View.DungeonScene"))
end




--
function TestScene:OnDestroy()
end




--
return TestScene