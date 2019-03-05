--
-- PageList item
-- 2018/4/2
-- Author LOLO
--

---@class Test.Samples.PageList.Test_PageListItem : ItemRenderer
---@field New fun():Test.Samples.PageList.Test_PageListItem
---
---@field bg UnityEngine.UI.Image
---@field label UnityEngine.UI.Text
---
local Test_PageListItem = class("Test.Samples.PageList.Test_PageListItem", ItemRenderer)

function Test_PageListItem:OnInitialize()
    Test_PageListItem.super.OnInitialize(self)

    local transform = self.gameObject.transform

    self.bg = GetComponent.Image(transform:Find("bg").gameObject)
    self.label = GetComponent.Text(transform:Find("label").gameObject)
end

function Test_PageListItem:Update(data, index)
    Test_PageListItem.super.Update(self, data, index)

    self.label.text = self._data
end

function Test_PageListItem:SetSelected(value)
    Test_PageListItem.super.SetSelected(self, value)

    self.label:DOColor(value and Color.red or Color.white, 0.15)
    self.bg:DOColor(value and Color.yellow or Color.gray, 0.15)
end

return Test_PageListItem