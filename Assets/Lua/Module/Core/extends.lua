--
-- 扩展框架底层（Manager）相关功能
-- 2017/10/16
-- Author LOLO
--


--Localization.Language = "zh-CN"
require("Data.Languages." .. Localization.Language)

Stage.loadingSceneClass = require("Module.Loading.View.LoadingScene")

Stats.Show()
