---@class DG.Tweening.Core.TweenerCore<UnityEngine.Vector3,UnityEngine.Vector3,DG.Tweening.Plugins.Options.VectorOptions> : DG.Tweening.Tweener
---@field startValue UnityEngine.Vector3
---@field endValue UnityEngine.Vector3
---@field changeValue UnityEngine.Vector3
---@field plugOptions DG.Tweening.Plugins.Options.VectorOptions
---@field getter DG.Tweening.Core.DOGetter
---@field setter DG.Tweening.Core.DOSetter
---@field timeScale float
---@field isBackwards bool
---@field id object
---@field target object
---@field easeOvershootOrAmplitude float
---@field easePeriod float
local m = {}
---@param newStartValue object
---@param newDuration float
---@return DG.Tweening.Tweener
function m:ChangeStartValue(newStartValue, newDuration) end
---@overload fun(newEndValue:object, newDuration:float, snapStartValue:bool):DG.Tweening.Tweener
---@param newEndValue object
---@param snapStartValue bool
---@return DG.Tweening.Tweener
function m:ChangeEndValue(newEndValue, snapStartValue) end
---@param newStartValue object
---@param newEndValue object
---@param newDuration float
---@return DG.Tweening.Tweener
function m:ChangeValues(newStartValue, newEndValue, newDuration) end
DG = {}
DG.Tweening = {}
DG.Tweening.Core = {}
DG.Tweening.Core.TweenerCore<UnityEngine = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Vector3,UnityEngine = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Vector3,UnityEngine.Vector3,DG = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Vector3,UnityEngine.Vector3,DG.Tweening = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Vector3,UnityEngine.Vector3,DG.Tweening.Plugins = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Vector3,UnityEngine.Vector3,DG.Tweening.Plugins.Options = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Vector3,UnityEngine.Vector3,DG.Tweening.Plugins.Options.VectorOptions> = m
return m