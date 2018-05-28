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
			if (Constants.OptimizeResolution && Screen.width > Constants.FixedWidth) {
				float scale = (float)Constants.FixedWidth / (float)Screen.width;
				int height = Mathf.CeilToInt (Screen.height * scale);
				Screen.SetResolution (Constants.FixedWidth, height, true);
				Debug.LogFormat ("resolution: {0} x {1},  scale: {2},  screen: {3} x {4}, {5}", Constants.FixedWidth, height, scale, Screen.width, Screen.height, Screen.resolutions.Length);
			}

			if (Constants.NeverSleep) {
				Screen.sleepTimeout = SleepTimeout.NeverSleep;
			}

			Application.targetFrameRate = Constants.FrameRate;

			Common.isDebug = Application.isEditor && !FileHelper.Exists (Application.streamingAssetsPath + "/TestModeFlag");

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
			Transform uiCanvas = GameObject.Find ("UICanvas").transform;
			Transform eventSystem = GameObject.Find ("EventSystem").transform;
			uiCanvas.SetParent (transform);
			eventSystem.SetParent (transform);

			Common.looper = gameObject.AddComponent<Looper> ();
			Common.luaMgr = gameObject.AddComponent<LuaManager> ();
			Common.timerMgr = gameObject.AddComponent<TimerManager> ();

			Stage.canvas = uiCanvas.gameObject.GetComponent<Canvas> ();
			Stage.uiCanvas = (RectTransform)uiCanvas;
			Stage.Initialize ();

			TimeUtil.Initialize ();
			ResManager.Initialize ();
			Common.luaMgr.Initialize ();// start lua

			Destroy (this);
		}

	}
}

