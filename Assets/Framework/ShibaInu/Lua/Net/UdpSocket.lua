--
-- Udp socket client.
-- 2018/5/15
-- Author LOLO
--

---@class UdpSocket : EventDispatcher
---@field New fun():UdpSocket
---
---@field host string
---@field port number
---@field conv number
---
---@field protected _client ShibaInu.UdpSocket
---
local UdpSocket = class("UdpSocket", EventDispatcher)

--- 构造函数
function UdpSocket:Ctor()
    UdpSocket.super.Ctor(self)

    self._client = ShibaInu.UdpSocket.New()
    self._client.luaTarget = self
end


--
--- 连接到指定地址和端口到服务器
---@param host string
---@param port number
---@param conv number
function UdpSocket:Connect (host, port, conv)
    self.host = host
    self.port = port
    self.conv = conv
    self._client:Connect(host, port, conv)
end


--
--- 发送数据
---@param data any
function UdpSocket:Send(data)
    self._client:Send(data)
end


--
--- 关闭当前连接
function UdpSocket:Close()
    self._client:Close()
end




--
--- 当前是否已连接
---@return boolean
function UdpSocket:IsConnected()
    return self._client.connected
end


--
--- 获取对应的 ShibaInu.UdpSocket
---@return ShibaInu.UdpSocket
function UdpSocket:GetClient()
    return self._client
end


--


return UdpSocket