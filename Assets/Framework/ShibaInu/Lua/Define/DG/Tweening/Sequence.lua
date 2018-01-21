---@class DG.Tweening.Sequence : DG.Tweening.Tween
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
---@param t DG.Tweening.Tween
---@return DG.Tweening.Sequence
function m:Append(t) end
---@param t DG.Tweening.Tween
---@return DG.Tweening.Sequence
function m:Prepend(t) end
---@param t DG.Tweening.Tween
---@return DG.Tweening.Sequence
function m:Join(t) end
---@param atPosition float
---@param t DG.Tweening.Tween
---@return DG.Tweening.Sequence
function m:Insert(atPosition, t) end
---@param interval float
---@return DG.Tweening.Sequence
function m:AppendInterval(interval) end
---@param interval float
---@return DG.Tweening.Sequence
function m:PrependInterval(interval) end
---@param callback DG.Tweening.TweenCallback
---@return DG.Tweening.Sequence
function m:AppendCallback(callback) end
---@param callback DG.Tweening.TweenCallback
---@return DG.Tweening.Sequence
function m:PrependCallback(callback) end
---@param atPosition float
---@param callback DG.Tweening.TweenCallback
---@return DG.Tweening.Sequence
function m:InsertCallback(atPosition, callback) end
DG = {}
DG.Tweening = {}
DG.Tweening.Sequence = m
return m