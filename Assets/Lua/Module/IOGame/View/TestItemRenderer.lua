--
-- 类描述
-- 2017/12/20
-- Author LOLO
--

---@class IOGame.IOGameItemRenderer : ItemRenderer
---@field New fun():IOGame.IOGameItemRenderer
local IOGameItemRenderer = class("IOGame.IOGameItemRenderer", ItemRenderer)

function IOGameItemRenderer:Ctor(...)
    IOGameItemRenderer.super.Ctor(self, ...)
end

function IOGameItemRenderer:OnInitialize()
    IOGameItemRenderer.super.OnInitialize(self)

    self._labelText = GetComponent.Text(self.gameObject.transform:Find("itemBtn/itemBtnText").gameObject)
    self._labelText.color = Color.gray
end

function IOGameItemRenderer:Update(data, index)
    IOGameItemRenderer.super.Update(self, data, index)

    self._labelText.text = self._data.name
end

function IOGameItemRenderer:SetSelected(value)
    IOGameItemRenderer.super.SetSelected(self, value)
    self._labelText.color = value and Color.red or Color.gray
end

function IOGameItemRenderer:OnRecycle()
    IOGameItemRenderer.super.OnRecycle(self)
end

return IOGameItemRenderer