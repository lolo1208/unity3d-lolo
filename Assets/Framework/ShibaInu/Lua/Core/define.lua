--
-- 与代码无关的IDE提示等定义
-- 该文件不会被打包发布
-- 2017/9/27
-- Author LOLO
--


-- Vector3
---@class Vector3
---@field x number
---@field y number
---@field z number
---@field normalized Vector3 @ 返回向量的长度为1（只读）
---@field magnitude number @ 返回向量的长度（只读）
---@field sqrMagnitude number @ 返回这个向量的长度的平方（只读）
---
---@field zero Vector3 @ Vector3(0, 0, 0)
---@field one Vector3 @ Vector3(1, 1, 1)
---@field forward Vector3 @ Vector3(0, 0, 1)
---@field up Vector3 @ Vector3(0, 1, 0)
---@field right Vector3 @ Vector3(1, 0, 0)
---
---@field Clone fun():Vector3
---@field Set fun(x:number, y:number, z:number)
---@field Get fun() : x_and_y_and_z
---
---@field New fun(x : number, y : number, z : number):Vector3
---@field Lerp fun(from : Vector3, to : Vector3, t : float) : Vector3 @ t是夹在 [0...1]之间，当t = 0时，返回from，当t = 1时，返回to。当t = 0.5 返回from和to的平均数。
---@field Slerp fun(from : Vector3, to : Vector3, t : float) : Vector3 @ 两个向量之间的弧形插值。通过t数值在from和to之间插值。返回的向量的长度将被插值到from到to的长度之间。
---@field OrthoNormalize fun(normal : Vector3, tangent : Vector3, binormal : Vector3) : void @ 规范化normal，规范化tangent并且确保它垂直于normal。规范化binormal并确保它到normal和tangent两者之间相互垂直。
---@field MoveTowards fun(current : Vector3, target : Vector3, maxDistanceDelta : float) : Vector3 @ 当前的地点移向目标。这个函数基本上和Vector3.Lerp相同，而是该函数将确保我们的速度不会超过maxDistanceDelta。maxDistanceDelta的负值从目标推开向量，就是说maxDistanceDelta是正值，当前地点移向目标，如果是负值当前地点将远离目标。
---@field RotateTowards fun(current : Vector3, target : Vector3, maxRadiansDelta : float, maxMagnitudeDelta : float) : Vector3 @ 当前的向量转向目标。该向量将旋转在弧线上，而不是线性插值。这个函数基本上和Vector3.Slerp相同，而是该函数将确保角速度和变换幅度不会超过maxRadiansDelta和maxMagnitudeDelta。maxRadiansDelta和maxMagnitudeDelta的负值从目标推开该向量。
---@field SmoothDamp fun(current : Vector3, target : Vector3, currentVelocity : Vector3, smoothTime : float) : Vector3_and_currentVelocity @ 随着时间的推移，逐渐改变一个向量朝向预期的目标。
---@field Scale fun(a : Vector3, b : Vector3) : Vector3 @ 两个矢量组件对应相乘。
---@field Cross fun(lhs : Vector3, rhs : Vector3) : Vector3 @ 两个向量的交叉乘积。返回lhs x rhs
---@field Reflect fun(inDirection : Vector3, inNormal : Vector3) : Vector3 @ 沿着法线反射向量。返回的值是被从带有法线inNormal的表面反射的inDirection。
---@field Dot fun(lhs : Vector3, rhs : Vector3) : float @ 两个向量的点乘积。对于normalized向量，如果他们指向在完全相同的方向，Dot返回1。如果他们指向完全相反的方向，返回-1。对于其他的情况返回一个数（例如：如果是垂直的Dot返回0）。
---@field Project fun(vector : Vector3, onNormal : Vector3) : Vector3 @ 投影一个向量到另一个向量。返回被投影到onNormal的vector。如果onNormal接近0，返回 0 vector。
---@field Angle fun(from : Vector3, to : Vector3) : float @ 由from和to两者返回一个角度。形象的说，from和to的连线和它们一个指定轴向的夹角。
---@field Distance fun(a : Vector3, b : Vector3) : float @ 返回a和b之间的距离。
---@field ClampMagnitude fun(vector : Vector3, maxLength : float) : Vector3 @ 返回向量的长度，最大不超过maxLength所指示的长度。也就是说，钳制向量长度到一个特定的长度。
---@field Min fun(lhs : Vector3, rhs : Vector3) : Vector3 @ 返回一个由两个向量的最小组件组成的向量。
---@field Max fun(lhs : Vector3, rhs : Vector3) : Vector3 @ 返回一个由两个向量的最大组件组成的向量。


--=------------------------------[ UnityEngine ]------------------------------=--
-- 这里写了堆废代码，是为了在IDE中代码提示
UnityEngine = UnityEngine
UnityEngine.AI = UnityEngine.AI
UnityEngine.UI = UnityEngine.UI
UnityEngine.Events = UnityEngine.Events
UnityEngine.EventSystems = UnityEngine.EventSystems

---@type UnityEngine.AnimationClip
UnityEngine.AnimationClip = UnityEngine.AnimationClip
---@type UnityEngine.AnimationCurve
UnityEngine.AnimationCurve = UnityEngine.AnimationCurve
---@type UnityEngine.AnimationState
UnityEngine.AnimationState = UnityEngine.AnimationState
---@type UnityEngine.Animation
UnityEngine.Animation = UnityEngine.Animation
---@type UnityEngine.AnimatorStateInfo
UnityEngine.AnimatorStateInfo = UnityEngine.AnimatorStateInfo
---@type UnityEngine.Animator
UnityEngine.Animator = UnityEngine.Animator
---@type UnityEngine.Application
UnityEngine.Application = UnityEngine.Application
---@type UnityEngine.AssetBundle
UnityEngine.AssetBundle = UnityEngine.AssetBundle
---@type UnityEngine.AsyncOperation
UnityEngine.AsyncOperation = UnityEngine.AsyncOperation
---@type UnityEngine.AudioClip
UnityEngine.AudioClip = UnityEngine.AudioClip
---@type UnityEngine.AudioSource
UnityEngine.AudioSource = UnityEngine.AudioSource
---@type UnityEngine.Behaviour
UnityEngine.Behaviour = UnityEngine.Behaviour
---@type UnityEngine.BoxCollider
UnityEngine.BoxCollider = UnityEngine.BoxCollider
---@type UnityEngine.Camera
UnityEngine.Camera = UnityEngine.Camera
---@type UnityEngine.CanvasGroup
UnityEngine.CanvasGroup = UnityEngine.CanvasGroup
---@type UnityEngine.Canvas
UnityEngine.Canvas = UnityEngine.Canvas
---@type UnityEngine.CapsuleCollider
UnityEngine.CapsuleCollider = UnityEngine.CapsuleCollider
---@type UnityEngine.CharacterController
UnityEngine.CharacterController = UnityEngine.CharacterController
---@type UnityEngine.Collider
UnityEngine.Collider = UnityEngine.Collider
---@type UnityEngine.Component
UnityEngine.Component = UnityEngine.Component
---@type UnityEngine.Debug
UnityEngine.Debug = UnityEngine.Debug
---@type UnityEngine.EventSystems.AbstractEventData
UnityEngine.EventSystems.AbstractEventData = UnityEngine.EventSystems.AbstractEventData
---@type UnityEngine.EventSystems.BaseEventData
UnityEngine.EventSystems.BaseEventData = UnityEngine.EventSystems.BaseEventData
---@type UnityEngine.EventSystems.EventSystem
UnityEngine.EventSystems.EventSystem = UnityEngine.EventSystems.EventSystem
---@type UnityEngine.EventSystems.PointerEventData
UnityEngine.EventSystems.PointerEventData = UnityEngine.EventSystems.PointerEventData
---@type UnityEngine.EventSystems.UIBehaviour
UnityEngine.EventSystems.UIBehaviour = UnityEngine.EventSystems.UIBehaviour
---@type UnityEngine.GameObject
UnityEngine.GameObject = UnityEngine.GameObject
---@type UnityEngine.Input
UnityEngine.Input = UnityEngine.Input
---@type UnityEngine.Light
UnityEngine.Light = UnityEngine.Light
---@type UnityEngine.Material
UnityEngine.Material = UnityEngine.Material
---@type UnityEngine.MeshCollider
UnityEngine.MeshCollider = UnityEngine.MeshCollider
---@type UnityEngine.MeshRenderer
UnityEngine.MeshRenderer = UnityEngine.MeshRenderer
---@type UnityEngine.MonoBehaviour
UnityEngine.MonoBehaviour = UnityEngine.MonoBehaviour
---@type UnityEngine.ParticleSystem
UnityEngine.ParticleSystem = UnityEngine.ParticleSystem
---@type UnityEngine.Physics
UnityEngine.Physics = UnityEngine.Physics
---@type UnityEngine.PlayerPrefs
UnityEngine.PlayerPrefs = UnityEngine.PlayerPrefs
---@type UnityEngine.Projector
UnityEngine.Projector = UnityEngine.Projector
---@type UnityEngine.QualitySettings
UnityEngine.QualitySettings = UnityEngine.QualitySettings
---@type UnityEngine.RectTransformUtility
UnityEngine.RectTransformUtility = UnityEngine.RectTransformUtility
---@type UnityEngine.RectTransform
UnityEngine.RectTransform = UnityEngine.RectTransform
---@type UnityEngine.Rect
UnityEngine.Rect = UnityEngine.Rect
---@type UnityEngine.RenderSettings
UnityEngine.RenderSettings = UnityEngine.RenderSettings
---@type UnityEngine.RenderTexture
UnityEngine.RenderTexture = UnityEngine.RenderTexture
---@type UnityEngine.Renderer
UnityEngine.Renderer = UnityEngine.Renderer
---@type UnityEngine.Rigidbody
UnityEngine.Rigidbody = UnityEngine.Rigidbody
---@type UnityEngine.Screen
UnityEngine.Screen = UnityEngine.Screen
---@type UnityEngine.ScriptableObject
UnityEngine.ScriptableObject = UnityEngine.ScriptableObject
---@type UnityEngine.ShaderVariantCollection
UnityEngine.ShaderVariantCollection = UnityEngine.ShaderVariantCollection
---@type UnityEngine.Shader
UnityEngine.Shader = UnityEngine.Shader
---@type UnityEngine.SkinnedMeshRenderer
UnityEngine.SkinnedMeshRenderer = UnityEngine.SkinnedMeshRenderer
---@type UnityEngine.SleepTimeout
UnityEngine.SleepTimeout = UnityEngine.SleepTimeout
---@type UnityEngine.SphereCollider
UnityEngine.SphereCollider = UnityEngine.SphereCollider
---@type UnityEngine.Texture2D
UnityEngine.Texture2D = UnityEngine.Texture2D
---@type UnityEngine.Texture
UnityEngine.Texture = UnityEngine.Texture
---@type UnityEngine.Time
UnityEngine.Time = UnityEngine.Time
---@type UnityEngine.TrackedReference
UnityEngine.TrackedReference = UnityEngine.TrackedReference
---@type UnityEngine.Transform
UnityEngine.Transform = UnityEngine.Transform
---@type UnityEngine.UI.BaseMeshEffect
UnityEngine.UI.BaseMeshEffect = UnityEngine.UI.BaseMeshEffect
---@type UnityEngine.UI.CanvasScaler
UnityEngine.UI.CanvasScaler = UnityEngine.UI.CanvasScaler
---@type UnityEngine.UI.CanvasUpdateRegistry
UnityEngine.UI.CanvasUpdateRegistry = UnityEngine.UI.CanvasUpdateRegistry
---@type UnityEngine.UI.Dropdown
UnityEngine.UI.Dropdown = UnityEngine.UI.Dropdown
---@type UnityEngine.UI.Graphic
UnityEngine.UI.Graphic = UnityEngine.UI.Graphic
---@type UnityEngine.UI.Image
UnityEngine.UI.Image = UnityEngine.UI.Image
---@type UnityEngine.UI.LayoutRebuilder
UnityEngine.UI.LayoutRebuilder = UnityEngine.UI.LayoutRebuilder
---@type UnityEngine.UI.Mask
UnityEngine.UI.Mask = UnityEngine.UI.Mask
---@type UnityEngine.UI.MaskableGraphic
UnityEngine.UI.MaskableGraphic = UnityEngine.UI.MaskableGraphic
---@type UnityEngine.UI.Outline
UnityEngine.UI.Outline = UnityEngine.UI.Outline
---@type UnityEngine.UI.RawImage
UnityEngine.UI.RawImage = UnityEngine.UI.RawImage
---@type UnityEngine.UI.ScrollRect
UnityEngine.UI.ScrollRect = UnityEngine.UI.ScrollRect
---@type UnityEngine.UI.Scrollbar
UnityEngine.UI.Scrollbar = UnityEngine.UI.Scrollbar
---@type UnityEngine.UI.Selectable
UnityEngine.UI.Selectable = UnityEngine.UI.Selectable
---@type UnityEngine.UI.Shadow
UnityEngine.UI.Shadow = UnityEngine.UI.Shadow
---@type UnityEngine.UI.Text
UnityEngine.UI.Text = UnityEngine.UI.Text
---@type UnityEngine.WWW
UnityEngine.WWW = UnityEngine.WWW
--if UnityEngine.AI then
---@type UnityEngine.AI.NavMeshAgent
UnityEngine.AI.NavMeshAgent = UnityEngine.AI.NavMeshAgent
---@type UnityEngine.AI.NavMeshObstacle
UnityEngine.AI.NavMeshObstacle = UnityEngine.AI.NavMeshObstacle
--end
--if UnityEngine.Events.UnityEventBase then
---@type UnityEngine.Events.UnityEventBase
UnityEngine.Events.UnityEventBase = UnityEngine.Events.UnityEventBase
---@type UnityEngine.Events.UnityEvent
UnityEngine.Events.UnityEvent = UnityEngine.Events.UnityEvent
---@type UnityEngine.Events.UnityEvent.bool
UnityEngine.Events.UnityEvent.bool = UnityEngine.Events.UnityEvent.bool
---@type UnityEngine.Events.UnityEvent.float
UnityEngine.Events.UnityEvent.float = UnityEngine.Events.UnityEvent.float
---@type UnityEngine.Events.UnityEvent.string
UnityEngine.Events.UnityEvent.string = UnityEngine.Events.UnityEvent.string
--end
--if UnityEngine.Experimental then
---@type UnityEngine.Experimental.Director.DirectorPlayer
UnityEngine.Experimental.Director.DirectorPlayer = UnityEngine.Experimental.Director.DirectorPlayer
--end
--if UnityEngine.SceneManagement then
---@type UnityEngine.SceneManagement.SceneManager
UnityEngine.SceneManagement.SceneManager = UnityEngine.SceneManagement.SceneManager
---@type UnityEngine.SceneManagement.Scene
UnityEngine.SceneManagement.Scene = UnityEngine.SceneManagement.Scene
--end
--if UnityEngine.UI.Button then
---@type UnityEngine.UI.Button
UnityEngine.UI.Button = UnityEngine.UI.Button
---@type UnityEngine.UI.Button.ButtonClickedEvent
UnityEngine.UI.Button.ButtonClickedEvent = UnityEngine.UI.Button.ButtonClickedEvent
--end
--if UnityEngine.UI.InputField then
---@type UnityEngine.UI.InputField
UnityEngine.UI.InputField = UnityEngine.UI.InputField
---@type UnityEngine.UI.InputField.SubmitEvent
UnityEngine.UI.InputField.SubmitEvent = UnityEngine.UI.InputField.SubmitEvent
--end
--if UnityEngine.UI.Slider then
---@type UnityEngine.UI.Slider
UnityEngine.UI.Slider = UnityEngine.UI.Slider
---@type UnityEngine.UI.Slider.SliderEvent
UnityEngine.UI.Slider.SliderEvent = UnityEngine.UI.Slider.SliderEvent
--end
--if UnityEngine.UI.Toggle then
---@type UnityEngine.UI.ToggleGroup
UnityEngine.UI.ToggleGroup = UnityEngine.UI.ToggleGroup
---@type UnityEngine.UI.Toggle
UnityEngine.UI.Toggle = UnityEngine.UI.Toggle
---@type UnityEngine.UI.Toggle.ToggleEvent
UnityEngine.UI.Toggle.ToggleEvent = UnityEngine.UI.Toggle.ToggleEvent
--end
--=---------------------------------------------------------------------------=--

