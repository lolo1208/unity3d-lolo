--
-- 网络相关事件
-- 2019/11/27
-- Author LOLO
--


--
---@class NetEvent : Event
---@field New fun():NetEvent
---
---@field netType number @ 当前网络类型。在 NetEvent.NET_TYPE_CHANGED 事件中才有该值，值为：Constants.NET_TYPE_xx 系列常量
---@field lastNetType number @ 之前的网络类型
---
---@field pingValue number @ ping 值（毫秒），值为 -1 时，表示超时。在 NetEvent.PING 事件中才有该值
---
local NetEvent = class("NetEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 网络类型有变化
NetEvent.NET_TYPE_CHANGED = "NetEvent_NetTypeChanged"
--- 有新的 ping 值
NetEvent.PING = "NetEvent_Ping"



--
local event = NetEvent.New()

--- 抛出网络相关事件，由 C# NetHelper.cs 调用
---@param type string
---@param netType number
---@param lastNetType number
---@param pingValue number
function NetEvent.DispatchEvent(type, netType, lastNetType, pingValue)
    event.data = nil
    event.target = nil
    event.isPropagationStopped = false

    event.type = type
    event.netType = netType
    event.lastNetType = lastNetType
    event.pingValue = pingValue

    trycall(DispatchEvent, nil, NetHelper, event, false, false)
end




--=----------------------------------------------------------------------=--




--
return NetEvent
