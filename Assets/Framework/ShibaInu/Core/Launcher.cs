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
			Screen.sleepTimeout = SleepTimeout.NeverSleep;
			Application.targetFrameRate = Constants.FrameRate;
			Common.isDebug = Application.isEditor && !FileHelper.Exists (Application.streamingAssetsPath + "/TestModeFlag");

			bool isLauncherScene = SceneManager.GetActiveScene ().name == Constants.LauncherSceneName;
			if (!isLauncherScene)
				SceneManager.LoadScene (Constants.LauncherSceneName);

			StartCoroutine (Initialize (isLauncherScene));
		}


		/// <summary>
		/// 初始化
		/// </summary>
		IEnumerator Initialize (bool isLauncherScene)
		{
			if (!isLauncherScene)
				yield return new WaitForEndOfFrame ();// 等之前场景等内容清除完毕

			// UICanvas 放到 Common.go 对象下
			Transform uiCanvas = GameObject.Find ("UICanvas").transform;
			Transform eventSystem = GameObject.Find ("EventSystem").transform;
			uiCanvas.SetParent (transform);
			eventSystem.SetParent (transform);

			Common.lua = gameObject.AddComponent<LuaManager> ();
			Common.looper = gameObject.AddComponent<StageLooper> ();

			ResManager.Initialize ();
			Stage.uiCanvas = uiCanvas;
			Stage.Initialize ();
			Common.lua.Initialize ();// start lua

			Destroy (this);
		}

	}
}

