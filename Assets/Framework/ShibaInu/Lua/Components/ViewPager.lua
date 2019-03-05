--
-- 翻页组件，可在两个界面间拖拽切换
-- 2019/02/25
-- Author LOLO
--

local error = error
local format = string.format


--
---@class ViewPager : View
---@field New fun(go:UnityEngine.GameObject):ViewPager
---
---@field viewPager ShibaInu.ViewPager @ 对应的 C#ShibaInu.ViewPager 对象
---
local ViewPager = class("ViewPager", View)


--
--- 构造函数
---@param go UnityEngine.GameObject
function ViewPager:Ctor(go)
    ViewPager.super.Ctor(self)

    local viewPager = GetComponent.ViewPager(go)
    if viewPager == nil then
        error(format(Constants.E2007, self.__classname, go.name))
    end
    viewPager.luaTarget = self
    self.viewPager = viewPager

    self.gameObject = go
    self:OnInitialize()
end


--
--- 抛出当前选中界面的显示和选中事件
function ViewPager:DispatchCurrentViewPageEvent()
    local curView = self.viewPager:GetCurrentView()
    if curView ~= nil then
        local curIndex = self.viewPager:GetCurrentViewIndex()
        PageEvent.DispatchEvent(self, PageEvent.VISIBILITY_CHANGED, curIndex, curView, true)
        PageEvent.DispatchEvent(self, PageEvent.SELECTION_CHANGED, curIndex, curView, true)
    end
end




--
return ViewPager
