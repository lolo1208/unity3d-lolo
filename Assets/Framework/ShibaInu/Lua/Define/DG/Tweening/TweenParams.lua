---@class DG.Tweening.TweenParams : object
---@field Params DG.Tweening.TweenParams
local m = {}
---@return DG.Tweening.TweenParams
function m:Clear() end
---@param autoKillOnCompletion bool
---@return DG.Tweening.TweenParams
function m:SetAutoKill(autoKillOnCompletion) end
---@param id object
---@return DG.Tweening.TweenParams
function m:SetId(id) end
---@param target object
---@return DG.Tweening.TweenParams
function m:SetTarget(target) end
---@param loops int
---@param loopType System.Nullable
---@return DG.Tweening.TweenParams
function m:SetLoops(loops, loopType) end
---@overload fun(animCurve:UnityEngine.AnimationCurve):DG.Tweening.TweenParams
---@overload fun(customEase:DG.Tweening.EaseFunction):DG.Tweening.TweenParams
---@param ease DG.Tweening.Ease
---@param overshootOrAmplitude System.Nullable
---@param period System.Nullable
---@return DG.Tweening.TweenParams
function m:SetEase(ease, overshootOrAmplitude, period) end
---@param recyclable bool
---@return DG.Tweening.TweenParams
function m:SetRecyclable(recyclable) end
---@overload fun(updateType:DG.Tweening.UpdateType, isIndependentUpdate:bool):DG.Tweening.TweenParams
---@param isIndependentUpdate bool
---@return DG.Tweening.TweenParams
function m:SetUpdate(isIndependentUpdate) end
---@param action DG.Tweening.TweenCallback
---@return DG.Tweening.TweenParams
function m:OnStart(action) end
---@param action DG.Tweening.TweenCallback
---@return DG.Tweening.TweenParams
function m:OnPlay(action) end
---@param action DG.Tweening.TweenCallback
---@return DG.Tweening.TweenParams
function m:OnRewind(action) end
---@param action DG.Tweening.TweenCallback
---@return DG.Tweening.TweenParams
function m:OnUpdate(action) end
---@param action DG.Tweening.TweenCallback
---@return DG.Tweening.TweenParams
function m:OnStepComplete(action) end
---@param action DG.Tweening.TweenCallback
---@return DG.Tweening.TweenParams
function m:OnComplete(action) end
---@param action DG.Tweening.TweenCallback
---@return DG.Tweening.TweenParams
function m:OnKill(action) end
---@param action DG.Tweening.TweenCallback
---@return DG.Tweening.TweenParams
function m:OnWaypointChange(action) end
---@param delay float
---@return DG.Tweening.TweenParams
function m:SetDelay(delay) end
---@param isRelative bool
---@return DG.Tweening.TweenParams
function m:SetRelative(isRelative) end
---@param isSpeedBased bool
---@return DG.Tweening.TweenParams
function m:SetSpeedBased(isSpeedBased) end
DG = {}
DG.Tweening = {}
DG.Tweening.TweenParams = m
return m