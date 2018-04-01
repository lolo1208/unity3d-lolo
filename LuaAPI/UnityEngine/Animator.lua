---@class UnityEngine.Animator : UnityEngine.Behaviour
---@field isOptimizable bool
---@field isHuman bool
---@field hasRootMotion bool
---@field humanScale float
---@field isInitialized bool
---@field deltaPosition UnityEngine.Vector3
---@field deltaRotation UnityEngine.Quaternion
---@field velocity UnityEngine.Vector3
---@field angularVelocity UnityEngine.Vector3
---@field rootPosition UnityEngine.Vector3
---@field rootRotation UnityEngine.Quaternion
---@field applyRootMotion bool
---@field linearVelocityBlending bool
---@field updateMode UnityEngine.AnimatorUpdateMode
---@field hasTransformHierarchy bool
---@field gravityWeight float
---@field bodyPosition UnityEngine.Vector3
---@field bodyRotation UnityEngine.Quaternion
---@field stabilizeFeet bool
---@field layerCount int
---@field parameters table
---@field parameterCount int
---@field feetPivotActive float
---@field pivotWeight float
---@field pivotPosition UnityEngine.Vector3
---@field isMatchingTarget bool
---@field speed float
---@field targetPosition UnityEngine.Vector3
---@field targetRotation UnityEngine.Quaternion
---@field cullingMode UnityEngine.AnimatorCullingMode
---@field playbackTime float
---@field recorderStartTime float
---@field recorderStopTime float
---@field recorderMode UnityEngine.AnimatorRecorderMode
---@field runtimeAnimatorController UnityEngine.RuntimeAnimatorController
---@field hasBoundPlayables bool
---@field avatar UnityEngine.Avatar
---@field playableGraph UnityEngine.Playables.PlayableGraph
---@field layersAffectMassCenter bool
---@field leftFeetBottomHeight float
---@field rightFeetBottomHeight float
---@field logWarnings bool
---@field fireEvents bool
local m = {}
---@overload fun(id:int):float
---@param name string
---@return float
function m:GetFloat(name) end
---@overload fun(name:string, value:float, dampTime:float, deltaTime:float):void
---@overload fun(id:int, value:float):void
---@overload fun(id:int, value:float, dampTime:float, deltaTime:float):void
---@param name string
---@param value float
function m:SetFloat(name, value) end
---@overload fun(id:int):bool
---@param name string
---@return bool
function m:GetBool(name) end
---@overload fun(id:int, value:bool):void
---@param name string
---@param value bool
function m:SetBool(name, value) end
---@overload fun(id:int):int
---@param name string
---@return int
function m:GetInteger(name) end
---@overload fun(id:int, value:int):void
---@param name string
---@param value int
function m:SetInteger(name, value) end
---@overload fun(id:int):void
---@param name string
function m:SetTrigger(name) end
---@overload fun(id:int):void
---@param name string
function m:ResetTrigger(name) end
---@overload fun(id:int):bool
---@param name string
---@return bool
function m:IsParameterControlledByCurve(name) end
---@param goal UnityEngine.AvatarIKGoal
---@return UnityEngine.Vector3
function m:GetIKPosition(goal) end
---@param goal UnityEngine.AvatarIKGoal
---@param goalPosition UnityEngine.Vector3
function m:SetIKPosition(goal, goalPosition) end
---@param goal UnityEngine.AvatarIKGoal
---@return UnityEngine.Quaternion
function m:GetIKRotation(goal) end
---@param goal UnityEngine.AvatarIKGoal
---@param goalRotation UnityEngine.Quaternion
function m:SetIKRotation(goal, goalRotation) end
---@param goal UnityEngine.AvatarIKGoal
---@return float
function m:GetIKPositionWeight(goal) end
---@param goal UnityEngine.AvatarIKGoal
---@param value float
function m:SetIKPositionWeight(goal, value) end
---@param goal UnityEngine.AvatarIKGoal
---@return float
function m:GetIKRotationWeight(goal) end
---@param goal UnityEngine.AvatarIKGoal
---@param value float
function m:SetIKRotationWeight(goal, value) end
---@param hint UnityEngine.AvatarIKHint
---@return UnityEngine.Vector3
function m:GetIKHintPosition(hint) end
---@param hint UnityEngine.AvatarIKHint
---@param hintPosition UnityEngine.Vector3
function m:SetIKHintPosition(hint, hintPosition) end
---@param hint UnityEngine.AvatarIKHint
---@return float
function m:GetIKHintPositionWeight(hint) end
---@param hint UnityEngine.AvatarIKHint
---@param value float
function m:SetIKHintPositionWeight(hint, value) end
---@param lookAtPosition UnityEngine.Vector3
function m:SetLookAtPosition(lookAtPosition) end
---@overload fun(weight:float, bodyWeight:float, headWeight:float):void
---@overload fun(weight:float, bodyWeight:float):void
---@overload fun(weight:float):void
---@overload fun(weight:float, bodyWeight:float, headWeight:float, eyesWeight:float, clampWeight:float):void
---@param weight float
---@param bodyWeight float
---@param headWeight float
---@param eyesWeight float
function m:SetLookAtWeight(weight, bodyWeight, headWeight, eyesWeight) end
---@param humanBoneId UnityEngine.HumanBodyBones
---@param rotation UnityEngine.Quaternion
function m:SetBoneLocalRotation(humanBoneId, rotation) end
---@param fullPathHash int
---@param layerIndex int
---@return table
function m:GetBehaviours(fullPathHash, layerIndex) end
---@param layerIndex int
---@return string
function m:GetLayerName(layerIndex) end
---@param layerName string
---@return int
function m:GetLayerIndex(layerName) end
---@param layerIndex int
---@return float
function m:GetLayerWeight(layerIndex) end
---@param layerIndex int
---@param weight float
function m:SetLayerWeight(layerIndex, weight) end
---@param layerIndex int
---@return UnityEngine.AnimatorStateInfo
function m:GetCurrentAnimatorStateInfo(layerIndex) end
---@param layerIndex int
---@return UnityEngine.AnimatorStateInfo
function m:GetNextAnimatorStateInfo(layerIndex) end
---@param layerIndex int
---@return UnityEngine.AnimatorTransitionInfo
function m:GetAnimatorTransitionInfo(layerIndex) end
---@param layerIndex int
---@return int
function m:GetCurrentAnimatorClipInfoCount(layerIndex) end
---@overload fun(layerIndex:int, clips:table):void
---@param layerIndex int
---@return table
function m:GetCurrentAnimatorClipInfo(layerIndex) end
---@param layerIndex int
---@return int
function m:GetNextAnimatorClipInfoCount(layerIndex) end
---@overload fun(layerIndex:int, clips:table):void
---@param layerIndex int
---@return table
function m:GetNextAnimatorClipInfo(layerIndex) end
---@param layerIndex int
---@return bool
function m:IsInTransition(layerIndex) end
---@param index int
---@return UnityEngine.AnimatorControllerParameter
function m:GetParameter(index) end
---@overload fun(matchPosition:UnityEngine.Vector3, matchRotation:UnityEngine.Quaternion, targetBodyPart:UnityEngine.AvatarTarget, weightMask:UnityEngine.MatchTargetWeightMask, startNormalizedTime:float):void
---@param matchPosition UnityEngine.Vector3
---@param matchRotation UnityEngine.Quaternion
---@param targetBodyPart UnityEngine.AvatarTarget
---@param weightMask UnityEngine.MatchTargetWeightMask
---@param startNormalizedTime float
---@param targetNormalizedTime float
function m:MatchTarget(matchPosition, matchRotation, targetBodyPart, weightMask, startNormalizedTime, targetNormalizedTime) end
---@overload fun():void
---@param completeMatch bool
function m:InterruptMatchTarget(completeMatch) end
---@overload fun(stateName:string, transitionDuration:float):void
---@overload fun(stateName:string, transitionDuration:float, layer:int, fixedTime:float):void
---@overload fun(stateNameHash:int, transitionDuration:float, layer:int, fixedTime:float):void
---@overload fun(stateNameHash:int, transitionDuration:float, layer:int):void
---@overload fun(stateNameHash:int, transitionDuration:float):void
---@param stateName string
---@param transitionDuration float
---@param layer int
function m:CrossFadeInFixedTime(stateName, transitionDuration, layer) end
---@overload fun(stateName:string, transitionDuration:float):void
---@overload fun(stateName:string, transitionDuration:float, layer:int, normalizedTime:float):void
---@overload fun(stateNameHash:int, transitionDuration:float, layer:int, normalizedTime:float):void
---@overload fun(stateNameHash:int, transitionDuration:float, layer:int):void
---@overload fun(stateNameHash:int, transitionDuration:float):void
---@param stateName string
---@param transitionDuration float
---@param layer int
function m:CrossFade(stateName, transitionDuration, layer) end
---@overload fun(stateName:string):void
---@overload fun(stateName:string, layer:int, fixedTime:float):void
---@overload fun(stateNameHash:int, layer:int, fixedTime:float):void
---@overload fun(stateNameHash:int, layer:int):void
---@overload fun(stateNameHash:int):void
---@param stateName string
---@param layer int
function m:PlayInFixedTime(stateName, layer) end
---@overload fun(stateName:string):void
---@overload fun(stateName:string, layer:int, normalizedTime:float):void
---@overload fun(stateNameHash:int, layer:int, normalizedTime:float):void
---@overload fun(stateNameHash:int, layer:int):void
---@overload fun(stateNameHash:int):void
---@param stateName string
---@param layer int
function m:Play(stateName, layer) end
---@param targetIndex UnityEngine.AvatarTarget
---@param targetNormalizedTime float
function m:SetTarget(targetIndex, targetNormalizedTime) end
---@param humanBoneId UnityEngine.HumanBodyBones
---@return UnityEngine.Transform
function m:GetBoneTransform(humanBoneId) end
function m:StartPlayback() end
function m:StopPlayback() end
---@param frameCount int
function m:StartRecording(frameCount) end
function m:StopRecording() end
---@param layerIndex int
---@param stateID int
---@return bool
function m:HasState(layerIndex, stateID) end
---@param name string
---@return int
function m.StringToHash(name) end
---@param deltaTime float
function m:Update(deltaTime) end
function m:Rebind() end
function m:ApplyBuiltinRootMotion() end
UnityEngine = {}
UnityEngine.Animator = m
return m