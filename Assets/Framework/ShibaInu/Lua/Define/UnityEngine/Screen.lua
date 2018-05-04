---@class UnityEngine.Screen : object
---@field resolutions table
---@field currentResolution UnityEngine.Resolution
---@field fullScreen bool
---@field width int
---@field height int
---@field dpi float
---@field orientation UnityEngine.ScreenOrientation
---@field sleepTimeout int
---@field autorotateToPortrait bool
---@field autorotateToPortraitUpsideDown bool
---@field autorotateToLandscapeLeft bool
---@field autorotateToLandscapeRight bool
---@field safeArea UnityEngine.Rect
local m = {}
---@overload fun(width:int, height:int, fullscreen:bool):void
---@param width int
---@param height int
---@param fullscreen bool
---@param preferredRefreshRate int
function m.SetResolution(width, height, fullscreen, preferredRefreshRate) end
UnityEngine = {}
UnityEngine.Screen = m
return m