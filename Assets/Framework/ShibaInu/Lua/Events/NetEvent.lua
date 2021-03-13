--
-- 网络相关事件
-- 2019/11/27
-- Author LOLO
--

---@class NetEvent : Event
---@field New fun():NetEvent
---
---@field netType number @ 当前网络类型。在 NetEvent.NET_TYPE_CHANGED 事件中才有该值，值为：Constants.NET_TYPE_xx 系列常量
---@field lastNetType number @ 之前的网络类型
---
---@field pingValue number @ ping 值（毫秒），值为 -1 时，表示超时。在 NetEvent.PING 事件中才有该值
local NetEvent = class("NetEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 网络类型有变化。该事件只会在 NetHelper 上抛出
NetEvent.NET_TYPE_CHANGED = "NetEvent_NetTypeChanged"

--- 获取到新的 ping 值。该事件只会在 NetHelper 上抛出
NetEvent.PING = "NetEvent_Ping"



--
--- 抛出网络相关事件，由 C# NetHelper.cs 调用
---@param type string
---@param netType number
---@param lastNetType number
---@param pingValue number
function NetEvent.DispatchEvent(type, netType, lastNetType, pingValue)
    ---@type NetEvent
    local event = Event.Get(NetEvent, type)
    event.netType = netType
    event.lastNetType = lastNetType
    event.pingValue = pingValue
    trycall(DispatchEvent, nil, NetHelper, event)
end




--=----------------------------------------------------------------------=--




--
return NetEvent
