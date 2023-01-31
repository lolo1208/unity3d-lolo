--
-- 基础列表
-- 2017/12/19
-- Author LOLO
--

local error = error
local format = string.format
local remove = table.remove
local min = math.min
local floor = math.floor


--
---@class BaseList : View
---@field New fun(go:UnityEngine.GameObject, itemClass:any):BaseList
---
---@field baseList ShibaInu.BaseList
---@field autoSelectItem boolean @ 在 Update()、PointerDown、PointerClick 发生时，是否自动切换子项的选中状态。默认值：true
---
---@field protected _list ShibaInu.BaseList
---@field protected _content UnityEngine.RectTransform @ item 容器
---@field protected _itemPrefab UnityEngine.GameObject @ Item 对应的 Prefab 对象
---
---@field protected _isUpdateCalc boolean @ 是否需要重新计算 行数，列数，item 间隔，整体偏移 等布局相关参数
---@field protected _itemOffetX number @ item 整体 x 偏移（当 isAutoSize 值为 true 时）
---@field protected _itemOffetY number @ item 整体 y 偏移
---
---@field protected _rowCount number @ 行数
---@field protected _columnCount number @ 列数
---@field protected _verticalGap number @ 水平方向子项间的像素间隔
---@field protected _horizontalGap number @ 垂直方向子项间的像素间隔
---
---@field protected _data MapList
---@field protected _itemClass any
---@field protected _itemList table<number, ItemRenderer> @ 当前已显示的 item 列表
---@field protected _itemPool table<number, ItemRenderer> @ item 缓存池
---@field protected _selectedItem ItemRenderer @ 当前选中的子项
---@field protected _isHorizontalSort boolean @ 是否水平方向排序。默认值：true
---@field protected _enabled boolean @ 是否启用。默认值：true
---@field protected _selectedItem ItemRenderer @ 当前选中的子项
---
---@field protected _selectMode string @ 刷新列表时，根据什么来选中子项，可选值["index", "key"]，默认值："index"
---@field protected _autoSelectDefaultItem boolean @ 在还未选中过子项时，创建列表（设置数据，翻页）是否自动选中第一个子项，默认值：true
---@field protected _curSelectedIndex number @ 当前选中子项的索引
---@field protected _curSelectedKeys table<number, any> @ 当前选中子项的索引列表
---
local BaseList = class("BaseList", View)
--


--- 列表更新时，根据索引来选中子项
BaseList.SELECT_MODE_INDEX = "index"
--- 列表更新时，根据键来选中子项
BaseList.SELECT_MODE_KEY = "key"

local pos = Vector3.New()


--
--- 构造函数
---@param go UnityEngine.GameObject
---@param itemClass any
function BaseList:Ctor(go, itemClass)
    BaseList.super.Ctor(self)

    self._itemList = {}
    self._itemPool = {}
    self._isHorizontalSort = true
    self._isUpdateCalc = true
    self._enabled = true

    self.autoSelectItem = true
    self._autoSelectDefaultItem = true
    self._selectMode = BaseList.SELECT_MODE_INDEX
    self._curSelectedIndex = -1

    -- BaseList or PageList
    local list
    if instanceof(self, PageList) then
        list = GetComponent.PageList(go)
    else
        list = GetComponent.BaseList(go) -- BaseList or ScrollList
        self.baseList = list
    end

    if list == nil then
        error(format(Constants.E2007, self.__classname, go.name))
    end
    list.luaTarget = self
    self._list = list
    self._content = list.content
    self._rowCount = list.rowCount
    self._columnCount = list.columnCount
    self._horizontalGap = list.horizontalGap
    self._verticalGap = list.verticalGap
    self._itemPrefab = list.itemPrefab
    if isnull(self._itemPrefab) then
        self._itemPrefab = nil
    end

    self._itemClass = itemClass
    self.gameObject = go
    self:OnInitialize()
end


--
--- 数据
---@param value MapList
function BaseList:SetData(value)
    if value == self._data then
        return
    end

    if self._data ~= nil then
        self._data.dispatchChanged = false
        self._data:RemoveEventListener(DataEvent.DATA_CHANGED, self.DataChanged, self)
    end

    self._data = value
    if value ~= nil then
        value.dispatchChanged = true
        value:AddEventListener(DataEvent.DATA_CHANGED, self.DataChanged, self)
    end

    self:SetSelectedItem(nil)
    self:Update()
end

---@return MapList
function BaseList:GetData()
    return self._data
end

--
--- 数据有改变
---@param event DataEvent
function BaseList:DataChanged(event)
    if event.reason == 4 then
        self:SetItemData(self:GetItemByIndex(event.index), event.newValue, event.oldValue)
    else
        self:Update()
    end
end


--
--- Item 对应的 Lua Class
---@param value any
function BaseList:SetItemClass(value)
    if value == self._itemClass then
        return
    end

    self._itemClass = value
    self:CleanAllItem()
    self:Update()
end

---@return any
function BaseList:GetItemClass()
    return self._itemClass
end



--=------------------------------[ update ]------------------------------=--

--- 更新列表（在 Event.LATE_UPDATE 事件中更新）
function BaseList:Update()
    AddEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
end

function BaseList:UpdateCalc()
    self._isUpdateCalc = true
    AddEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
end

--
--- 立即更新显示内容，而不是等待 Event.LATE_UPDATE 事件更新
function BaseList:UpdateNow()
    RemoveEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
    self:RecycleAllItem()

    -- 属性或数据不完整，不能显示
    local data = self._data
    local dataCount = data ~= nil and data:GetCount() or 0
    if dataCount == 0 or self._itemClass == nil or self._itemPrefab == nil then
        if self._selectedItem ~= nil then
            self:SetSelectedItem(nil) -- 取消选中
        end
        self:HideItemPool()
        self:DispatchListEvent(ListEvent.UPDATE)
        return
    end

    local item ---@type ItemRenderer

    -- 重新计算影响布局的各参数
    if self._isUpdateCalc then
        self._isUpdateCalc = false
        local list = self._list
        local contentSize = self._content.rect
        local cw, ch = contentSize.width, contentSize.height
        item = self:GetItem()

        if list.isAutoSize then
            self._itemOffetX = -cw / 2
            self._itemOffetY = ch / 2
        else
            self._itemOffetX = 0
            self._itemOffetY = 0
        end

        if list.isAutoItemCount then
            self._columnCount = floor(cw / item.itemWidth)
            self._rowCount = floor(ch / item.itemHeight)
        else
            self._columnCount = list.columnCount
            self._rowCount = list.rowCount
        end

        if list.isAutoItemGap then
            if self._columnCount > 1 then
                self._horizontalGap = (cw - self._columnCount * item.itemWidth) / (self._columnCount - 1)
            end
            if self._rowCount > 1 then
                self._verticalGap = (ch - self._rowCount * item.itemHeight) / (self._rowCount - 1)
            end
        else
            self._horizontalGap = list.horizontalGap
            self._verticalGap = list.verticalGap
        end

        self._itemPool[#self._itemPool + 1] = item
        self:SyncPropertysToCS(false)
    end

    -- 根据数据显示（创建）子项
    local count = min(dataCount, self._rowCount * self._columnCount)
    local lastItem ---@type ItemRenderer
    local lastItemX, lastItemY
    for i = 1, count do
        if lastItem ~= nil then
            local idx = i - 1
            if self._isHorizontalSort then
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
            pos.x = 0
            pos.y = 0
        end

        item = self:GetItem()
        lastItem = item
        lastItemX = pos.x
        lastItemY = pos.y

        pos.x = pos.x + item.itemOffsetX + self._itemOffetX
        pos.y = pos.y + item.itemOffsetY + self._itemOffetY
        item.transform.localPosition = pos
        self:UpdateItem(item, data:GetValueByIndex(i), i)

    end

    self:HideItemPool()
    self:UpdateSelectedItem()
    self:DispatchListEvent(ListEvent.UPDATE)
end

--
--- 将 item 添加到 _itemList，并调用 item.Update()
---@param item ItemRenderer
function BaseList:UpdateItem(item, data, index)
    local itemList = self._itemList
    itemList[#itemList + 1] = item
    item:SetEnabled(self._enabled)
    item:Update(data, index)
end

--
--- 在 Update() 之后，更新选中的 item
function BaseList:UpdateSelectedItem()
    -- 还没有选中过任何子项
    if self._curSelectedIndex == -1 then
        if self._autoSelectDefaultItem and self.autoSelectItem then
            self:SelectItemByIndex(1)
        end
    elseif self._selectMode == BaseList.SELECT_MODE_INDEX then
        -- 通过索引来选中子项
        self:AutoSelectItemByIndex(self._curSelectedIndex)
    else
        -- 根据键来选中子项
        local index = self._data:GetIndexByKey(self._curSelectedKeys[1])
        if index ~= -1 then
            self:SelectItemByIndex(index)
        else
            self:AutoSelectItemByIndex(self._curSelectedIndex)
        end
    end
end

--
--- 通过索引来选中子项。如果指定的 index 不存在，将会自动选中 index-1 的子项
--- @param index number
function BaseList:AutoSelectItemByIndex(index)
    local itemList = self._itemList
    -- 超出范围，直接由 SelectItemByIndex 去决定是否选中。或可能在滚动列表中创建了item
    if index > #itemList or itemList[index] ~= nil then
        self:SelectItemByIndex(index)
    else
        if index > 1 then
            self:AutoSelectItemByIndex(index - 1)
        end
    end
end



--=------------------------------[ item ]------------------------------=--

--- 设置子项的数据，该方法会在调用 item.Update() 之前触发 item.OnRecycle()
---@param item ItemRenderer
---@param data any
---@param oldData any
function BaseList:SetItemData(item, data, oldData)
    if item ~= nil then
        item:OnRecycle()
        item:Update(data, item:GetIndex(), oldData)
        self:DispatchListEvent(ListEvent.UPDATE, item)
    end
end

--
--- 获取一个 item，先尝试从缓存池中拿，如果没有，将创建一个新的 item
---@return ItemRenderer
function BaseList:GetItem()
    local itemPool = self._itemPool
    local item ---@type ItemRenderer
    if #itemPool > 0 then
        item = remove(itemPool)
        if not item.gameObject.activeSelf then
            item.gameObject:SetActive(true)
        end
    else
        item = self._itemClass.New()
        item._list = self
        local go = Instantiate(self._itemPrefab, self._content)
        AddEventListener(go, PointerEvent.DOWN, self.ItemPointerDown, self, 0, item)
        AddEventListener(go, PointerEvent.UP, self.ItemPointerUp, self, 0, item)
        AddEventListener(go, PointerEvent.EXIT, self.ItemPointerExit, self, 0, item)
        AddEventListener(go, PointerEvent.CLICK, self.ItemPointerClick, self, 0, item)
        item.gameObject = go
        item:OnInitialize()
    end
    return item
end

--
--- 子项 鼠标指针（touch）按下
---@param event PointerEvent
---@param item ItemRenderer
function BaseList:ItemPointerDown(event, item)
    if item:GetEnabled() then
        self:DispatchListEvent(ListEvent.ITEM_POINTER_DOWN, item)
    end
end

--
--- 子项 鼠标指针（touch）释放
---@param event PointerEvent
---@param item ItemRenderer
function BaseList:ItemPointerUp(event, item)
    if item:GetEnabled() then
        self:DispatchListEvent(ListEvent.ITEM_POINTER_UP, item)
    end
end

--
--- 子项 鼠标指针（touch）离开对象
---@param event PointerEvent
---@param item ItemRenderer
function BaseList:ItemPointerExit(event, item)
    if item:GetEnabled() then
        self:DispatchListEvent(ListEvent.ITEM_POINTER_EXIT, item)
    end
end

--
--- 子项 鼠标指针（touch）点击
---@param event PointerEvent
---@param item ItemRenderer
function BaseList:ItemPointerClick(event, item)
    if item:GetEnabled() then
        self:SwitchItem(item)
        self:DispatchListEvent(ListEvent.ITEM_POINTER_CLICK, item)
    end
end


--
--- 切换子项的选中状态
---@param item ItemRenderer
function BaseList:SwitchItem(item)
    if not self.autoSelectItem then
        return
    end

    if self._selectedItem == item then
        if item.deselect then
            self:SetSelectedItem(nil)
        end
    else
        self:SetSelectedItem(item)
    end
end

--
--- 设置当前选中的子项（如果值为 nil，将什么都不选中）
---@param value ItemRenderer
function BaseList:SetSelectedItem(value)
    local curItem = self._selectedItem
    if curItem ~= nil and not isnull(curItem.gameObject) then
        if value == curItem then
            if curItem.deselect then
                curItem:SetSelected(false)
                value = nil
            else
                return
            end
        else
            curItem:SetSelected(false)
        end
    end

    self._selectedItem = value
    if value ~= nil then
        self._curSelectedIndex = value:GetIndex()
        if self._selectMode == BaseList.SELECT_MODE_KEY then
            -- 数据过多时，该方法效率会比较低
            self._curSelectedKeys = self._data:getKeysByIndex(self._curSelectedIndex)
        end
        value:SetSelected(true)
    else
        self._curSelectedIndex = -1
        self._curSelectedKeys = nil
    end

    self:DispatchListEvent(ListEvent.ITEM_SELECTED, value)
end

--
--- 获取当前选中的子项（如果值为 nil，表示没有选中的子项）
---@return ItemRenderer
function BaseList:GetSelectedItem()
    return self._selectedItem
end

--
--- 当前选中子项的数据
---@return any
function BaseList:GetSelectedItemData()
    if self._selectedItem ~= nil then
        return self._selectedItem:GetData()
    end
    return nil
end


--
--- 通过索引选中子项
---@param index number
function BaseList:SelectItemByIndex(index)
    local itemCount = #self._itemList
    if itemCount == 0 then
        return
    end

    index = floor(index)
    if index < 1 then
        index = 1
    elseif index > itemCount then
        index = itemCount
    end
    self:SetSelectedItem(self._itemList[index])
end

--
--- 通过数据中的索引来选中子项
---@param index number
function BaseList:SelectItemByDataIndex(index)
    index = floor(index)
    local dataCount = self._data:GetCount()
    if index > dataCount then
        index = dataCount
    elseif index < 1 then
        index = 1
    end
    self:SetSelectedItem(self:GetItemByIndex(index))
end

--
--- 通过数据中的键来选中子项
---@param key any
function BaseList:SelectItemByDataKey(key)
    self:SelectItemByDataIndex(self._data:GetIndexByKey(key))
end


--
--- 通过索引获取子项
---@param index number
---@return ItemRenderer
function BaseList:GetItemByIndex(index)
    return self._itemList[index]
end

--
--- 通过数据中的键来获取子项
---@return ItemRenderer
function BaseList:GetItemByKey(key)
    return self:GetItemByIndex(self._data:GetIndexByKey(key))
end

--
--- 获取列表索引（item:GetIndex()）对应的在数据中的索引
function BaseList:GetDataIndexByListIndex(index)
    return index
end

--
--- 获取 Item 总数（数据的值总数）
function BaseList:GetCount()
    if self._data == nil then
        return 0
    end
    return self._data:GetCount()
end



--=------------------------------[ other ]------------------------------=--

--- 抛出列表相关事件
---@param type string
---@param item ItemRenderer
function BaseList:DispatchListEvent(type, item)
    ---@type ListEvent
    local event = Event.Get(ListEvent, type)
    event.item = item
    self:DispatchEvent(event)
end

--
--- 是否启用
---@param value boolean
function BaseList:SetEnabled(value)
    if value == self._enabled then
        return
    end

    self._enabled = value
    local itemList = self._itemList
    for i = 1, #itemList do
        itemList[i]:SetEnabled(value)
    end
end

---@return boolean
function BaseList:GetEnabled()
    return self._enabled
end

--
--- 刷新列表时，根据什么来选中子项，可选值["index", "key"]，默认值："index"
---@param value string
function BaseList:SetSelectMode(value)
    if value == self._selectMode then
        return
    end

    if self._selectedItem ~= nil and self._curSelectedKeys ~= nil then
        self._curSelectedKeys = self._data:GetKeysByIndex(self._curSelectedIndex)
    end
    self._selectMode = value
    self:Update()
end

---@return string
function BaseList:GetSelectMode()
    return self._selectMode
end

--
--- 在还未选中过子项时，创建列表（设置数据，翻页）是否自动选中第一个子项，默认值：true
---@param value boolean
function BaseList:SetAutoSelectDefaultItem(value)
    if value == self._autoSelectDefaultItem then
        return
    end
    self._autoSelectDefaultItem = value
    self:Update()
end

---@return boolean
function BaseList:GetAutoSelectDefaultItem()
    return self._autoSelectDefaultItem
end

--
--- 是否水平方向排序，默认值：true。ScrollList 中，该值为与 ScrollBar.direction 相对应
---@param value boolean
function BaseList:SetIsHorizontalSort(value)
    if value == self._isHorizontalSort then
        return
    end
    self._isHorizontalSort = value
    self:Update()
end

---@return boolean
function BaseList:GetIsHorizontalSort()
    return self._isHorizontalSort
end



--=------------------------------[ C# BaseList.cs ]------------------------------=--

--- Item 对应的 Prefab 对象
---@param value UnityEngine.GameObject
function BaseList:SetItemPrefab(value)
    if isnull(value) then
        value = nil
    end
    if value == self._itemPrefab then
        return
    end
    self._itemPrefab = value
    self:CleanAllItem()
    self:SyncPropertysToCS()
end

---@return UnityEngine.GameObject
function BaseList:GetItemPrefab()
    return self._itemPrefab
end

--
--- 行数
---@param value number
function BaseList:SetRowCount(value)
    if value == self._rowCount then
        return
    end
    self._rowCount = value
    self:SyncPropertysToCS()
end

---@return number
function BaseList:GetRowCount()
    return self._rowCount
end

--
--- 列数
---@param value number
function BaseList:SetColumnCount(value)
    if value == self._columnCount then
        return
    end
    self._columnCount = value
    self:SyncPropertysToCS()
end

---@return number
function BaseList:GetColumnCount()
    return self._columnCount
end


--
--- 水平方向子项间的像素间隔
---@param value number
function BaseList:SetHorizontalGap(value)
    if value == self._horizontalGap then
        return
    end
    self._horizontalGap = value
    self:SyncPropertysToCS()
end

---@return number
function BaseList:GetHorizontalGap()
    return self._horizontalGap
end

--
--- 垂直方向子项间的像素间隔
---@param value number
function BaseList:SetVerticalGap(value)
    if value == self._verticalGap then
        return
    end
    self._verticalGap = value
    self:SyncPropertysToCS()
end

---@return number
function BaseList:GetVerticalGap()
    return self._verticalGap
end


--
--- 属性有改变时，将 lua 中的属性同步到 C# 中
---@param update boolean @ 是否调用更新函数
function BaseList:SyncPropertysToCS(update)
    self._list:SyncPropertys(self._itemPrefab, self._rowCount, self._columnCount, self._horizontalGap, self._verticalGap)
    if update ~= false then
        self:Update()
    end
end

--
--- 同步 C# 相关属性
--- 由 BaseList.cs 调用
function BaseList:SyncPropertys(itemPrefab, rowCount, columnCount, horizontalGap, verticalGap)
    if isnull(itemPrefab) then
        itemPrefab = nil
    end
    if itemPrefab ~= self._itemPrefab then
        self._itemPrefab = itemPrefab
        self:CleanAllItem()
    end
    self._rowCount = rowCount
    self._columnCount = columnCount
    self._horizontalGap = horizontalGap
    self._verticalGap = verticalGap
    self:Update()
end



--=------------------------------[ recycle & clean ]------------------------------=--

--
--- 移除所有子项，并回收到缓存池中
---@param deselectCurItem boolean @ 是否取消选中当前已选 item。默认：true
function BaseList:RecycleAllItem(deselectCurItem)
    local itemList = self._itemList
    local itemPool = self._itemPool
    local poolCount = #itemPool
    for i = #itemList, 1, -1 do
        local item = itemList[i]
        item:OnRecycle()
        poolCount = poolCount + 1
        itemPool[poolCount] = item
    end
    self._itemList = {}

    if deselectCurItem ~= false then
        local curItem = self._selectedItem
        if curItem ~= nil then
            curItem:SetSelected(false)
            self._selectedItem = nil
        end
    end
end

--
--- 隐藏缓存池中的所有 item
function BaseList:HideItemPool()
    local itemPool = self._itemPool
    for i = 1, #itemPool do
        local item = itemPool[i]
        if item.gameObject.activeSelf then
            item.gameObject:SetActive(false)
        end
    end
end

--
--- 清空子项缓存池
function BaseList:CleanItemPool()
    local itemPool = self._itemPool
    for i = 1, #itemPool do
        local go = itemPool[i].gameObject
        Destroy(go)
    end
    self._itemPool = {}
end

--
--- 清空并销毁所有 item，但继续保留数据和选中信息
function BaseList:CleanAllItem()
    local data = self._data
    self._data = nil -- 避免 Clean() 时清理 EventListener
    local index = self._curSelectedIndex
    local keys = self._curSelectedKeys
    self:Clean()
    self._data = data
    self._curSelectedIndex = index
    self._curSelectedKeys = keys
end

--
--- 清空列表，清空缓存池，销毁所有 item
function BaseList:Clean()
    RemoveEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
    self:RecycleAllItem()
    self:CleanItemPool()

    if self._data ~= nil then
        self._data.dispatchChanged = false
        self._data:RemoveEventListener(DataEvent.DATA_CHANGED, self.DataChanged, self)
        self._data = nil
    end

    self._curSelectedIndex = -1
    self._curSelectedKeys = nil
    self:DispatchListEvent(ListEvent.UPDATE)
end



--
function BaseList:OnDestroy()
    BaseList.super.OnDestroy(self)
    self:Clean()
end




--
return BaseList
