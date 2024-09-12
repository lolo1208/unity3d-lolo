--
-- 2次贝塞尔曲线。根据间距，生成锚点
-- 建议直接使用 CubicBezier
-- 2019/4/2
-- Author LOLO
--

local floor = math.floor
local sqrt = math.sqrt
local log = math.log
local pow = math.pow
local abs = math.abs
local pi = math.pi
local atan2 = math.atan2


--
---@class QuadraticBezier
---@field New fun(pStart:Vector2, pBezier:Vector2, pEnd:Vector2, anchorSpace):QuadraticBezier
---
---@field _p0 Vector2 @ 起点
---@field _p1 Vector2 @ 贝塞尔点
---@field _p2 Vector2 @ 终点
---
---@field pStart Vector2 @ 起点
---@field pEnd Vector2 @ 终点
---@field pBezier Vector2 @ 贝塞尔点
---@field anchorSpace number @ 锚点间距
---@field anchorCount number @ 锚点总数
---@field curveLength number @ 曲长
---
---@field _ax number
---@field _ay number
---@field _bx number
---@field _by number
---@field _a number
---@field _b number
---@field _c number
---
local QuadraticBezier = class("QuadraticBezier")


--
function QuadraticBezier:Ctor(pStart, pBezier, pEnd, anchorSpace)
    self:Init(pStart, pBezier, pEnd, anchorSpace)
end


--
--- 初始化
---@param p0 Vector2 @ 起点
---@param p1 Vector2 @ 贝塞尔点
---@param p2 Vector2 @ 终点
---@param anchorSpace number @ 锚点间距
---@return number @ 锚点总数
function QuadraticBezier:Init(p0, p1, p2, anchorSpace)
    if p0 == nil or p1 == nil or p2 == nil or anchorSpace == 0 then
        return 0
    end

    self._p0 = p0
    self._p1 = p1
    self._p2 = p2
    self.anchorSpace = anchorSpace
    self.pStart = p0
    self.pBezier = p1
    self.pEnd = p2

    self._ax = p0.x - 2 * p1.x + p2.x
    self._ay = p0.y - 2 * p1.y + p2.y
    self._bx = 2 * p1.x - 2 * p0.x
    self._by = 2 * p1.y - 2 * p0.y

    if self._ax == 0 then
        self._ax = 1
    end
    if self._ay == 0 then
        self._ay = 1
    end

    self._a = 4 * (self._ax * self._ax + self._ay * self._ay)
    self._b = 4 * (self._ax * self._bx + self._ay * self._by)
    self._c = self._bx * self._bx + self._by * self._by

    self.curveLength = self:GetLength(1)

    self.anchorCount = floor(self.curveLength / self.anchorSpace)
    if self.curveLength % self.anchorSpace > self.anchorSpace / 2 then
        self.anchorCount = self.anchorCount + 1
    end

    return self.anchorCount
end


--
---@return number
function QuadraticBezier:GetSpeed(t)
    return sqrt(self._a * t * t + self._b * t + self._c)
end


--
---@param t number
---@return number
function QuadraticBezier:GetLength(t)
    local temp1 = sqrt(self._c + t * (self._b + self._a * t))
    local temp2 = (2 * self._a * t * temp1 + self._b * (temp1 - sqrt(self._c)))
    local temp3 = log(self._b + 2 * sqrt(self._a) * sqrt(self._c))
    local temp4 = log(self._b + 2 * self._a * t + 2 * sqrt(self._a) * temp1)
    local temp5 = 2 * sqrt(self._a) * temp2
    local temp6 = (self._b * self._b - 4 * self._a * self._c) * (temp3 - temp4)

    return (temp5 + temp6) / (8 * pow(self._a, 1.5))
end


--
---@param t number
---@param l number
---@return number
function QuadraticBezier:GetInvertLength(t, l)
    local t1 = t
    local t2
    while true do
        t2 = t1 - (self:GetLength(t1) - l) / self:GetSpeed(t1)
        if abs(t1 - t2) < 0.000001 then
            break
        end
        t1 = t2
    end
    return t2
end


--
--- 根据锚点的索引，获取锚点的信息
--- 索引 从 0 开始，例：
--- for i = 0, bezier.anchorCount do
---     local anchor = bezier:GetAnchor(i)
--- end
---@param index number
---@return { x:number, y:number, d:number} @ { x坐标, y坐标, 角度 }
function QuadraticBezier:GetAnchor(index)
    if index >= 0 and index <= self.anchorCount then
        local t = index / self.anchorCount
        local l = t * self.curveLength -- 对应的曲长
        t = self:GetInvertLength(t, l) -- 获得对应的 t 值
        local nt = 1 - t

        local p0x, p0y = self._p0.x, self._p0.y
        local p1x, p1y = self._p1.x, self._p1.y
        local p2x, p2y = self._p2.x, self._p2.y

        -- 获得坐标
        local x = nt * nt * p0x + 2 * nt * t * p1x + t * t * p2x
        local y = nt * nt * p0y + 2 * nt * t * p1y + t * t * p2y

        -- 获得切线
        local t0x = nt * p0x + t * p1x
        local t0y = nt * p0y + t * p1y
        local t1x = nt * p1x + t * p2x
        local t1y = nt * p1y + t * p2y

        -- 算出角度
        local dx = t1x - t0x
        local dy = t1y - t0y
        local radians = atan2(dy, dx)
        local degrees = radians * 180 / pi

        local vector3 = Vector3.New(x, y)
        vector3.d = degrees
        return vector3
    else
        return nil
    end
end



--
return QuadraticBezier
