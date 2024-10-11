--
-- 粘性列表
--  在指定的 item 滚动到显示区域外时，item 将会停靠在顶部或者底部
-- 2024/10/10
-- Author LOLO
--

local ceil = math.ceil


--
---@class StickyList : ScrollList
---@field New fun(go:UnityEngine.GameObject, itemClass:any, stickyItemIndex:number):StickyList
---
---@field protected _stickyItemIndex number @ 启用粘性的 item 的索引。默认：0（不启用）
---@field protected _stickyItemState number @ 粘性 item 的当前状态
---@field protected _stickyItem ItemRenderer @ 已创建的粘性 item
---
local StickyList = class("StickyList", ScrollList)

local pos = Vector3.New()
local STICKY_STATE = {
    Init = 0, -- 初始化
    Hidden = 1, -- 已隐藏
    Top = 2, -- 已停靠顶部
    Bottom = 3, -- 已停靠底部
}


--
--- 构造函数
---@param go UnityEngine.GameObject
---@param itemClass any
---@param stickyItemIndex number @ 可选，默认：0
function StickyList:Ctor(go, itemClass, stickyItemIndex)
    StickyList.super.Ctor(self, go, itemClass)

    self._stickyItemIndex = stickyItemIndex or 0
end


--
--- 滚动更新，由 ScrollList.cs 调用
function StickyList:UpdateScroll()
    StickyList.super.UpdateScroll(self)

    if self._stickyItemIndex ~= 0 then
        self:UpdateStickyItemPosition()
    end
end

--
--- 更新粘性 item 的位置
function StickyList:UpdateStickyItemPosition()
    local item = self._stickyItem
    local index = self._stickyItemIndex
    local isVertical = self._isVertical

    -- 显示区域宽或高，内容宽或高，水平或垂直 item 间隔，每行或列 item 数量
    local viewportSize, contentSize, itemGap, itemCount
    if isVertical then
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

    local isTop, isBottom
    -- 内容超出显示区域，可以滚动时，才需计算
    if contentSize > viewportSize then
        local realViewportSize = contentSize - viewportSize
        local posMax = 1 + (viewportSize + itemGap) / realViewportSize -- 总宽或高（值大于 1）
        local posRatio = posMax / ceil(self._data:GetCount() / itemCount) -- 每行或列所占宽高比
        local posTop = posRatio * ceil(index / itemCount - 1) -- index 对应位置（0~posMax）
        local posBottom = posTop - viewportSize / realViewportSize
        local posCur
        pos.x = item.itemOffsetX
        pos.y = item.itemOffsetY

        if isVertical then
            posTop = 1 - posTop
            posBottom = 1 - posBottom - item.itemHeight / realViewportSize
            posCur = self._scrollRect.verticalNormalizedPosition
            isTop = posCur < posTop
            isBottom = posCur > posBottom
            pos.x = pos.x + (index - 1) % self._columnCount * (item.itemWidth + self._horizontalGap)
        else
            posBottom = posBottom + item.itemWidth / realViewportSize
            posCur = self._scrollRect.horizontalNormalizedPosition
            isTop = posCur > posTop
            isBottom = posCur < posBottom
            pos.y = pos.y - (index - 1) % self._rowCount * (item.itemHeight + self._verticalGap)
        end
    end

    if isTop then
        -- 停靠顶部
        if self._stickyItemState ~= STICKY_STATE.Top then
            self._stickyItemState = STICKY_STATE.Top
            item.transform.localPosition = pos
            item:Show()
        end

    elseif isBottom then
        -- 停靠底部
        if self._stickyItemState ~= STICKY_STATE.Bottom then
            self._stickyItemState = STICKY_STATE.Bottom
            if isVertical then
                pos.y = pos.y - viewportSize + item.itemHeight
            else
                pos.x = pos.x + viewportSize - item.itemWidth
            end
            item.transform.localPosition = pos
            item:Show()
        end
    else
        -- 在显示区域内
        self._stickyItemState = STICKY_STATE.Hidden
        item:Hide()
    end
end


--
--- 更新粘性 item 的数据，或创建与回收
function StickyList:UpdateStickyItemData()
    self._stickyItemState = STICKY_STATE.Init
    if self._stickyItemIndex == 0 then
        if self._stickyItem then
            self:RecycleStickyItem()
        end
    else
        local itemData = self._data:GetValueByIndex(self._stickyItemIndex)
        if itemData == nil then
            self:RecycleStickyItem()
        else
            if self._stickyItem == nil then
                self._stickyItem = self:GetItem()
                SetParent(self._stickyItem.transform, self.transform)
                self._stickyItem:SetStickyEnabled(true)
            end
            self._stickyItem:Update(itemData, self._stickyItemIndex)
        end
    end
end


--
--- 设置启用粘性的 item 的索引。
--- 如果值为 nil 或小于 0，将会将会禁用粘性 item
---@param index number
function StickyList:SetStickyItemIndex(index)
    if index == nil or index < 0 then
        index = 0
    end
    self._stickyItemIndex = index

    -- 不启用
    if index == 0 then
        self:RecycleStickyItem()
    else
        self:UpdateStickyItemData()
        self:UpdateStickyItemPosition()
    end
end

--
function StickyList:GetStickyItemIndex()
    return self._stickyItemIndex
end



--
--- 数据有改变
---@param event DataEvent
function StickyList:DataChanged(event)
    StickyList.super.DataChanged(self, event)

    if event.reason == 4 and event.index ~= self._stickyItemIndex then
        return
    end
    self:UpdateStickyItemData()
end



--
--- 回收粘性 item
function StickyList:RecycleStickyItem()
    local item = self._stickyItem
    if item then
        item:SetStickyEnabled(false)
        item:Hide()
        item:OnRecycle()
        SetParent(item.transform, self._content)
        self._itemPool[#self._itemPool + 1] = item
        self._stickyItem = nil
    end
end


--
--- 清空列表，清空缓存池，销毁所有 item
function StickyList:Clean()
    self:RecycleStickyItem()
    self._stickyItemIndex = 0

    StickyList.super.Clean(self)
end


--
return StickyList
