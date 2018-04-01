---@class DG.Tweening.DOVirtual
local m = {}
---@param from float
---@param to float
---@param duration float
---@param onVirtualUpdate DG.Tweening.TweenCallback
---@return DG.Tweening.Tweener
function m.Float(from, to, duration, onVirtualUpdate) end
---@overload fun(from:float, to:float, lifetimePercentage:float, easeType:DG.Tweening.Ease, overshoot:float):float
---@overload fun(from:float, to:float, lifetimePercentage:float, easeType:DG.Tweening.Ease, amplitude:float, period:float):float
---@overload fun(from:float, to:float, lifetimePercentage:float, easeCurve:UnityEngine.AnimationCurve):float
---@param from float
---@param to float
---@param lifetimePercentage float
---@param easeType DG.Tweening.Ease
---@return float
function m.EasedValue(from, to, lifetimePercentage, easeType) end
---@param delay float
---@param callback DG.Tweening.TweenCallback
---@param ignoreTimeScale bool
---@return DG.Tweening.Tween
function m.DelayedCall(delay, callback, ignoreTimeScale) end
DG = {}
DG.Tweening = {}
DG.Tweening.DOVirtual = m
return m