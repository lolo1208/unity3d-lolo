---@class UnityEngine.AudioSource : UnityEngine.Behaviour
---@field volume float
---@field pitch float
---@field time float
---@field timeSamples int
---@field clip UnityEngine.AudioClip
---@field outputAudioMixerGroup UnityEngine.Audio.AudioMixerGroup
---@field isPlaying bool
---@field isVirtual bool
---@field loop bool
---@field ignoreListenerVolume bool
---@field playOnAwake bool
---@field ignoreListenerPause bool
---@field velocityUpdateMode UnityEngine.AudioVelocityUpdateMode
---@field panStereo float
---@field spatialBlend float
---@field spatialize bool
---@field spatializePostEffects bool
---@field reverbZoneMix float
---@field bypassEffects bool
---@field bypassListenerEffects bool
---@field bypassReverbZones bool
---@field dopplerLevel float
---@field spread float
---@field priority int
---@field mute bool
---@field minDistance float
---@field maxDistance float
---@field rolloffMode UnityEngine.AudioRolloffMode
local m = {}
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOFade(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOPitch(endValue, duration) end
---@overload fun():void
---@param delay ulong
function m:Play(delay) end
---@param delay float
function m:PlayDelayed(delay) end
---@param time double
function m:PlayScheduled(time) end
---@param time double
function m:SetScheduledStartTime(time) end
---@param time double
function m:SetScheduledEndTime(time) end
function m:Stop() end
function m:Pause() end
function m:UnPause() end
---@overload fun(clip:UnityEngine.AudioClip, volumeScale:float):void
---@param clip UnityEngine.AudioClip
function m:PlayOneShot(clip) end
---@overload fun(clip:UnityEngine.AudioClip, position:UnityEngine.Vector3, volume:float):void
---@param clip UnityEngine.AudioClip
---@param position UnityEngine.Vector3
function m.PlayClipAtPoint(clip, position) end
---@param type UnityEngine.AudioSourceCurveType
---@param curve UnityEngine.AnimationCurve
function m:SetCustomCurve(type, curve) end
---@param type UnityEngine.AudioSourceCurveType
---@return UnityEngine.AnimationCurve
function m:GetCustomCurve(type) end
---@param samples table
---@param channel int
function m:GetOutputData(samples, channel) end
---@param samples table
---@param channel int
---@param window UnityEngine.FFTWindow
function m:GetSpectrumData(samples, channel, window) end
---@param index int
---@param value float
---@return bool
function m:SetSpatializerFloat(index, value) end
---@param index int
---@param value float
---@return bool
function m:GetSpatializerFloat(index, value) end
---@param index int
---@param value float
---@return bool
function m:SetAmbisonicDecoderFloat(index, value) end
---@param index int
---@param value float
---@return bool
function m:GetAmbisonicDecoderFloat(index, value) end
UnityEngine = {}
UnityEngine.AudioSource = m
return m