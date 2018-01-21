---@class UnityEngine.SkinnedMeshRenderer : UnityEngine.Renderer
---@field bones table
---@field rootBone UnityEngine.Transform
---@field quality UnityEngine.SkinQuality
---@field sharedMesh UnityEngine.Mesh
---@field updateWhenOffscreen bool
---@field skinnedMotionVectors bool
---@field localBounds UnityEngine.Bounds
local m = {}
---@param mesh UnityEngine.Mesh
function m:BakeMesh(mesh) end
---@param index int
---@return float
function m:GetBlendShapeWeight(index) end
---@param index int
---@param value float
function m:SetBlendShapeWeight(index, value) end
UnityEngine = {}
UnityEngine.SkinnedMeshRenderer = m
return m