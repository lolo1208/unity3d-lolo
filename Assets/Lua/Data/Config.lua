--
-- 配置信息
-- 2018/12/7
-- Author LOLO
--


local Config = {}


--=------------------[ C#LanguageWindow 修改 ]------------------=--
--- 使用的语种地区代码
Config.language = "en-US"
--=-------------------------------------------------------------=--


--=------------------[ C#LocalizationText 调用 ]------------------=--
--- 获取当前使用的语种地区代码
function Config._GetCurrentLanguage()
    return Config.language
end

--- 获取 key 对应的语言包数据
function Config._GetLanguageByKey(key)
    return Language[key]
end
--=---------------------------------------------------------------=--



--
--- 是否记录网络通信日志
Config.logNetEnabled = true



--
return Config
