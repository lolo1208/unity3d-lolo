--
-- ScrollList item
-- 2018/4/2
-- Author LOLO
--

---@class Test.Samples.BaseList.Test_ScrollListItem : ItemRenderer
---@field New fun():Test.Samples.BaseList.Test_ScrollListItem
---
---@field bg UnityEngine.UI.Image
---@field label UnityEngine.UI.Text
---
local Test_ScrollListItem = class("Test.Samples.BaseList.Test_ScrollListItem", ItemRenderer)

function Test_ScrollListItem:OnInitialize()
    Test_ScrollListItem.super.OnInitialize(self)

    local transform = self.gameObject.transform

    self.bg = GetComponent.Image(transform:Find("bg").gameObject)
    self.label = GetComponent.Text(transform:Find("label").gameObject)
end

function Test_ScrollListItem:Update(data, index)
    Test_ScrollListItem.super.Update(self, data, index)

    self.label.text = self._data
end

function Test_ScrollListItem:SetSelected(value)
    Test_ScrollListItem.super.SetSelected(self, value)

    self.label.color = value and Color.red or Color.white, 0.15
    self.bg.color = value and Color.yellow or Color.gray, 0.15
end

return Test_ScrollListItem