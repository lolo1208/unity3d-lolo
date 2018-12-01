--
-- Lua 入口
-- 2017/9/26
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
    collectgarbage("collect")
    require("Module.Core.launcher")
end


-- 设置当前时间为随机种子
local now = System.DateTime.Now
math.randomseed(now.Minute * 60 * 1000 + now.Second * 1000 + now.Millisecond)


-- try 启动函数
local function errorTraceback(msg)
    local err = {
        "[LUA ERROR : Main] ",
        tostring(msg),
        debug.traceback("", 2)
    }
    LuaHelper.ConsoleLogError(table.concat(err, ""))
end
xpcall(Main, errorTraceback)


