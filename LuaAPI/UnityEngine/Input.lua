---@class UnityEngine.Input : object
---@field compensateSensors bool
---@field gyro UnityEngine.Gyroscope
---@field mousePosition UnityEngine.Vector3
---@field mouseScrollDelta UnityEngine.Vector2
---@field mousePresent bool
---@field simulateMouseWithTouches bool
---@field anyKey bool
---@field anyKeyDown bool
---@field inputString string
---@field acceleration UnityEngine.Vector3
---@field accelerationEvents table
---@field accelerationEventCount int
---@field touches table
---@field touchCount int
---@field touchPressureSupported bool
---@field stylusTouchSupported bool
---@field touchSupported bool
---@field multiTouchEnabled bool
---@field location UnityEngine.LocationService
---@field compass UnityEngine.Compass
---@field deviceOrientation UnityEngine.DeviceOrientation
---@field imeCompositionMode UnityEngine.IMECompositionMode
---@field compositionString string
---@field imeIsSelected bool
---@field compositionCursorPos UnityEngine.Vector2
---@field backButtonLeavesApp bool
local m = {}
---@param axisName string
---@return float
function m.GetAxis(axisName) end
---@param axisName string
---@return float
function m.GetAxisRaw(axisName) end
---@param buttonName string
---@return bool
function m.GetButton(buttonName) end
---@param buttonName string
---@return bool
function m.GetButtonDown(buttonName) end
---@param buttonName string
---@return bool
function m.GetButtonUp(buttonName) end
---@overload fun(key:UnityEngine.KeyCode):bool
---@param name string
---@return bool
function m.GetKey(name) end
---@overload fun(key:UnityEngine.KeyCode):bool
---@param name string
---@return bool
function m.GetKeyDown(name) end
---@overload fun(key:UnityEngine.KeyCode):bool
---@param name string
---@return bool
function m.GetKeyUp(name) end
---@return table
function m.GetJoystickNames() end
---@param button int
---@return bool
function m.GetMouseButton(button) end
---@param button int
---@return bool
function m.GetMouseButtonDown(button) end
---@param button int
---@return bool
function m.GetMouseButtonUp(button) end
function m.ResetInputAxes() end
---@param index int
---@return UnityEngine.AccelerationEvent
function m.GetAccelerationEvent(index) end
---@param index int
---@return UnityEngine.Touch
function m.GetTouch(index) end
UnityEngine = {}
UnityEngine.Input = m
return m