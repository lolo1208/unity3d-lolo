--
-- 数学运算相关工具类
-- 2018/2/6
-- Author LOLO
--

local atan2 = math.atan2
local pi = math.pi


--


---@class MathUtil
local MathUtil = {}


--
function MathUtil.Angle(p1, p2)
    local x = p2.x - p1.x
    local z = p2.z - p1.z
    local angle = atan2(z, -x) * 180 / pi
    if z < 0 then
        angle = angle + 360
    end
    return angle
end


--
return MathUtil