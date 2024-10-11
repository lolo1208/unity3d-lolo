--
-- StickyList Item Renderer
-- 2024/10/11
-- Author LOLO
--

---@class Test.Samples.StickyList.Test_StickyItem : ItemRenderer
---@field New fun():Test.Samples.StickyList.Test_StickyItem
---
---@field bg UnityEngine.UI.Image
---@field label UnityEngine.UI.Text
---
local Test_StickyItem = class("Test.Samples.StickyList.Test_StickyItem", ItemRenderer)

function Test_StickyItem:OnInitialize()
    Test_StickyItem.super.OnInitialize(self)

    local transform = self.transform

    self.bg = GetComponent.Image(transform:Find("bg").gameObject)
    self.label = GetComponent.Text(transform:Find("label").gameObject)
    self.stickyBg = transform:Find("stickyBg").gameObject
    self.stickyBg:SetActive(false)
end

function Test_StickyItem:Update(data, index)
    Test_StickyItem.super.Update(self, data, index)

    self.label.text = self._data
end

function Test_StickyItem:SetSelected(value)
    Test_StickyItem.super.SetSelected(self, value)

    self.label.color = value and Color.red or Color.white, 0.15
    self.bg.color = value and Color.yellow or Color.gray, 0.15
end

function Test_StickyItem:SetStickyEnabled(value)
    Test_StickyItem.super.SetStickyEnabled(self, value)

    self.bg.gameObject:SetActive(not value)
    self.stickyBg:SetActive(value)
end

return Test_StickyItem