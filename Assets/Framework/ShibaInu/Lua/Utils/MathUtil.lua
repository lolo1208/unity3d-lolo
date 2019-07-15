--
-- 数学运算相关工具类
-- 2018/2/6
-- Author LOLO
--

local atan2 = math.atan2
local floor = math.floor
local random = math.random
local pi = math.pi
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin

local RADIAN = 2 * math.pi / 360 -- 弧度实数



--
---@class MathUtil
local MathUtil = {}



--
--- 四舍五入取整
---@param num number
---@return number
function MathUtil.Round(num)
    return floor(num + 0.5)
end



--
--- 随机一个分子，并返回该分子是否在 numerator 范围内
--- 例如：MathUtil.Random(30, 100) 会有百分之三十的几率返回 true
---@param numerator number @ -可选- 分子，默认：50
---@param denominator number @ -可选- 分母，默认：100
---@return boolean
function MathUtil.Random(numerator, denominator)
    numerator = numerator or 50
    denominator = denominator or 100
    return random() * denominator < numerator
end


--
--- 获取介于min与max之间的随机数，返回值大于等于min，小于max
---@param min number @ 最小值
---@param max number @ 最大值
---@return number
function MathUtil.RandomBetween(min, max)
    local range = max - min
    return random() * range + min
end



--
--- 获取两点之间距离
--- Vector3 只计算 x 和 z
---@param p1_x1 Vector2 | Vector3 | number
---@param p2_y1 Vector2 | Vector3 | number
---@param x2 number @ - 可选 -
---@param y2 number @ - 可选 -
---@return number
function MathUtil.Distance(p1_x1, p2_y1, x2, y2)
    if x2 ~= nil then
        return sqrt((p1_x1 - x2) ^ 2 + (p2_y1 - y2) ^ 2)
    end

    if p1_x1.z ~= nil then
        return sqrt((p1_x1.x - p2_y1.x) ^ 2 + (p1_x1.z - p2_y1.z) ^ 2)
    end

    return sqrt((p1_x1.x - p2_y1.x) ^ 2 + (p1_x1.y - p2_y1.y) ^ 2)
end


--
--- 获取 第二个点 在 第一个点 的角度（0 ~ 360）
--- 角度 0(360) 为 正左 Vector3(-1, 0 ,0) | Vector2(-1, 0)
--- 角度 90 为 正上 Vector3(0, 0 ,1) |  Vector2(0, 1)
--- Vector3 只计算 x 和 z
---@param p1_x1 Vector2 | Vector3 | number
---@param p2_y1 Vector2 | Vector3 | number
---@param x2 number @ - 可选 -
---@param y2 number @ - 可选 -
---@return number
function MathUtil.Angle(p1_x1, p2_y1, x2, y2)
    local x1, y1
    if x2 ~= nil then
        x1 = p1_x1
        y1 = p2_y1
    elseif p1_x1.z ~= nil then
        x1 = p1_x1.x
        y1 = p1_x1.z
        x2 = p2_y1.x
        y2 = p2_y1.z
    else
        x1 = p1_x1.x
        y1 = p1_x1.y
        x2 = p2_y1.x
        y2 = p2_y1.y
    end

    local x = x2 - x1
    local y = y2 - y1
    local angle = atan2(y, -x) * 180 / pi
    if y < 0 then
        angle = angle + 360
    end
    return angle
end


--
--- 获取 第二个点 在 第一个点 的角度（eulerAngles.y）
--- Vector3 只计算 x 和 z
---@param p1_x1 Vector2 | Vector3 | number
---@param p2_y1 Vector2 | Vector3 | number
---@param x2 number @ - 可选 -
---@param y2 number @ - 可选 -
---@return number
function MathUtil.AngleY(p1_x1, p2_y1, x2, y2)
    -- 四个参数
    if x2 ~= nil then
        return atan2(y2 - p2_y1, -(x2 - p1_x1)) * 180 / pi
    end
    -- 两个 Vector3 参数
    if p1_x1.z ~= nil then
        return atan2(p2_y1.z - p1_x1.z, -(p2_y1.x - p1_x1.x)) * 180 / pi
    end
    -- 两个 Vector2 参数
    return atan2(p2_y1.y - p1_x1.y, -(p2_y1.x - p1_x1.x)) * 180 / pi
end


--
--- 获取两个指定点之间的点（只计算两个轴）
--- 参数 f 的值越接近 1.0，则内插点就越接近 p1。参数 f 的值越接近 0，则内插点就越接近p2
---@param p1 Vector2 | Vector3
---@param p2 Vector2 | Vector3
---@param f number
---@return number, number
function MathUtil.Lerp(p1, p2, f)
    local x1 = p1.x
    local x2 = p2.x
    local y1 = p1.z or p1.y
    local y2 = p2.z or p2.y
    local f1 = 1 - f
    return x1 * f + x2 * f1, y1 * f + y2 * f1
end



--
--- 根据角度，偏移指定距离（只计算 x 和 z）
---@param pos Vector3 @ 位置
---@param angle number @ 角度
---@param distance number @ 距离
---@param resultPos Vector3 @ -可选- 如果传入该值，偏移后的结果将会修改到该值，否则结果修改到参数 pos
---@return Vector3
function MathUtil.OffsetByAngle(pos, angle, distance, resultPos)
    resultPos = resultPos or pos
    local radian = RADIAN * angle
    local x = cos(radian) * distance
    local z = sin(radian) * distance
    resultPos.x = pos.x + x
    resultPos.z = pos.z - z
    return resultPos
end




--
return MathUtil
