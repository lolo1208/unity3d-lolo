--
-- 网络相关测试范例
-- 2018/4/3
-- Author LOLO
--

local insert = table.insert
local concat = table.concat
local floor = math.floor
local tostring = tostring


--
---@class Test.Samples.BaseList.Test_Network : View
---@field New fun():Test.Samples.BaseList.Test_Network
---
---@field hrUrl UnityEngine.UI.InputField
---@field hrPost UnityEngine.UI.InputField
---@field hrHead UnityEngine.UI.Toggle
---@field hrSendBtn UnityEngine.UI.Button
---@field hrLog UnityEngine.UI.Text
---@field request HttpRequest
---
---@field dlGO UnityEngine.GameObject
---@field dlUrl UnityEngine.UI.InputField
---@field dlStartBtn UnityEngine.UI.Button
---@field dlProgress ShibaInu.CircleImage
---@field dlLog UnityEngine.UI.Text
---@field download HttpDownload
---
---@field ulGO UnityEngine.GameObject
---@field ulUrl UnityEngine.UI.InputField
---@field ulStartBtn UnityEngine.UI.Button
---@field ulProgress ShibaInu.CircleImage
---@field ulLog UnityEngine.UI.Text
---@field upload HttpUpload
---
---@field udpHost UnityEngine.UI.InputField
---@field udpPort UnityEngine.UI.InputField
---@field udpConv UnityEngine.UI.InputField
---@field udpConnBtn UnityEngine.UI.Button
---@field udpConnBtnLabel UnityEngine.UI.Text
---@field udpSendData UnityEngine.UI.InputField
---@field udpSendBtn UnityEngine.UI.Button
---@field udpLog UnityEngine.UI.Text
---@field udpLogData table
---@field udpSocket UdpSocket
---
---@field tcpHost UnityEngine.UI.InputField
---@field tcpPort UnityEngine.UI.InputField
---@field tcpConnBtn UnityEngine.UI.Button
---@field tcpConnBtnLabel UnityEngine.UI.Text
---@field tcpSendData UnityEngine.UI.InputField
---@field tcpSendBtn UnityEngine.UI.Button
---@field tcpLog UnityEngine.UI.Text
---@field tcpLogData table
---@field tcpSocket TcpSocket
---
local Test_Network = class("Test.Samples.BaseList.Test_Network", View)

function Test_Network:Ctor(...)
    Test_Network.super.Ctor(self, ...)
end

function Test_Network:OnInitialize()
    Test_Network.super.OnInitialize(self)

    local transform = self.gameObject.transform


    -- HttpRequest
    local hrTra = transform:Find("HttpRequest")
    self.hrUrl = GetComponent.InputField(hrTra:Find("url").gameObject)
    self.hrPost = GetComponent.InputField(hrTra:Find("post").gameObject)
    self.hrHead = GetComponent.Toggle(hrTra:Find("head").gameObject)
    self.hrSendBtn = GetComponent.Button(hrTra:Find("sendBtn").gameObject)
    self.hrLog = GetComponent.Text(hrTra:Find("log/viewport/text").gameObject)
    self.request = HttpRequest.New()
    self.request:AddEventListener(HttpEvent.ENDED, self.HttpRequestEnded, self)
    AddEventListener(self.hrSendBtn.gameObject, PointerEvent.CLICK, self.Click_hrSendBtn, self)
    self.hrUrl.text = "http://httpbin.org/get"
    self.hrLog.text = ""


    -- HttpDownload
    local dlTra = transform:Find("HttpDownload")
    self.dlGO = dlTra.gameObject
    self.dlUrl = GetComponent.InputField(dlTra:Find("url").gameObject)
    self.dlStartBtn = GetComponent.Button(dlTra:Find("startBtn").gameObject)
    self.dlProgress = GetComponent.CircleImage(dlTra:Find("progress").gameObject)
    self.dlLog = GetComponent.Text(dlTra:Find("log/viewport/text").gameObject)
    self.download = HttpDownload.New()
    self.download:AddEventListener(HttpEvent.ENDED, self.HttpDownloadEventHandler, self)
    AddEventListener(self.dlStartBtn.gameObject, PointerEvent.CLICK, self.Click_dlStartBtn, self)
    self.dlProgress.fan = 1
    self.dlUrl.text = "http://10.8.40.35:12377/test-dl.zip"
    self.dlLog.text = ""


    -- HttpUpload
    local ulTra = transform:Find("HttpUpload")
    self.ulGO = ulTra.gameObject
    self.ulUrl = GetComponent.InputField(ulTra:Find("url").gameObject)
    self.ulStartBtn = GetComponent.Button(ulTra:Find("startBtn").gameObject)
    self.ulProgress = GetComponent.CircleImage(ulTra:Find("progress").gameObject)
    self.ulLog = GetComponent.Text(ulTra:Find("log/viewport/text").gameObject)
    self.upload = HttpUpload.New()
    self.upload:AddEventListener(HttpEvent.ENDED, self.HttpUploadEventHandler, self)
    AddEventListener(self.ulStartBtn.gameObject, PointerEvent.CLICK, self.Click_ulStartBtn, self)
    self.ulProgress.fan = 1
    self.ulUrl.text = "http://10.8.40.35:12366/upload"
    self.ulLog.text = ""


    -- Switch - HttpDownload / HttpUpload
    local switchBtn = transform:Find("switchBtn").gameObject
    AddEventListener(switchBtn, PointerEvent.CLICK, self.Click_switchBtn, self)
    self:Click_switchBtn()


    -- TcpSocket
    local tcpTra = transform:Find("TcpSocket")
    self.tcpHost = GetComponent.InputField(tcpTra:Find("host").gameObject)
    self.tcpPort = GetComponent.InputField(tcpTra:Find("port").gameObject)
    self.tcpConnBtn = GetComponent.Button(tcpTra:Find("connBtn").gameObject)
    self.tcpConnBtnLabel = GetComponent.Text(tcpTra:Find("connBtn/Text").gameObject)
    self.tcpSendData = GetComponent.InputField(tcpTra:Find("sendData").gameObject)
    self.tcpSendBtn = GetComponent.Button(tcpTra:Find("sendBtn").gameObject)
    self.tcpLog = GetComponent.Text(tcpTra:Find("log/viewport/text").gameObject)
    self.tcpSocket = TcpSocket.New()
    self.tcpSocket:AddEventListener(SocketEvent.CONNECTED, self.TcpSocketEventHandler, self)
    self.tcpSocket:AddEventListener(SocketEvent.CONNECT_FAIL, self.TcpSocketEventHandler, self)
    self.tcpSocket:AddEventListener(SocketEvent.DISCONNECT, self.TcpSocketEventHandler, self)
    self.tcpSocket:AddEventListener(SocketEvent.MESSAGE, self.TcpSocketEventHandler, self)
    AddEventListener(self.tcpConnBtn.gameObject, PointerEvent.CLICK, self.Click_tcpConnBtn, self)
    AddEventListener(self.tcpSendBtn.gameObject, PointerEvent.CLICK, self.Click_tcpSendBtn, self)
    self.tcpHost.text = "10.8.40.35"
    self.tcpPort.text = "12388"
    self.tcpSendData.text = "Bonjour, 你好, 안녕하세요"
    self.tcpLog.text = ""


    -- UdpSocket
    local udpTra = transform:Find("UdpSocket")
    self.udpHost = GetComponent.InputField(udpTra:Find("host").gameObject)
    self.udpPort = GetComponent.InputField(udpTra:Find("port").gameObject)
    self.udpConv = GetComponent.InputField(udpTra:Find("conv").gameObject)
    self.udpConnBtn = GetComponent.Button(udpTra:Find("connBtn").gameObject)
    self.udpConnBtnLabel = GetComponent.Text(udpTra:Find("connBtn/Text").gameObject)
    self.udpSendData = GetComponent.InputField(udpTra:Find("sendData").gameObject)
    self.udpSendBtn = GetComponent.Button(udpTra:Find("sendBtn").gameObject)
    self.udpLog = GetComponent.Text(udpTra:Find("log/viewport/text").gameObject)
    self.udpSocket = UdpSocket.New()
    self.udpSocket:AddEventListener(SocketEvent.CONNECTED, self.UdpSocketEventHandler, self)
    self.udpSocket:AddEventListener(SocketEvent.CONNECT_FAIL, self.UdpSocketEventHandler, self)
    self.udpSocket:AddEventListener(SocketEvent.DISCONNECT, self.UdpSocketEventHandler, self)
    self.udpSocket:AddEventListener(SocketEvent.MESSAGE, self.UdpSocketEventHandler, self)
    AddEventListener(self.udpConnBtn.gameObject, PointerEvent.CLICK, self.Click_udpConnBtn, self)
    AddEventListener(self.udpSendBtn.gameObject, PointerEvent.CLICK, self.Click_udpSendBtn, self)
    self.udpHost.text = "10.8.40.35"
    self.udpPort.text = "12399"
    self.udpConv.text = "123"
    self.udpSendData.text = "Hello, สวัสดี, こんにちは"
    self.udpLog.text = ""
end



--=----------------------[ HTTP Request ]----------------------=--

---@param event PointerEvent
function Test_Network:Click_hrSendBtn(event)
    local url = self.hrUrl.text
    local postData = self.hrPost.text
    if postData ~= "" then
        self.request.postData = postData
        if url == "http://httpbin.org/get" then
            url = "http://httpbin.org/post"
            self.hrUrl.text = url
        end
    else
        self.request.postData = nil
        if url == "http://httpbin.org/post" then
            url = "http://httpbin.org/get"
            self.hrUrl.text = url
        end
    end
    self.hrLog.text = "requesting..."
    self.request.method = self.hrHead.isOn and Constants.HTTP_METHOD_HEAD or nil
    self.request:Send(url)
end

---@param event HttpEvent
function Test_Network:HttpRequestEnded(event)
    local str = ""
    str = str .. "successful : " .. tostring(self.request.successful) .. "\n"
    str = str .. "statusCode : " .. self.request.statusCode .. "\n"
    str = str .. "content : " .. self.request.content
    self.hrLog.text = str
end




--=----------------------[ HTTP Download ]----------------------=--

---@param event PointerEvent
function Test_Network:Click_dlStartBtn(event)
    if not self.download:IsDownloading() then
        self.dlStartBtn.interactable = false
        AddEventListener(Stage, Event.UPDATE, self.HttpDownloadEventHandler, self)
        self.download:Start(self.dlUrl.text, UnityEngine.Application.persistentDataPath .. "/data.zip")
    end
end

---@param event Event
function Test_Network:HttpDownloadEventHandler(event)
    local p = self.download:GetProgress()
    local s = floor(self.download:GetSpeed() / 1024 * 10) / 10
    self.dlProgress.fan = 1 - p
    self.dlLog.text = "downloading... " .. floor(p * 100) .. "%   " .. s .. " kb/s"

    if event.type == HttpEvent.ENDED then
        RemoveEventListener(Stage, Event.UPDATE, self.HttpDownloadEventHandler, self)
        self.dlStartBtn.interactable = true

        if self.download.successful then
            self.dlLog.text = "svae path: " .. self.download.savePath
        else
            self.dlLog.text = "download error! statusCode: " .. self.download.statusCode .. "\nerrMsg: " .. self.download.errMsg
        end
    end
end




--=----------------------[ HTTP Upload ]----------------------=--

---@param event PointerEvent
function Test_Network:Click_ulStartBtn(event)
    if not self.upload:IsUploading() then
        self.ulStartBtn.interactable = false
        AddEventListener(Stage, Event.UPDATE, self.HttpUploadEventHandler, self)
        self.upload:Start(
                self.ulUrl.text,
                --"/Users/limylee/LOLO/nodejs/UnityTestServer/lib/testServers/uploadData.pptx",
                UnityEngine.Application.persistentDataPath .. "/data.zip",
                nil,
                { kkk = "value", aaa = "AASAA", ddd = "大大大" }
        )
    end
end

---@param event Event
function Test_Network:HttpUploadEventHandler(event)
    local p = self.upload:GetProgress()
    local s = floor(self.upload:GetSpeed() / 1024 * 10) / 10
    self.ulProgress.fan = 1 - p
    self.ulLog.text = "uploading... " .. floor(p * 100) .. "%   " .. s .. " kb/s"

    if event.type == HttpEvent.ENDED then
        RemoveEventListener(Stage, Event.UPDATE, self.HttpUploadEventHandler, self)
        self.ulStartBtn.interactable = true

        local str = ""
        str = str .. "successful : " .. tostring(self.upload.successful) .. ",  "
        str = str .. "statusCode : " .. self.upload.statusCode .. "\n"
        str = str .. "content : " .. self.upload.content
        self.ulLog.text = str
    end
end




--=----------------------[ TCP Socket ]----------------------=--

---@param event PointerEvent
function Test_Network:Click_tcpConnBtn(event)
    if self.tcpSocket:IsConnected() then
        self.tcpSocket:Close()
        self.tcpConnBtnLabel.text = "Connect"
    else
        self.tcpConnBtnLabel.text = "Disconnect"
        self.tcpLogData = {}
        self:AppendTcpLog("connecting...\n", true)
        self.tcpSocket:Connect(self.tcpHost.text, self.tcpPort.text)
    end
end

---@param event SocketEvent
function Test_Network:TcpSocketEventHandler(event)
    self:AppendTcpLog(event.type)
    if event.data ~= nil then
        self:AppendTcpLog(" : ")
        self:AppendTcpLog(event.data)
    end
    self:AppendTcpLog("\n", true)

    if event.type == SocketEvent.CONNECT_FAIL or event.type == SocketEvent.DISCONNECT then
        self.tcpConnBtnLabel.text = "Connect"
    end
end

---@param event PointerEvent
function Test_Network:Click_tcpSendBtn(event)
    if self.tcpSocket:IsConnected() then
        local data = self.tcpSendData.text
        self:AppendTcpLog("send : ")
        self:AppendTcpLog(data)
        self:AppendTcpLog("\n", true)
        self.tcpSocket:Send(data)
    end
end

function Test_Network:AppendTcpLog(log, isUpdate)
    insert(self.tcpLogData, log)
    if isUpdate then
        self.tcpLog.text = concat(self.tcpLogData)
    end
end




--=----------------------[ UDP Socket ]----------------------=--

---@param event PointerEvent
function Test_Network:Click_udpConnBtn(event)
    if self.udpConnBtn.interactable then
        self.udpConnBtn.interactable = false
        self.udpConnBtnLabel.text = "Connected"
        self.udpLogData = {}
        self.udpSocket:Connect(self.udpHost.text, self.udpPort.text, self.udpConv.text)
    end
end

---@param event SocketEvent
function Test_Network:UdpSocketEventHandler(event)
    local log = self.udpLogData
    insert(log, event.type)
    if event.data ~= nil then
        insert(log, " : ")
        insert(log, event.data)
    end
    insert(log, "\n")
    self.udpLog.text = concat(log)

    if event.type == SocketEvent.CONNECT_FAIL or event.type == SocketEvent.DISCONNECT then
        self.udpConnBtn.interactable = true
        self.udpConnBtnLabel.text = "Connect"
    end
end

---@param event PointerEvent
function Test_Network:Click_udpSendBtn(event)
    if self.udpSocket:IsConnected() then
        local data = self.udpSendData.text
        local log = self.udpLogData
        insert(log, "send : ")
        insert(log, data)
        insert(log, "\n")
        self.udpLog.text = concat(log)

        self.udpSocket:Send(data)
    end
end



--
---@param event PointerEvent
function Test_Network:Click_switchBtn(event)
    local dlVisible = self.dlGO.activeSelf
    self.dlGO:SetActive(not dlVisible)
    self.ulGO:SetActive(dlVisible)
end



--
return Test_Network