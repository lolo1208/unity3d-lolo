--
-- 滚动列表
-- 2017/12/29
-- Author LOLO
--

local floor = math.floor
local ceil = math.ceil
local abs = math.abs

---@class ScrollList : BaseList
---@field New fun(go:UnityEngine.GameObject, itemClass:any):ScrollList
---
---@field protected _list ShibaInu.ScrollList
---@field protected _isVertical boolean
---@field protected _viewport UnityEngine.RectTransform
---@field protected _viewportWidth number
---@field protected _viewportHeight number
---
---@field protected _itemWidth number @ 设置的item宽度
---@field protected _itemHeight number @ 设置的item高度
---@field protected _itemLayoutWidth number @ 用来布局的item宽度（_itemWidth + _horizontalGap）
---@field protected _itemLayoutHeight number @ 用来布局的item高度（_itemHeight + _verticalGap）
---
---@field protected _lastUpdatePos number @ _content 上次滚动更新的位置
---@field protected _updateDirty boolean @ 是否已经被标记当前帧会更新
---
local ScrollList = class("ScrollList", BaseList)

--
--- 构造函数
---@param go UnityEngine.GameObject
---@param itemClass any
function ScrollList:Ctor(go, itemClass)
    ScrollList.super.Ctor(self, go, itemClass)

    self._itemWidth = 0
    self._itemHeight = 0
    self._itemLayoutWidth = 0
    self._itemLayoutHeight = 0
    self._lastUpdatePos = 0
    self._updateDirty = false

    self._isVertical = self._list.isVertical
    self._viewport = self._list.viewport
    local viewportSize = self._viewport.sizeDelta
    self._viewportWidth = viewportSize.x
    self._viewportHeight = viewportSize.y
end



--
--- 滚动更新，由 ScrollList.cs 调用
function ScrollList:UpdateScroll()
    if self._updateDirty then
        return
    end

    -- 验证滚动距离是否已经有一个 item 的尺寸
    local itemSize = self._isVertical and self._itemLayoutHeight or self._itemLayoutWidth
    if itemSize > 0 then
        local contentPos = self._content.localPosition
        local curPos = self._isVertical and contentPos.y or contentPos.x
        if abs(curPos - self._lastUpdatePos) > itemSize then
            self:Update()
            self._updateDirty = true
            AddEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
        end
    end
end


--
--- 更新列表（在 Event.LATE_UPDATE 事件中更新）
function ScrollList:Update()
    if not self._updateDirty then
        self._updateDirty = true
        AddEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
    end
end


--
--- 立即更新显示内容，而不是等待 Event.LATE_UPDATE 事件更新
function ScrollList:UpdateNow()
    self._updateDirty = false
    RemoveEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
    self:RecycleAllItem()

    -- 属性或数据不完整，不能显示
    local data = self._data
    local dataCount = data ~= nil and data:GetCount() or 0
    if dataCount == 0 or self._itemClass == nil or self._itemPrefab == nil then
        if self._selectedItem ~= nil then
            self:SetSelectedItem(nil) -- 取消选中
        end
        self._list:SetContentSize(0, 0)
        self:DispatchListEvent(ListEvent.UPDATE)
        return
    end

    local item ---@type ItemRenderer
    local isVertical = self._isVertical

    -- 先得到item的宽高
    if self._itemWidth == 0 or self._itemHeight == 0 then
        item = self:GetItemByIndex(1)
        self._itemWidth = item.itemWidth
        self._itemHeight = item.itemHeight
        self._itemLayoutWidth = self._itemWidth + self._horizontalGap
        self._itemLayoutHeight = self._itemHeight + self._verticalGap
        self:RecycleAllItem()
    end

    -- 根据数据计算出内容的宽高
    local cw, ch
    if isVertical then
        cw = self._columnCount * self._itemLayoutWidth - self._horizontalGap
        ch = ceil(dataCount / self._columnCount) * self._itemLayoutHeight - self._verticalGap
    else
        cw = ceil(dataCount / self._rowCount) * self._itemLayoutWidth - self._horizontalGap
        ch = self._rowCount * self._itemLayoutHeight - self._verticalGap
    end
    self._list:SetContentSize(cw, ch)

    -- 只用显示该范围内的item，前后都多创建一排，作为缓冲
    local minI, maxI
    if isVertical then
        self._lastUpdatePos = self._content.localPosition.y
        local contentY = self._lastUpdatePos - self._itemLayoutWidth
        local minY = contentY < 0 and 0 or contentY
        local maxY = minY + self._viewportHeight + self._itemLayoutWidth * 2
        minI = floor(minY / self._itemLayoutHeight) * self._columnCount
        maxI = ceil(maxY / self._itemLayoutHeight) * self._columnCount
    else
        self._lastUpdatePos = self._content.localPosition.x
        local contentX = abs(self._lastUpdatePos) - self._itemLayoutWidth
        local minX = contentX < 0 and 0 or contentX
        local maxX = minX + self._viewportWidth + self._itemLayoutWidth * 2
        minI = floor(minX / self._itemLayoutWidth) * self._rowCount
        maxI = ceil(maxX / self._itemLayoutWidth) * self._rowCount
    end

    if maxI > dataCount then
        maxI = dataCount
    end

    -- 根据数据显示（创建）子项
    local lastItem ---@type ItemRenderer
    local lastItemX, lastItemY
    local pos = Vector3.zero
    for i = minI + 1, maxI do
        local idx = i - 1
        if lastItem ~= nil then
            if isVertical then
                -- 新行的开始
                if idx % self._columnCount == 0 then
                    pos.x = 0
                    pos.y = lastItemY - lastItem.itemHeight - self._verticalGap
                else
                    pos.x = lastItemX + lastItem.itemWidth + self._horizontalGap
                    pos.y = lastItemY
                end
            else
                if idx % self._rowCount == 0 then
                    pos.x = lastItemX + lastItem.itemWidth + self._horizontalGap
                    pos.y = 0
                else
                    pos.x = lastItemX
                    pos.y = lastItemY - lastItem.itemHeight - self._verticalGap
                end
            end
        else
            -- 开始的item
            if isVertical then
                pos.x = 0
                pos.y = -(minI / self._columnCount * self._itemLayoutHeight)
            else
                pos.x = minI / self._rowCount * self._itemLayoutWidth
                pos.y = 0
            end
        end

        item = self:GetItem()
        item.gameObject.transform.localPosition = pos
        self:UpdateItem(item, data:GetValueByIndex(i), i)

        lastItem = item
        lastItemX = pos.x
        lastItemY = pos.y
    end

    self:UpdateSelectedItem()
    self:DispatchListEvent(ListEvent.UPDATE)
end

--- 通过索引来选中子项。
--- @param index number
function ScrollList:AutoSelectItemByIndex(index)
    local dataCount = self._data:GetCount()
    if index > dataCount then
        index = dataCount
    end
    self:SelectItemByIndex(index)
end


--
--- 通过索引选中子项
---@param index number
function ScrollList:SelectItemByIndex(index)
    if self._data ~= nil then
        self:SetSelectedItem(self:GetItemByIndex(index))
    end
end



--
--- 通过索引获取子项
---@param index number
---@return ItemRenderer
function ScrollList:GetItemByIndex(index)
    local data = self._data
    local dataCount = data ~= nil and data:GetCount() or 0
    if dataCount == 0 or index > dataCount or index < 0 then
        return nil
    end

    -- 在已创建的item中（显示范围内），寻找指定 index 的 item
    local itemList = self._itemList
    local item ---@type ItemRenderer
    for i = 1, #itemList do
        item = itemList[i]
        if item:GetIndex() == index then
            return item
        end
    end

    -- 已创建的item中，没有对应index的item（表示item在显示范围外），直接创建
    item = self:GetItem()
    self:UpdateItem(item, data:GetValueByIndex(index), index)
    local pos = Vector3.zero
    local idx = index - 1
    if self._isVertical then
        pos.x = (idx % self._columnCount) * self._itemLayoutWidth
        pos.y = floor(idx / self._columnCount) * self._itemLayoutHeight
    else
        pos.x = floor(idx / self._rowCount) * self._itemLayoutWidth
        pos.y = (idx % self._rowCount) * self._itemLayoutHeight
    end
    item.gameObject.transform.localPosition = pos
    return item
end




--=------------------------------[ C# ScrollList.cs ]------------------------------=--

--- 是否为垂直方向滚动
---@param value boolean
function ScrollList:SetIsVertical(value)
    if value == self._isVertical then
        return
    end
    self._lastUpdatePos = 0
    self._isVertical = value
    self:SyncPropertysToCS()
    self._list:ResetContentPosition()
end

---@return boolean
function ScrollList:GetIsVertical()
    return self._isVertical
end


--
--- 设置显示区域宽高
---@param width number
---@param height number
function ScrollList:SetViewportSize(width, height)
    if width == nil or width == 0 then
        width = self._viewportWidth
    end
    if height == nil or height == 0 then
        height = self._viewportHeight
    end
    if width == self._viewportWidth and height == self._viewportHeight then
        return
    end

    self._lastUpdatePos = 0
    self._viewportWidth = width
    self._viewportHeight = height
    self:SyncPropertysToCS()
    self._list:ResetContentPosition()
end

---@return number
function ScrollList:GetViewportWidth()
    return self._viewportWidth
end

---@return number
function ScrollList:GetViewportHeight()
    return self._viewportHeight
end

---@return ShibaInu.ScrollList
function ScrollList:GetCSList()
    return self._list
end



--
--- 属性有改变时，将 lua 中的属性同步到 C# 中
function ScrollList:SyncPropertysToCS()
    self._list:SyncPropertys(self._itemPrefab, self._rowCount, self._columnCount, self._horizontalGap, self._verticalGap, self._isVertical, self._viewportWidth, self._viewportHeight)
    self:Update()
end


--
--- 同步 C# 相关属性
--- 由 ScrollList.cs 调用
function ScrollList:SyncPropertys(itemPrefab, rowCount, columnCount, horizontalGap, verticalGap, isVertical, viewportWidth, viewportHeight)
    self._isVertical = isVertical
    self._viewportWidth = viewportWidth
    self._viewportHeight = viewportHeight

    ScrollList.super.SyncPropertys(self, itemPrefab, rowCount, columnCount, horizontalGap, verticalGap)
end




--=------------------------------[ recycle & clean ]------------------------------=--

function ScrollList:Clean()
    ScrollList.super.Clean(self)
    self._updateDirty = false
    self._lastUpdatePos = 0
end



--
return ScrollList