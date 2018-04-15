--
-- 卡牌 Picker item
-- 2018/4/2
-- Author LOLO
--

---@class Test.Samples.Picker.Test_CardPickerItem : ItemRenderer
---@field New fun():Test.Samples.Picker.Test_CardPickerItem
---
---@field _labelText UnityEngine.UI.Text
---
local Test_CardPickerItem = class("Test.Samples.Picker.Test_CardPickerItem", ItemRenderer)

function Test_CardPickerItem:OnInitialize()
    Test_CardPickerItem.super.OnInitialize(self)

    self._labelText = GetComponent.Text(self.gameObject.transform:Find("labelText").gameObject)
end

function Test_CardPickerItem:Update(data, index)
    Test_CardPickerItem.super.Update(self, data, index)

    self._labelText.text = self._data
end

return Test_CardPickerItem