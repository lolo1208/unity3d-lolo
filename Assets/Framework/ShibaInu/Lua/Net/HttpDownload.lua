--
-- HTTP 下载文件，并保存在本地
-- 2018/5/25
-- Author LOLO
--

local error = error


--
---@class HttpDownload : EventDispatcher
---@field New fun():HttpDownload
---
---@field url string @ 文件网络地址
---@field savePath string @ 本地保存路径
---@field timeout number @ 超时时间，默认值：5秒
---@field callback Handler @ 请求结束时的回调 callback(successful, errMsg)
---
---@field statusCode number @ 请求结束时的状态码
---@field successful boolean @ 请求是否成功（statusCode 介于 200 - 299 之间）
---@field errMsg string @ 返回当错误消息（当 successful = false 时）
---
---@field protected _proxyHost string @ 代理地址
---@field protected _proxyPort number @ 代理端口
---@field protected _download ShibaInu.HttpDownload
---@field protected _speed number @ 下载结束时，记录的最终速度
---@field protected _handler Handler
---
local HttpDownload = class("HttpDownload", EventDispatcher)

local event = HttpEvent.New(HttpEvent.ENDED)


--
--- 构造函数
function HttpDownload:Ctor()
    HttpDownload.super.Ctor(self)
end


--
--- 发送请求
---@param optional url string @ 文件网络地址
---@param optional savePath string @ 本地保存路径
---@param optional callback Handler @ 请求结束时的回调 callback(successful, errMsg)
function HttpDownload:Start(url, savePath, callback)
    if callback ~= nil then
        self.callback = callback
    end
    self.statusCode = nil
    self.errMsg = nil
    self.successful = false
    self._speed = nil


    -- 取消正在发送的请求
    if self._handler ~= nil then
        self._handler:Recycle()
        self._handler = nil
    end
    local download = self._download --- @type ShibaInu.HttpDownload
    if download ~= nil then
        download:Abort()
        self._download = nil
    end


    -- url 验证
    if url ~= nil then
        self.url = url
    end
    if self.url == nil then
        error(Constants.E3006)
    end


    -- savePath 验证
    if savePath ~= nil then
        self.savePath = savePath
    end
    if self.savePath == nil then
        error(Constants.E3007)
    end


    -- 创建 ShibaInu.HttpDownload
    download = ShibaInu.HttpDownload.New()
    self._download = download
    download.url = self.url
    download.savePath = self.savePath

    -- 有指定超时时间
    if self.timeout ~= nil then
        download.timeout = self.timeout
    end

    -- 有设置代理
    if self._proxyHost ~= nil then
        download:SetProxy(self._proxyHost, self._proxyPort)
    end

    -- 发送请求
    self._handler = handler(self.EndedHandler, self)
    download:SetLuaCallback(self._handler.lambda)
    download:Start()
end


--
--- HTTP 请求已结束
---@param statusCode number
---@param errMsg string
function HttpDownload:EndedHandler(statusCode, errMsg)
    self._handler = nil
    self._speed = self._download.speed
    self._download = nil

    self.statusCode = statusCode
    self.errMsg = errMsg
    self.successful = statusCode > 199 and statusCode < 300

    -- 抛出 HttpRequestEvent.ENDED 事件
    self:DispatchEvent(event, false, false)

    -- 执行 callback
    local callback = self.callback
    if callback ~= nil then
        self.callback = nil
        callback:Execute(self.successful, errMsg)
    end
end


--
--- 取消正在发送的请求
function HttpDownload:Abort()
    if self._download ~= nil then
        self._download:Abort()
    end
end


--
--- 设置代理
---@param host string @ 代理地址
---@param optional port number @ 代理端口，默认：80
function HttpDownload:SetProxy(host, port)
    self._proxyHost = host
    self._proxyPort = port or 80
end


--
--- 是否正在下载中
---@return boolean
function HttpDownload:IsDownloading()
    return self._download ~= nil
end


--
--- 获取下载进度，0～1
---@return number
function HttpDownload:GetProgress()
    if self._download ~= nil then
        return self._download.progress
    end
    return self.successful and 1 or 0
end


--
--- 获取下载速度，字节/秒
---@return number
function HttpDownload:GetSpeed()
    if self._download ~= nil then
        return self._download.speed
    end
    if self._speed ~= nil then
        return self._speed
    end
    return 0
end




--
return HttpDownload