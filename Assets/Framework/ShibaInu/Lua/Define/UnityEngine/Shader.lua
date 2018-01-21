---@class UnityEngine.Shader : UnityEngine.Object
---@field isSupported bool
---@field maximumLOD int
---@field globalMaximumLOD int
---@field globalRenderPipeline string
---@field renderQueue int
local m = {}
---@param name string
---@return UnityEngine.Shader
function m.Find(name) end
---@param keyword string
function m.EnableKeyword(keyword) end
---@param keyword string
function m.DisableKeyword(keyword) end
---@param keyword string
---@return bool
function m.IsKeywordEnabled(keyword) end
---@overload fun(name:string, buffer:UnityEngine.ComputeBuffer):void
---@param nameID int
---@param buffer UnityEngine.ComputeBuffer
function m.SetGlobalBuffer(nameID, buffer) end
---@param name string
---@return int
function m.PropertyToID(name) end
function m.WarmupAllShaders() end
---@overload fun(nameID:int, value:float):void
---@param name string
---@param value float
function m.SetGlobalFloat(name, value) end
---@overload fun(nameID:int, value:int):void
---@param name string
---@param value int
function m.SetGlobalInt(name, value) end
---@overload fun(nameID:int, value:UnityEngine.Vector4):void
---@param name string
---@param value UnityEngine.Vector4
function m.SetGlobalVector(name, value) end
---@overload fun(nameID:int, value:UnityEngine.Color):void
---@param name string
---@param value UnityEngine.Color
function m.SetGlobalColor(name, value) end
---@overload fun(nameID:int, value:UnityEngine.Matrix4x4):void
---@param name string
---@param value UnityEngine.Matrix4x4
function m.SetGlobalMatrix(name, value) end
---@overload fun(nameID:int, value:UnityEngine.Texture):void
---@param name string
---@param value UnityEngine.Texture
function m.SetGlobalTexture(name, value) end
---@overload fun(nameID:int, values:table):void
---@overload fun(name:string, values:table):void
---@overload fun(nameID:int, values:table):void
---@param name string
---@param values table
function m.SetGlobalFloatArray(name, values) end
---@overload fun(nameID:int, values:table):void
---@overload fun(name:string, values:table):void
---@overload fun(nameID:int, values:table):void
---@param name string
---@param values table
function m.SetGlobalVectorArray(name, values) end
---@overload fun(nameID:int, values:table):void
---@overload fun(name:string, values:table):void
---@overload fun(nameID:int, values:table):void
---@param name string
---@param values table
function m.SetGlobalMatrixArray(name, values) end
---@overload fun(nameID:int):float
---@param name string
---@return float
function m.GetGlobalFloat(name) end
---@overload fun(nameID:int):int
---@param name string
---@return int
function m.GetGlobalInt(name) end
---@overload fun(nameID:int):UnityEngine.Vector4
---@param name string
---@return UnityEngine.Vector4
function m.GetGlobalVector(name) end
---@overload fun(nameID:int):UnityEngine.Color
---@param name string
---@return UnityEngine.Color
function m.GetGlobalColor(name) end
---@overload fun(nameID:int):UnityEngine.Matrix4x4
---@param name string
---@return UnityEngine.Matrix4x4
function m.GetGlobalMatrix(name) end
---@overload fun(nameID:int):UnityEngine.Texture
---@param name string
---@return UnityEngine.Texture
function m.GetGlobalTexture(name) end
---@overload fun(nameID:int, values:table):void
---@overload fun(name:string):table
---@overload fun(nameID:int):table
---@param name string
---@param values table
function m.GetGlobalFloatArray(name, values) end
---@overload fun(nameID:int, values:table):void
---@overload fun(name:string):table
---@overload fun(nameID:int):table
---@param name string
---@param values table
function m.GetGlobalVectorArray(name, values) end
---@overload fun(nameID:int, values:table):void
---@overload fun(name:string):table
---@overload fun(nameID:int):table
---@param name string
---@param values table
function m.GetGlobalMatrixArray(name, values) end
UnityEngine = {}
UnityEngine.Shader = m
return m