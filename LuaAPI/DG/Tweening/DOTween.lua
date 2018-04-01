---@class DG.Tweening.DOTween : object
---@field logBehaviour DG.Tweening.LogBehaviour
---@field Version string
---@field useSafeMode bool
---@field showUnityEditorReport bool
---@field timeScale float
---@field useSmoothDeltaTime bool
---@field maxSmoothUnscaledTime float
---@field drawGizmos bool
---@field defaultUpdateType DG.Tweening.UpdateType
---@field defaultTimeScaleIndependent bool
---@field defaultAutoPlay DG.Tweening.AutoPlay
---@field defaultAutoKill bool
---@field defaultLoopType DG.Tweening.LoopType
---@field defaultRecyclable bool
---@field defaultEaseType DG.Tweening.Ease
---@field defaultEaseOvershootOrAmplitude float
---@field defaultEasePeriod float
local m = {}
---@param recycleAllByDefault System.Nullable
---@param useSafeMode System.Nullable
---@param logBehaviour System.Nullable
---@return DG.Tweening.IDOTweenInit
function m.Init(recycleAllByDefault, useSafeMode, logBehaviour) end
---@param tweenersCapacity int
---@param sequencesCapacity int
function m.SetTweensCapacity(tweenersCapacity, sequencesCapacity) end
---@param destroy bool
function m.Clear(destroy) end
function m.ClearCachedTweens() end
---@return int
function m.Validate() end
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:double, duration:float):DG.Tweening.Core.TweenerCore
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:int, duration:float):DG.Tweening.Tweener
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:uint, duration:float):DG.Tweening.Tweener
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:long, duration:float):DG.Tweening.Tweener
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:ulong, duration:float):DG.Tweening.Tweener
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:string, duration:float):DG.Tweening.Core.TweenerCore
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:UnityEngine.Vector2, duration:float):DG.Tweening.Core.TweenerCore
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:UnityEngine.Vector3, duration:float):DG.Tweening.Core.TweenerCore
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:UnityEngine.Vector4, duration:float):DG.Tweening.Core.TweenerCore
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:UnityEngine.Vector3, duration:float):DG.Tweening.Core.TweenerCore
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:UnityEngine.Color, duration:float):DG.Tweening.Core.TweenerCore
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:UnityEngine.Rect, duration:float):DG.Tweening.Core.TweenerCore
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, endValue:UnityEngine.RectOffset, duration:float):DG.Tweening.Tweener
---@overload fun(setter:DG.Tweening.Core.DOSetter, startValue:float, endValue:float, duration:float):DG.Tweening.Tweener
---@param getter DG.Tweening.Core.DOGetter
---@param setter DG.Tweening.Core.DOSetter
---@param endValue float
---@param duration float
---@return DG.Tweening.Core.TweenerCore
function m.To(getter, setter, endValue, duration) end
---@param getter DG.Tweening.Core.DOGetter
---@param setter DG.Tweening.Core.DOSetter
---@param endValue float
---@param duration float
---@param axisConstraint DG.Tweening.AxisConstraint
---@return DG.Tweening.Core.TweenerCore
function m.ToAxis(getter, setter, endValue, duration, axisConstraint) end
---@param getter DG.Tweening.Core.DOGetter
---@param setter DG.Tweening.Core.DOSetter
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m.ToAlpha(getter, setter, endValue, duration) end
---@param getter DG.Tweening.Core.DOGetter
---@param setter DG.Tweening.Core.DOSetter
---@param direction UnityEngine.Vector3
---@param duration float
---@param vibrato int
---@param elasticity float
---@return DG.Tweening.Core.TweenerCore
function m.Punch(getter, setter, direction, duration, vibrato, elasticity) end
---@overload fun(getter:DG.Tweening.Core.DOGetter, setter:DG.Tweening.Core.DOSetter, duration:float, strength:UnityEngine.Vector3, vibrato:int, randomness:float, fadeOut:bool):DG.Tweening.Core.TweenerCore
---@param getter DG.Tweening.Core.DOGetter
---@param setter DG.Tweening.Core.DOSetter
---@param duration float
---@param strength float
---@param vibrato int
---@param randomness float
---@param ignoreZAxis bool
---@param fadeOut bool
---@return DG.Tweening.Core.TweenerCore
function m.Shake(getter, setter, duration, strength, vibrato, randomness, ignoreZAxis, fadeOut) end
---@param getter DG.Tweening.Core.DOGetter
---@param setter DG.Tweening.Core.DOSetter
---@param endValues table
---@param durations table
---@return DG.Tweening.Core.TweenerCore
function m.ToArray(getter, setter, endValues, durations) end
---@return DG.Tweening.Sequence
function m.Sequence() end
---@param withCallbacks bool
---@return int
function m.CompleteAll(withCallbacks) end
---@param targetOrId object
---@param withCallbacks bool
---@return int
function m.Complete(targetOrId, withCallbacks) end
---@return int
function m.FlipAll() end
---@param targetOrId object
---@return int
function m.Flip(targetOrId) end
---@param to float
---@param andPlay bool
---@return int
function m.GotoAll(to, andPlay) end
---@param targetOrId object
---@param to float
---@param andPlay bool
---@return int
function m.Goto(targetOrId, to, andPlay) end
---@overload fun(complete:bool, idsOrTargetsToExclude:table):int
---@param complete bool
---@return int
function m.KillAll(complete) end
---@param targetOrId object
---@param complete bool
---@return int
function m.Kill(targetOrId, complete) end
---@return int
function m.PauseAll() end
---@param targetOrId object
---@return int
function m.Pause(targetOrId) end
---@return int
function m.PlayAll() end
---@overload fun(target:object, id:object):int
---@param targetOrId object
---@return int
function m.Play(targetOrId) end
---@return int
function m.PlayBackwardsAll() end
---@overload fun(target:object, id:object):int
---@param targetOrId object
---@return int
function m.PlayBackwards(targetOrId) end
---@return int
function m.PlayForwardAll() end
---@overload fun(target:object, id:object):int
---@param targetOrId object
---@return int
function m.PlayForward(targetOrId) end
---@param includeDelay bool
---@return int
function m.RestartAll(includeDelay) end
---@overload fun(target:object, id:object, includeDelay:bool, changeDelayTo:float):int
---@param targetOrId object
---@param includeDelay bool
---@param changeDelayTo float
---@return int
function m.Restart(targetOrId, includeDelay, changeDelayTo) end
---@param includeDelay bool
---@return int
function m.RewindAll(includeDelay) end
---@param targetOrId object
---@param includeDelay bool
---@return int
function m.Rewind(targetOrId, includeDelay) end
---@return int
function m.SmoothRewindAll() end
---@param targetOrId object
---@return int
function m.SmoothRewind(targetOrId) end
---@return int
function m.TogglePauseAll() end
---@param targetOrId object
---@return int
function m.TogglePause(targetOrId) end
---@param targetOrId object
---@param alsoCheckIfIsPlaying bool
---@return bool
function m.IsTweening(targetOrId, alsoCheckIfIsPlaying) end
---@return int
function m.TotalPlayingTweens() end
---@return table
function m.PlayingTweens() end
---@return table
function m.PausedTweens() end
---@param id object
---@param playingOnly bool
---@return table
function m.TweensById(id, playingOnly) end
---@param target object
---@param playingOnly bool
---@return table
function m.TweensByTarget(target, playingOnly) end
DG = {}
DG.Tweening = {}
DG.Tweening.DOTween = m
return m