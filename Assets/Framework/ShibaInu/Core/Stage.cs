using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using LuaInterface;


namespace ShibaInu
{

    public static class Stage
    {
        /// UI 相机模态图像（背景）使用的 Shader
        private const string CAMERA_BLUR_SHADER = "ShibaInu/Effect/BoxBlur";

        /// UI Canvas
        public static Canvas uiCanvas;
        public static CanvasScaler uiCanvasScaler;
        public static RectTransform uiCanvasTra;
        // Layers
        public static RectTransform sceneLayer;
        public static RectTransform uiLayer;
        public static RectTransform windowLayer;
        public static RectTransform uiTopLayer;
        public static RectTransform alertLayer;
        public static RectTransform guideLayer;
        public static RectTransform topLayer;

        /// 不需要被销毁的对象列表
        private static readonly HashSet<Transform> s_dontDestroyList = new HashSet<Transform>();

        // 模态图像
        private static GameObject s_modalGo;
        private static RawImage s_modalImg;
        private static RectTransform s_modalTra;
        private static GameObject s_camBlurModalGo;
        private static RawImage s_camBlurModalImg;
        private static RectTransform s_camBlurModalTra;



        #region UI 初始化与清空销毁

        /// <summary>
        /// 初始化
        /// </summary>
        [NoToLua]
        public static void Initialize()
        {
            s_dontDestroyList.Clear();
            s_modalGo = s_camBlurModalGo = null;
            s_modalImg = s_camBlurModalImg = null;
            s_modalTra = s_camBlurModalTra = null;

            GameObject go = (GameObject)Object.Instantiate(ResManager.LoadAsset("Prefabs/Core/UICanvas.prefab", Constants.CoreAssetGroup), Common.go.transform);
            go.name = "UICanvas";
            uiCanvasTra = (RectTransform)go.transform;

            uiCanvas = go.GetComponent<Canvas>();
            uiCanvasScaler = go.GetComponent<CanvasScaler>();
            sceneLayer = (RectTransform)uiCanvasTra.Find("scene");
            uiLayer = (RectTransform)uiCanvasTra.Find("ui");
            windowLayer = (RectTransform)uiCanvasTra.Find("window");
            uiTopLayer = (RectTransform)uiCanvasTra.Find("uiTop");
            alertLayer = (RectTransform)uiCanvasTra.Find("alert");
            guideLayer = (RectTransform)uiCanvasTra.Find("guide");
            topLayer = (RectTransform)uiCanvasTra.Find("top");

            if (Common.IsOptimizeResolution) Common.OptimizeResolution();
        }


        /// <summary>
        /// 清空UI（切换场景时）
        /// </summary>
        public static void CleanUI()
        {
            for (int i = 0; i < uiCanvasTra.childCount; i++)
            {
                Transform layer = uiCanvasTra.GetChild(i);
                for (int n = 0; n < layer.childCount; n++)
                    DestroyChildUI(layer.GetChild(n));
            }
        }

        /// <summary>
        /// 销毁子UI
        /// </summary>
        /// <returns><c>true</c>, if child U was destroyed, <c>false</c> otherwise.</returns>
        /// <param name="tra">Tra.</param>
        private static bool DestroyChildUI(Transform tra)
        {
            if (s_dontDestroyList.Contains(tra))
                return false;// 本身不可销毁

            bool canDestroy = true;
            for (int i = tra.childCount - 1; i >= 0; i--)
            {
                // 子节点不可销毁
                Transform child = tra.GetChild(i);
                if (s_dontDestroyList.Contains(child))
                {
                    canDestroy = false;
                }
                else
                {
                    if (!DestroyChildUI(child))
                        canDestroy = false;
                }
            }
            if (canDestroy)
            {
                UnityEngine.Object.Destroy(tra.gameObject);
            }
            return canDestroy;
        }


        /// <summary>
        /// 添加一个在清空（切换）场景时，无需被销毁的对象（UI图层中的对象）
        /// </summary>
        /// <param name="go">Go.</param>
        public static void AddDontDestroy(GameObject go)
        {
            s_dontDestroyList.Add(go.transform);
        }

        /// <summary>
        /// 移除一个在清空（切换）场景时，无需被销毁的对象（UI图层中的对象）
        /// </summary>
        /// <param name="go">Go.</param>
        public static void RemoveDontDestroy(GameObject go)
        {
            s_dontDestroyList.Remove(go.transform);
        }

        #endregion



        #region UI 全屏模态遮盖（相机模糊图像）

        /// <summary>
        /// 显示全屏模态
        /// 模态对象为单例，就算调用该方法多次，也只会有一个模态实例存在
        /// </summary>
        /// <param name="parent"></param>
        /// <param name="color"></param>
        public static void ShowModal(RectTransform parent, Color color)
        {
            if (s_modalGo == null)
            {
                s_modalGo = LuaHelper.CreateGameObject("[Modal]", sceneLayer, false);
                s_modalImg = s_modalGo.AddComponent<RawImage>();
                s_modalTra = s_modalGo.transform as RectTransform;
                s_modalTra.anchorMin = s_modalTra.sizeDelta = Vector2.zero;
                s_modalTra.anchorMax = Vector2.one;
                AddDontDestroy(s_modalGo);
            }
            s_modalImg.color = color;
            s_modalTra.SetParent(parent, false);
            s_modalTra.SetAsFirstSibling();
            if (!s_modalGo.activeSelf)
                s_modalGo.SetActive(true);
        }

        /// <summary>
        /// 隐藏全屏模态
        /// </summary>
        public static void HideModal()
        {
            if (s_modalGo != null && s_modalGo.activeSelf)
                s_modalGo.SetActive(false);
        }


        /// <summary>
        /// 显示 全屏的经过简单均值模糊的相机图像（模态背景）
        /// 该图像为单例，每次调用该方法，都会更新图像内容
        /// </summary>
        /// <param name="parent"></param>
        /// <param name="camera"></param>
        public static void ShowCameraBlurModal(RectTransform parent, Camera camera)
        {
            if (s_camBlurModalGo == null)
            {
                s_camBlurModalGo = LuaHelper.CreateGameObject("[CameraBlurModal]", sceneLayer, false);
                s_camBlurModalImg = s_camBlurModalGo.AddComponent<RawImage>();
                s_camBlurModalTra = s_camBlurModalGo.transform as RectTransform;
                s_camBlurModalTra.anchorMin = s_camBlurModalTra.sizeDelta = Vector2.zero;
                s_camBlurModalTra.anchorMax = Vector2.one;
                s_camBlurModalImg.material = new Material(LuaHelper.GetShader(CAMERA_BLUR_SHADER));
                s_camBlurModalImg.texture = new RenderTexture(Screen.width >> 2, Screen.height >> 2, 0, RenderTextureFormat.ARGB32);
                s_camBlurModalImg.material.SetTexture("_MainTex", s_camBlurModalImg.texture);
                s_camBlurModalImg.material.SetFloat("_BlurRadius", 1f);
                AddDontDestroy(s_camBlurModalGo);
            }
            s_camBlurModalTra.SetParent(parent, false);
            s_camBlurModalTra.SetAsFirstSibling();
            if (!s_camBlurModalGo.activeSelf)
                s_camBlurModalGo.SetActive(true);

            RenderTexture rtCamera = camera.targetTexture;
            camera.targetTexture = s_camBlurModalImg.texture as RenderTexture;
            camera.Render();
            camera.targetTexture = rtCamera;
        }

        /// <summary>
        /// 隐藏相机模糊图像（模态背景）
        /// </summary>
        public static void HideCameraBlurModal()
        {
            if (s_camBlurModalGo != null && s_camBlurModalGo.activeSelf)
                s_camBlurModalGo.SetActive(false);
        }

        #endregion


        //
    }
}