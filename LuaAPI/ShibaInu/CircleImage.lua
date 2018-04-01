---@class ShibaInu.CircleImage : UnityEngine.UI.MaskableGraphic
---@field sourceImage UnityEngine.Sprite
---@field fan float
---@field ring float
---@field sides int
---@field mainTexture UnityEngine.Texture
local m = {}
---@param screenPoint UnityEngine.Vector2
---@param eventCamera UnityEngine.Camera
---@return bool
function m:IsRaycastLocationValid(screenPoint, eventCamera) end
ShibaInu = {}
ShibaInu.CircleImage = m
return m