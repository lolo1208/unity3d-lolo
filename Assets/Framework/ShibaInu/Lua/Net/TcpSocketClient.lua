--
-- Tcp socket client.
-- 2018/1/23
-- Author LOLO
--

---@class TcpSocketClient : EventDispatcher
---@field New fun():TcpSocketClient
---
---@field host string
---@field port number
---
---@field protected _client ShibaInu.TcpSocketClient
---
local TcpSocketClient = class("TcpSocketClient", EventDispatcher)

--- 构造函数
function TcpSocketClient:Ctor()
    TcpSocketClient.super.Ctor(self)

    self._client = ShibaInu.TcpSocketClient.New()
    self._client.luaClient = self
end

--- 连接到指定地址和端口到服务器
---@param host string
---@param port number
function TcpSocketClient:Content (host, port)
    self.host = host
    self.port = port
    self._client:Content(host, port)
end

--- 发送数据
---@param data any
function TcpSocketClient:Send(data)
    self._client:Send(data)
end


--


--- 获取对应的 ShibaInu.TcpSocketClient
---@return ShibaInu.TcpSocketClient
function TcpSocketClient:GetClient()
    return self._client
end


--


return TcpSocketClient