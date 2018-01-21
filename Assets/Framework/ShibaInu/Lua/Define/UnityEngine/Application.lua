---@class UnityEngine.Application : object
---@field streamedBytes int
---@field isPlaying bool
---@field isFocused bool
---@field isEditor bool
---@field platform UnityEngine.RuntimePlatform
---@field buildGUID string
---@field isMobilePlatform bool
---@field isConsolePlatform bool
---@field runInBackground bool
---@field dataPath string
---@field streamingAssetsPath string
---@field persistentDataPath string
---@field temporaryCachePath string
---@field absoluteURL string
---@field unityVersion string
---@field version string
---@field installerName string
---@field identifier string
---@field installMode UnityEngine.ApplicationInstallMode
---@field sandboxType UnityEngine.ApplicationSandboxType
---@field productName string
---@field companyName string
---@field cloudProjectId string
---@field targetFrameRate int
---@field systemLanguage UnityEngine.SystemLanguage
---@field backgroundLoadingPriority UnityEngine.ThreadPriority
---@field internetReachability UnityEngine.NetworkReachability
---@field genuine bool
---@field genuineCheckAvailable bool
local m = {}
function m.Quit() end
function m.CancelQuit() end
function m.Unload() end
---@overload fun(levelName:string):float
---@param levelIndex int
---@return float
function m.GetStreamProgressForLevel(levelIndex) end
---@overload fun(levelName:string):bool
---@param levelIndex int
---@return bool
function m.CanStreamedLevelBeLoaded(levelIndex) end
---@return table
function m.GetBuildTags() end
---@param buildTags table
function m.SetBuildTags(buildTags) end
---@return bool
function m.HasProLicense() end
---@param delegateMethod UnityEngine.Application.AdvertisingIdentifierCallback
---@return bool
function m.RequestAdvertisingIdentifierAsync(delegateMethod) end
---@param url string
function m.OpenURL(url) end
---@param logType UnityEngine.LogType
---@return UnityEngine.StackTraceLogType
function m.GetStackTraceLogType(logType) end
---@param logType UnityEngine.LogType
---@param stackTraceType UnityEngine.StackTraceLogType
function m.SetStackTraceLogType(logType, stackTraceType) end
---@param mode UnityEngine.UserAuthorization
---@return UnityEngine.AsyncOperation
function m.RequestUserAuthorization(mode) end
---@param mode UnityEngine.UserAuthorization
---@return bool
function m.HasUserAuthorization(mode) end
UnityEngine = {}
UnityEngine.Application = m
return m