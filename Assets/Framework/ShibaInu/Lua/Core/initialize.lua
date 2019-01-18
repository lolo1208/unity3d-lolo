--
-- 初始化框架
-- 2017/9/29
-- Author LOLO
--


require("Core.functions")
require("Core.variables")


-- 全局函数和全局变量定义完成后，才能定义的内容 --

-- log function
trycall = Logger.TryCall
log = Logger.Log
logWarning = Logger.LogWarning
logError = Logger.LogError


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


