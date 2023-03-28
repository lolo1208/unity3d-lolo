--
-- 选择器列表
-- 2018/3/30
-- Author LOLO
--

local pairs = pairs
local error = error
local format = string.format
local remove = table.remove
local floor = math.floor

---@class Picker : View
---@field New fun(go:UnityEngine.GameObject, itemClass:any):Picker
---
---@field protected _picker ShibaInu.Picker
---@field protected _data MapList
---@field protected _itemClass any
---@field protected _itemList table<number, ItemRenderer> @ 当前已显示的 item 列表（index 为 key）
---@field protected _itemPool table<number, ItemRenderer> @ item 缓存池
---@field protected _selectedItem ItemRenderer @ 当前选中的子项
---
local Picker = class("Picker", View)

--
--- 构造函数
---@param go UnityEngine.GameObject
---@param itemClass any
function Picker:Ctor(go, itemClass)
    Picker.super.Ctor(self)

    self._itemList = {}
    self._itemPool = {}

    self._itemClass = itemClass
    self.gameObject = go
    self:OnInitialize()

    local picker = GetComponent.Picker(go)
    if picker == nil then
        error(format(Constants.E2007, self.__classname, go.name))
    end
    picker.luaTarget = self
    self._picker = picker
end



--
--- 数据
---@param value MapList
function Picker:SetData(value)
    if value == self._data then
        return
    end

    if value ~= nil then
        value.dispatchChanged = true
        value:AddEventListener(DataEvent.DATA_CHANGED, self.DataChanged, self)
        self:ResetAllItem(value)
    else
        self:Clean()
        self._data = nil
    end
end

---@return MapList
function Picker:GetData()
    return self._data
end

--
--- 数据有改变
---@param event DataEvent
function Picker:DataChanged(event)
    if event.reason == 4 then
        self:SetItemData(self:GetItemByIndex(event.index), event.newValue, event.oldValue)
    else
        self:ResetAllItem()
    end
end


--
--- Item 对应的 Lua Class
---@param value any
function Picker:SetItemClass(value)
    if value == self._itemClass then
        return
    end
    self._itemClass = value
    self:ResetAllItem()
end

---@return any
function Picker:GetItemClass()
    return self._itemClass
end



--=------------------------------[ C# Picker.cs ]------------------------------=--

--- C# 新添加一个子项
---@param index number
---@param go UnityEngine.GameObject
function Picker:AddItem(index, go)
    index = index + 1

    local itemPool = self._itemPool
    local item ---@type ItemRenderer
    if #itemPool > 0 then
        item = remove(itemPool)
        item.gameObject = go
    else
        item = self._itemClass.New()
        item._list = self
        AddEventListener(go, PointerEvent.DOWN, self.OnItemPointerEventHandler, self, 0, item, ListEvent.ITEM_POINTER_DOWN)
        AddEventListener(go, PointerEvent.UP, self.OnItemPointerEventHandler, self, 0, item, ListEvent.ITEM_POINTER_UP)
        AddEventListener(go, PointerEvent.EXIT, self.OnItemPointerEventHandler, self, 0, item, ListEvent.ITEM_POINTER_EXIT)
        AddEventListener(go, PointerEvent.CLICK, self.OnItemPointerEventHandler, self, 0, item, ListEvent.ITEM_POINTER_CLICK)
        item.gameObject = go
        item:OnInitialize()
    end

    self._itemList[index] = item
    item:Update(self._data:GetValueByIndex(index), index)
end

--
--- C# 移除渲染区域外的子项
---@param index number
function Picker:RemoveItem(index)
    index = index + 1

    local item = self._itemList[index]
    item:OnRecycle()
    self._itemList[index] = nil

    local itemPool = self._itemPool
    itemPool[#itemPool + 1] = item
end

--
--- C# 选中某个子项
---@param index number
function Picker:SelectItem(index)
    index = index + 1
    self:SetSelectedItem(self._itemList[index])
end


--
--- 子项 鼠标指针（touch）相关事件处理
---@param event PointerEvent
---@param item ItemRenderer
function Picker:OnItemPointerEventHandler(event, item, eventType)
    if item:GetEnabled() then
        self:DispatchListEvent(eventType, item)
    end
end



--=------------------------------[ item ]------------------------------=--

--- 设置子项的数据，该方法会在调用 item.Update() 之前触发 item.OnRecycle()
---@param item ItemRenderer
---@param data any
---@param oldData any
function Picker:SetItemData(item, data, oldData)
    if item ~= nil then
        item:OnRecycle()
        item:Update(data, item:GetIndex(), oldData)
        self:DispatchListEvent(ListEvent.UPDATE, item)
    end
end


--
--- 设置当前选中的子项
---@param value ItemRenderer
function Picker:SetSelectedItem(value)
    if value == nil or isnull(value.gameObject) then
        return
    end

    local curItem = self._selectedItem
    if curItem ~= nil and not isnull(curItem.gameObject) then
        curItem:SetSelected(false)
    end

    self._selectedItem = value
    value:SetSelected(true)
    self:DispatchListEvent(ListEvent.ITEM_SELECTED, value)
end

--
--- 获取当前选中的子项（如果值为 nil，表示没有选中的子项）
---@return ItemRenderer
function Picker:GetSelectedItem()
    return self._selectedItem
end

--
--- 当前选中子项的数据
---@return any
function Picker:GetSelectedItemData()
    if self._selectedItem ~= nil then
        return self._selectedItem:GetData()
    end
    return nil
end


--
--- 通过数据中的索引选中子项
---@param index number
function Picker:SelectItemByIndex(index)
    local itemCount = self._data:GetCount()
    if itemCount == 0 then
        return
    end

    index = floor(index)
    if index < 1 then
        index = 1
    elseif index > itemCount then
        index = itemCount
    end
    self._picker.index = index - 1
end

--
--- 通过数据中的键来选中子项
---@param key any
function Picker:SelectItemByKey(key)
    self:SelectItemByIndex(self._data:GetIndexByKey(key))
end


--
--- 通过据中的索引获取子项。如果 index 对应的子项在渲染区域外，将会返回 nil
---@param index number
---@return ItemRenderer
function Picker:GetItemByIndex(index)
    return self._itemList[index]
end

--
--- 通过数据中的键来获取子项。如果 key 对应的子项在渲染区域外，将会返回 nil
---@return ItemRenderer
function Picker:GetItemByKey(key)
    return self:GetItemByIndex(self._data:GetIndexByKey(key))
end

--
--- 获取 Item 总数（数据的值总数）
function Picker:GetCount()
    if self._data == nil then
        return 0
    end
    return self._data:GetCount()
end



--=------------------------------[ other ]------------------------------=--

--- 抛出列表相关事件
---@param type string
---@param item ItemRenderer
function Picker:DispatchListEvent(type, item)
    ---@type ListEvent
    local event = Event.Get(ListEvent, type)
    event.item = item
    self:DispatchEvent(event)
end



--=------------------------------[ recycle & clean ]------------------------------=--

--
--- 清空并销毁所有 item
function Picker:Clean()
    -- 清空列表
    local itemList = self._itemList
    for index, item in pairs(itemList) do
        item:OnDestroy()
    end
    self._itemList = {}

    -- 清空缓存池
    local itemPool = self._itemPool
    for i = 1, #itemPool do
        itemPool[i]:OnDestroy()
    end
    self._itemPool = {}

    if self._data ~= nil then
        self._data.dispatchChanged = false
        self._data:RemoveEventListener(DataEvent.DATA_CHANGED, self.DataChanged, self)
        self._data = nil
    end

    self._picker:Clean()
    self:DispatchListEvent(ListEvent.UPDATE)
end


--
--- 重置（清空并销毁）当前所有 item，保留数据和选中信息，根据数据再重新创建和选中 item
---@param newData MapList @ -可选- 新数据
function Picker:ResetAllItem(newData)
    local data
    if newData == nil then
        data = self._data
        self._data = nil -- 避免 Clean() 时清理 EventListener
    else
        data = newData
    end

    local index = self._selectedItem ~= nil and self._selectedItem:GetIndex() or -1

    self:Clean()
    self._data = data
    if data ~= nil then
        self._picker.itemCount = data:GetCount()
        if index ~= -1 then
            self._picker.index = index - 1
        end
    end
end




--

return Picker