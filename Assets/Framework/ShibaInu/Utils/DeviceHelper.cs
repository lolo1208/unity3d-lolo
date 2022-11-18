using System.Runtime.InteropServices; // [DllImport]
using UnityEngine;


namespace ShibaInu
{

    /// <summary>
    /// 设备相关工具
    /// </summary>
    public static class DeviceHelper
    {

        /// 设备是否为横屏
        public static bool isLandscape;
        /// 设备是否支持自动旋转
        public static bool isAutoRotation;
        /// 当前设备方向是否为 LandscapeLeft
        public static bool isLandscapeLeft;

        /// 设备是否为异形屏
        public static bool isNotchScreen = false;
        /// 设备安全边界偏移值 [ top, bottom, left, right ]
        public static float[] safeInsets = { 0, 0, 0, 0 };



        /// <summary>
        /// 设置屏幕方向
        /// </summary>
        /// <param name="isLandscape">是否横屏</param>
        /// <param name="isAutoRotation">是否支持自动旋转（竖屏不支持旋转）</param>
        /// <param name="isLandscapeLeft">横屏，并且不支持旋转时，方向是否为 LandscapeLeft（Home 键在右边）</param>
        public static void SetScreenOrientation(bool isLandscape, bool isAutoRotation = true, bool isLandscapeLeft = true)
        {
            DeviceHelper.isLandscape = isLandscape;
            DeviceHelper.isAutoRotation = isAutoRotation;
            DeviceHelper.isLandscapeLeft = isLandscapeLeft;

            if (isLandscape)
            {
                if (isAutoRotation)
                {
                    Screen.orientation = ScreenOrientation.AutoRotation;
                    Screen.autorotateToLandscapeLeft = true;
                    Screen.autorotateToLandscapeRight = true;
                    Screen.autorotateToPortrait = false;
                    Screen.autorotateToPortraitUpsideDown = false;
                }
                else
                {
                    Screen.orientation = isLandscapeLeft ? ScreenOrientation.LandscapeLeft : ScreenOrientation.LandscapeRight;
                }
            }
            else
            {
                Screen.orientation = ScreenOrientation.Portrait;
            }

            Debug.LogFormat("[ShibaInu.DeviceHelper] landscape: {0}, autoRotation: {1}", isLandscape, isAutoRotation);
        }



        /// <summary>
        /// Looper 判断设备方向是否有变化
        /// </summary>
        public static bool Update()
        {
            if (!isLandscape || !isAutoRotation)
                return false;

            if (isLandscapeLeft)
            {
                if (Input.deviceOrientation != DeviceOrientation.LandscapeRight)
                    return false;
                isLandscapeLeft = false;
            }
            else
            {
                if (Input.deviceOrientation != DeviceOrientation.LandscapeLeft)
                    return false;
                isLandscapeLeft = true;
            }

            Debug.LogFormat("[ShibaInu.DeviceHelper] deviceOrientation: {0}", Input.deviceOrientation);
            return true;
        }



        /// <summary>
        /// 更新设备安全边界偏移值
        /// </summary>
        public static void UpdateSafeInsets()
        {
            Rect sa = Screen.safeArea; // 原点(0,0)在左下角
            int screenWidth = Screen.width;
            int screenHeight = Screen.height;
            isNotchScreen = sa.x != 0 || sa.y != 0 || sa.width != screenWidth || sa.height != screenHeight;
            if (isNotchScreen)
            {
                safeInsets[0] = screenHeight - sa.height - sa.y;
                safeInsets[1] = sa.y;
                safeInsets[2] = sa.x;
                safeInsets[3] = screenWidth - sa.width - sa.x;
            }
            Debug.LogFormat("[ShibaInu.DeviceHelper] notchScreen: {0}, safeInsets: {1}", isNotchScreen, string.Join(" / ", safeInsets));
        }



        /// <summary>
        /// 设备震动反馈
        /// </summary>
        /// <param name="style">震动方式 [ 1:轻微, 2:明显, 3:强烈 ]</param>
        public static void Vibrate(int style)
        {
#if UNITY_ANDROID && !UNITY_EDITOR

            m_androidDeviceHelper.CallStatic ("vibrate", style);

#elif UNITY_IOS && !UNITY_EDITOR

            VibrateImpl (style);

#endif
        }



#if UNITY_ANDROID && !UNITY_EDITOR

        private static readonly AndroidJavaClass m_androidDeviceHelper = new AndroidJavaClass("shibaInu.util.DeviceHelper");

#endif


#if UNITY_IOS && !UNITY_EDITOR
		
        [DllImport ("__Internal")]
        private static extern void VibrateImpl (int style);

#endif


        //
    }
}

