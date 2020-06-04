--
-- 随机数（线性同余）
-- 2020/06/01
-- Author LOLO
--

local floor = math.floor


-- 随机数算法
local A = 1103515245
local C = 12345
local M = 134217728 -- RAND_MAX

local function rand(seed)
    return (seed * A + C) % M
end



--
---@class Random
---@field New fun(seed:number):Random
---
---@field seed number @ 随机种子。要更改该值请调用 self:SetSeed(value) 方法
---@field next number @ 下次的随机种子值（请勿修改该值）
local Random = class("Random")


--
--- 创建一个随机数对象
---@param seed number @ -可选- 随机种子，默认值为当前时间
function Random:Ctor(seed)
    self:SetSeed(seed)
end


--
--- 设置随机种子
function Random:SetSeed(seed)
    self.seed = floor(seed or os.time())
    self.next = self.seed
end


--
--- 返回一个随机整数（正数）
---   Next() 返回：0 ~ M（不包含 M）
---   Next(10) 返回：0 ~ 9
---   Next(10, 20) 返回：10 ~ 19
---@param a number
---@param b number
---@return number
function Random:Next(a, b)
    local next = rand(self.next)
    self.next = next

    if a == nil then
        return next
    end

    if b == nil then
        b = a
        a = 0
    end

    return floor(a + (b - a) * next / (M + 1))
end


--
--- 返回一个随机浮点数
---   NextFloat() 返回：0 ~ 1（不包含 1）
---   NextFloat(10) 返回：0 ~ 9.9999999
---   NextFloat(10, 20) 返回：10 ~ 19.9999999
---@param a number
---@param b number
---@return number
function Random:NextFloat(a, b)
    local next = rand(self.next)
    self.next = next
    local val = next / M

    if a == nil then
        return val
    end

    if b == nil then
        return a * val
    end

    return a + (b - a) * val
end


--
--- 获取一个随机数，并返回该随机数是否在 a 范围内
--- 默认 a = 0.5, b = 1，有 50% 概率返回 true
---   Chance(0.3, 1) 将会有 30% 概率返回 true
---@param a number
---@param b number
---@return boolean
function Random:Chance(a, b)
    a = a or 0.5
    b = b or 1
    local next = rand(self.next)
    self.next = next
    return next / M * b <= a
end



--
return Random
