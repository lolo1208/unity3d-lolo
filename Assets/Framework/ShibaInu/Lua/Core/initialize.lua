--
-- 初始化框架
-- 2017/9/29
-- Author LOLO
--

local require = require


require("Module.Core.extends")
require("Core.functions")
require("Core.variables")


--=-------------------[ 全局函数和变量定义完成后，才能定义的内容 ]-------------------=--

-- log function
logError = Logger.AddErrorLog
trycall = Logger.TryCall

--=--------------------------------------------------------------------------=--

local prefab = ShibaInu.ResManager.test() ---@type UnityEngine.GameObject
Instantiate(prefab, stage.uiCanvas)
