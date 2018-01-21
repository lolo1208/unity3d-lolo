---@class DG.Tweening.Tweener : DG.Tweening.Tween
---@field timeScale float
---@field isBackwards bool
---@field id object
---@field target object
---@field onPlay DG.Tweening.TweenCallback
---@field onPause DG.Tweening.TweenCallback
---@field onRewind DG.Tweening.TweenCallback
---@field onUpdate DG.Tweening.TweenCallback
---@field onStepComplete DG.Tweening.TweenCallback
---@field onComplete DG.Tweening.TweenCallback
---@field onKill DG.Tweening.TweenCallback
---@field onWaypointChange DG.Tweening.TweenCallback
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



-- specific settings and options
-- http://dotween.demigiant.com/documentation.php#specificSettings

---@param optional isRelative boolean @ default : false
---@return DG.Tweening.Tween
function m:From(isRelative) end

---@param delay float
---@return DG.Tweening.Tween
function m:SetDelay(isRelative) end

---@param optional isSpeedBased boolean @ default : true
---@return DG.Tweening.Tween
function m:SetSpeedBased(isRelative) end

---@param ... any[]
---@return DG.Tweening.Tween
function m:SetOptions(...) end



return m