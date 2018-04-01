---@class UnityEngine.AudioClip : UnityEngine.Object
---@field length float
---@field samples int
---@field channels int
---@field frequency int
---@field loadType UnityEngine.AudioClipLoadType
---@field preloadAudioData bool
---@field ambisonic bool
---@field loadState UnityEngine.AudioDataLoadState
---@field loadInBackground bool
local m = {}
---@return bool
function m:LoadAudioData() end
---@return bool
function m:UnloadAudioData() end
---@param data table
---@param offsetSamples int
---@return bool
function m:GetData(data, offsetSamples) end
---@param data table
---@param offsetSamples int
---@return bool
function m:SetData(data, offsetSamples) end
---@overload fun(name:string, lengthSamples:int, channels:int, frequency:int, stream:bool, pcmreadercallback:UnityEngine.AudioClip.PCMReaderCallback):UnityEngine.AudioClip
---@overload fun(name:string, lengthSamples:int, channels:int, frequency:int, stream:bool, pcmreadercallback:UnityEngine.AudioClip.PCMReaderCallback, pcmsetpositioncallback:UnityEngine.AudioClip.PCMSetPositionCallback):UnityEngine.AudioClip
---@param name string
---@param lengthSamples int
---@param channels int
---@param frequency int
---@param stream bool
---@return UnityEngine.AudioClip
function m.Create(name, lengthSamples, channels, frequency, stream) end
UnityEngine = {}
UnityEngine.AudioClip = m
return m