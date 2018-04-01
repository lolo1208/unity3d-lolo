---@class DG.Tweening.Tweener : DG.Tweening.Tween
---@field timeScale float
---@field isBackwards bool
---@field id object
---@field target object
---@field easeOvershootOrAmplitude float
---@field easePeriod float
local m = {}
---@param newStartValue object
---@param newDuration float
---@return DG.Tweening.Tweener
function m:ChangeStartValue(newStartValue, newDuration) end
---@overload fun(newEndValue:object, snapStartValue:bool):DG.Tweening.Tweener
---@param newEndValue object
---@param newDuration float
---@param snapStartValue bool
---@return DG.Tweening.Tweener
function m:ChangeEndValue(newEndValue, newDuration, snapStartValue) end
---@param newStartValue object
---@param newEndValue object
---@param newDuration float
---@return DG.Tweening.Tweener
function m:ChangeValues(newStartValue, newEndValue, newDuration) end
DG = {}
DG.Tweening = {}
DG.Tweening.Tweener = m
return m