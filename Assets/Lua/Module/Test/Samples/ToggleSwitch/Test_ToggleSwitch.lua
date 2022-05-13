--
-- CircleImage 组件测试范例
-- 2018/4/3
-- Author LOLO
--

local ToggleSwitch_iOS = require("Module.Test.Samples.ToggleSwitch.ToggleSwitch_iOS")

---@class Test.Samples.Test_ToggleSwitch : View
---@field New fun():Test.Samples.Test_ToggleSwitch
---
local Test_ToggleSwitch = class("Test.Samples.Test_ToggleSwitch", View)


--
function Test_ToggleSwitch:OnInitialize()
    Test_ToggleSwitch.super.OnInitialize(self)

    self.stateLable = GetComponent.Text(self.transform:Find("StateLable"))

    ToggleSwitch_iOS.New(self.transform:Find("ToggleSwitch1"), true)
    self.ts2 = ToggleSwitch_iOS.New(self.transform:Find("ToggleSwitch2"))
    self.ts3 = ToggleSwitch_iOS.New(self.transform:Find("ToggleSwitch3"))
    ToggleSwitch_iOS.New(self.transform:Find("ToggleSwitch4"), false, self.transform:Find("HitArea").gameObject)

    self.ts2:AddEventListener(ToggleSwitch.EVENT_CHANGED, self.ChangeLable, self)
    self.ts3:SetEnabled(false)
    DelayedCall(1.5, self.ts3.Toggle, self.ts3)
end




--
function Test_ToggleSwitch:ChangeLable()
    self.stateLable.text = "当前状态：" .. (self.ts2:GetChecked() and "On" or "Off")
end


--
function Test_ToggleSwitch:OnDestroy()
end


--
return Test_ToggleSwitch
