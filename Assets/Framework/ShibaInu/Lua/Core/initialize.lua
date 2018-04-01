--
-- 初始化框架
-- 2017/9/29
-- Author LOLO
--

local require = require

require("Core.functions")
require("Core.variables")


--=-------------------[ 全局函数和全局变量定义完成后，才能定义的内容 ]-------------------=--

-- log function
logError = Logger.AddErrorLog
trycall = Logger.TryCall

--=--------------------------------------------------------------------------=--


-- 禁止创建全局变量或全局函数
setmetatable(_G, {
    __newindex = function(_, name, value)
        error(Constants.E1001)
    end
})


