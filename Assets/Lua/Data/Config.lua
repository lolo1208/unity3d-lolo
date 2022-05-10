--
-- 配置信息
-- 2018/12/7
-- Author LOLO
--


local Config = {}


--=------------------[ C#LanguageWindow 修改 ]------------------=--
--- 使用的语种地区代码
Config.language = "zh-CN"
--=-------------------------------------------------------------=--


--=------------------[ C#LocalizationText 调用 ]-----------------=--
--- 设置当前使用的语言包
function Config.SetCurrentLanguage(language)
    Config.language = language
    Language = require("Data.Languages." .. language)
    trycall(DispatchEvent, nil, Stage, Event.Get(Event, Event.LANGUAGE_CHANGED, language))
end
Config.SetCurrentLanguage(Config.language)

--- 获取当前使用的语种地区代码
function Config.GetCurrentLanguage()
    return Config.language
end

--- 获取 key 对应的语言包数据
function Config.GetLanguageValueByKey(key)
    return Language[key]
end
--=--------------------------------------------------------------=--



--
--- 是否记录网络通信日志
Config.logNetEnabled = true



--
return Config
