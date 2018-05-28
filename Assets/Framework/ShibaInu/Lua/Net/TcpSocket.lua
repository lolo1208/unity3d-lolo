--
-- Tcp socket client.
-- 2018/1/23
-- Author LOLO
--

---@class TcpSocket : EventDispatcher
---@field New fun():TcpSocket
---
---@field host string
---@field port number
---
---@field protected _client ShibaInu.TcpSocket
---
local TcpSocket = class("TcpSocket", EventDispatcher)

--- 构造函数
function TcpSocket:Ctor()
    TcpSocket.super.Ctor(self)

    self._client = ShibaInu.TcpSocket.New()
    self._client.luaTarget = self
end


--
--- 连接到指定地址和端口到服务器
---@param host string
---@param port number
function TcpSocket:Connect (host, port)
    self.host = host
    self.port = port
    self._client:Connect(host, port)
end


--
--- 发送数据
---@param data any
function TcpSocket:Send(data)
    self._client:Send(data)
end


--
--- 关闭当前连接
function TcpSocket:Close()
    self._client:Close()
end




--
--- 当前是否已连接
---@return boolean
function TcpSocket:IsConnected()
    return self._client.connected
end


--
--- 获取对应的 ShibaInu.TcpSocket
---@return ShibaInu.TcpSocket
function TcpSocket:GetClient()
    return self._client
end


--


return TcpSocket