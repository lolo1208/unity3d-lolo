using System;
using System.IO;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;


namespace ShibaInu
{
	public class Launcher : MonoBehaviour
	{
		
		void Start ()
		{
			// 初始变量赋值
			Common.FixedValue = 640;
			Common.IsFixedWidth = false;
			DeviceHelper.SetScreenOrientation (true);
			Common.IsOptimizeResolution = true;
			Common.FrameRate = 60;
			Common.IsNeverSleep = true;
			#if UNITY_EDITOR
			Common.IsDebug = !File.Exists (Application.streamingAssetsPath + "/TestModeFlag");
			#endif


			// 先进入启动场景
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

			// UICanvas
			ResManager.Initialize ();
			GameObject uiCanvas = (GameObject)Instantiate (ResManager.LoadAsset ("Prefabs/Core/UICanvas.prefab", "Core"), transform);
			uiCanvas.name = "UICanvas";
			Stage.uiCanvasTra = (RectTransform)uiCanvas.transform;
			Stage.Initialize ();

			// EventSystem
			GameObject eventSystem = new GameObject ("EventSystem");
			eventSystem.AddComponent<EventSystem> ();
			eventSystem.AddComponent<StandaloneInputModule> ();
			eventSystem.transform.SetParent (transform);

			Common.looper = gameObject.AddComponent<Looper> ();
			Common.luaMgr = gameObject.AddComponent<LuaManager> ();

			TimeUtil.Initialize ();
			Logger.Initialize ();

			Common.initialized = true;
			Common.luaMgr.Initialize ();// start lua

			Destroy (this);
		}


		//
	}
}