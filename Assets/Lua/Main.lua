--
-- Lua 入口
-- 2017/9/26
-- Author LOLO
--



local function Main()
    require("Core.initialize")
    collectgarbage("collect")

    -- 启动游戏
    require("Module.Core.launcher")
end





local function errorTraceback(msg)
    local err = {
        "[LUA ERROR : Main] ",
        tostring(msg),
        debug.traceback("", 2)
    }
    print(table.concat(err, ""))
end
xpcall(Main, errorTraceback)


