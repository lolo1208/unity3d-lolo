--
-- 只保留三位小数相关转换和运算工具类
-- 2018/2/28
-- Author LOLO
--

local floor = math.floor
local cos = math.cos
local sin = math.sin

local RADIAN = 2 * math.pi / 360 -- 弧度实数


--

---@class Float3
local Float3 = {}


--


--- 将 value 转换成只保留3位小数的 number，并返回该值
---@return number
function Float3.To(value)
    return floor(value * 1000) / 1000
end
local to = Float3.To


--


--- 根据角度，偏移指定距离（只计算 x 和 z）
---@param pos Vector3 @ 位置
---@param angle number @ 角度
---@param distance number @ 距离
---@param resultPos Vector3 @ -可选- 如果传入该值，偏移后的结果将会修改到该值，否则结果修改到参数 pos
function Float3.OffsetByAngle(pos, angle, distance, resultPos)
    resultPos = resultPos or pos
    local radian = RADIAN * angle
    local x = to(cos(radian))
    local z = to(sin(radian))
    x = to(distance * x)
    z = to(distance * z)
    resultPos.x = to(pos.x + x)
    resultPos.z = to(pos.z - z)
end


--

return Float3