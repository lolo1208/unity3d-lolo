---@class ShibaInu.Stage : object
---@field uiCanvas UnityEngine.RectTransform
---@field sceneLayer UnityEngine.RectTransform
---@field uiLayer UnityEngine.RectTransform
---@field windowLayer UnityEngine.RectTransform
---@field uiTopLayer UnityEngine.RectTransform
---@field alertLayer UnityEngine.RectTransform
---@field guideLayer UnityEngine.RectTransform
---@field topLayer UnityEngine.RectTransform
local m = {}
function m.Initialize() end
function m.Resize() end
function m.Clean() end
---@param go UnityEngine.GameObject
function m.AddDontDestroy(go) end
---@param go UnityEngine.GameObject
function m.RemoveDontDestroy(go) end
---@param sceneName string
function m.LoadScene(sceneName) end
---@param sceneName string
function m.LoadSceneAsync(sceneName) end
---@param type string
---@param sceneName string
function m.DispatchLuaEvent(type, sceneName) end
---@return float
function m.GetProgress() end
ShibaInu = {}
ShibaInu.Stage = m
return m