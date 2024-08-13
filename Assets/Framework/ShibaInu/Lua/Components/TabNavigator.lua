--
-- 标签导航组件
-- 点击选项卡按钮时，切换到对应的界面。
-- 界面有切换时，将会触发事件：TabNavigator.EVENT_VIEW_CHANGED
-- * tabBtn 需要包含两个子节点：Normal 和 Selected
-- 2018/12/11
-- Author LOLO
--


--
---@class TabNavigator : EventDispatcher
---@field New fun(defaultViewName:string):TabNavigator
---
---@field defaultViewName string @ 默认显示界面的名称。默认：nil，表示选中第一个添加的界面
---@field protected _currentViewName string @ 当前选中界面的名称
---@field protected _views table<string, View> @ 界面列表
---
local TabNavigator = class("TabNavigator", EventDispatcher)

--- 选中界面有改变事件
TabNavigator.EVENT_VIEW_CHANGED = "TabNavigatorEvent_ViewChanged"

local STATE_NORMAL = "Normal"     -- 按钮正常状态子节点的名称
local STATE_SELECTED = "Selected" -- 按钮选中状态子节点的名称


--
--- 构造函数
---@param defaultViewName string @ -可选- 默认显示界面的名称。默认：nil，表示选中第一个添加的界面
function TabNavigator:Ctor(defaultViewName)
    TabNavigator.super.Ctor(self)

    self.defaultViewName = defaultViewName
    self._views = {}
end



--
--- 设置界面的选中状态
---@param tabNav TabNavigator
---@param viewName string
---@param selected boolean
local function SetSelect(tabNav, viewName, selected)
    local info = tabNav._views[viewName]
    info.normalBtn:SetActive(not selected)
    info.selectedBtn:SetActive(selected)

    if selected then
        if info.view ~= nil then
            info.view:Show()
        else
            if info.viewClass ~= nil then
                info.view = info.viewClass.New()
                info.view:Show()
            end
        end
    else
        if info.view ~= nil then
            info.view:Hide()
        end
    end
end



--
--- 添加一个选项卡按钮，以及注册对应的界面名称
---@param tabBtn UnityEngine.Transform @ 选项卡按钮
---@param viewClass View @ 对应的界面 Class
---@param viewName string @ 界面名称
---@param view View @ 界面实例
function TabNavigator:Add(tabBtn, viewClass, viewName, view)
    local info = {
        viewClass = viewClass,
        view = view,
        tabBtn = tabBtn,
        normalBtn = tabBtn:Find(STATE_NORMAL).gameObject,
        selectedBtn = tabBtn:Find(STATE_SELECTED).gameObject
    }
    self._views[viewName] = info
    AddEventListener(info.normalBtn, PointerEvent.CLICK, self.TabBtnClick, self, 0, viewName)

    -- 选中默认界面 或 第一个添加的界面
    if viewName == self.defaultViewName or (self._currentViewName == nil and self.defaultViewName == nil) then
        self:SelectView(viewName)
    else
        SetSelect(self, viewName, false)
    end
end


--
--- 点击 tabBtn
---@param e PointerEvent
---@param viewName string
function TabNavigator:TabBtnClick(e, viewName)
    self:SelectView(viewName)
end


--
--- 选中（切换）界面
---@param viewName string @ 界面的名称
function TabNavigator:SelectView(viewName)
    if self._currentViewName == viewName then
        return
    end

    if self._currentViewName ~= nil then
        SetSelect(self, self._currentViewName, false)
    end

    self._currentViewName = viewName
    SetSelect(self, viewName, true)

    self:DispatchEvent(Event.Get(Event, TabNavigator.EVENT_VIEW_CHANGED, viewName))
end


--
--- 通过 界面名称 获取对应的 view
---@param viewName string
---@return View
function TabNavigator:GetView(viewName)
    local info = self._views[viewName]
    if info ~= nil then
        return info.view
    end
    return nil
end


--
--- 通过 界面名称 获取对应的 按钮
---@param viewName string
---@return UnityEngine.Transform
function TabNavigator:GetTabBtn(viewName)
    local info = self._views[viewName]
    if info ~= nil then
        return info.tabBtn
    end
    return nil
end


--
--- 获取当前选中的界面
---@return View
function TabNavigator:GetCurrentView()
    return self:GetView(self._currentViewName)
end


--
--- 获取当前选中界面的名称
---@return string
function TabNavigator:GetCurrentViewName()
    return self._currentViewName
end




--
return TabNavigator
