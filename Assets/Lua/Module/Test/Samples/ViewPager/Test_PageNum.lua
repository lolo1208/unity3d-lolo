--
-- ViewPager 与 PageList 页码显示范例
-- 2019/2/26
-- Author LOLO
--


--
---@class Test.Samples.ViewPager.Test_PageNum : View
---@field New fun(go:UnityEngine.GameObject, viewPager:ViewPager):Test.Samples.ViewPager.Test_PageNum
---
---@field viewPager ViewPager
---@field vp ShibaInu.ViewPager
---@field icons UnityEngine.CanvasGroup[]
---
local Test_PageNum = class("Test.Samples.ViewPager.Test_PageNum", View)

local GAP = 5
local ALPHA_NORMAL = 0.3


--
function Test_PageNum:Ctor(go, viewPager)
    Test_PageNum.super.Ctor(self)

    self.viewPager = viewPager
    self.vp = instanceof(viewPager, ViewPager) and viewPager.viewPager or viewPager.pageList
    self.gameObject = go
    self:OnInitialize()
end


--
function Test_PageNum:OnInitialize()
    Test_PageNum.super.OnInitialize(self)

    self.icons = {}
    self:TotalPageChanged()

    self.viewPager:AddEventListener(PageEvent.VISIBILITY_CHANGED, self.EventHandler, self)
    self.viewPager:AddEventListener(PageEvent.SELECTION_CHANGED, self.EventHandler, self)
    self.viewPager:AddEventListener(PageEvent.ADDED, self.EventHandler, self)
    self.viewPager:AddEventListener(PageEvent.REMOVED, self.EventHandler, self)
end


--
function Test_PageNum:TotalPageChanged()
    -- 清空 icon
    for i = 1, #self.icons do
        Destroy(self.icons[i].gameObject)
    end

    -- 重新创建 icon
    local curIndex = self.vp.currentViewIndex + 1
    local viewCount = self.vp.viewCount
    local width = self.transform.sizeDelta.x - (viewCount - 1) * GAP
    width = width / viewCount
    local pos = Vector3.zero
    local size = Vector2.New(width, 5)
    local hitAreaSize = Vector2.New(width, 30)
    local pivot = Vector2.New(0, 1)
    local hitAreaPivot = Vector2.New(0, 0.5)
    self.icons = {}
    for i = 1, viewCount do
        local go = CreateGameObject("icon" .. i, self.transform)
        local tra = go.transform
        tra.sizeDelta = size
        tra.pivot = pivot

        local hitArea = CreateGameObject("hitArea", tra)
        local hitAreaTra = hitArea.transform
        hitAreaTra.sizeDelta = hitAreaSize
        hitAreaTra.pivot = hitAreaPivot
        AddOrGetComponent(hitArea, UnityEngine.UI.Image).color = Color.clear

        AddOrGetComponent(go, UnityEngine.UI.Image)
        local cg = AddOrGetComponent(go, UnityEngine.CanvasGroup)
        cg.alpha = i == curIndex and 1 or ALPHA_NORMAL
        self.icons[i] = cg

        if i ~= 1 then
            pos.x = pos.x + width + GAP
        end
        tra.localPosition = pos

        AddEventListener(go, PointerEvent.CLICK, self.ClickIcon, self, 0, i - 1)
    end
end


--
---@param event PointerEvent
---@param index number
function Test_PageNum:ClickIcon(event, index)
    self.vp.currentViewIndex = index
end


--
---@param event PageEvent
function Test_PageNum:EventHandler(event)
    -- print event info
    if event.view ~= nil then
        print(event.type, event.index, event.view.name, event.value)
    else
        print(event.type, event.index)
    end

    if event.type == PageEvent.SELECTION_CHANGED then
        self.icons[event.index + 1]:DOFade(event.value and 1 or ALPHA_NORMAL, 0.2)

    elseif event.type == PageEvent.ADDED or event.type == PageEvent.REMOVED then
        self:TotalPageChanged()
    end
end




--
return Test_PageNum