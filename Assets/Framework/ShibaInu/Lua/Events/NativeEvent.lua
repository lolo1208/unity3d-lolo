--
-- Native 发来的消息事件
-- 2020/08/04
-- Author LOLO
--

---@class NativeEvent : Event
---@field New fun():NativeEvent
---
---@field action string @ 消息指令。不可包含字符 "#"
---@field message string @ 消息内容
local NativeEvent = class("NativeEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 收到 Native 发来的消息。该事件只会在 Stage 上抛出
NativeEvent.RECEIVE_MESSAGE = "NativeEvent_ReceiveMessage"


--
--- 抛出收到 Native 发来的消息事件，由 C# NativeHelper.cs 调用
---@param action string
---@param message string
function NativeEvent.DispatchEvent(action, message)
    ---@type NativeEvent
    local event = Event.Get(NativeEvent, NativeEvent.RECEIVE_MESSAGE)
    event.action = action
    event.message = message
    trycall(DispatchEvent, nil, Stage, event)
end

--=----------------------------------------------------------------------=--



--
return NativeEvent
