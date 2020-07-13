--
-- 贝塞尔测试范例
-- 2019/3/30
-- Author LOLO
--

local QuadraticBezier = require("Utils.Bezier.QuadraticBezier")
local CubicBezier = require("Utils.Bezier.CubicBezier")


--
---@class Test.Samples.Test_Bezier : View
---@field New fun():Test.Samples.Test_Bezier
---
---
local Test_Bezier = class("Test.Samples.Test_Bezier", View)

local quadraticBezier = QuadraticBezier.New()
local cubicBezier = CubicBezier.New()


--
function Test_Bezier:OnInitialize()
    Test_Bezier.super.OnInitialize(self)

    self.container = self.transform:Find("Anchors")

    self.pStart = self.transform:Find("Start").localPosition
    self.pEnd = self.transform:Find("End").localPosition
    self.bezierList = {
        self.transform:Find("Bezier1").localPosition,
        self.transform:Find("Bezier2").localPosition,
        self.transform:Find("Bezier3").localPosition,
    }

    AddEventListener(self.transform:Find("QuadraticBtn").gameObject, PointerEvent.CLICK, self.ClickQuadraticBtn, self)
    AddEventListener(self.transform:Find("CubicBtn").gameObject, PointerEvent.CLICK, self.ClickCubicBtn, self)
end


--
function Test_Bezier:ClickQuadraticBtn(event)
    for i = 0, self.container.childCount - 1 do
        Destroy(self.container:GetChild(i).gameObject)
    end

    quadraticBezier:Init(
            self.pStart,
            self.bezierList[math.random(#self.bezierList)],
            self.pEnd,
            math.random(40, 50)
    )
    for i = 0, quadraticBezier.anchorCount do
        self:CreateAnchor(quadraticBezier:GetAnchor(i))
    end
end


--
function Test_Bezier:ClickCubicBtn(event)
    for i = 0, self.container.childCount - 1 do
        Destroy(self.container:GetChild(i).gameObject)
    end

    cubicBezier:Init(
            self.pStart,
            self.pEnd,
            self.bezierList,
            math.random(40, 50)
    )
    for i = 1, cubicBezier.anchorCount do
        self:CreateAnchor(cubicBezier:GetAnchor(i))
    end
end


--
function Test_Bezier:CreateAnchor(anchor)
    local go = Instantiate("Prefabs/Test/Arrow.prefab", self.container)
    local tra = go.transform
    tra.sizeDelta = Vector2.New(23, 8)
    tra.localPosition = Vector2.New(anchor.x, anchor.y)
    tra.localEulerAngles = Vector3.New(0, 0, anchor.d)
end



--
return Test_Bezier
