--
-- 发送 HTTP 请求
-- 2018/1/22
-- Author LOLO
--

local error = error
local pairs = pairs

---@class HttpRequest : EventDispatcher
---@field New fun():HttpRequest
---
---@field url string @ url 地址
---@field timeout number @ 超时时间，默认值：5秒
---@field postData table @ 要发送的 post 数据
---@field callback Handler @ 请求结束时的回调 callback(successful, content)
---
---@field statusCode number @ 请求结束时的状态码
---@field content string @ 返回的内容
---@field successful boolean @ 请求是否成功（statusCode 介于 200 - 299 之间）
---
---@field protected _proxyHost string @ 代理地址
---@field protected _proxyPort number @ 代理端口
---@field protected _request ShibaInu.HttpRequest
---@field protected _handler Handler
---
local HttpRequest = class("HttpRequest", EventDispatcher)

--

--- 异常状态码：创建线程时发生异常
HttpRequest.EXCEPTION_CREATE_THREAD = -1
--- 异常状态码：发送请求时发生异常
HttpRequest.EXCEPTION_SEND_REQUEST = -2
--- 异常状态码：获取内容时发生异常
HttpRequest.EXCEPTION_GET_RESPONSE = -3
--- 异常状态码：发送请求或获取内容过程中被取消了
HttpRequest.EXCEPTION_ABORTED = -4

--

--- 构造函数
function HttpRequest:Ctor(...)
    HttpRequest.super.Ctor(self, ...)
end

--- 发送请求
---@param optional url string @ url 地址
---@param optional callback Handler @ 请求结束时的回调 callback(successful, content)
---@param optional postData table<string, string> @ 要发送的 post 数据列表
function HttpRequest:Send(url, callback, postData)
    if callback ~= nil then
        self.callback = callback
    end
    self.statusCode = nil
    self.content = nil
    self.successful = false

    -- 取消正在发送的请求
    if self._handler ~= nil then
        self._handler:Clean()
        self._handler = nil
    end
    local request = self._request --- @type ShibaInu.HttpRequest
    if request ~= nil then
        request:Abort()
        self._request = nil
    end

    -- url 验证
    if url ~= nil then
        self.url = url
    end
    if self.url == nil then
        error(Constants.E3003)
    end

    -- 创建 ShibaInu.HttpRequest
    request = ShibaInu.HttpRequest.New()
    self._request = request
    request.url = url ~= nil and url or self.url

    -- 添加 post 数据
    if postData ~= nil then
        self.postData = postData
    end
    if self.postData ~= nil then
        request.method = "POST"
        for k, v in pairs(self.postData) do
            request:AppedPostData(k, v)
        end
    end

    -- 有指定超时时间
    if self.timeout ~= nil then
        request.timeout = self.timeout
    end

    -- 有设置代理
    if self._proxyHost ~= nil then
        request:SetProxy(self._proxyHost, self._proxyPort)
    end

    -- 发送请求
    self._handler = Handler.New(self.Ended, self)
    request:SetLuaCallback(self._handler.lambda)
    request:Send()
end

--- HTTP 请求已结束
---@param statusCode number
---@param content string
function HttpRequest:Ended(statusCode, content)
    self.statusCode = statusCode
    self.content = content
    self.successful = statusCode > 199 and statusCode < 300
    self._request = nil
    self._handler = nil

    -- 抛出 HttpRequestEvent.ENDED 事件
    self:DispatchEvent(Event.Get(HttpRequestEvent, HttpRequestEvent.ENDED))

    -- 执行 callback
    local callback = self.callback
    if callback ~= nil then
        self.callback = nil
        callback:Execute(self.successful, content)
    end
end

--- 设置代理
---@param host string @ 代理地址
---@param optional port number @ 代理端口，默认：80
function HttpRequest:SetProxy(host, port)
    self._proxyHost = host
    self._proxyPort = port or 80
end

--- 是否正在请求中
---@return boolean
function HttpRequest:IsRequesting()
    return self._request ~= nil
end

return HttpRequest