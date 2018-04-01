---@class ShibaInu.HttpRequest : object
---@field requeting bool
---@field url string
---@field method string
---@field timeout int
---@field postData string
---@field callback System.Action
local m = {}
---@param key string
---@param value string
function m:AppedPostData(key, value) end
function m:CleanPostData() end
---@param host string
---@param port int
function m:SetProxy(host, port) end
---@param callback LuaInterface.LuaFunction
function m:SetLuaCallback(callback) end
function m:Send() end
function m:Abort() end
ShibaInu = {}
ShibaInu.HttpRequest = m
return m