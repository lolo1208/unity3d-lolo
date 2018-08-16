--
-- 登录界面 pic 选择器 item
-- 2018/4/8
-- Author LOLO
--

local floor = math.floor
local random = math.random

local IOGameData = require("Module.IOGame.Model.IOGameData") ---@type IOGame.IOGameData

---@class IOGame.PicPickerItem : ItemRenderer
---@field New fun():IOGame.PicPickerItem
---
---@field transform UnityEngine.Transform
---@field aniGO UnityEngine.GameObject
---@field ani UnityEngine.Animation
---
local PicPickerItem = class("IOGame.PicPickerItem", ItemRenderer)

local POS = Vector3.New(0, -40, 0)
local EA = Vector3.New(0, 180, 0)
local SCALE = Vector3.New(70, 70, 70)
local ANIs = { "attack1", "attack2", "attack3", "block", "jump", "punch", "salute", "shot", "shot loop", "special" }

function PicPickerItem:OnInitialize()
    PicPickerItem.super.OnInitialize(self)

    self.transform = self.gameObject.transform
end

function PicPickerItem:Update(data, index)
    PicPickerItem.super.Update(self, data, index)

    self.aniGO = Instantiate("Prefabs/IOGame/dwarfs/dwarf_" .. data .. ".prefab", self.transform)
    self.ani = GetComponent.Animation(self.aniGO)

    local transform = self.aniGO.transform
    transform.localPosition = POS
    transform.localEulerAngles = EA
    transform.localScale = SCALE
end

function PicPickerItem:SetSelected(value)
    PicPickerItem.super.SetSelected(self, value)

    if value then
        self.ani:Play(ANIs[floor(random(#ANIs))])
    else
        self.ani:Play("idle")
    end
end

function PicPickerItem:OnRecycle()
    Destroy(self.aniGO)
end

return PicPickerItem