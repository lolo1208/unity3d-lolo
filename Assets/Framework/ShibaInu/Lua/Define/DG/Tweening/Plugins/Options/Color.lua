---@class DG.Tweening.Core.TweenerCore<UnityEngine.Color,UnityEngine.Color,DG.Tweening.Plugins.Options.ColorOptions> : DG.Tweening.Tweener
---@field startValue UnityEngine.Color
---@field endValue UnityEngine.Color
---@field changeValue UnityEngine.Color
---@field plugOptions DG.Tweening.Plugins.Options.ColorOptions
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
DG.Tweening.Core.TweenerCore<UnityEngine.Color,UnityEngine = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Color,UnityEngine.Color,DG = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Color,UnityEngine.Color,DG.Tweening = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Color,UnityEngine.Color,DG.Tweening.Plugins = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Color,UnityEngine.Color,DG.Tweening.Plugins.Options = {}
DG.Tweening.Core.TweenerCore<UnityEngine.Color,UnityEngine.Color,DG.Tweening.Plugins.Options.ColorOptions> = m
return m