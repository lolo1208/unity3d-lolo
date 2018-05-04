---@class UnityEngine.SkinnedMeshRenderer : UnityEngine.Renderer
---@field bones table
---@field quality UnityEngine.SkinQuality
---@field updateWhenOffscreen bool
---@field rootBone UnityEngine.Transform
---@field sharedMesh UnityEngine.Mesh
---@field skinnedMotionVectors bool
---@field localBounds UnityEngine.Bounds
local m = {}
---@param index int
---@return float
function m:GetBlendShapeWeight(index) end
---@param index int
---@param value float
function m:SetBlendShapeWeight(index, value) end
---@param mesh UnityEngine.Mesh
function m:BakeMesh(mesh) end
UnityEngine = {}
UnityEngine.SkinnedMeshRenderer = m
return m