--
-- 测试场景
-- 2018/3/14
-- Author LOLO
--


--
---@class Test.TestScene : Scene
---
---@field samples UnityEngine.GameObject
---@field backBtn UnityEngine.GameObject
---@field curSample View
---
local TestScene = class("Test.TestScene", Scene)
TestScene.SCENE_NAME = "Test"



--
function TestScene:OnInitialize()
    TestScene.super.OnInitialize(self)

    SceneManager.SetDontUnloadAssetBundle(self.sceneName, true)

    local uiCanvasTra = self.transform:Find("SceneUICanvas")
    local samplesTra = uiCanvasTra:Find("Samples")
    self.samples = samplesTra.gameObject

    --
    local sampleNames = {
        "Picker", "BaseList", "ScrollList", "PageList", "AutoList", "Waterfall",
        "ViewPager", "CircleImage", "SafeArea", "Bezier", "Misc",
        "Network", "UIEffects", "ViewEffects", "ToggleSwitch"
    }
    for i = 1, #sampleNames do
        local sampleName = sampleNames[i]
        local btn = samplesTra:Find(sampleName).gameObject
        AddEventListener(btn, PointerEvent.CLICK, self.OnClick_ShowSample, self, 0, sampleName)
    end
    --

    local dungeonBtn = samplesTra:Find("dungeonBtn").gameObject
    AddEventListener(dungeonBtn, PointerEvent.CLICK, self.OnClick_dungeonBtn, self)

    local backBtn = uiCanvasTra:Find("BackBtn")
    SetParent(backBtn, Constants.LAYER_UI_TOP)
    self.backBtn = backBtn.gameObject
    self.backBtn:SetActive(false)
    AddEventListener(self.backBtn, PointerEvent.CLICK, self.OnClick_backBtn, self)
end


--
function TestScene:OnClick_ShowSample(event, sampleName)
    local sampleClass = require("Module.Test.Samples." .. sampleName .. ".Test_" .. sampleName)
    self.curSample = sampleClass.New(
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
function TestScene:OnClick_dungeonBtn(event)
    SceneController.EnterDungeon()
end


--
function TestScene:OnDestroy()
    TestScene.super.OnDestroy(self)
end



--
return TestScene

