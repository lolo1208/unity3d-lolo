--
-- Socket 相关事件
-- 2017/12/15
-- Author LOLO
--

---@class SocketEvent : Event
---@field New fun():SocketEvent
local SocketEvent = class("SocketEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 连接成功
SocketEvent.CONNECTED = "SocketEvent_Connected"

--- 连接失败
SocketEvent.CONNECT_FAIL = "SocketEvent_ConnectFail"

--- 连接断开
SocketEvent.DISCONNECT = "SocketEvent_Disconnect"

--- 收到消息
SocketEvent.MESSAGE = "SocketEvent_Message"


--
--- 抛出 Socket 相关事件，由 TcpSocket.cs / UdpSocket.cs 调用
---@param socket TcpSocket | UdpSocket
---@param type string
---@param data any
function SocketEvent.DispatchEvent(socket, type, data)
    trycall(socket.DispatchEvent, socket, Event.Get(SocketEvent, type, data))
end

--=----------------------------------------------------------------------=--



--
return SocketEvent

