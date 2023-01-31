--
-- 滚动列表
-- 2017/12/29
-- Author LOLO
--

local floor = math.floor
local ceil = math.ceil
local abs = math.abs


--
---@class ScrollList : BaseList
---@field New fun(go:UnityEngine.GameObject, itemClass:any):ScrollList
---
---@field scrollList ShibaInu.ScrollList
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
---@field protected _isUpdateDirty boolean @ 是否已经被标记当前帧会更新
---
local ScrollList = class("ScrollList", BaseList)

local pos = Vector3.New()


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
    self._isUpdateDirty = false

    self.scrollList = self._list
    self._isVertical = self._list.isVertical
    self._viewport = self._list.viewport

    if self.scrollList.isAutoSize then
        local viewportSize = self._viewport.rect
        self._viewportWidth = viewportSize.width
        self._viewportHeight = viewportSize.height
    else
        local viewportSize = self.scrollList:GetViewportSize()
        self._viewportWidth = viewportSize.x
        self._viewportHeight = viewportSize.y
    end
end


--
--- 滚动更新，由 ScrollList.cs 调用
function ScrollList:UpdateScroll()
    if self._isUpdateDirty then
        return
    end

    -- 验证滚动距离是否已经有一个 item 的尺寸
    local itemSize = self._isVertical and self._itemLayoutHeight or self._itemLayoutWidth
    local contentPos = self._content.localPosition
    local curPos = self._isVertical and contentPos.y or contentPos.x
    if abs(curPos - self._lastUpdatePos) > itemSize then
        self:Update()
    end
end


--
--- 更新列表（在 Event.LATE_UPDATE 事件中更新）
function ScrollList:Update()
    if not self._isUpdateDirty then
        self._isUpdateDirty = true
        AddEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
    end
end


--
--- 立即更新显示内容，而不是等待 Event.LATE_UPDATE 事件更新
function ScrollList:UpdateNow()
    self._isUpdateDirty = false
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
        self:HideItemPool()
        self:DispatchListEvent(ListEvent.UPDATE)
        return
    end

    local item ---@type ItemRenderer
    local isVertical = self._isVertical

    -- 重新计算影响布局的各参数
    if self._isUpdateCalc then
        self._isUpdateCalc = false
        local list = self._list
        local cw, ch = self._viewportWidth, self._viewportHeight
        item = self:GetItem()

        if list.isAutoSize then
            self._itemOffetX = -cw / 2
            self._itemOffetY = ch / 2
        else
            self._itemOffetX = 0
            self._itemOffetY = 0
        end

        self._columnCount = list.columnCount
        self._rowCount = list.rowCount
        if list.isAutoItemCount then
            if isVertical then
                self._columnCount = floor(cw / item.itemWidth)
            else
                self._rowCount = floor(ch / item.itemHeight)
            end
        end

        self._horizontalGap = list.horizontalGap
        self._verticalGap = list.verticalGap
        if list.isAutoItemGap then
            if isVertical then
                if self._columnCount > 1 then
                    self._horizontalGap = (cw - self._columnCount * item.itemWidth) / (self._columnCount - 1)
                end
            else
                if self._rowCount > 1 then
                    self._verticalGap = (ch - self._rowCount * item.itemHeight) / (self._rowCount - 1)
                end
            end
        end

        -- 得到item的宽高
        self._itemWidth = item.itemWidth
        self._itemHeight = item.itemHeight
        self._itemLayoutWidth = self._itemWidth + self._horizontalGap
        self._itemLayoutHeight = self._itemHeight + self._verticalGap

        self._itemPool[#self._itemPool + 1] = item
        self:SyncPropertysToCS(false)
    end


    -- 根据数据量计算出内容的预计宽高
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
        lastItem = item
        lastItemX = pos.x
        lastItemY = pos.y

        pos.x = pos.x + item.itemOffsetX
        pos.y = pos.y + item.itemOffsetY
        item.transform.localPosition = pos
        self:UpdateItem(item, data:GetValueByIndex(i), i)
    end

    self:HideItemPool()
    self:UpdateSelectedItem()
    self:DispatchListEvent(ListEvent.UPDATE)
end


--
--- 检查当前是否需要更新，如果需要更新，将会立即更新
function ScrollList:UpdateCheck()
    if self._isUpdateDirty then
        self:UpdateNow()
    end
end


--
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
    local idx = index - 1
    if self._isVertical then
        pos.x = (idx % self._columnCount) * self._itemLayoutWidth
        pos.y = floor(idx / self._columnCount) * self._itemLayoutHeight
    else
        pos.x = floor(idx / self._rowCount) * self._itemLayoutWidth
        pos.y = (idx % self._rowCount) * self._itemLayoutHeight
    end
    item.transform.localPosition = pos
    self:UpdateItem(item, data:GetValueByIndex(index), index)

    return item
end



--=------------------------------[ scroll ]------------------------------=--

--
--- 滚动到指定位置
---@param position number @ 位置，值范围：0~1
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function ScrollList:ScrollToPosition(position, duration, ease)
    self:UpdateCheck()
    self.scrollList:ScrollToPosition(position, duration or 0.4, ease or DOTween_Enum.Ease.OutCubic)
end

--
--- 滚动到顶部
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function ScrollList:ScrollToTop(duration, ease)
    self:ScrollToPosition(self._isVertical and 1 or 0, duration, ease)
end

--
--- 滚动到底部
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function ScrollList:ScrollToBottom(duration, ease)
    self:ScrollToPosition(self._isVertical and 0 or 1, duration, ease)
end

--
--- 滚动到指定 item 位置
---@param item ItemRenderer
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function ScrollList:ScrollToItem(item, duration, ease)
    if item ~= nil and item:GetList() == self then
        self:ScrollToItemIndex(item:GetIndex(), duration, ease)
    end
end

--
--- 滚动到当前选中的 item 位置
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function ScrollList:ScrollToSelectedItem(duration, ease)
    self:ScrollToItem(self._selectedItem, duration, ease)
end

--
--- 滚动到 item 索引所在的位置
---@param itemIndex number
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function ScrollList:ScrollToItemIndex(itemIndex, duration, ease)
    self:UpdateCheck()

    -- 显示区域宽或高，内容宽或高，水平或垂直 item 间隔，每行或列 item 数量
    local viewportSize, contentSize, itemGap, itemCount
    if self._isVertical then
        viewportSize = self._viewportHeight
        contentSize = self._content.sizeDelta.y
        itemGap = self._verticalGap
        itemCount = self._columnCount
    else
        viewportSize = self._viewportWidth
        contentSize = self._content.sizeDelta.x
        itemGap = self._horizontalGap
        itemCount = self._rowCount
    end

    local posMax = 1 + (viewportSize + itemGap) / (contentSize - viewportSize) -- 总宽或高（值大于 1）
    local posRatio = posMax / ceil(self._data:GetCount() / itemCount) -- 每行或列所占宽高比
    local position = posRatio * ceil(itemIndex / itemCount - 1) -- index 对应位置（0~posMax）
    if self._isVertical then
        position = 1 - position
    end
    self:ScrollToPosition(position, duration, ease)
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
---@param update boolean @ 是否调用更新函数
function ScrollList:SyncPropertysToCS(update)
    self._list:SyncPropertys(self._itemPrefab, self._rowCount, self._columnCount, self._horizontalGap, self._verticalGap, self._isVertical, self._viewportWidth, self._viewportHeight)
    if update ~= false then
        self:Update()
    end
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

--
--- 清空列表，清空缓存池，销毁所有 item
function ScrollList:Clean()
    ScrollList.super.Clean(self)

    self._isUpdateDirty = false
    self._lastUpdatePos = 0
end



--
return ScrollList