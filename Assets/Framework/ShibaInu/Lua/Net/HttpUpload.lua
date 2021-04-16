--
-- HTTP 上传本地文件
-- 2018/6/1
-- Author LOLO
--

local error = error
local pairs = pairs


--
---@class HttpUpload : EventDispatcher
---@field New fun():HttpUpload
---
---@field url string @ 网络地址
---@field filePath string @ 本地文件地址
---@field timeout number @ 超时时间，默认值：5秒
---@field postData table @ 要发送的 post 数据
---@field callback HandlerRef @ 请求结束时的回调 callback(successful, content)
---
---@field statusCode number @ 请求结束时的状态码
---@field successful boolean @ 请求是否成功（statusCode 介于 200 - 299 之间）
---@field content string @ 返回的内容
---
---@field protected _proxyHost string @ 代理地址
---@field protected _proxyPort number @ 代理端口
---@field protected _speed number @ 上传结束时，记录的最终速度
---@field protected _upload ShibaInu.HttpUpload
---@field protected _handlerRef HandlerRef
---
local HttpUpload = class("HttpUpload", EventDispatcher)


--
--- 开始上传
---@param url string @ -可选- 网络地址
---@param filePath string @ -可选- 本地文件地址
---@param callback HandlerRef @ -可选- 请求结束时的回调 callback(successful, content)
---@param postData table<string, string> @ -可选- 要发送的 post 数据列表
function HttpUpload:Start(url, filePath, callback, postData)
    if callback ~= nil then
        self.callback = callback
    end
    self.statusCode = nil
    self.content = nil
    self.successful = false
    self._speed = nil


    -- 取消正在发送的请求
    if self._handlerRef ~= nil then
        CancelHandler(self._handlerRef)
        self._handlerRef = nil
    end
    local upload = self._upload
    if upload ~= nil then
        upload:Abort()
        self._upload = nil
    end


    -- url 验证
    if url ~= nil then
        self.url = url
    end
    if self.url == nil then
        error(Constants.E3008)
    end


    -- filePath 验证
    if filePath ~= nil then
        self.filePath = filePath
    end
    if self.filePath == nil then
        error(Constants.E3009)
    end


    -- 创建 ShibaInu.HttpUpload
    upload = ShibaInu.HttpUpload.New()
    self._upload = upload
    upload.url = self.url
    upload.filePath = self.filePath


    -- 添加 post 数据
    if postData ~= nil then
        self.postData = postData
    end
    if self.postData ~= nil then
        for k, v in pairs(self.postData) do
            upload:AppedPostData(k, v)
        end
    end


    -- 有指定超时时间
    if self.timeout ~= nil then
        upload.timeout = self.timeout
    end

    -- 有设置代理
    if self._proxyHost ~= nil then
        upload:SetProxy(self._proxyHost, self._proxyPort)
    end

    -- 发送请求
    self._handlerRef = handler(self.EndedHandler, self)
    upload:SetLuaCallback(GetHandlerLambda(self._handlerRef))
    upload:Start()
end


--
--- HTTP 请求已结束
---@param statusCode number
---@param content string
function HttpUpload:EndedHandler(statusCode, content)
    self._handlerRef = nil
    self._speed = self._upload.speed
    self._upload = nil

    self.statusCode = statusCode
    self.content = content
    self.successful = statusCode > 199 and statusCode < 300

    -- 抛出 HttpEvent.ENDED 事件
    self:DispatchEvent(Event.Get(HttpEvent, HttpEvent.ENDED))

    -- 执行 callback
    local callback = self.callback
    if callback ~= nil then
        self.callback = nil
        CallHandler(callback, self.successful, content)
    end
end


--
--- 取消正在发送的请求
function HttpUpload:Abort()
    if self._upload ~= nil then
        self._upload:Abort()
    end
end


--
--- 设置代理
---@param host string @ 代理地址
---@param port number @ -可选- 代理端口，默认：80
function HttpUpload:SetProxy(host, port)
    self._proxyHost = host
    self._proxyPort = port or 80
end


--
--- 是否正在上传中
---@return boolean
function HttpUpload:IsUploading()
    return self._request ~= nil
end


--
--- 获取上传进度，0～1
---@return number
function HttpUpload:GetProgress()
    if self._upload ~= nil then
        return self._upload.progress
    end
    return self.successful and 1 or 0
end


--
--- 获取上传速度，字节/秒（每秒统计两次）
---@return number
function HttpUpload:GetSpeed()
    if self._upload ~= nil then
        return self._upload.speed
    end
    if self._speed ~= nil then
        return self._speed
    end
    return 0
end



--
return HttpUpload