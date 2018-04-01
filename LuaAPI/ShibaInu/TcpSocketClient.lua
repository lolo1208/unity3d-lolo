---@class ShibaInu.TcpSocketClient : object
---@field msgProtocol ShibaInu.IMsgProtocol
---@field host string
---@field port int
---@field connected bool
---@field connecting bool
---@field connentTimeout int
---@field sendTimeout int
---@field receiveTimeout int
---@field luaClient LuaInterface.LuaTable
---@field eventCallback System.Action
local m = {}
---@param host string
---@param port int
function m:Content(host, port) end
---@param data object
function m:Send(data) end
function m:Close() end
ShibaInu = {}
ShibaInu.TcpSocketClient = m
return m