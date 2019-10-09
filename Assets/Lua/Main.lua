--
-- Lua 入口
-- 2017/09/26
-- Author LOLO
--



-- 启动函数
local function Main()
    require("Core.initialize")
    require("Module.Core.extends")

    -- 禁止创建全局变量或全局函数
    setmetatable(_G, {
        __newindex = function(_, name, value)
            error(Constants.E1001)
        end
    })

    -- 启动游戏
    --collectgarbage("collect")
    require("Module.Core.launcher")
end


-- try call Main
local function errorHandler(msg)
    ShibaInu.Logger.LogError("[Lua Main Error]\n" .. msg, debug.traceback("", 2))
end
xpcall(Main, errorHandler)
