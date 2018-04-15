--
-- BaseList item
-- 2018/4/2
-- Author LOLO
--

---@class Test.Samples.BaseList.Test_BaseListItem : ItemRenderer
---@field New fun():Test.Samples.BaseList.Test_BaseListItem
---
---@field bg UnityEngine.UI.Image
---@field label UnityEngine.UI.Text
---
local Test_BaseListItem = class("Test.Samples.BaseList.Test_BaseListItem", ItemRenderer)

function Test_BaseListItem:OnInitialize()
    Test_BaseListItem.super.OnInitialize(self)

    local transform = self.gameObject.transform

    self.bg = GetComponent.Image(transform:Find("bg").gameObject)
    self.label = GetComponent.Text(transform:Find("label").gameObject)
end

function Test_BaseListItem:Update(data, index)
    Test_BaseListItem.super.Update(self, data, index)

    self.label.text = self._data
end

function Test_BaseListItem:SetSelected(value)
    Test_BaseListItem.super.SetSelected(self, value)

    self.label:DOColor(value and Color.red or Color.white, 0.15)
    self.bg:DOColor(value and Color.yellow or Color.gray, 0.15)
end

return Test_BaseListItem