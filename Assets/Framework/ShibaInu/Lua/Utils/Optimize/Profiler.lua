--
-- lua 代码耗时统计工具
-- 2018/8/21
-- Author LOLO
--

local sethook = debug.sethook
local getinfo = debug.getinfo
local gettime = tolua.gettime
local remove = table.remove
local tostring = tostring
local floor = math.floor


--
---@class Profiler
---
local Profiler = {}

--- 是否正在统计中
Profiler.profiling = false

local tree = {} --- 组装好的树列表 tree={ key:{ t:time, n:num, c:... }, ... }
local stack = {} --- 函数栈
local id = 0 --- 唯一ID（key）
local cache = {} --- 已获取信息的缓存列表。 cache[fn]=key
local newFn = {} --- 距离上次汇总，新增的函数信息列表 newCache = { key:{ s:source, n:name, l:linedefined }, ... }
local ignoreCache = {} --- C# 函数忽略缓存 ignoreCache[C#fn] = true
local ignoreFrameCount = 0 --- 剩余忽略帧数（在开始统计时需要忽略几帧数据）

--- 需要被忽略的 lua 函数名称列表
local ignoreList = {
    "(for generator)", "trycall"
}

-- ignoreList[fnName] = true
local tmpList = ignoreList
ignoreList = {}
for i = 1, #tmpList do
    ignoreList[tmpList[i]] = true
end
tmpList = nil


--
--- 代码耗时抓取函数
local function ProfilerHook(type)

    -- 忽略 C# 函数（为了提高运行效率）
    local fn = getinfo(2, "f").func
    if ignoreCache[fn] then
        return
    end

    -- 忽略匿名函数，和 ignoreList
    local key = cache[fn]
    local fnName
    if key == nil then
        fnName = getinfo(2, "n").name
        if fnName == nil or ignoreList[fnName] then
            return
        end
    end

    local count = #stack


    -- 函数结束
    if type == "return" then
        if count == 0 then
            --print("count == 0 忽略", key)
            return
        end

        local tail = stack[count]
        while count > 1 and key ~= tail.k do
            --print("移除", tail.k)
            count = count - 1
            tail = stack[count]
            remove(stack)
        end

        --print("出栈", key)
        tail.t = floor((gettime() - tail.t) * 1000 + 0.5) -- 得出函数耗时（微秒）
        remove(stack) -- 出栈

        -- 增加自身总耗时
        tail.r.t = tail.r.t + tail.t
        return


        -- 函数开始
    elseif type == "call" then
        if key == nil then
            local info = getinfo(2, "S")
            if info.source == "=[C]" then
                ignoreCache[fn] = true
                return
            end

            id = id + 1
            key = tostring(id)
            newFn[key] = {
                s = info.source, -- 函数所在文件路径
                l = info.linedefined, -- 函数所在行号
                n = fnName, -- 函数名称
            }
            cache[fn] = key
        end

        local item = {
            k = key,
            t = gettime(), -- 函数耗时（当前是记录函数开始时间）
        }

        -- 记录到树列表
        local parent
        if count == 0 then
            parent = tree -- 没有父函数，直接加入树顶端
        else
            parent = stack[count].r
        end
        if parent.c == nil then
            parent.c = {}
        end
        parent = parent.c

        -- 在 父函数.c 中记录信息
        local record = parent[key]
        if record == nil then
            record = { n = 1, t = 0 }
            parent[key] = record
        else
            record.n = record.n + 1 -- 递增调用次数
        end
        item.r = record

        -- 入栈
        stack[count + 1] = item
        --print("入栈", key)
    end
end


--
--- 开始采样统计
---@param host string
---@param port number
---@param isUDP boolean
function Profiler.Begin(host, port, isUDP)
    if Profiler.profiling then
        return
    end

    if host ~= nil and port ~= nil then
        ShibaInu.LuaProfiler.Begin(host, port, isUDP)
    end

    Profiler.profiling = true
    if isJIT and not isUDP then
        ignoreFrameCount = 15
    else
        ignoreFrameCount = 5
    end
end


--
--- 获取采样数据（每帧汇总）
function Profiler.GetData()
    local t = tree
    local n = newFn
    tree = {}
    newFn = {}
    stack = {}

    if ignoreFrameCount > 0 then
        ignoreFrameCount = ignoreFrameCount - 1
        if ignoreFrameCount == 0 then
            sethook(ProfilerHook, "cr")
        end
        return '{ "t":{}, "n":{} }'
    end

    return JSON.Stringify({ t = t, n = n })
end


--
--- 结束采样统计
function Profiler.End()
    if not Profiler.profiling then
        return
    end
    Profiler.profiling = false
    ignoreFrameCount = 0
    tree = {}
    stack = {}
    cache = {}
    newFn = {}
    sethook()
    ShibaInu.LuaProfiler.End()
end


--
--- 显示或隐藏控制台
Profiler.Console = ShibaInu.LuaProfiler.Console


--
return Profiler