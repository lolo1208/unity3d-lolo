--
-- 类描述
-- 2017/12/20
-- Author LOLO
--

---@class Test.TestItemRenderer : ItemRenderer
---@field New fun():Test.TestItemRenderer
local TestItemRenderer = class("Test.TestItemRenderer", ItemRenderer)


function TestItemRenderer:Ctor(...)
    TestItemRenderer.super.Ctor(self, ...)
end


function TestItemRenderer:OnInitialize()
    TestItemRenderer.super.OnInitialize(self)

    self._labelText = GetComponent.Text(self.gameObject.transform:Find("itemBtn/itemBtnText").gameObject)
    self._labelText.color = Color.gray
end


function TestItemRenderer:Update(data, index)
    TestItemRenderer.super.Update(self, data, index)

    self._labelText.text = self._data.name
end


function TestItemRenderer:SetSelected(value)
    TestItemRenderer.super.SetSelected(self, value)
    self._labelText.color = value and Color.red or Color.gray
end


function TestItemRenderer:OnRecycle()
    TestItemRenderer.super.OnRecycle(self)
end



return TestItemRenderer