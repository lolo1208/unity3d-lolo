--
-- 列表子项基类
-- 2017/12/19
-- Author LOLO
--

---@class ItemRenderer : View
---@field New fun():ItemRenderer
---
---@field deselect boolean @ 在已选中时，是否可以取消选中
---@field itemWidth number @ 布局宽度
---@field itemHeight number @ 布局高度
---@field itemOffsetX number @ 布局时 x 偏移
---@field itemOffsetY number @ 布局时 y 偏移
---
---@field protected _list BaseList
---@field protected _index number
---@field protected _data any
---@field protected _selected boolean
---@field protected _enabled boolean
---
local ItemRenderer = class("ItemRenderer", View)


--
function ItemRenderer:Ctor()
    ItemRenderer.super.Ctor(self)

    self.deselect = false
    self._selected = false
    self._enabled = true
end


--
--- 更新内容
---@param data any
---@param index number
---@param oldData any @ -可选- 只有在更新单条数据时，该参数才会有值
function ItemRenderer:Update(data, index, oldData)
    self._data = data
    self._index = index
end


--
--- 是否被选中
function ItemRenderer:SetSelected(value)
    self._selected = value
end

function ItemRenderer:GetSelected()
    return self._selected
end


--
--- 是否启用
---@param value boolean
function ItemRenderer:SetEnabled(value)
    self._enabled = value
end

function ItemRenderer:GetEnabled()
    return self._enabled
end


--
--- 对应的数据
---@return any
function ItemRenderer:GetData()
    return self._data
end

--
--- 在列表中的索引
---@return number
function ItemRenderer:GetIndex()
    return self._index
end

--
--- 对应的列表
---@return BaseList
function ItemRenderer:GetList()
    return self._list
end



--=------------------------------[ event ]------------------------------=--

--- 初始化时。由 BaseList 调用
function ItemRenderer:OnInitialize()
    ItemRenderer.super.OnInitialize(self)

    self:CalcSizeAndOffset()
end


--
--- 计算宽高与偏移
---@param transform UnityEngine.RectTransform @ 用于计算宽高与偏移的 trasform，默认：self.transform
function ItemRenderer:CalcSizeAndOffset(transform)
    transform = transform or self.transform

    local rect = transform.rect
    self.itemWidth = rect.width
    self.itemHeight = rect.height

    local pivot = transform.pivot
    self.itemOffsetX = pivot.x * self.itemWidth
    self.itemOffsetY = -(pivot.y * self.itemHeight)
end


--
--- 被回收到缓存池时。由 BaseList 调用
function ItemRenderer:OnRecycle()
end


--
--- 被销毁时。由 BaseList 调用
function ItemRenderer:OnDestroy()
    ItemRenderer.super.OnDestroy(self)
end



--
return ItemRenderer