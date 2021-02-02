--
-- UI 特效测试范例
-- 2018/8/6
-- Author LOLO
--


local random = math.random

local FlyUp = require("Effects.UI.FlyUp")
local FlyDown = require("Effects.UI.FlyDown")
local FlyTo = require("Effects.UI.FlyTo")
local FlyBezier = require("Effects.UI.FlyBezier")
local FlyBehind = require("Effects.UI.FlyBehind")
local DelayedHide = require("Effects.UI.DelayedHide")

local tmpVec3 = Vector3.zero

--
---@class Test.Samples.UIEffects.Test_UIEffects : View
---@field New fun():Test.Samples.UIEffects.Test_UIEffects
---
local Test_UIEffects = class("Test.Samples.UIEffects.Test_UIEffects ", View)

local TIPS_PATH = "Prefabs/Test/TestTips.prefab"
local ARROW_PATH = "Prefabs/Test/Arrow.prefab"


--
function Test_UIEffects:OnInitialize()
    Test_UIEffects.super.OnInitialize(self)

    AddEventListener(self.transform:Find("FlyUp").gameObject, PointerEvent.CLICK, self.Click_FlyUp, self)
    AddEventListener(self.transform:Find("FlyDown").gameObject, PointerEvent.CLICK, self.Click_FlyDown, self)
    AddEventListener(self.transform:Find("FlyTo").gameObject, PointerEvent.CLICK, self.Click_FlyTo, self)
    AddEventListener(self.transform:Find("FlyBezier").gameObject, PointerEvent.CLICK, self.Click_FlyBezier, self)
    AddEventListener(self.transform:Find("FlyBehind").gameObject, PointerEvent.CLICK, self.Click_FlyBehind, self)
    AddEventListener(self.transform:Find("DelayedHide").gameObject, PointerEvent.CLICK, self.Click_DelayedHide, self)

    self:EnableDestroyListener()
    Profiler.Console(true)
end


--
function Test_UIEffects:Click_FlyUp(event)
    FlyUp.Once(self:GetItem(), TIPS_PATH)
end


--
function Test_UIEffects:Click_FlyDown(event)
    FlyDown.Once(self:GetItem(), TIPS_PATH)
end


--
function Test_UIEffects:Click_FlyTo(event)
    FlyTo.Once(self:GetItem(), Vector3.zero, TIPS_PATH)
end


--
function Test_UIEffects:Click_FlyBezier(event)
    FlyBezier.Once(self:GetItem(ARROW_PATH), nil, Vector3.zero, ARROW_PATH)
end


--
function Test_UIEffects:Click_FlyBehind(event)
    local size = Stage.uiCanvasTra.sizeDelta
    local x = size.x * 0.7
    local y = size.y * 0.7
    tmpVec3.x = random(x) - x / 2
    tmpVec3.y = random(y) - y / 2

    local item = PrefabPool.Get(TIPS_PATH, Constants.LAYER_ALERT).transform
    item.localPosition = Vector3.zero
    FlyBehind.Once(item, tmpVec3, TIPS_PATH)
end


--
function Test_UIEffects:Click_DelayedHide(event)
    DelayedHide.Once(self:GetItem(), TIPS_PATH)
end





--
---@return UnityEngine.Transform
function Test_UIEffects:GetItem(path)
    path = path or TIPS_PATH

    local tra = PrefabPool.Get(path, Constants.LAYER_ALERT).transform
    local size = Stage.uiCanvasTra.sizeDelta
    tmpVec3.x = random(size.x) - size.x / 2
    tmpVec3.y = random(size.y) - size.y / 2
    tra.localPosition = tmpVec3

    return tra
end




--
function Test_UIEffects:OnDestroy()
    Test_UIEffects.super.OnDestroy(self)
    --Profiler.End()
end



--
return Test_UIEffects