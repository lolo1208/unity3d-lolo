--
-- 贝塞尔测试范例
-- 2019/3/30
-- Author LOLO
--


--
---@class Test.Samples.Test_Misc : View
---@field New fun():Test.Samples.Test_Misc
---
---
local Test_Misc = class("Test.Samples.Test_Misc", View)


--
function Test_Misc:OnInitialize()
    Test_Misc.super.OnInitialize(self)

    self.transform.sizeDelta = Vector2.zero

    local ntTra = self.transform:Find("NumberText")
    self.numberText = NumberText.New(GetComponent.Text(ntTra:Find("Text").gameObject), math.random(999, 9999))
    self.blinkToggle = GetComponent.Toggle(ntTra:Find("Blink").gameObject)
    self.rollToggle = GetComponent.Toggle(ntTra:Find("Roll").gameObject)
    AddEventListener(ntTra:Find("UpBtn").gameObject, PointerEvent.CLICK, self.ChangeNumberText, self, 0, true)
    AddEventListener(ntTra:Find("DownBtn").gameObject, PointerEvent.CLICK, self.ChangeNumberText, self, 0, false)
    AddEventListener(self.blinkToggle.gameObject, PointerEvent.CLICK, self.ChangeNumberTextEff, self)
    AddEventListener(self.rollToggle.gameObject, PointerEvent.CLICK, self.ChangeNumberTextEff, self)
end


--
function Test_Misc:ChangeNumberText(event, isUp)
    local val = math.random(99, 999)
    if not isUp then
        val = -val
    end
    self.numberText:SetValue(self.numberText.value + val)
end


--
function Test_Misc:ChangeNumberTextEff(event)
    self.numberText.isBlink = self.blinkToggle.isOn
    self.numberText.isRoll = self.rollToggle.isOn
end



--
return Test_Misc
