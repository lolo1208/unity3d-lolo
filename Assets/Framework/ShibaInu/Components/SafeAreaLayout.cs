using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 安全区域布局
    /// </summary>
    [AddComponentMenu("ShibaInu/Safe Area Layout", 204)]
    [DisallowMultipleComponent]
    public class SafeAreaLayout : MonoBehaviour
    {
        /// 安全区域容器
        private static RectTransform s_safeArea;



        // 原始布局信息
        private Vector2 m_offsetMin;
        private Vector2 m_offsetMax;



        /// <summary>
        /// 更新安全区域位置和尺寸（设备方向有改变时）
        /// </summary>
        private static void UpdateSafeArea(object ignored = null)
        {
            float[] insets = DeviceHelper.safeInsets;
            if (DeviceHelper.isLandscapeLeft)
            {
                s_safeArea.offsetMin = new Vector2(insets[2], insets[1]);// +left, +bottom
                s_safeArea.offsetMax = new Vector2(-insets[3], -insets[0]);// -right, -top
            }
            else
            {
                s_safeArea.offsetMin = new Vector2(insets[3], insets[1]);// +left, +bottom
                s_safeArea.offsetMax = new Vector2(-insets[2], -insets[0]);// -right, -top
            }
        }



        void Start()
        {
            if (!DeviceHelper.isNotchScreen)
            {
                Destroy(this);
                return;
            }

            // 是否横屏，并且可以翻转
            bool canTurnScreen = DeviceHelper.isLandscape && DeviceHelper.isAutoRotation;

            // 创建安全区域容器
            if (s_safeArea == null)
            {
                GameObject safeArea = LuaHelper.CreateGameObject("[SafeArea]", Stage.uiCanvasTra, false);
                safeArea.SetActive(false);
                s_safeArea = (RectTransform)safeArea.transform;
                s_safeArea.anchorMin = Vector2.zero;
                s_safeArea.anchorMax = Vector2.one;

                UpdateSafeArea();
                Common.looper.ResizeHandler.Add(UpdateSafeArea);
                if (canTurnScreen)
                    Common.looper.ScreenOrientationHandler.Add(UpdateSafeArea);
            }

            UpdateLayout();
            Common.looper.ResizeHandler.Add(LayoutInSafeArea);
            if (canTurnScreen)
                Common.looper.ScreenOrientationHandler.Add(LayoutInSafeArea);
        }


        /// <summary>
        /// 更新布局（记录原始布局信息）
        /// </summary>
        public void UpdateLayout()
        {
            RectTransform tra = (RectTransform)transform;
            m_offsetMin = tra.offsetMin;
            m_offsetMax = tra.offsetMax;
            LayoutInSafeArea();
        }


        /// <summary>
        /// 在安全区域内布局（设备方向有改变时）
        /// </summary>
        /// <param name="ignored">Ignored.</param>
        private void LayoutInSafeArea(object ignored = null)
        {
            // 记录更换容器可能会改变的属性
            Transform parent = transform.parent;
            float z = transform.localPosition.z;
            Vector3 scale = transform.localScale;
            int siblingIndex = transform.GetSiblingIndex();

            // 恢复原始布局信息
            RectTransform tra = (RectTransform)transform;
            tra.offsetMin = m_offsetMin;
            tra.offsetMax = m_offsetMax;

            // 放到 SafeArea 调整位置和尺寸
            transform.SetParent(s_safeArea, false);

            // 还原容器和属性
            transform.SetParent(parent);
            transform.SetSiblingIndex(siblingIndex);
            Vector3 pos = transform.localPosition;
            pos.z = z;
            transform.localPosition = pos;
            transform.localScale = scale;
        }



        void OnDestroy()
        {
            Common.looper.ResizeHandler.Remove(LayoutInSafeArea);
            Common.looper.ScreenOrientationHandler.Remove(LayoutInSafeArea);
        }



        #region 清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void ClearReference()
        {
            Common.looper.ResizeHandler.Remove(UpdateSafeArea);
            Common.looper.ScreenOrientationHandler.Remove(UpdateSafeArea);
            s_safeArea = null;
        }

        #endregion


        //
    }
}

