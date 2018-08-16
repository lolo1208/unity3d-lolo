using System;
using System.IO;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;


namespace ShibaInu
{
	public class Launcher : MonoBehaviour
	{
		
		void Start ()
		{
			
			// 初始变量赋值
			Common.FrameRate = 60;
			Common.FixedWidth = 1136;
			Common.OptimizeResolution = false;
			Common.NeverSleep = true;

			#if UNITY_EDITOR
			Common.isDebug = !File.Exists (Application.streamingAssetsPath + "/TestModeFlag");
			#endif
			//


			// 等比降低分辨率
			if (Common.OptimizeResolution && Screen.width > Common.FixedWidth) {
				float scale = (float)Common.FixedWidth / (float)Screen.width;
				int height = Mathf.CeilToInt (Screen.height * scale);
				Screen.SetResolution (Common.FixedWidth, height, true);
				Debug.LogFormat ("resolution: {0} x {1},  scale: {2},  screen: {3} x {4}, {5}", Common.FixedWidth, height, scale, Screen.width, Screen.height, Screen.resolutions.Length);
			}

			if (Common.NeverSleep)
				Screen.sleepTimeout = SleepTimeout.NeverSleep;

			Application.targetFrameRate = Common.FrameRate;


			// Call Initialize
			if (SceneManager.GetActiveScene ().name != Constants.LauncherSceneName)
				SceneManager.LoadScene (Constants.LauncherSceneName);
			
			StartCoroutine (Initialize ());
		}


		/// <summary>
		/// 初始化
		/// </summary>
		IEnumerator Initialize ()
		{
			yield return new WaitForEndOfFrame ();// 等之前场景等内容清除完毕

			// UICanvas 放到 Common.go 对象下
			Transform uiCanvasTra = GameObject.Find ("UICanvas").transform;
			Transform eventSystem = GameObject.Find ("EventSystem").transform;
			uiCanvasTra.SetParent (transform);
			eventSystem.SetParent (transform);

			Common.looper = gameObject.AddComponent<Looper> ();
			Common.luaMgr = gameObject.AddComponent<LuaManager> ();

			Stage.uiCanvas = uiCanvasTra.gameObject.GetComponent<Canvas> ();
			Stage.uiCanvasTra = (RectTransform)uiCanvasTra;
			Stage.Initialize ();

			TimeUtil.Initialize ();
			ResManager.Initialize ();
			Common.luaMgr.Initialize ();// start lua

			Destroy (this);
		}


		//
	}
}

