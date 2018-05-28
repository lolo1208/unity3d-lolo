--
-- Socket 相关事件
-- 2017/12/15
-- Author LOLO
--

---@class SocketEvent : Event
local SocketEvent = class("SocketEvent", Event)

function SocketEvent:Ctor(type, data)
    SocketEvent.super.Ctor(self, type, data)
end



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
local event = SocketEvent.New()

--- 抛出 Socket 相关事件，由 TcpSocket.cs / UdpSocket.cs 调用
---@param client TcpSocketClient
---@param type string
---@param data any
function SocketEvent.DispatchEvent(client, type, data)
    event.type = type
    event.data = data
    trycall(client.DispatchEvent, client, event, false, false)
end


--=----------------------------------------------------------------------=--



return SocketEvent