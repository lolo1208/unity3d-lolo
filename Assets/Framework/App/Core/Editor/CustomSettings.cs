using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using DG.Tweening;
using DG.Tweening.Core;
using DG.Tweening.Plugins.Options;
using ShibaInu;
using BindType = ToLuaMenu.BindType;
using LuaInterface;

public static class CustomSettings
{
    public static string saveDir = Constants.ToLuaRootPath + "Source/Generate/";
    public static string toluaBaseType = Constants.ToLuaRootPath + "BaseType/";
    public static string injectionFilesPath = Constants.ToLuaRootPath + "Injection/";


    //导出时强制做为静态类的类型(注意customTypeList 还要添加这个类型才能导出)
    //unity 有些类作为sealed class, 其实完全等价于静态类
    public static List<Type> staticClassTypes = new List<Type>
    {
        typeof(Application),
        typeof(Time),
        typeof(Screen),
        typeof(SleepTimeout),
        typeof(Input),
        typeof(Resources),
        typeof(Physics),
        typeof(RenderSettings),
        typeof(QualitySettings),
        typeof(GL),
        typeof(Graphics),
    };


    //附加导出委托类型(在导出委托时, customTypeList 中牵扯的委托类型都会导出， 无需写在这里)
    public static DelegateType[] customDelegateList =
    {
        _DT(typeof(Action)),
        _DT(typeof(UnityAction)),
        _DT(typeof(Predicate<int>)),
        _DT(typeof(Action<int>)),
        _DT(typeof(Comparison<int>)),
        _DT(typeof(Func<int, int>)),
    };


    //在这里添加你要导出注册到lua的类型列表
    public static BindType[] customTypeList =
    {
        _GT(typeof(LuaInjectionStation)),
        _GT(typeof(InjectType)),
        _GT(typeof(LuaInterface.Debugger)).SetNameSpace(null),
        

        // DoTween
        _GT(typeof(Component)).AddExtendType (typeof(ShortcutExtensions)),
        _GT(typeof(Transform)).AddExtendType (typeof(ShortcutExtensions)),
        _GT(typeof(Light)).AddExtendType (typeof(ShortcutExtensions)),
        _GT(typeof(Material)).AddExtendType (typeof(ShortcutExtensions)),
        _GT(typeof(Rigidbody)).AddExtendType (typeof(ShortcutExtensions)),
        _GT(typeof(Camera)).AddExtendType (typeof(ShortcutExtensions)),
        _GT(typeof(AudioSource)).AddExtendType (typeof(ShortcutExtensions)),
        _GT(typeof(LineRenderer)).AddExtendType(typeof(ShortcutExtensions)),
        _GT(typeof(TrailRenderer)).AddExtendType(typeof(ShortcutExtensions)),
        _GT(typeof(RectTransform)).AddExtendType (typeof(ShortcutExtensions46)),
        _GT(typeof(Graphic)).AddExtendType (typeof(ShortcutExtensions46)),
        _GT(typeof(Image)).AddExtendType (typeof(ShortcutExtensions46)),
        _GT(typeof(Text)).AddExtendType (typeof(ShortcutExtensions46)),
        _GT(typeof(Slider)).AddExtendType (typeof(ShortcutExtensions46)),
        _GT(typeof(CanvasGroup)).AddExtendType (typeof(ShortcutExtensions46)),
        _GT(typeof(SpriteRenderer)).AddExtendType (typeof(ShortcutExtensions46)),

        _GT(typeof(DOTween)),
        _GT(typeof(DOVirtual)),
        _GT(typeof(EaseFactory)),
        _GT(typeof(TweenParams)),
        _GT(typeof(ABSSequentiable)),

        _GT(typeof(Ease)),
        _GT(typeof(LoopType)),
        _GT(typeof(PathMode)),
        _GT(typeof(PathType)),
        _GT(typeof(RotateMode)),
        _GT(typeof(AutoPlay)),
        _GT(typeof(AxisConstraint)),
        _GT(typeof(LogBehaviour)),
        _GT(typeof(ScrambleMode)),
        _GT(typeof(TweenType)),
        _GT(typeof(UpdateType)),

        _GT(typeof(Tween)).SetBaseType (typeof(object)).AddExtendType (typeof(TweenExtensions)),
        _GT(typeof(Sequence)).AddExtendType (typeof(TweenSettingsExtensions)),
        _GT(typeof(Tweener)).AddExtendType (typeof(TweenSettingsExtensions)),

        _GT(typeof(TweenerCore<string, string, StringOptions>)).SetWrapName ("DG_Tweening_Plugins_Options_String").SetLibName ("DG_Tweening_Plugins_Options_String"),
        _GT(typeof(TweenerCore<float, float, FloatOptions>)).SetWrapName ("DG_Tweening_Plugins_Options_Float").SetLibName ("DG_Tweening_Plugins_Options_Float"),
        _GT(typeof(TweenerCore<uint, uint, UintOptions>)).SetWrapName ("DG_Tweening_Plugins_Options_Uint").SetLibName ("DG_Tweening_Plugins_Options_Uint"),
        _GT(typeof(TweenerCore<Vector3, Vector3, VectorOptions>)).SetWrapName ("DG_Tweening_Plugins_Options_Vector").SetLibName ("DG_Tweening_Plugins_Options_Vector"),
        _GT(typeof(TweenerCore<Quaternion, Vector3, QuaternionOptions>)).SetWrapName ("DG_Tweening_Plugins_Options_Quaternion").SetLibName ("DG_Tweening_Plugins_Options_Quaternion"),
        _GT(typeof(TweenerCore<Color, Color, ColorOptions>)).SetWrapName ("DG_Tweening_Plugins_Options_Color").SetLibName ("DG_Tweening_Plugins_Options_Color"),


        // UnityEngine
        _GT(typeof(Behaviour)),
        _GT(typeof(MonoBehaviour)),
        _GT(typeof(GameObject)),
        _GT(typeof(TrackedReference)),
        _GT(typeof(Application)),
        _GT(typeof(RuntimePlatform)),
        _GT(typeof(Physics)),
        _GT(typeof(Collider)),
        _GT(typeof(Time)),
        _GT(typeof(Texture)),
        _GT(typeof(Texture2D)),
        _GT(typeof(Shader)),
        _GT(typeof(Renderer)),
        _GT(typeof(Screen)),
        _GT(typeof(CameraClearFlags)),
        _GT(typeof(AudioClip)),
        _GT(typeof(AssetBundle)),
        _GT(typeof(ParticleSystem)),
        _GT(typeof(AsyncOperation)).SetBaseType (typeof(object)),
        _GT(typeof(LightType)),
        _GT(typeof(SleepTimeout)),
        _GT(typeof(Animator)),
        _GT(typeof(AnimatorStateInfo)),
        _GT(typeof(AnimatorCullingMode)),
        _GT(typeof(RuntimeAnimatorController)),
        _GT(typeof(Input)),
        _GT(typeof(KeyCode)),
        _GT(typeof(SkinnedMeshRenderer)),
        _GT(typeof(Space)),

        _GT(typeof(MeshRenderer)),

        _GT(typeof(BoxCollider)),
        _GT(typeof(MeshCollider)),
        _GT(typeof(SphereCollider)),
        _GT(typeof(CharacterController)),
        _GT(typeof(CapsuleCollider)),

        _GT(typeof(Animation)),
        _GT(typeof(AnimationClip)).SetBaseType (typeof(UnityEngine.Object)),
        _GT(typeof(AnimationState)),
        _GT(typeof(AnimationBlendMode)),
        _GT(typeof(QueueMode)),
        _GT(typeof(PlayMode)),
        _GT(typeof(WrapMode)),

        _GT(typeof(QualitySettings)),
        _GT(typeof(RenderSettings)),
        _GT(typeof(BlendWeights)),
        _GT(typeof(RenderTexture)),
        _GT(typeof(Resources)),

        _GT(typeof(PlayerPrefs)),
        _GT(typeof(Canvas)),
        _GT(typeof(Sprite)),
        _GT(typeof(Font)),
        _GT(typeof(Rect)),
        _GT(typeof(LayerMask)),
        _GT(typeof(TextMesh)),
        _GT(typeof(MaterialPropertyBlock)),
        _GT(typeof(MeshFilter)),
        _GT(typeof(Mesh)),

        _GT(typeof(PointerEventData)),

        _GT(typeof(ScrollRect)),
        _GT(typeof(InputField)),
        _GT(typeof(Button)),
        _GT(typeof(Toggle)),
        _GT(typeof(Shadow)),
        _GT(typeof(RawImage)),


        // .Net
        _GT(typeof(DateTime)),


        #region ShibaInu
        _GT(typeof(Stage)),
        _GT(typeof(ResManager)),
        _GT(typeof(AudioManager)),
        _GT(typeof(NetHelper)),

        _GT(typeof(HttpRequest)),
        _GT(typeof(HttpDownload)),
        _GT(typeof(HttpUpload)),
        _GT(typeof(TcpSocket)),
        _GT(typeof(UdpSocket)),

        _GT(typeof(Picker)),
        _GT(typeof(BaseList)),
        _GT(typeof(ScrollList)),
        _GT(typeof(PageList)),
        _GT(typeof(ViewPager)),
        _GT(typeof(PageTransformerType)),
        _GT(typeof(CircleImage)),
        _GT(typeof(LocalizationText)),

        _GT(typeof(SafeAreaLayout)),
        _GT(typeof(PointerScaler)),
        _GT(typeof(PointerEventPasser)),
        _GT(typeof(FrameAnimationController)),
        _GT(typeof(ThirdPersonCamera)),

        _GT(typeof(DoubleImageShake)),
        _GT(typeof(Mosaic)),
        _GT(typeof(RadialBlur)),

        _GT(typeof(MD5Util)),
        _GT(typeof(ShibaInu.LuaProfiler)),
        _GT(typeof(ShibaInu.Logger)),
        #endregion


        // Project
        _GT(typeof(App.LuaHelper)),
        _GT(typeof(App.AstMsgProtocol)),


    };


    public static List<Type> dynamicList = new List<Type>() {
        typeof(MeshRenderer),

        typeof(BoxCollider),
        typeof(MeshCollider),
        typeof(SphereCollider),
        typeof(CharacterController),
        typeof(CapsuleCollider),

        typeof(Animation),
        typeof(AnimationClip),
        typeof(AnimationState),

        typeof(BlendWeights),
        typeof(RenderTexture),
        typeof(Rigidbody)
    };


    //重载函数，相同参数个数，相同位置out参数匹配出问题时, 需要强制匹配解决
    //使用方法参见例子14
    public static List<Type> outList = new List<Type>()
    {
    };


    //ngui优化，下面的类没有派生类，可以作为sealed class
    public static List<Type> sealedList = new List<Type>()
    {
    };


    public static BindType _GT(Type t)
    {
        return new BindType(t);
    }

    public static DelegateType _DT(Type t)
    {
        return new DelegateType(t);
    }


    //
}
