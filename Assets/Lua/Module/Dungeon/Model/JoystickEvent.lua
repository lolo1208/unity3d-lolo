--
-- 摇杆事件
-- 2018/6/15
-- Author LOLO
--


--
---@class Dungeon.Events.JoystickEvent : Event
---@field New fun():Dungeon.Events.JoystickEvent
---
---@field using boolean @ 是否正在使用中
---@field angle number @ 当前角度
---
local JoystickEvent = class("Dungeon.Events.JoystickEvent", Event)


--
--- Ctor
function JoystickEvent:Ctor(...)
    JoystickEvent.super.Ctor(self, ...)
end



--


--- 使用状态有改变
JoystickEvent.STATE_CHANGED = "JoystickEvent_StateChanged"

--- 角度有改变
JoystickEvent.ANGLE_CHANGED = "JoystickEvent_AngleChanged"




--
return JoystickEvent