---@class DG.Tweening.Core.TweenerCore<float,float,DG.Tweening.Plugins.Options.FloatOptions> : DG.Tweening.Tweener
---@field startValue float
---@field endValue float
---@field changeValue float
---@field plugOptions DG.Tweening.Plugins.Options.FloatOptions
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
DG.Tweening.Core.TweenerCore<float,float,DG = {}
DG.Tweening.Core.TweenerCore<float,float,DG.Tweening = {}
DG.Tweening.Core.TweenerCore<float,float,DG.Tweening.Plugins = {}
DG.Tweening.Core.TweenerCore<float,float,DG.Tweening.Plugins.Options = {}
DG.Tweening.Core.TweenerCore<float,float,DG.Tweening.Plugins.Options.FloatOptions> = m
return m