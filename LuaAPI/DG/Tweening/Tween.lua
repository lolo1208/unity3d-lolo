---@class DG.Tweening.Tween : object
---@field fullPosition float
---@field timeScale float
---@field isBackwards bool
---@field id object
---@field target object
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
return m