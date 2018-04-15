--
-- 时间 Picker item
-- 2018/4/2
-- Author LOLO
--

---@class Test.Samples.Picker.Test_TimePickerItem : ItemRenderer
---@field New fun():Test.Samples.Test_TimePickerItem
---
---@field _labelText UnityEngine.UI.Text
---
local Test_TimePickerItem = class("Test.Samples.Picker.Test_TimePickerItem", ItemRenderer)

function Test_TimePickerItem:OnInitialize()
    Test_TimePickerItem.super.OnInitialize(self)

    self._labelText = GetComponent.Text(self.gameObject.transform:Find("timeText").gameObject)
end

function Test_TimePickerItem:Update(data, index)
    Test_TimePickerItem.super.Update(self, data, index)

    self._labelText.text = self._data
end

function Test_TimePickerItem:SetSelected(value)
    Test_TimePickerItem.super.SetSelected(self, value)
    self._labelText.color = value and Color.black or Color.gray
end

return Test_TimePickerItem