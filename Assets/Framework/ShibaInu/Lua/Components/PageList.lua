--
-- 翻页列表
-- 2019/2/27
-- Author LOLO
--

local pairs = pairs
local min = math.min
local ceil = math.ceil


--
---@class PageList : BaseList
---@field New fun(go:UnityEngine.GameObject, itemClass:any):PageList
---
---@field pageList ShibaInu.PageList @ 对应的 C#ShibaInu.PageList 对象
---
---@field protected _list ShibaInu.PageList
---@field protected _viewItemList table<number, ItemRenderer[]> @ view index 对应的 item 列表
---@field protected _viewUpdateDirty table<number, boolean> @ view index 对应的是否需要更新标记
---@field protected _selectTargetIndex number @ 翻页结束后，选中该索引 item（根据数据索引得来的）
---@field protected _selectTargetViewIndex number @ 目标 _selectTargetIndex 所在的页码
---
---
local PageList = class("PageList", BaseList)

local pos = Vector3.New()


--
--- 构造函数
---@param go UnityEngine.GameObject
---@param itemClass any
function PageList:Ctor(go, itemClass)
    PageList.super.Ctor(self, go, itemClass)

    self.pageList = self._list
    self._viewUpdateDirty = {}
    self._viewItemList = {}
    self:AddEventListener(PageEvent.VISIBILITY_CHANGED, self.VisibilityChangedHandler, self, Constants.PRIORITY_LOW)
    self:AddEventListener(PageEvent.SELECTION_CHANGED, self.SelectionChangedHandler, self, Constants.PRIORITY_LOW)
    self:AddEventListener(PageEvent.REMOVED, self.RemovedHandler, self, Constants.PRIORITY_LOW)
end


--
--- 页面触发显示或隐藏
---@param event PageEvent
function PageList:VisibilityChangedHandler(event)
    if event.value then
        self._viewUpdateDirty[event.index] = true
        AddEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
    else
        self._viewUpdateDirty[event.index] = nil
        self:RecycleViewItem(event.index)
    end
end


--
--- 页面被选中或取消选中
---@param event PageEvent
function PageList:SelectionChangedHandler(event)
    if event.value then
        -- 先更新当前页
        if self._viewUpdateDirty[event.index] then
            self:UpdateNow()
        end

        -- 切换 _itemList 并选中对应的 item
        self._itemList = self._viewItemList[event.index]
        if self._selectTargetIndex ~= nil and self._selectTargetViewIndex == event.index then
            self:SelectItemByIndex(self._selectTargetIndex)
        else
            self._curSelectedIndex = -1
            self._curSelectedKeys = nil
            self:UpdateSelectedItem()
        end
        self._selectTargetIndex = nil
        self._selectTargetViewIndex = nil
    end
end


--
--- 页面被移除
---@param event PageEvent
function PageList:RemovedHandler(event)
    self._viewUpdateDirty[event.index] = nil
    Destroy(event.view)
end


--
--- 更新指定页，在该页面中显示对应的所有 item
---@param index number
function PageList:UpdateViewItem(index)
    self._viewUpdateDirty[index] = nil
    self:RecycleViewItem(index) -- 该函数会改变：self._itemList = self._viewItemList[index]

    -- 根据数据显示（创建）子项
    local data = self._data
    local dataCount = data:GetCount()
    local container = self._list:GetView(index).transform:Find("Content")
    local numPerPage = self:GetNumPerPage()
    local startIndex = index * numPerPage -- 该页开始的索引
    local count = min(dataCount, numPerPage)
    if (index + 1) * numPerPage > dataCount then
        count = dataCount - index * numPerPage -- 最后一页
    end
    local item, lastItem ---@type ItemRenderer
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
        SetParent(item.transform, container)

        pos.x = pos.x + item.itemOffsetX
        pos.y = pos.y + item.itemOffsetY
        item.transform.localPosition = pos
        self:UpdateItem(item, data:GetValueByIndex(i + startIndex), i)
    end

    -- 偏移容器位置，居中显示
    pos.x = -(self._columnCount * (lastItem.itemWidth + self._horizontalGap) - self._horizontalGap) / 2
    pos.y = (self._rowCount * (lastItem.itemHeight + self._verticalGap) - self._verticalGap) / 2
    container.localPosition = pos
end


--
--- 回收指定页中所有的 item
---@param index number
function PageList:RecycleViewItem(index)
    local itemList = self._viewItemList[index]
    self._itemList = itemList ~= nil and itemList or {}
    self:RecycleAllItem(false) -- 该函数会改变：self._itemList = {}
    self._viewItemList[index] = self._itemList
end


--
--- 计算出总页数
function PageList:CalcTotalPageNum()
    if not self.destroyed then
        if self._data == nil then
            self._list.viewCount = 0
        else
            self._list.viewCount = ceil(self._data:GetCount() / self:GetNumPerPage())
        end
    end
end


--
--- 每页显示多少条数据
function PageList:GetNumPerPage()
    return self._rowCount * self._columnCount
end




-- -----------------------[ override ]----------------------- --


--- 更新列表，当前页（在 Event.LATE_UPDATE 事件中更新）
function PageList:Update()
    self._viewUpdateDirty[self._list:GetCurrentViewIndex()] = true
    AddEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)
end


--
--- 立即更新显示内容（有更新标记的页），而不是等待 Event.LATE_UPDATE 事件更新
function PageList:UpdateNow()
    RemoveEventListener(Stage, Event.LATE_UPDATE, self.UpdateNow, self)

    local data = self._data
    local dataCount = data ~= nil and data:GetCount() or 0
    if dataCount == 0 or self._itemClass == nil or self._itemPrefab == nil then
        -- 属性或数据不完整，不能显示
        if self._selectedItem ~= nil then
            self:SetSelectedItem(nil) -- 取消选中
        end
        self._itemPool = {} -- 待会会调用 HideItemPool()

    else
        -- 更新所有被标记的页
        for index, dirty in pairs(self._viewUpdateDirty) do
            self:UpdateViewItem(index)
        end
    end

    self:HideItemPool()
    self:DispatchListEvent(ListEvent.UPDATE)
end


--
--- 数据
---@param value MapList
function PageList:SetData(value)
    PageList.super.SetData(self, value)
    self:CalcTotalPageNum()
end


--
--- 数据有改变
---@param event DataEvent
function PageList:DataChanged(event)
    PageList.super.DataChanged(self, event)
    if event.reason ~= 4 then
        self:CalcTotalPageNum()
    end
end


--
--- 通过数据中的索引来选中子项
---@param index number
function PageList:SelectItemByDataIndex(index)
    PageList.super.SelectItemByDataIndex(self, index)
    local numPerPage = self:GetNumPerPage()
    local viewIndex = ceil(index / numPerPage) - 1
    self._selectTargetIndex = index - viewIndex * numPerPage
    self._selectTargetViewIndex = viewIndex
    self.pageList.currentViewIndex = viewIndex
end


--
--- 获取列表索引（item:GetIndex()）对应的在数据中的索引
function PageList:GetDataIndexByListIndex(index)
    return self.pageList.currentViewIndex * self:GetNumPerPage() + index
end




--
--- 隐藏缓存池中的所有 item
function PageList:HideItemPool()
    local itemPool = self._itemPool
    for i = 1, #itemPool do
        local item = itemPool[i]
        if not isnull(item.gameObject) and item.gameObject.activeSelf then
            item.gameObject:SetActive(false)
        end
    end
end


--
--- 清空列表，清空缓存池，销毁所有 item
function PageList:Clean()
    -- real RecycleAllItem()
    for i = 0, self.pageList.viewCount do
        self:RecycleViewItem(i)
    end

    PageList.super.Clean(self)
    self:CalcTotalPageNum()
end




--
return PageList
