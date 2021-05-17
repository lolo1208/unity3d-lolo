using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using LuaInterface;


namespace ShibaInu
{

    public static class Stage
    {
        /// UI Canvas
        public static Canvas uiCanvas;
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



        #region UI初始化与清空销毁

        /// <summary>
        /// 初始化
        /// </summary>
        [NoToLua]
        public static void Initialize()
        {
            s_dontDestroyList.Clear();

            GameObject go = (GameObject)Object.Instantiate(ResManager.LoadAsset("Prefabs/Core/UICanvas.prefab", Constants.CoreAssetGroup), Common.go.transform);
            go.name = "UICanvas";
            uiCanvasTra = (RectTransform)go.transform;

            uiCanvas = go.GetComponent<Canvas>();
            sceneLayer = (RectTransform)uiCanvasTra.Find("scene");
            uiLayer = (RectTransform)uiCanvasTra.Find("ui");
            windowLayer = (RectTransform)uiCanvasTra.Find("window");
            uiTopLayer = (RectTransform)uiCanvasTra.Find("uiTop");
            alertLayer = (RectTransform)uiCanvasTra.Find("alert");
            guideLayer = (RectTransform)uiCanvasTra.Find("guide");
            topLayer = (RectTransform)uiCanvasTra.Find("top");
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


        //
    }
}