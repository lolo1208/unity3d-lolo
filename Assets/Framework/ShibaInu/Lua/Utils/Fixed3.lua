--
-- 只保留三位小数的 Vector3 对象
-- 2019/6/29
-- Author LOLO
--

local type = type
local setmetatable = setmetatable
local floor = math.floor


--
---@class Fixed3
---
---@field x number
---@field y number
---@field z number
---
local Fixed3 = {}



-- [ static] --

--
---@return Fixed3 | number
function Fixed3.Fix3(x, y, z)
    if y == nil then
        x.x = floor(x.x * 1000) / 1000
        x.y = floor(x.y * 1000) / 1000
        x.z = floor(x.z * 1000) / 1000
        return x
    end

    return floor(x * 1000) / 1000, floor(y * 1000) / 1000, floor(z * 1000) / 1000
end
local fix3 = Fixed3.Fix3


--
---@return number
function Fixed3.FixVal(val)
    return floor(val * 1000) / 1000
end
local fixVal = Fixed3.FixVal


--
---@return Fixed3
function Fixed3.New(x, y, z)
    local val3
    if x == nil or type(x) == "number" then
        val3 = { x = x or 0, y = y or 0, z = z or 0 }
    else
        val3 = { x = x.x, y = x.y, z = x.z }
    end
    setmetatable(fix3(val3), Fixed3)
    return val3
end
local new = Fixed3.New


--
function Fixed3.up()
    return new(0, 1, 0)
end
function Fixed3.down()
    return new(0, -1, 0)
end
function Fixed3.right()
    return new(1, 0, 0)
end
function Fixed3.left()
    return new(-1, 0, 0)
end
function Fixed3.forward()
    return new(0, 0, 1)
end
function Fixed3.back()
    return new(0, 0, -1)
end
function Fixed3.zero()
    return new(0, 0, 0)
end
function Fixed3.one()
    return new(1, 1, 1)
end

-- --



-- [ operators ] --
-- 运算的结果都会直接赋值给 va，并返回 va

Fixed3.__add = function(va, vb)
    va.x = va.x + vb.x
    va.y = va.y + vb.y
    va.z = va.z + vb.z
    return fix3(va)
end

Fixed3.__sub = function(va, vb)
    va.x = va.x - vb.x
    va.y = va.y - vb.y
    va.z = va.z - vb.z
    return fix3(va)
end

Fixed3.__mul = function(va, d)
    va.x = va.x * d
    va.y = va.y * d
    va.z = va.z * d
    return fix3(va)
end

Fixed3.__div = function(va, d)
    va.x = va.x / d
    va.y = va.y / d
    va.z = va.z / d
    return fix3(va)
end

Fixed3.__unm = function(va)
    va.x = -va.x
    va.y = -va.y
    va.z = -va.z
    return va
end

Fixed3.__eq = function(va, vb)
    return va.x == vb.x and va.y == vb.y and va.z == vb.z
end

Fixed3.__tostring = function(self)
    return "[" .. self.x .. ", " .. self.y .. ", " .. self.z .. "]"
end

Fixed3.__index = Fixed3

-- --



-- [ public ] --

--
function Fixed3:Set(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    fix3(self)
end


--
function Fixed3:Set3(v)
    self.x = v.x
    self.y = v.y
    self.z = v.z
    fix3(self)
end


--
function Fixed3:FixSelf()
    fix3(self)
end


--
function Fixed3:Clone()
    return setmetatable({ x = self.x, y = self.y, z = self.z }, Fixed3)
end



--
return Fixed3
