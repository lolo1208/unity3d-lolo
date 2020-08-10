using System;
using System.Runtime.InteropServices;
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
        /// 设备设备的安全边界偏移值 [ top, bottom, left, right ]
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

            isNotchScreen = IsNotchScreen();
            if (isNotchScreen)
                GetSafeInsets();

            Debug.Log(
                "[Device] landscape: " + isLandscape.ToString() +
                ",  autoRotation: " + isAutoRotation.ToString() +
                ",  notchScreen: " + isNotchScreen.ToString() +
                ",  safeInsets: " + safeInsets[0] + "/" + safeInsets[1] + "/" + safeInsets[2] + "/" + safeInsets[3]
            );
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

            Debug.Log("[Device] deviceOrientation: " + Input.deviceOrientation);
            return true;
        }



        /// <summary>
        /// 当前设备是否为异形屏
        /// </summary>
        /// <returns><c>true</c>, if notch screen was ised, <c>false</c> otherwise.</returns>
        private static bool IsNotchScreen()
        {
#if UNITY_ANDROID && !UNITY_EDITOR

            return m_androidDeviceHelper.CallStatic<bool>("isNotchScreen");

#elif UNITY_IOS && !UNITY_EDITOR

            return IsNotchScreenImpl();

#endif

            return false;
        }


        /// <summary>
        /// 获取当前设备的安全区域边距
        /// </summary>
        private static void GetSafeInsets()
        {
#if UNITY_ANDROID && !UNITY_EDITOR

			string androidInsets = m_androidDeviceHelper.CallStatic<string> ("getSafeInsets");
			string[] insets = androidInsets.Split (',');
			if (insets.Length == 4) {
				safeInsets = new float[] {
					ToInsetValue (insets [0]),
					ToInsetValue (insets [1]),
					ToInsetValue (insets [2]),
					ToInsetValue (insets [3])
				};
			} else {
				float notchHeight = ToInsetValue ((insets.Length == 2) ? insets [1] : insets [0]);
				if (isLandscape) {
					if (isLandscapeLeft)
						safeInsets = new float[] { 0, 0, notchHeight, 0 };
					else
						safeInsets = new float[] { 0, 0, 0, notchHeight };
				} else {
					safeInsets = new float[] { notchHeight, 0, 0, 0 };
				}
			}

#elif UNITY_IOS && !UNITY_EDITOR

			float top, bottom, left, right;
			GetSafeInsetsImpl (out top, out bottom, out left, out right);
			float s = Common.GetFixedScreenScale ();
			safeInsets = new float[] { top * s, bottom * s, left * s, right * s };

#endif
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


        private static float ToInsetValue(float value)
        {
            return value * Common.GetFixedScreenScale();
        }

        private static float ToInsetValue(string value)
        {
            return ToInsetValue(float.Parse(value));
        }

#endif


#if UNITY_IOS && !UNITY_EDITOR
		
		[DllImport ("__Internal")]
		private static extern bool IsNotchScreenImpl ();

		[DllImport ("__Internal")]
		private static extern void GetSafeInsetsImpl (out float top, out float bottom, out float left, out float right);
        
        [DllImport ("__Internal")]
        private static extern void VibrateImpl (int style);

#endif


        //
    }
}

