---@class DG.Tweening.EaseFactory : object
local m = {}
---@overload fun(motionFps:int, animCurve:UnityEngine.AnimationCurve):DG.Tweening.EaseFunction
---@overload fun(motionFps:int, customEase:DG.Tweening.EaseFunction):DG.Tweening.EaseFunction
---@param motionFps int
---@param ease System.Nullable
---@return DG.Tweening.EaseFunction
function m.StopMotion(motionFps, ease) end
DG = {}
DG.Tweening = {}
DG.Tweening.EaseFactory = m
return m