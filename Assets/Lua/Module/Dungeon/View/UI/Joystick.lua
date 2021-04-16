--
-- 摇杆
-- 2018/1/31
-- Author LOLO
--

local max = math.max
local min = math.min
local sqrt = math.sqrt
local atan2 = math.atan2
local floor = math.floor
local abs = math.abs
local pi = math.pi

local JoystickEvent = require("Module.Dungeon.Model.JoystickEvent")

--

---@class Dungeon.Joystick : View
---@field New fun(go:UnityEngine.GameObject):Dungeon.Joystick
---
---@field lockAngle boolean @ 是否锁定摇杆，不能变换角度
---
---@field protected _radius number @ 可摇动半径
---
---@field protected _sight UnityEngine.Transform
---@field protected _container UnityEngine.Transform
---@field protected _canvasGroup UnityEngine.CanvasGroup
---
---@field protected _sightTweener DG.Tweening.Tweener
---@field protected _cgTweener DG.Tweening.Tweener
---
---@field protected _screenWidth number
---@field protected _screenHeight number
---@field protected _uiWidth number
---@field protected _uiHeight number
---
---@field protected _curPos Vector3
---@field protected _pointerId number
---@field protected _enabled boolean
---
---@field protected _angleTimer Timer
---@field protected _curAngle number
---@field protected _tarAngle number
---@field protected _moveing boolean @ 是否正在移动中
---
local Joystick = class("Dungeon.Joystick", View)

local tmpPos = Vector3.zero

local CHANGE_ANGLE_DELAY = 0.04 -- 变换角度间隔
local MAX_ANGLE = 360 -- 每次最多变换角度数
local KEYBOARD_ID = -999 -- 键盘输入时使用的 pointerId


--
function Joystick:Ctor(go)
    Joystick.super.Ctor(self)

    self.lockAngle = false
    self._radius = 45
    self._enabled = true
    self._curPos = Vector3.zero

    self._container = go.transform:Find("container")
    self._sight = self._container:Find("sight")
    self._canvasGroup = GetComponent.CanvasGroup(self._container.gameObject)

    self._screenWidth = Screen.width
    self._screenHeight = Screen.height
    local canvasRect = GetComponent.RectTransform(GameObject.Find("SceneUICanvas"))
    self._uiWidth = canvasRect.rect.width
    self._uiHeight = canvasRect.rect.height

    self._angleTimer = Timer.New(CHANGE_ANGLE_DELAY, NewHandler(self.AngleTimerHandler, self))
    self._curAngle = 0
    self._tarAngle = 0
    self._moveing = false

    self.gameObject = go
    self:OnInitialize()
    self:EnableDestroyListener()
end



--
function Joystick:AngleTimerHandler()
    local cur = self._curAngle
    local tar = self._tarAngle
    if cur == tar and self._pointerId ~= nil then
        return
    end

    local moveing = true

    -- 锁定了角度
    if self.lockAngle then
        -- 已松开摇杆
        if self._pointerId == nil then
            self._angleTimer:Stop()
            moveing = false
        end

    else
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

            self._curAngle = cur
        else
            self._curAngle = tar
            -- 已松开摇杆
            if self._pointerId == nil then
                self._angleTimer:Stop()
                moveing = false
            end
        end

        -- 变换角度
        self:DispatchJoystickEvent(JoystickEvent.ANGLE_CHANGED)
    end

    -- 移动状态有改变
    if moveing ~= self._moveing then
        self._moveing = moveing
        self:DispatchJoystickEvent(JoystickEvent.STATE_CHANGED)
    end
end



--
--- PointerEventHandler
---@param event PointerEvent
function Joystick:PointerEventHandler(event)
    local eventData = event.data --- @type UnityEngine.EventSystems.PointerEventData
    local p = eventData.position
    local x = p.x / self._screenWidth * self._uiWidth
    local y = p.y / self._screenHeight * self._uiHeight

    -- 按下
    if event.type == PointerEvent.DOWN then
        if self._pointerId ~= nil then
            return
        end

        self._pointerId = eventData.pointerId
        if self._sightTweener ~= nil then
            self._sightTweener:Kill(false)
        end

        self._curPos.x = min(max(x, 90), 370)
        self._curPos.y = min(max(y, 90), 240)
        self._container.localPosition = self._curPos

        self:Fade(true)
        AddEventListener(self.gameObject, DragDropEvent.DRAG, self.PointerEventHandler, self)
        AddEventListener(self.gameObject, PointerEvent.UP, self.PointerEventHandler, self)

    elseif event.type == PointerEvent.UP then
        -- 拖动结束
        if eventData.pointerId == self._pointerId then
            self:End()
            return
        end
    end

    -- 拖动中
    if eventData.pointerId ~= self._pointerId then
        return
    end

    x = x - self._curPos.x
    y = y - self._curPos.y
    if x == 0 and y == 0 then
        return
    end

    local angle = atan2(x, y) * 180 / pi
    if x < 0 then
        angle = angle + 360
    end
    self._tarAngle = floor(angle + 0.5)
    self._angleTimer:Start()

    local radius = sqrt(x * x + y * y)
    if radius > self._radius then
        local relativeThickness = self._radius / radius
        x = x * relativeThickness
        y = y * relativeThickness
    end

    tmpPos.x = x
    tmpPos.y = y
    self._sight.localPosition = tmpPos
end


--
--- 显示或逐渐隐藏（半透）
---@param fadeIn boolean
function Joystick:Fade(fadeIn)
    if self._cgTweener ~= nil then
        self._cgTweener:Kill(false)
    end

    if fadeIn then
        self._cgTweener = self._canvasGroup:DOFade(1, 0.2)
    else
        self._cgTweener = DOTween.Sequence()
        self._cgTweener:PrependInterval(0.8)
        self._cgTweener:Append(self._canvasGroup:DOFade(0.4, 0.3))
    end
end

--
--- 结束使用虚拟摇杆
function Joystick:End()
    self._pointerId = nil
    RemoveEventListener(self.gameObject, DragDropEvent.DRAG, self.PointerEventHandler, self)
    RemoveEventListener(self.gameObject, PointerEvent.UP, self.PointerEventHandler, self)
    if self._sightTweener ~= nil then
        self._sightTweener:Kill(false)
    end
    self._sightTweener = self._sight:DOLocalMove(Vector3.zero, 0.15)
    self:Fade(false)
end



--
--- Editor 环境下检测键盘输入
function Joystick:Update_Keyboard(event)
    if not self.visible then
        return
    end

    -- 已有 pointer event 在控制了
    if self._pointerId ~= nil and self._pointerId ~= KEYBOARD_ID then
        return
    end

    local up = Input.GetKey(KeyCode.W)
    local down = Input.GetKey(KeyCode.S)
    local left = Input.GetKey(KeyCode.A)
    local right = Input.GetKey(KeyCode.D)

    -- 按键互斥
    if up and down then
        up = false
        down = false
    end
    if left and right then
        left = false
        right = false
    end

    -- 没有键盘被按下
    if not up and not down and not left and not right then
        -- 结束使用键盘
        if self._pointerId == KEYBOARD_ID then
            self._pointerId = nil
            self._moveing = false
            self._angleTimer:Stop()
            self:DispatchJoystickEvent(JoystickEvent.STATE_CHANGED)
        end
        return
    end

    -- 根据键盘得出角度
    if up then
        if left then
            self._tarAngle = 315
        elseif right then
            self._tarAngle = 45
        else
            self._tarAngle = 0
        end
    elseif down then
        if left then
            self._tarAngle = 225
        elseif right then
            self._tarAngle = 135
        else
            self._tarAngle = 180
        end
    elseif left then
        self._tarAngle = 270
    else
        self._tarAngle = 90
    end

    -- 开始使用键盘
    if self._pointerId ~= KEYBOARD_ID then
        self._pointerId = KEYBOARD_ID
        self._moveing = true
        self._angleTimer:Start()
        self:DispatchJoystickEvent(JoystickEvent.STATE_CHANGED)
    end
end


--
--- 是否启用
---@param value boolean
function Joystick:SetEnabled(value)
    self._enabled = value
    if value and self.visible then
        AddEventListener(self.gameObject, PointerEvent.DOWN, self.PointerEventHandler, self)
        if isEditor then
            AddEventListener(Stage, Event.UPDATE, self.Update_Keyboard, self)
        end
    else
        RemoveEventListener(self.gameObject, PointerEvent.DOWN, self.PointerEventHandler, self)
        RemoveEventListener(Stage, Event.UPDATE, self.Update_Keyboard, self)
        self:End()
        if self._moveing then
            self._moveing = false
            self._angleTimer:Stop()
            self:DispatchJoystickEvent(JoystickEvent.STATE_CHANGED)
        end
    end
end

function Joystick:GetEnabled()
    return self._enabled
end



--
--- 抛出摇杆事件
function Joystick:DispatchJoystickEvent(type)
    ---@type Dungeon.Events.JoystickEvent
    local event = Event.Get(JoystickEvent, type)
    event.using = self._moveing
    event.angle = self._curAngle
    self:DispatchEvent(event)
end




--
function Joystick:OnShow()
    Joystick.super.OnShow(self)

    self:Fade(false)
    if self._enabled then
        self:SetEnabled(true)
    end
end

function Joystick:OnHide()
    Joystick.super.OnHide(self)

    if self._enabled then
        self:SetEnabled(true)
    end
end



--
function Joystick:OnDestroy()
    Joystick.super.OnDestroy(self)
    RemoveEventListener(Stage, Event.UPDATE, self.Update_Keyboard, self)
end



--
return Joystick