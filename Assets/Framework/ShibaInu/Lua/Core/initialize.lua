--
-- 初始化框架
-- 2017/9/29
-- Author LOLO
--

local type = type
local tostring = tostring
local concat = table.concat

require("Core.functions")
require("Core.variables")



-- 全局函数和全局变量定义完成后，才能定义的内容 --
local stringify = JSON.Stringify
SetRandomseedWithNowTime()



-- log function
trycall = Logger.TryCall
log = Logger.Log
logWarning = Logger.LogWarning
logError = Logger.LogError


--
local warningMsgCount = {}
--- 添加一条警告日志。相同内容的 msg，最多警告 maximum 次。maximum 默认值：1
function logWarningCount(msg, maximum)
    local count = warningMsgCount[msg]
    if count == nil then
        count = 0
        warningMsgCount[msg] = count
    end
    if count < (maximum or 1) then
        warningMsgCount[msg] = count + 1
        logWarning(msg)
    end
end

--
--- 添加（打印）一条 [Trace] 类型日志。
--- 该函数可传入多个参数
function trace(...)
    local args = { ... }
    for i = 1, #args do
        args[i] = tostring(args[i])
    end
    log(concat(args, "    "))
end

--
--- 添加（打印）一条 [Trace] 类型日志。
--- 与 trace() 函数不同的是，传入的 lua table 将会被格式化成 JSON 字符串
function dump(...)
    local args = { ... }
    for i = 1, #args do
        args[i] = type(args[i]) == "table" and stringify(args[i]) or tostring(args[i])
    end
    log(concat(args, "    "))
end



-- PlayerPrefs on Editor
if isEditor then
    local path = Application.dataPath
    local playerPrefs = PlayerPrefs
    ---@type UnityEngine.PlayerPrefs
    PlayerPrefs = {
        SetInt = function(key, value)
            playerPrefs.SetInt(path .. key, value)
        end,
        GetInt = function(key, defaultValue)
            return playerPrefs.GetInt(path .. key, defaultValue or 0)
        end,

        SetFloat = function(key, value)
            playerPrefs.SetFloat(path .. key, value)
        end,
        GetFloat = function(key, defaultValue)
            return playerPrefs.GetFloat(path .. key, defaultValue or 0)
        end,

        SetString = function(key, value)
            playerPrefs.SetString(path .. key, value)
        end,
        GetString = function(key, defaultValue)
            return playerPrefs.GetString(path .. key, defaultValue or "")
        end,

        HasKey = function(key)
            return playerPrefs.HasKey(path .. key)
        end,
        DeleteKey = function(key)
            playerPrefs.DeleteKey(path .. key)
        end,

        DeleteAll = playerPrefs.DeleteAll,
        Save = playerPrefs.Save,
    }
end



-- 禁用协程
coroutine = setmetatable({}, { __index = function()
    error(Constants.E1002)
end })

