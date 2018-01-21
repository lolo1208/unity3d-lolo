---@class UnityEngine.Transform : UnityEngine.Component
---@field position UnityEngine.Vector3
---@field localPosition UnityEngine.Vector3
---@field eulerAngles UnityEngine.Vector3
---@field localEulerAngles UnityEngine.Vector3
---@field right UnityEngine.Vector3
---@field up UnityEngine.Vector3
---@field forward UnityEngine.Vector3
---@field rotation UnityEngine.Quaternion
---@field localRotation UnityEngine.Quaternion
---@field localScale UnityEngine.Vector3
---@field parent UnityEngine.Transform
---@field worldToLocalMatrix UnityEngine.Matrix4x4
---@field localToWorldMatrix UnityEngine.Matrix4x4
---@field root UnityEngine.Transform
---@field childCount int
---@field lossyScale UnityEngine.Vector3
---@field hasChanged bool
---@field hierarchyCapacity int
---@field hierarchyCount int
local m = {}
---@param endValue UnityEngine.Vector3
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOMove(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOMoveX(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOMoveY(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOMoveZ(endValue, duration, snapping) end
---@param endValue UnityEngine.Vector3
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOLocalMove(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOLocalMoveX(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOLocalMoveY(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOLocalMoveZ(endValue, duration, snapping) end
---@param endValue UnityEngine.Vector3
---@param duration float
---@param mode DG.Tweening.RotateMode
---@return DG.Tweening.Tweener
function m:DORotate(endValue, duration, mode) end
---@param endValue UnityEngine.Quaternion
---@param duration float
---@return DG.Tweening.Tweener
function m:DORotateQuaternion(endValue, duration) end
---@param endValue UnityEngine.Vector3
---@param duration float
---@param mode DG.Tweening.RotateMode
---@return DG.Tweening.Tweener
function m:DOLocalRotate(endValue, duration, mode) end
---@param endValue UnityEngine.Quaternion
---@param duration float
---@return DG.Tweening.Tweener
function m:DOLocalRotateQuaternion(endValue, duration) end
---@overload fun(endValue:float, duration:float):DG.Tweening.Tweener
---@param endValue UnityEngine.Vector3
---@param duration float
---@return DG.Tweening.Tweener
function m:DOScale(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOScaleX(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOScaleY(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOScaleZ(endValue, duration) end
---@param towards UnityEngine.Vector3
---@param duration float
---@param axisConstraint DG.Tweening.AxisConstraint
---@param up System.Nullable
---@return DG.Tweening.Tweener
function m:DOLookAt(towards, duration, axisConstraint, up) end
---@param punch UnityEngine.Vector3
---@param duration float
---@param vibrato int
---@param elasticity float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOPunchPosition(punch, duration, vibrato, elasticity, snapping) end
---@param punch UnityEngine.Vector3
---@param duration float
---@param vibrato int
---@param elasticity float
---@return DG.Tweening.Tweener
function m:DOPunchScale(punch, duration, vibrato, elasticity) end
---@param punch UnityEngine.Vector3
---@param duration float
---@param vibrato int
---@param elasticity float
---@return DG.Tweening.Tweener
function m:DOPunchRotation(punch, duration, vibrato, elasticity) end
---@overload fun(duration:float, strength:UnityEngine.Vector3, vibrato:int, randomness:float, snapping:bool, fadeOut:bool):DG.Tweening.Tweener
---@param duration float
---@param strength float
---@param vibrato int
---@param randomness float
---@param snapping bool
---@param fadeOut bool
---@return DG.Tweening.Tweener
function m:DOShakePosition(duration, strength, vibrato, randomness, snapping, fadeOut) end
---@overload fun(duration:float, strength:UnityEngine.Vector3, vibrato:int, randomness:float, fadeOut:bool):DG.Tweening.Tweener
---@param duration float
---@param strength float
---@param vibrato int
---@param randomness float
---@param fadeOut bool
---@return DG.Tweening.Tweener
function m:DOShakeRotation(duration, strength, vibrato, randomness, fadeOut) end
---@overload fun(duration:float, strength:UnityEngine.Vector3, vibrato:int, randomness:float, fadeOut:bool):DG.Tweening.Tweener
---@param duration float
---@param strength float
---@param vibrato int
---@param randomness float
---@param fadeOut bool
---@return DG.Tweening.Tweener
function m:DOShakeScale(duration, strength, vibrato, randomness, fadeOut) end
---@param endValue UnityEngine.Vector3
---@param jumpPower float
---@param numJumps int
---@param duration float
---@param snapping bool
---@return DG.Tweening.Sequence
function m:DOJump(endValue, jumpPower, numJumps, duration, snapping) end
---@param endValue UnityEngine.Vector3
---@param jumpPower float
---@param numJumps int
---@param duration float
---@param snapping bool
---@return DG.Tweening.Sequence
function m:DOLocalJump(endValue, jumpPower, numJumps, duration, snapping) end
---@param path table
---@param duration float
---@param pathType DG.Tweening.PathType
---@param pathMode DG.Tweening.PathMode
---@param resolution int
---@param gizmoColor System.Nullable
---@return DG.Tweening.Core.TweenerCore
function m:DOPath(path, duration, pathType, pathMode, resolution, gizmoColor) end
---@param path table
---@param duration float
---@param pathType DG.Tweening.PathType
---@param pathMode DG.Tweening.PathMode
---@param resolution int
---@param gizmoColor System.Nullable
---@return DG.Tweening.Core.TweenerCore
function m:DOLocalPath(path, duration, pathType, pathMode, resolution, gizmoColor) end
---@param byValue UnityEngine.Vector3
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOBlendableMoveBy(byValue, duration, snapping) end
---@param byValue UnityEngine.Vector3
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOBlendableLocalMoveBy(byValue, duration, snapping) end
---@param byValue UnityEngine.Vector3
---@param duration float
---@param mode DG.Tweening.RotateMode
---@return DG.Tweening.Tweener
function m:DOBlendableRotateBy(byValue, duration, mode) end
---@param byValue UnityEngine.Vector3
---@param duration float
---@param mode DG.Tweening.RotateMode
---@return DG.Tweening.Tweener
function m:DOBlendableLocalRotateBy(byValue, duration, mode) end
---@param byValue UnityEngine.Vector3
---@param duration float
---@return DG.Tweening.Tweener
function m:DOBlendableScaleBy(byValue, duration) end
---@overload fun(parent:UnityEngine.Transform, worldPositionStays:bool):void
---@param parent UnityEngine.Transform
function m:SetParent(parent) end
---@param position UnityEngine.Vector3
---@param rotation UnityEngine.Quaternion
function m:SetPositionAndRotation(position, rotation) end
---@overload fun(translation:UnityEngine.Vector3, relativeTo:UnityEngine.Space):void
---@overload fun(x:float, y:float, z:float):void
---@overload fun(x:float, y:float, z:float, relativeTo:UnityEngine.Space):void
---@overload fun(translation:UnityEngine.Vector3, relativeTo:UnityEngine.Transform):void
---@overload fun(x:float, y:float, z:float, relativeTo:UnityEngine.Transform):void
---@param translation UnityEngine.Vector3
function m:Translate(translation) end
---@overload fun(eulerAngles:UnityEngine.Vector3, relativeTo:UnityEngine.Space):void
---@overload fun(xAngle:float, yAngle:float, zAngle:float):void
---@overload fun(xAngle:float, yAngle:float, zAngle:float, relativeTo:UnityEngine.Space):void
---@overload fun(axis:UnityEngine.Vector3, angle:float):void
---@overload fun(axis:UnityEngine.Vector3, angle:float, relativeTo:UnityEngine.Space):void
---@param eulerAngles UnityEngine.Vector3
function m:Rotate(eulerAngles) end
---@param point UnityEngine.Vector3
---@param axis UnityEngine.Vector3
---@param angle float
function m:RotateAround(point, axis, angle) end
---@overload fun(target:UnityEngine.Transform, worldUp:UnityEngine.Vector3):void
---@overload fun(worldPosition:UnityEngine.Vector3, worldUp:UnityEngine.Vector3):void
---@overload fun(worldPosition:UnityEngine.Vector3):void
---@param target UnityEngine.Transform
function m:LookAt(target) end
---@overload fun(x:float, y:float, z:float):UnityEngine.Vector3
---@param direction UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:TransformDirection(direction) end
---@overload fun(x:float, y:float, z:float):UnityEngine.Vector3
---@param direction UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:InverseTransformDirection(direction) end
---@overload fun(x:float, y:float, z:float):UnityEngine.Vector3
---@param vector UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:TransformVector(vector) end
---@overload fun(x:float, y:float, z:float):UnityEngine.Vector3
---@param vector UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:InverseTransformVector(vector) end
---@overload fun(x:float, y:float, z:float):UnityEngine.Vector3
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:TransformPoint(position) end
---@overload fun(x:float, y:float, z:float):UnityEngine.Vector3
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:InverseTransformPoint(position) end
function m:DetachChildren() end
function m:SetAsFirstSibling() end
function m:SetAsLastSibling() end
---@param index int
function m:SetSiblingIndex(index) end
---@return int
function m:GetSiblingIndex() end
---@param name string
---@return UnityEngine.Transform
function m:Find(name) end
---@param parent UnityEngine.Transform
---@return bool
function m:IsChildOf(parent) end
---@return System.Collections.IEnumerator
function m:GetEnumerator() end
---@param index int
---@return UnityEngine.Transform
function m:GetChild(index) end
UnityEngine = {}
UnityEngine.Transform = m
return m