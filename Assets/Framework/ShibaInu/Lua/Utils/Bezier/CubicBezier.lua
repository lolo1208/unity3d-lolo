--
-- 多次贝塞尔曲线，根据贝塞尔点列表和间距，生成一系列锚点
-- 2019/4/2
-- Author LOLO
--

local insert = table.insert
local lerp = Vector2.Lerp

local QuadraticBezier = require("Utils.Bezier.QuadraticBezier")


--
---@class CubicBezier
---@field New fun(pStart:Vector2, pEnd:Vector2, pBezierList:Vector2[], anchorSpace:number):CubicBezier
---
---@field pStart Vector2 @ 起点
---@field pEnd Vector2 @ 终点
---@field pBezierList Vector2[] @ 贝塞尔点列表
---@field anchorSpace number @ 锚点间距
---@field anchorList {x:number,y:number,d:number}[] @ 锚点信息列表 { x坐标, y坐标, 角度 }
---@field anchorCount number @ 锚点总数
---@field curveLength number @ 曲长
---
local CubicBezier = class("CubicBezier")

local tp0 = Vector2.New()
local tp1 = Vector2.New()
local tp2 = Vector2.New()


--
function CubicBezier:Ctor(pStart, pEnd, pBezierList, anchorSpace)
    self:Init(pStart, pEnd, pBezierList, anchorSpace)
end


--
--- 初始化
---@param pStart Vector2 @ 起点
---@param pEnd Vector2 @ 终点
---@param pBezierList Vector2[] @ 贝塞尔点列表。当列表长度为0时，将自动取起点与终点的中心点为贝塞尔点
---@param anchorSpace number @ 锚点间距
---@return number @ 锚点总数
function CubicBezier:Init(pStart, pEnd, pBezierList, anchorSpace)
    if pStart == nil or pEnd == nil or pBezierList == nil or anchorSpace == 0 then
        return 0
    end

    self.pStart = pStart
    self.pEnd = pEnd
    self.pBezierList = pBezierList
    self.anchorSpace = anchorSpace

    -- 连接首尾和贝塞尔点列表
    local path = { pStart }
    if #pBezierList == 0 then
        insert(pBezierList, lerp(pStart, pEnd, 0.5))
    end
    for i = 1, #pBezierList do
        path[i + 1] = pBezierList[i]
    end
    insert(path, pEnd)

    self.anchorList = {}
    local bezier = QuadraticBezier.New()
    local p0, p1, p2
    local count = #path
    for n = 1, count - 2 do
        if n == 1 then
            p0 = path[1]
        else
            p0 = tp0
            p0:Set((path[n].x + path[n + 1].x) / 2, (path[n].y + path[n + 1].y) / 2)
        end

        p1 = tp1
        p1:Set(path[n + 1].x, path[n + 1].y)

        if n <= count - 3 then
            p2 = tp2
            p2:Set((path[n + 1].x + path[n + 2].x) / 2, (path[n + 1].y + path[n + 2].y) / 2)
        else
            p2 = path[n + 2]
        end

        bezier:Init(p0, p1, p2, anchorSpace)
        for i = 0, bezier.anchorCount do
            insert(self.anchorList, bezier:GetAnchor(i))
        end
    end

    self.curveLength = bezier ~= nil and bezier.curveLength or 0
    self.anchorCount = #self.anchorList
    return self.anchorCount
end


--
--- 根据锚点的索引，获取锚点的信息
--- 索引 从 1 开始，例：
--- for i = 1, bezier.anchorCount do
---     local anchor = bezier:GetAnchor(i)
--- end
---@param index number
---@return { x:number, y:number, d:number} @ { x坐标, y坐标, 角度 }
function CubicBezier:GetAnchor(index)
    return self.anchorList[index]
end




--
return CubicBezier
