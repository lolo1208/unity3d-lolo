---@class UnityEngine.Time : object
---@field time float
---@field timeSinceLevelLoad float
---@field deltaTime float
---@field fixedTime float
---@field unscaledTime float
---@field fixedUnscaledTime float
---@field unscaledDeltaTime float
---@field fixedUnscaledDeltaTime float
---@field fixedDeltaTime float
---@field maximumDeltaTime float
---@field smoothDeltaTime float
---@field maximumParticleDeltaTime float
---@field timeScale float
---@field frameCount int
---@field renderedFrameCount int
---@field realtimeSinceStartup float
---@field captureFramerate int
---@field inFixedTimeStep bool
local m = {}
UnityEngine = {}
UnityEngine.Time = m
return m