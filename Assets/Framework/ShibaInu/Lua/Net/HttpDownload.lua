--
-- HTTP 下载文件，并保存在本地
-- 2018/5/25
-- Author LOLO
--

local error = error
local STATUS_CODE_COMPLETE = ShibaInu.HttpDownload.STATUS_CODE_COMPLETE


--
---@class HttpDownload : EventDispatcher
---@field New fun():HttpDownload
---
---@field url string @ 文件网络地址
---@field savePath string @ 本地保存路径
---@field timeout number @ 超时时间，默认值：5秒
---@field callback HandlerRef @ 请求结束时的回调 callback(successful, errMsg)
---
---@field statusCode number @ 请求结束时的状态码
---@field successful boolean @ 请求是否成功（statusCode 介于 200 - 299 之间）
---@field errMsg string @ 返回当错误消息（当 successful = false 时）
---
---@field protected _proxyHost string @ 代理地址
---@field protected _proxyPort number @ 代理端口
---@field protected _speed number @ 下载结束时，记录的最终速度
---@field protected _download ShibaInu.HttpDownload
---@field protected _handlerRef HandlerRef
---
local HttpDownload = class("HttpDownload", EventDispatcher)


--
--- 开始下载
---@param url string @ -可选- 文件网络地址
---@param savePath string @ -可选- 本地保存路径
---@param callback HandlerRef @ -可选- 请求结束时的回调 callback(successful, errMsg)
function HttpDownload:Start(url, savePath, callback)
    if callback ~= nil then
        self.callback = callback
    end
    self.statusCode = nil
    self.errMsg = nil
    self.successful = false
    self._speed = nil

    -- 取消正在发送的请求
    if self._handlerRef ~= nil then
        CancelHandler(self._handlerRef)
        self._handlerRef = nil
    end
    local download = self._download
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
    download.Url = self.url
    download.SavePath = self.savePath

    -- 有指定超时时间
    if self.timeout ~= nil then
        download.Timeout = self.timeout
    end

    -- 有设置代理
    if self._proxyHost ~= nil then
        download:SetProxy(self._proxyHost, self._proxyPort)
    end

    -- 发送请求
    self._handlerRef = handler(self.EndedHandler, self)
    download:SetLuaCallback(GetHandlerLambda(self._handlerRef))
    download:Start()
end


--
--- 下载请求已结束
---@param statusCode number
---@param errMsg string
function HttpDownload:EndedHandler(statusCode, errMsg)
    self._handlerRef = nil
    self._speed = self._download.Speed
    self._download = nil

    self.statusCode = statusCode
    self.errMsg = errMsg
    self.successful = statusCode == STATUS_CODE_COMPLETE

    -- 抛出 HttpEvent.ENDED 事件
    self:DispatchEvent(Event.Get(HttpEvent, HttpEvent.ENDED))

    -- 执行回调
    local callback = self.callback
    if callback ~= nil then
        self.callback = nil
        CallHandler(callback, self.successful, errMsg)
    end
end


--
--- 取消正在下载的请求
function HttpDownload:Abort()
    if self._download ~= nil then
        self._download:Abort()
    end
end


--
--- 设置代理
---@param host string @ 代理地址
---@param port number @ -可选- 代理端口，默认：80
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
--- 获取已下载字节数
---@return number
function HttpDownload:GetBytesLoaded()
    if self._download ~= nil then
        return self._download.BytesLoaded
    end
    return 0
end


--
--- 获取文件总字节数
---@return number
function HttpDownload:GetBytesTotal()
    if self._download ~= nil then
        return self._download.BytesTotal
    end
    return 0
end


--
--- 获取下载进度，0～1
---@return number
function HttpDownload:GetProgress()
    if self._download ~= nil then
        return self._download.Progress
    end
    return self.successful and 1 or 0
end


--
--- 获取下载速度，字节/秒（每秒统计两次）
---@return number
function HttpDownload:GetSpeed()
    if self._download ~= nil then
        return self._download.Speed
    end
    if self._speed ~= nil then
        return self._speed
    end
    return 0
end



--
return HttpDownload

