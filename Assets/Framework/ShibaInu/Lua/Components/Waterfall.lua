--
-- 瀑布流列表，用于展示宽或高不一致的 item 的列表
--
-- 使用时，有几个需要注意的地方：
--   1. 目前仅支持单行或单列。
--   2. 一定要在 ItemRenderer 的 item:Update() 函数中调用 item:CalcSizeAndOffset() 函数，（或手动）设置 item 的宽高与偏移。
--   3. itemSkeletonSize 的值建议等于或略小于 item 最小状态的尺寸。
--   4. 当显示区域很大，item 尺寸较小时，建议将 scrollBackItemCount 的值设置得大一些。
--
-- 2023/01/06
-- Author LOLO
--

local abs = math.abs
local max = math.max


--
---@alias PlaceholderSize
---@field width number
---@field height number

--
---@class Waterfall : ScrollList
---@field New fun(go:UnityEngine.GameObject, itemClass:any):Waterfall
---
---@field waterfall ShibaInu.Waterfall
---@field protected _list ShibaInu.Waterfall
---@field protected _scrollRect UnityEngine.UI.ScrollRect
---
---@field itemSkeletonSize any @ item 的占位尺寸，默认：50x50
---@field renderOffsetSize any @ 渲染缓冲区域尺寸，默认一个显示区域
---@field scrollBackItemCount number @ 往回滚动时，一次测量多少个 item 的尺寸。默认：30
---
---@field protected _itemSizes number[] @ 已记录的 item 尺寸列表
---
local Waterfall = class("Waterfall", ScrollList)
--
local pos = Vector3.New()
local sizeZero = Vector2.zero


--
--- 构造函数
---@param go UnityEngine.GameObject
---@param itemClass any
function Waterfall:Ctor(go, itemClass)
    Waterfall.super.Ctor(self, go, itemClass)

    self.waterfall = self._list
    self._scrollRect = self._list.scrollRect

    self.itemSkeletonSize = { width = 50, height = 50 }
    self.renderOffsetSize = { width = -1, height = -1 }
    self.scrollBackItemCount = 30

    self._itemSizes = {}
    -- 注意！！该值已脱离实际声明意义，目前用于将显示区域外的选中的 item 移动到不可见区域（在 ScrollList:GetItemByIndex() 中）
    self._itemLayoutWidth = -99999
    self._itemLayoutHeight = -99999
    -- 默认将 content 的尺寸设为 0，避免第一次更新时，会被测量为往回滚动，从而改变了 content 的位置
    self._content.sizeDelta = sizeZero
end



--
--- 立即更新显示内容，而不是等待 Event.LATE_UPDATE 事件更新
function Waterfall:UpdateNow()
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

    ---@type ItemRenderer
    local item
    local isVertical = self._isVertical
    local itemDefaultSize -- item 的默认尺寸
    local itemGap -- item 的间隔
    local curPos -- content 当前的位置
    local vpSize -- 显示区域尺寸
    local renderOffsetSize, vpMin, vpMax -- 显示区域最大和最小值（加上缓冲区域）
    local isScrollBack -- 当前是否正在往回（左或上）滚动
    local startItemIndex -- 显示区域内，渲染开始的 item.index

    if isVertical then
        itemDefaultSize = self.itemSkeletonSize.height
        itemGap = self._verticalGap
        curPos = self._content.localPosition.y
        vpSize = self._viewportHeight
        isScrollBack = curPos < self._lastUpdatePos
        renderOffsetSize = self.renderOffsetSize.height < 0 and vpSize or self.renderOffsetSize.height
        vpMin = curPos - renderOffsetSize
        vpMax = curPos + renderOffsetSize + vpSize
    else
        itemDefaultSize = self.itemSkeletonSize.width
        itemGap = self._horizontalGap
        curPos = self._content.localPosition.x
        vpSize = self._viewportWidth
        isScrollBack = curPos > self._lastUpdatePos
        renderOffsetSize = self.renderOffsetSize.width < 0 and vpSize or self.renderOffsetSize.width
        vpMin = -curPos - renderOffsetSize
        vpMax = -curPos + renderOffsetSize + vpSize
    end

    self._lastUpdatePos = curPos
    local sumSize = -itemGap -- 计算 content 的宽高（预计）

    for i = 1, dataCount do
        sumSize = sumSize + itemGap -- 这也是 item 当前的位置
        local pItemMax = sumSize + itemDefaultSize
        -- 预测 item 的 pos 或 pos+size 在显示范围内，需要渲染该 item
        if (sumSize > vpMin and sumSize < vpMax) or (pItemMax > vpMin and pItemMax < vpMax) then
            if startItemIndex == nil then
                startItemIndex = i
            end
            item = self:GetItem()
            -- 需在 item:Update() 中调用 item:CalcSizeAndOffset() 动态得出宽高与偏移
            self:UpdateItem(item, data:GetValueByIndex(i), i)
            if isVertical then
                pos.x = item.itemOffsetX
                pos.y = item.itemOffsetY - sumSize
            else
                pos.x = item.itemOffsetX + sumSize
                pos.y = item.itemOffsetY
            end
            item.transform.localPosition = pos
            self._itemSizes[i] = isVertical and item.itemHeight or item.itemWidth
        end
        sumSize = sumSize + (self._itemSizes[i] or itemDefaultSize)
    end

    local lastSize -- content 在本次更新前的尺寸
    if isVertical then
        lastSize = self._content.sizeDelta.y
        self._list:SetContentSize(self._viewportWidth, sumSize)
    else
        lastSize = self._content.sizeDelta.x
        self._list:SetContentSize(sumSize, self._viewportHeight)
    end

    -- content 尺寸有变化时
    if sumSize - lastSize ~= 0 then
        if isScrollBack and lastSize ~= 0 then
            -- 在 ScrollRect 组件滚动过程中，动态修改了 content 的尺寸之后，
            -- 就算根据尺寸差调整 content 的位置，也会被 ScrollRect 强行拉回（无法实现无感连续滚动）。
            -- 所以做如下操作：

            -- 1. 停止 ScrollRect 的滚动
            self._scrollRect.enabled = false
            self._scrollRect.enabled = true

            -- 2. 往回再测量出指定数量（scrollBackItemCount）的 item 尺寸
            startItemIndex = startItemIndex - 1
            for i = max(startItemIndex - self.scrollBackItemCount, 1), startItemIndex do
                if self._itemSizes[i] == nil then
                    -- 这里无需 GetItem()，直接用最后使用的 item 测量尺寸，因为马上就会 UpdateNow()
                    item:Update(data:GetValueByIndex(i), i)
                    self._itemSizes[i] = isVertical and item.itemHeight or item.itemWidth
                    sumSize = sumSize + (self._itemSizes[i] - itemDefaultSize)
                end
            end

            -- 3. 将 content 偏移到正确的位置上
            local p = self._content.localPosition
            if isVertical then
                p.y = p.y + (sumSize - lastSize)
                self._lastUpdatePos = p.y
            else
                p.x = p.x - (sumSize - lastSize)
                self._lastUpdatePos = p.x
            end
            self._content.localPosition = p
        end

        -- 重新排列渲染，不然会有 item 跳动的问题
        self:UpdateNow()
        return
    end

    self:SyncPropertysToCS(false)
    self:HideItemPool()
    self:UpdateSelectedItem()
    self:DispatchListEvent(ListEvent.UPDATE)
end


--
--- 滚动更新，由 ScrollList.cs 调用
function Waterfall:UpdateScroll()
    if self._isUpdateDirty then
        return
    end

    -- 验证滚动距离是否已经有一个 item 的默认尺寸
    local itemDefaultSize = self._isVertical and self.itemSkeletonSize.height or self.itemSkeletonSize.width
    local contentPos = self._content.localPosition
    local curPos = self._isVertical and contentPos.y or contentPos.x
    if abs(curPos - self._lastUpdatePos) > itemDefaultSize then
        self:Update()
    end
end




--=------------------------------[ scroll ]------------------------------=--

--
--- 滚动到指定 item 位置
---@param item ItemRenderer
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function Waterfall:ScrollToItem(item, duration, ease)
    print("暂未实现该功能！")
end

--
--- 滚动到当前选中的 item 位置
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function Waterfall:ScrollToSelectedItem(duration, ease)
    print("暂未实现该功能！")
end

--
--- 滚动到 item 索引所在的位置
---@param itemIndex number
---@param duration number @ -可选- 滚动耗时（秒），值 <= 0 时表示不使用缓动。默认：0.4
---@param ease DG.Tweening.Ease @ -可选- 缓动方式。默认：OutCubic
function Waterfall:ScrollToItemIndex(itemIndex, duration, ease)
    print("暂未实现该功能！")
end



--=------------------------------[ recycle & clean ]------------------------------=--

--
--- 清空列表，清空缓存池，销毁所有 item
function Waterfall:Clean()
    Waterfall.super.Clean(self)

    self._content.sizeDelta = sizeZero
end


--
return Waterfall

