using System;
using UnityEngine;
using UnityEngine.SceneManagement;
using LuaInterface;
using DG.Tweening;


namespace ShibaInu
{

    /// <summary>
    /// ShibaInu 框架提供给 lua 调用的相关接口
    /// </summary>
    public class LuaHelper
    {
        /// 临时使用的 Vector3 对象
        protected static Vector3 tmpVec3 = new Vector3();



        #region 系统 / 信息

        /// <summary>
        /// 是否在编辑器中运行，并且在开发模式下
        /// </summary>
        /// <returns><c>true</c>, if debug was ised, <c>false</c> otherwise.</returns>
        public static bool IsDebug()
        {
            return Common.IsDebug;
        }


        /// <summary>
        /// 获取版本信息
        /// </summary>
        /// <returns>The version info.</returns>
        public static string GetVersionInfo()
        {
            return string.Format(@"{{
                ""CoreVersion"":""{0}"",
                ""FullVersion"":""{1}"",
                ""ResVersion"":""{2}"",
                ""BuildNumber"":""{3}"",
                ""PackID"":""{4}""
            }}",
                Common.VersionInfo.CoreVersion,
                Common.VersionInfo.FullVersion,
                Common.VersionInfo.ResVersion,
                Common.VersionInfo.BuildNumber,
                Common.VersionInfo.PackID
            );
        }


        /// <summary>
        /// 向 Native 发送消息
        /// </summary>
        /// <param name="action"></param>
        /// <param name="msg"></param>
        public static void SendMessageToNative(string action, string msg)
        {
            NativeHelper.SendMessageToNative(action, msg);
        }


        /// <summary>
        /// 设备震动反馈
        /// </summary>
        /// <param name="style">震动方式 [ 0:持续, 1:轻微, 2:明显, 3:强烈 ]</param>
        public static void DeviceVibrate(int style)
        {
#if !UNITY_STANDALONE && !UNITY_EDITOR
            if (style == 0)
            {
                Handheld.Vibrate();
            }
            else
            {
                DeviceHelper.Vibrate(style);
            }
#endif
        }


        /// <summary>
        /// 重启项目（动更完成后）
        /// </summary>
        public static void Relaunch()
        {
            DOTween.KillAll();
            Common.go.AddComponent<Launcher>();
        }

        #endregion



        #region GameObject / Transform

        /// <summary>
        /// 创建并返回一个空 GameObject
        /// </summary>
        /// <returns>The game object.</returns>
        /// <param name="name">名称</param>
        /// <param name="parent">父节点</param>
        /// <param name="notUI">是否不是 UI 对象</param>
        public static GameObject CreateGameObject(string name, Transform parent, bool notUI)
        {
            GameObject go;
            if (notUI)
                go = new GameObject(name);
            else
            {
                go = new GameObject(name, typeof(RectTransform))
                {
                    layer = LayerMask.NameToLayer("UI")
                };
            }

            if (parent != null)
            {
                go.transform.SetParent(parent, false);
            }

            return go;
        }


        /// <summary>
        /// 设置目标对象，以及子节点的所属图层
        /// </summary>
        /// <param name="target">Target.</param>
        /// <param name="layer">Layer.</param>
        public static void SetLayerRecursively(Transform target, int layer)
        {
            target.gameObject.layer = layer;
            foreach (Transform child in target)
                SetLayerRecursively(child, layer);
        }


        /// <summary>
        /// 销毁 target 的所有子节点（保留 target）
        /// </summary>
        /// <param name="target"></param>
        public static void DestroyChildren(Transform target)
        {
            for (int i = target.childCount - 1; i >= 0; i--)
            {
                GameObject.Destroy(target.GetChild(i).gameObject);
            }
        }


        /// <summary>
        /// 先找到 sceneName 对应的场景，然后在该场景中获取 objName 对应的根节点 GameObject，并返回该对象
        /// </summary>
        /// <param name="sceneName">场景名称</param>
        /// <param name="objName">要查找的根节点 GameObject 的名称</param>
        /// <returns></returns>
        public static GameObject FindRootObjectInScene(string sceneName, string objName)
        {
            Scene scene = SceneManager.GetSceneByName(sceneName);
            if (!scene.isLoaded || scene.rootCount == 0)
                return null;

            GameObject[] list = scene.GetRootGameObjects();
            foreach (GameObject go in list)
            {
                if (go.name == objName)
                    return go;
            }
            return null;
        }

        #endregion



        #region 转换

        /// <summary>
        /// 将世界（主摄像机）坐标转换成 UICanvas 坐标
        /// </summary>
        /// <returns>The to canvas point.</returns>
        /// <param name="pos">world position</param>
        public static Vector3 WorldToCanvasPoint(Vector3 pos)
        {
            pos = Camera.main.WorldToScreenPoint(pos);

            if (Stage.uiCanvas.renderMode == RenderMode.ScreenSpaceOverlay)
                return ScreenToCanvasPoint(pos);

            pos = Stage.uiCanvas.worldCamera.ScreenToWorldPoint(pos);
            Vector3 s = Stage.uiCanvasTra.localScale;
            //tmpVec3.Set(pos.x / s.x, pos.y / s.y, Stage.uiCanvasTra.anchoredPosition3D.z);
            tmpVec3.Set(pos.x / s.x, pos.y / s.y, 0);
            return tmpVec3;
        }


        /// <summary>
        /// 将屏幕坐标转换成 UICanvas 坐标
        /// </summary>
        /// <returns>The to canvas point.</returns>
        /// <param name="pos">Position.</param>
        /// <param name="parent">Parent.</param>
        public static Vector3 ScreenToCanvasPoint(Vector3 pos, RectTransform parent = null)
        {
            if (parent == null) parent = Stage.uiLayer;
            Camera cam = Stage.uiCanvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : Stage.uiCanvas.worldCamera;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(parent, pos, cam, out Vector2 p);
            //tmpVec3.Set(p.x, p.y, Stage.uiCanvasTra.anchoredPosition3D.z);
            tmpVec3.Set(p.x, p.y, 0);
            return tmpVec3;
        }

        #endregion



        #region 获取

        /// <summary>
        /// 通过名称获取 Shader(Always Included Shaders)，或通过路径加载 Shader(AssetBundle)
        /// </summary>
        /// <returns>The shader.</returns>
        /// <param name="nameOrPath">Name or path.</param>
        public static Shader GetShader(string nameOrPath)
        {
            Shader shader = Shader.Find(nameOrPath);
            if (shader == null)
                shader = ResManager.LoadShader(nameOrPath, Constants.CoreAssetGroup);
            return shader;
        }


        /// <summary>
        /// 添加或获取 GameObject 下的组件
        /// </summary>
        /// <returns>The or get component.</returns>
        /// <param name="go">Go.</param>
        /// <param name="componentType">Component type.</param>
        public static Component AddOrGetComponent(GameObject go, Type componentType)
        {
            Component c = go.GetComponent(componentType);
            if (c == null)
                c = go.AddComponent(componentType);
            return c;
        }


        /// <summary>
        /// 获取指定名字（gameObject.name）的标记点 GameObject
        /// </summary>
        /// <returns>The mark point game object.</returns>
        /// <param name="root">根节点</param>
        /// <param name="name">需匹配的 GameObject 名称</param>
        public static GameObject GetMarkPointGameObject(GameObject root, string name)
        {
            MarkPoint[] list = root.GetComponentsInChildren<MarkPoint>(true);
            foreach (MarkPoint mp in list)
            {
                GameObject go = mp.gameObject;
                if (go.name == name)
                    return go;
            }
            return null;
        }

        #endregion



        #region 其他

        /// <summary>
        /// 发送一条 http 请求，并返回对应 HttpRequest 实例
        /// </summary>
        /// <returns>The http request.</returns>
        /// <param name="url">URL.</param>
        /// <param name="callback">Callback.</param>
        /// <param name="postData">Post data.</param>
        public static HttpRequest SendHttpRequest(string url, LuaFunction callback, string postData)
        {
            HttpRequest req = new HttpRequest { url = url };

            if (postData != null)
            {
                req.method = HttpRequestMethod.POST;
                req.postData = postData;
            }

            if (callback != null)
                req.SetLuaCallback(callback);

            req.Send();
            return req;
        }

        #endregion



        #region Behaviours

        /// <summary>
        /// 在指定的 gameObject 上添加 DestroyEventDispatcher 脚本。
        /// 当 gameObject 销毁时，在 lua 层（gameObject上）派发 DestroyEvent.DESTROY 事件。
        /// </summary>
        /// <param name="go">Go.</param>
        /// <param name="ed">Ed.</param>
        public static void AddDestroyEvent(GameObject go, LuaTable ed)
        {
            DestroyEventDispatcher dispatcher = go.GetComponent<DestroyEventDispatcher>();
            if (dispatcher == null)
                dispatcher = go.AddComponent<DestroyEventDispatcher>();
            dispatcher.ed = ed;
        }


        /// <summary>
        /// 在指定的 gameObject 上添加 PointerEventDispatcher 脚本。
        /// 当 gameObject 与鼠标指针（touch）交互时，派发相关事件。
        /// </summary>
        /// <param name="go">Go.</param>
        /// <param name="ed">Ed.</param>
        public static void AddPointerEvent(GameObject go, LuaTable ed)
        {
            PointerEventDispatcher dispatcher = go.GetComponent<PointerEventDispatcher>();
            if (dispatcher == null)
                dispatcher = go.AddComponent<PointerEventDispatcher>();
            dispatcher.ed = ed;
        }


        /// <summary>
        /// 在指定的 gameObject 上添加 DragDropEventDispatcher 脚本。
        /// 当 gameObject 与鼠标指针（touch）交互时，派发拖放相关事件。
        /// </summary>
        /// <param name="go">Go.</param>
        /// <param name="ed">Ed.</param>
        public static void AddDragDropEvent(GameObject go, LuaTable ed)
        {
            DragDropEventDispatcher dispatcher = go.GetComponent<DragDropEventDispatcher>();
            if (dispatcher == null)
                dispatcher = go.AddComponent<DragDropEventDispatcher>();
            dispatcher.ed = ed;
        }


        /// <summary>
        /// 在指定的 gameObject 上添加 AvailabilityEventDispatcher 脚本。
        /// 当 gameObject 可用性有改变时（OnEnable() / OnDisable()），派发 AvailabilityEvent.CHANGED 事件
        /// </summary>
        /// <param name="go">Go.</param>
        /// <param name="ed">Ed.</param>
        public static void AddAvailabilityEvent(GameObject go, LuaTable ed)
        {
            AvailabilityEventDispatcher dispatcher = go.GetComponent<AvailabilityEventDispatcher>();
            if (dispatcher == null)
                dispatcher = go.AddComponent<AvailabilityEventDispatcher>();
            dispatcher.ed = ed;
        }


        /// <summary>
        /// 在指定的 gameObject 上添加 TriggerEventDispatcher 脚本。
        /// 当 gameObject 产生 Trigger 相关行为时，派发事件。
        /// </summary>
        /// <param name="go">Go.</param>
        /// <param name="ed">Ed.</param>
        public static void AddTriggerEvent(GameObject go, LuaTable ed)
        {
            TriggerEventDispatcher dispatcher = go.GetComponent<TriggerEventDispatcher>();
            if (dispatcher == null)
                dispatcher = go.AddComponent<TriggerEventDispatcher>();
            dispatcher.ed = ed;
        }

        #endregion



        #region 后处理效果

        /// <summary>
        /// 播放叠影抖动效果
        /// </summary>
        /// <returns>The double image shake.</returns>
        /// <param name="duration">Duration.</param>
        /// <param name="callback">Callback.</param>
        /// <param name="x">The x coordinate.</param>
        /// <param name="y">The y coordinate.</param>
        /// <param name="interval">Interval.</param>
        /// <param name="cam">Cam.</param>
        public static DoubleImageShake PlayDoubleImageShake(float duration, LuaFunction callback = null, float x = 35f, float y = 10f, float interval = 0.045f, Camera cam = null)
        {
            if (cam == null)
                cam = Camera.main;

            DoubleImageShake dis = (DoubleImageShake)AddOrGetComponent(cam.gameObject, typeof(DoubleImageShake));
            if (dis.shader == null)
                dis.shader = GetShader("Shaders/PostEffect/DoubleImageShake.shader");

            Action action = null;
            if (callback != null)
                action = () =>
                {
                    callback.BeginPCall();
                    callback.Call();
                    callback.EndPCall();
                };
            dis.Play(duration, action, x, y, interval);
            return dis;
        }


        /// <summary>
        /// 播放马赛克效果
        /// </summary>
        /// <returns>The mosaic.</returns>
        /// <param name="toTileSize">To tile size.</param>
        /// <param name="duration">Duration.</param>
        /// <param name="callback">Callback.</param>
        /// <param name="cam">Cam.</param>
        public static Mosaic PlayMosaic(float toTileSize, float duration, LuaFunction callback = null, Camera cam = null)
        {
            if (cam == null)
                cam = Camera.main;

            Mosaic mosaic = (Mosaic)AddOrGetComponent(cam.gameObject, typeof(Mosaic));
            if (mosaic.shader == null)
                mosaic.shader = GetShader("Shaders/PostEffect/Mosaic.shader");

            Action action = null;
            if (callback != null)
                action = () =>
                {
                    callback.BeginPCall();
                    callback.Call();
                    callback.EndPCall();
                };
            mosaic.Play(toTileSize, duration, action);
            return mosaic;
        }


        /// <summary>
        /// 播放径向模糊效果
        /// </summary>
        /// <returns>The radial blur.</returns>
        /// <param name="toBlurFactor">To blur factor.</param>
        /// <param name="duration">Duration.</param>
        /// <param name="callback">Callback.</param>
        /// <param name="cam">Cam.</param>
        public static RadialBlur PlayRadialBlur(float toBlurFactor, float duration, LuaFunction callback = null, Camera cam = null)
        {
            if (cam == null)
                cam = Camera.main;

            RadialBlur radialBlur = (RadialBlur)AddOrGetComponent(cam.gameObject, typeof(RadialBlur));
            if (radialBlur.shader == null)
                radialBlur.shader = GetShader("Shaders/PostEffect/RadialBlur.shader");

            Action action = null;
            if (callback != null)
                action = () =>
                {
                    callback.BeginPCall();
                    callback.Call();
                    callback.EndPCall();
                };
            radialBlur.Play(toBlurFactor, duration, action);
            return radialBlur;
        }


        /// <summary>
        /// 启用或禁用高斯模糊效果
        /// </summary>
        /// <returns>The gaussian blur enabled.</returns>
        /// <param name="enabled">If set to <c>true</c> enabled.</param>
        /// <param name="blurRadius">Blur radius.</param>
        /// <param name="downSample">Down sample.</param>
        /// <param name="iteration">Iteration.</param>
        /// <param name="cam">Cam.</param>
        public static GaussianBlur SetGaussianBlurEnabled(bool enabled, float blurRadius = 0.6f, int downSample = 2, int iteration = 1, Camera cam = null)
        {
            if (cam == null)
                cam = Camera.main;

            GameObject camGO = cam.gameObject;
            GaussianBlur gaussianBlur = camGO.GetComponent<GaussianBlur>();

            if (enabled)
            {
                if (gaussianBlur == null)
                {
                    gaussianBlur = camGO.AddComponent<GaussianBlur>();
                    gaussianBlur.shader = GetShader("Shaders/PostEffect/GaussianBlur.shader");
                }
                else
                    gaussianBlur.enabled = true;

                gaussianBlur.blurRadius = blurRadius;
                gaussianBlur.downSample = downSample;
                gaussianBlur.iteration = iteration;
            }

            //
            else
            {
                if (gaussianBlur != null)
                    gaussianBlur.enabled = false;
            }

            return gaussianBlur;
        }

        #endregion


        //
    }
}

