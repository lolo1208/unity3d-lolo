---@class DG.Tweening.Tween : object
---@field fullPosition float
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
---@overload fun(withCallbacks:bool):void
function m:Complete() end
function m:Flip() end
function m:ForceInit() end
---@param to float
---@param andPlay bool
function m:Goto(to, andPlay) end
---@param complete bool
function m:Kill(complete) end
function m:PlayBackwards() end
function m:PlayForward() end
---@param includeDelay bool
---@param changeDelayTo float
function m:Restart(includeDelay, changeDelayTo) end
---@param includeDelay bool
function m:Rewind(includeDelay) end
function m:SmoothRewind() end
function m:TogglePause() end
---@param waypointIndex int
---@param andPlay bool
function m:GotoWaypoint(waypointIndex, andPlay) end
---@return UnityEngine.YieldInstruction
function m:WaitForCompletion() end
---@return UnityEngine.YieldInstruction
function m:WaitForRewind() end
---@return UnityEngine.YieldInstruction
function m:WaitForKill() end
---@param elapsedLoops int
---@return UnityEngine.YieldInstruction
function m:WaitForElapsedLoops(elapsedLoops) end
---@param position float
---@return UnityEngine.YieldInstruction
function m:WaitForPosition(position) end
---@return UnityEngine.Coroutine
function m:WaitForStart() end
---@return int
function m:CompletedLoops() end
---@return float
function m:Delay() end
---@param includeLoops bool
---@return float
function m:Duration(includeLoops) end
---@param includeLoops bool
---@return float
function m:Elapsed(includeLoops) end
---@param includeLoops bool
---@return float
function m:ElapsedPercentage(includeLoops) end
---@return float
function m:ElapsedDirectionalPercentage() end
---@return bool
function m:IsActive() end
---@return bool
function m:IsBackwards() end
---@return bool
function m:IsComplete() end
---@return bool
function m:IsInitialized() end
---@return bool
function m:IsPlaying() end
---@return int
function m:Loops() end
---@param pathPercentage float
---@return UnityEngine.Vector3
function m:PathGetPoint(pathPercentage) end
---@param subdivisionsXSegment int
---@return table
function m:PathGetDrawPoints(subdivisionsXSegment) end
---@return float
function m:PathLength() end
DG = {}
DG.Tweening = {}
DG.Tweening.Tween = m



-- http://dotween.demigiant.com/documentation.php#tweenerSequenceSettings
-- Chained settings

---@param tweenParams TweenParams
---@return DG.Tweening.Tween
function m:SetAs(pathPercentage) end

---@param optional autoKillOnCompletion boolean @ default : true
---@return DG.Tweening.Tween
function m:SetAutoKill(autoKillOnCompletion) end

---@param optional easeType DG.Tweening.Ease
---@return DG.Tweening.Tween
function m:SetEase(easeType) end

---@param id string
---@return DG.Tweening.Tween
function m:SetId(id) end

---@param loops int
---@param optional loopType DG.Tweening.LoopType @ default : DG.Tweening.LoopType.Restart
---@return DG.Tweening.Tween
function m:SetLoops(loops, loopType) end

---@param recyclable boolean
---@return DG.Tweening.Tween
function m:SetRecyclable(recyclable) end

---@param optional isRelative boolean @ default : true
---@return DG.Tweening.Tween
function m:SetRelative(isRelative) end

---@param updateType DG.Tweening.UpdateType
---@param optional isIndependentUpdate boolean @ default : false
---@return DG.Tweening.Tween
function m:SetUpdate(updateType, isIndependentUpdate) end


-- Chained callbacks

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnComplete(callback) end

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnKill(callback) end

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnPlay(callback) end

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnPause(callback) end

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnRewind(callback) end

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnStart(callback) end

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnStepComplete(callback) end

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnUpdate(callback) end

---@param callback fun()
---@return DG.Tweening.Tween
function m:OnWaypointChange(callback) end



return m