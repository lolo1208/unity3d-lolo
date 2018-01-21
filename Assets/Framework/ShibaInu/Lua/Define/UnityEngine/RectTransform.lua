---@class UnityEngine.RectTransform : UnityEngine.Transform
---@field rect UnityEngine.Rect
---@field anchorMin UnityEngine.Vector2
---@field anchorMax UnityEngine.Vector2
---@field anchoredPosition3D UnityEngine.Vector3
---@field anchoredPosition UnityEngine.Vector2
---@field sizeDelta UnityEngine.Vector2
---@field pivot UnityEngine.Vector2
---@field offsetMin UnityEngine.Vector2
---@field offsetMax UnityEngine.Vector2
local m = {}
---@param endValue UnityEngine.Vector2
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOAnchorPos(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOAnchorPosX(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOAnchorPosY(endValue, duration, snapping) end
---@param endValue UnityEngine.Vector3
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOAnchorPos3D(endValue, duration, snapping) end
---@param endValue UnityEngine.Vector2
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOAnchorMax(endValue, duration, snapping) end
---@param endValue UnityEngine.Vector2
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOAnchorMin(endValue, duration, snapping) end
---@param endValue UnityEngine.Vector2
---@param duration float
---@return DG.Tweening.Tweener
function m:DOPivot(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOPivotX(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOPivotY(endValue, duration) end
---@param endValue UnityEngine.Vector2
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOSizeDelta(endValue, duration, snapping) end
---@param punch UnityEngine.Vector2
---@param duration float
---@param vibrato int
---@param elasticity float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOPunchAnchorPos(punch, duration, vibrato, elasticity, snapping) end
---@overload fun(duration:float, strength:UnityEngine.Vector2, vibrato:int, randomness:float, snapping:bool, fadeOut:bool):DG.Tweening.Tweener
---@param duration float
---@param strength float
---@param vibrato int
---@param randomness float
---@param snapping bool
---@param fadeOut bool
---@return DG.Tweening.Tweener
function m:DOShakeAnchorPos(duration, strength, vibrato, randomness, snapping, fadeOut) end
---@param endValue UnityEngine.Vector2
---@param jumpPower float
---@param numJumps int
---@param duration float
---@param snapping bool
---@return DG.Tweening.Sequence
function m:DOJumpAnchorPos(endValue, jumpPower, numJumps, duration, snapping) end
---@param fourCornersArray table
function m:GetLocalCorners(fourCornersArray) end
---@param fourCornersArray table
function m:GetWorldCorners(fourCornersArray) end
---@param edge UnityEngine.RectTransform.Edge
---@param inset float
---@param size float
function m:SetInsetAndSizeFromParentEdge(edge, inset, size) end
---@param axis UnityEngine.RectTransform.Axis
---@param size float
function m:SetSizeWithCurrentAnchors(axis, size) end
UnityEngine = {}
UnityEngine.RectTransform = m
return m