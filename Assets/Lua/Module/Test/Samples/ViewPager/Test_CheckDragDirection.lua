--
-- 根据首次拖拽的方向（水平或垂直），触发对应组件的事件
-- 2019/3/2
-- Author LOLO
--

local abs = math.abs


--
---@class Test.Samples.ViewPager.Test_CheckDragDirection : View
---@field New fun(go:UnityEngine.GameObject, hTarget:any, vTarget:any):Test.Samples.ViewPager.Test_CheckDragDirection
---
---@field hTarget any
---@field vTarget any
---@field curTarget any
---@field startPos Vector2
---@field pointerId number @ 当前交互的 touch ID
---@field passer ShibaInu.PointerEventPasser
---
local Test_CheckDragDirection = class("Test.Samples.ViewPager.Test_CheckDragDirection", View)


--
function Test_CheckDragDirection:Ctor(go, hTarget, vTarget)
    Test_CheckDragDirection.super.Ctor(self)

    self.hTarget = hTarget
    self.vTarget = vTarget
    self.gameObject = go
    self:OnInitialize()
end


--
function Test_CheckDragDirection:OnInitialize()
    Test_CheckDragDirection.super.OnInitialize(self)

    self.passer = GetComponent.PointerEventPasser(self.gameObject)
    AddEventListener(self.gameObject, DragDropEvent.INITIALIZE_POTENTIAL_DRAG, self.DragHandler, self)
    AddEventListener(self.gameObject, DragDropEvent.DRAG, self.DragHandler, self)
    AddEventListener(self.gameObject, DragDropEvent.END_DRAG, self.DragHandler, self)
end


--
---@param event DragDropEvent
function Test_CheckDragDirection:DragHandler(event)
    local data = event.data

    -- 记录手指ID，接下来只响应该手指的操作
    if self.pointerId == nil then
        self.pointerId = data.pointerId
        self.startPos = data.position
    elseif data.pointerId ~= self.pointerId then
        return
    end

    if event.type == DragDropEvent.DRAG then
        if self.curTarget == nil then
            if data.position == self.startPos then
                return
            end
            -- 根据第一次滚动位置来决定接下来使用垂直还是水平滚动
            if abs(data.position.x - self.startPos.x) > abs(data.position.y - self.startPos.y) then
                self.curTarget = self.hTarget
            else
                self.curTarget = self.vTarget
            end
            self.curTarget:OnBeginDrag(data)
            self.passer:ReleaseTarget()
        end
        self.curTarget:OnDrag(data)

    elseif event.type == DragDropEvent.END_DRAG then
        self.curTarget:OnEndDrag(data)
        self.pointerId = nil
        self.curTarget = nil

    elseif event.type == DragDropEvent.INITIALIZE_POTENTIAL_DRAG then
        -- 触发该事件可以停止 ScrollRect 的持续滚动
        self.hTarget:OnInitializePotentialDrag(data)
        self.vTarget:OnInitializePotentialDrag(data)
    end
end



--
return Test_CheckDragDirection
