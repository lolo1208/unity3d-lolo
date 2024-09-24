--
-- 切换开关组件
--   组件拥有两个状态：开启或关闭（checked）
--   可以设置是否启用响应交互（enabled）
--   在状态切换时，会派发事件：ToggleSwitch.EVENT_CHANGED
--   应继承该类，重写 PlayToggleEffect() 和 SetEnabled() 方法，来实现界面效果
-- 2022/05/12
-- Author LOLO
--


--
---@class ToggleSwitch : EventDispatcher
---@field New fun():ToggleSwitch
---
---@field protected _checked boolean @ true: 开启状态（ON 状态），false: 关闭状态（OFF 状态）
---@field protected _enabled boolean @ true: 当前为可交互状态（响应点击），false: 当前为禁用状态
---
local ToggleSwitch = class("ToggleSwitch", EventDispatcher)

--- 开启或关闭状态切换时的事件
ToggleSwitch.EVENT_CHANGED = "ToggleSwitchEvent_Changed"


--
--- 构造函数
function ToggleSwitch:Ctor()
    ToggleSwitch.super.Ctor(self)

    self._checked = false
    self._enabled = true
end


--
--- 切换到开启状态（ON）
function ToggleSwitch:On()
    if not self._checked then
        self:Toggle()
    end
end

--
--- 切换到关闭状态（OFF）
function ToggleSwitch:Off()
    if self._checked then
        self:Toggle()
    end
end

--
--- 切换到 开启（true）或 关闭状态（false）
---@param isOn boolean
function ToggleSwitch:ToggleTo(isOn)
    if isOn then
        self:On()
    else
        self:Off()
    end
end

--
--- 在开启和关闭状态间切换
function ToggleSwitch:Toggle()
    self._checked = not self._checked
    self:PlayToggleEffect()
    self:DispatchEvent(Event.Get(Event, ToggleSwitch.EVENT_CHANGED, self._checked))
end

--
--- 交互式切换
--- 该函数内会检查 enabled 状态，来决定是否切换开启关闭状态
--- 该函数可用于绑定 click 事件等。
function ToggleSwitch:InteractiveToggle()
    if self._enabled then
        self:Toggle()
    end
end

--
--- 播放状态切换时的效果
--- + 可重写该函数实现开启和关闭状态切换时的效果
function ToggleSwitch:PlayToggleEffect()
end

--
--- 当前是否为开启状态
---@return boolean
function ToggleSwitch:GetChecked()
    return self._checked
end


--
--- 设置是否可交互（响应点击）
--- + 可重写该函数实现启用和禁用状态的效果
---@param value boolean
function ToggleSwitch:SetEnabled(value)
    self._enabled = value
end

--
--- 当前是否可交互（响应点击）
---@return boolean
function ToggleSwitch:GetEnabled()
    return self._enabled
end


--
return ToggleSwitch
