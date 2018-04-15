--
-- 角色
-- 2018/2/1
-- Author LOLO
--

local abs = math.abs

local IOGameData = require("Module.IOGame.Model.IOGameData")

---@class IOGame.Avatar : View
---@field New fun(data:IOGame.FrameData.NewAvatar):IOGame.Avatar
---
---@field state IOGame.FSM.FSM
---@field action IOGame.FSM.FSM
---@field canMove boolean @ 由 action 控制是否可以移动
---
---@field transform UnityEngine.Transform
---@field isSelf boolean @ 是否为玩家自己
---@field id number
---@field name string
---@field pic string
---
---@field position Vector3 @ 当前位置
---@field moveing number @ [ 0:停止, 1:移动中 ]
---@field angle number @ 当前角度
---@field angle3 Vector3 @ 当前角度 Vector3 对象
---
---@field map IOGame.Map
---@field ani UnityEngine.Animation
---
local Avatar = class("IOGame.Avatar", View)

local MAX_ANGLE = 5

---Ctor
---@param map IOGame.Map
---@param data IOGame.FrameData.NewAvatar
function Avatar:Ctor(map, data)
    Avatar.super.Ctor(self)

    self.canMove = true

    self.map = map
    self.isSelf = data.id == IOGameData.playerID
    self.id = data.id
    self.name = data.name
    self.pic = data.pic

    self.gameObject = CreateGameObject(data.name, map.avatarC, true)
    self.transform = self.gameObject.transform

    local go = Instantiate("Prefabs/IOGame/dwarfs/dwarf_" .. data.pic .. ".prefab", self.transform, IOGameData.NAME)
    self.ani = GetComponent.Animation(go)

    self.position = Vector3.New(data.x, 0, data.z)
    self.transform.localPosition = self.position

    self.angle3 = Vector3.New(0, 270, 0)
    self:SetAngle(data.angle)

    self:OnInitialize()
    self:EnableDestroyListener()
end


--

function Avatar:SetAngle(value)
    self.angle = value
    AddEventListener(Stage, Event.UPDATE, self.ChangeAngle, self)
    self:ChangeAngle()
end

function Avatar:ChangeAngle(event)
    local cur = self.angle3.y - 90
    local tar = self.angle

    local ofs = abs(tar - cur)
    if ofs > MAX_ANGLE then
        local add = tar > cur
        if add then
            add = ofs < 180
        else
            add = ofs > 180
        end
        if add then
            cur = cur + MAX_ANGLE
        else
            cur = cur - MAX_ANGLE
        end

        if cur < 0 then
            cur = cur + 360
        elseif cur > 360 then
            cur = cur - 360
        end
    else
        cur = tar
    end

    if cur == tar then
        RemoveEventListener(Stage, Event.UPDATE, self.ChangeAngle, self)
    end

    self.angle3.y = cur + 90
    self.transform.localEulerAngles = self.angle3
end

--


function Avatar:SetMoveing(value)
    self.moveing = value
end



--

function Avatar:OnDestroy()
    RemoveEventListener(Stage, Event.UPDATE, self.ChangeAngle, self)
    self.state:Transition()
    self.action:Transition()
end


--


return Avatar