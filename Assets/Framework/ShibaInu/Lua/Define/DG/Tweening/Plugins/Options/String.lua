---@class DG.Tweening.Core.TweenerCore<string,string,DG.Tweening.Plugins.Options.StringOptions> : DG.Tweening.Tweener
---@field startValue string
---@field endValue string
---@field changeValue string
---@field plugOptions DG.Tweening.Plugins.Options.StringOptions
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
DG.Tweening.Core.TweenerCore<string,string,DG = {}
DG.Tweening.Core.TweenerCore<string,string,DG.Tweening = {}
DG.Tweening.Core.TweenerCore<string,string,DG.Tweening.Plugins = {}
DG.Tweening.Core.TweenerCore<string,string,DG.Tweening.Plugins.Options = {}
DG.Tweening.Core.TweenerCore<string,string,DG.Tweening.Plugins.Options.StringOptions> = m
return m