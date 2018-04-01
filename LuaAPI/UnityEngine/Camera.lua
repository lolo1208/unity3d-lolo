---@class UnityEngine.Camera : UnityEngine.Behaviour
---@field fieldOfView float
---@field nearClipPlane float
---@field farClipPlane float
---@field renderingPath UnityEngine.RenderingPath
---@field actualRenderingPath UnityEngine.RenderingPath
---@field allowHDR bool
---@field forceIntoRenderTexture bool
---@field allowMSAA bool
---@field orthographicSize float
---@field orthographic bool
---@field opaqueSortMode UnityEngine.Rendering.OpaqueSortMode
---@field transparencySortMode UnityEngine.TransparencySortMode
---@field transparencySortAxis UnityEngine.Vector3
---@field depth float
---@field aspect float
---@field cullingMask int
---@field scene UnityEngine.SceneManagement.Scene
---@field eventMask int
---@field backgroundColor UnityEngine.Color
---@field rect UnityEngine.Rect
---@field pixelRect UnityEngine.Rect
---@field targetTexture UnityEngine.RenderTexture
---@field activeTexture UnityEngine.RenderTexture
---@field pixelWidth int
---@field pixelHeight int
---@field cameraToWorldMatrix UnityEngine.Matrix4x4
---@field worldToCameraMatrix UnityEngine.Matrix4x4
---@field projectionMatrix UnityEngine.Matrix4x4
---@field nonJitteredProjectionMatrix UnityEngine.Matrix4x4
---@field useJitteredProjectionMatrixForTransparentRendering bool
---@field previousViewProjectionMatrix UnityEngine.Matrix4x4
---@field velocity UnityEngine.Vector3
---@field clearFlags UnityEngine.CameraClearFlags
---@field stereoEnabled bool
---@field stereoSeparation float
---@field stereoConvergence float
---@field cameraType UnityEngine.CameraType
---@field stereoTargetEye UnityEngine.StereoTargetEyeMask
---@field areVRStereoViewMatricesWithinSingleCullTolerance bool
---@field stereoActiveEye UnityEngine.Camera.MonoOrStereoscopicEye
---@field targetDisplay int
---@field main UnityEngine.Camera
---@field current UnityEngine.Camera
---@field allCameras table
---@field allCamerasCount int
---@field useOcclusionCulling bool
---@field cullingMatrix UnityEngine.Matrix4x4
---@field layerCullDistances table
---@field layerCullSpherical bool
---@field depthTextureMode UnityEngine.DepthTextureMode
---@field clearStencilAfterLightingPass bool
---@field commandBufferCount int
---@field onPreCull UnityEngine.Camera.CameraCallback
---@field onPreRender UnityEngine.Camera.CameraCallback
---@field onPostRender UnityEngine.Camera.CameraCallback
local m = {}
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOAspect(endValue, duration) end
---@param endValue UnityEngine.Color
---@param duration float
---@return DG.Tweening.Tweener
function m:DOColor(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOFarClipPlane(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOFieldOfView(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DONearClipPlane(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOOrthoSize(endValue, duration) end
---@param endValue UnityEngine.Rect
---@param duration float
---@return DG.Tweening.Tweener
function m:DOPixelRect(endValue, duration) end
---@param endValue UnityEngine.Rect
---@param duration float
---@return DG.Tweening.Tweener
function m:DORect(endValue, duration) end
---@overload fun(duration:float, strength:UnityEngine.Vector3, vibrato:int, randomness:float, fadeOut:bool):DG.Tweening.Tweener
---@param duration float
---@param strength float
---@param vibrato int
---@param randomness float
---@param fadeOut bool
---@return DG.Tweening.Tweener
function m:DOShakePosition(duration, strength, vibrato, randomness, fadeOut) end
---@overload fun(duration:float, strength:UnityEngine.Vector3, vibrato:int, randomness:float, fadeOut:bool):DG.Tweening.Tweener
---@param duration float
---@param strength float
---@param vibrato int
---@param randomness float
---@param fadeOut bool
---@return DG.Tweening.Tweener
function m:DOShakeRotation(duration, strength, vibrato, randomness, fadeOut) end
---@overload fun(colorBuffer:table, depthBuffer:UnityEngine.RenderBuffer):void
---@param colorBuffer UnityEngine.RenderBuffer
---@param depthBuffer UnityEngine.RenderBuffer
function m:SetTargetBuffers(colorBuffer, depthBuffer) end
function m:ResetWorldToCameraMatrix() end
function m:ResetProjectionMatrix() end
function m:ResetAspect() end
---@param eye UnityEngine.Camera.StereoscopicEye
---@return UnityEngine.Matrix4x4
function m:GetStereoViewMatrix(eye) end
---@param eye UnityEngine.Camera.StereoscopicEye
---@param matrix UnityEngine.Matrix4x4
function m:SetStereoViewMatrix(eye, matrix) end
function m:ResetStereoViewMatrices() end
---@param eye UnityEngine.Camera.StereoscopicEye
---@return UnityEngine.Matrix4x4
function m:GetStereoProjectionMatrix(eye) end
---@param eye UnityEngine.Camera.StereoscopicEye
---@param matrix UnityEngine.Matrix4x4
function m:SetStereoProjectionMatrix(eye, matrix) end
---@param viewport UnityEngine.Rect
---@param z float
---@param eye UnityEngine.Camera.MonoOrStereoscopicEye
---@param outCorners table
function m:CalculateFrustumCorners(viewport, z, eye, outCorners) end
function m:ResetStereoProjectionMatrices() end
function m:ResetTransparencySortSettings() end
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:WorldToScreenPoint(position) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:WorldToViewportPoint(position) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:ViewportToWorldPoint(position) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:ScreenToWorldPoint(position) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:ScreenToViewportPoint(position) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:ViewportToScreenPoint(position) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Ray
function m:ViewportPointToRay(position) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Ray
function m:ScreenPointToRay(position) end
---@param cameras table
---@return int
function m.GetAllCameras(cameras) end
function m:Render() end
---@param shader UnityEngine.Shader
---@param replacementTag string
function m:RenderWithShader(shader, replacementTag) end
---@param shader UnityEngine.Shader
---@param replacementTag string
function m:SetReplacementShader(shader, replacementTag) end
function m:ResetReplacementShader() end
function m:ResetCullingMatrix() end
function m:RenderDontRestore() end
---@param cur UnityEngine.Camera
function m.SetupCurrent(cur) end
---@overload fun(cubemap:UnityEngine.Cubemap, faceMask:int):bool
---@overload fun(cubemap:UnityEngine.RenderTexture):bool
---@overload fun(cubemap:UnityEngine.RenderTexture, faceMask:int):bool
---@param cubemap UnityEngine.Cubemap
---@return bool
function m:RenderToCubemap(cubemap) end
---@param other UnityEngine.Camera
function m:CopyFrom(other) end
---@param evt UnityEngine.Rendering.CameraEvent
---@param buffer UnityEngine.Rendering.CommandBuffer
function m:AddCommandBuffer(evt, buffer) end
---@param evt UnityEngine.Rendering.CameraEvent
---@param buffer UnityEngine.Rendering.CommandBuffer
function m:RemoveCommandBuffer(evt, buffer) end
---@param evt UnityEngine.Rendering.CameraEvent
function m:RemoveCommandBuffers(evt) end
function m:RemoveAllCommandBuffers() end
---@param evt UnityEngine.Rendering.CameraEvent
---@return table
function m:GetCommandBuffers(evt) end
---@param clipPlane UnityEngine.Vector4
---@return UnityEngine.Matrix4x4
function m:CalculateObliqueMatrix(clipPlane) end
UnityEngine = {}
UnityEngine.Camera = m
return m