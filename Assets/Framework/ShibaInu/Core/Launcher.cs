using System;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;


namespace ShibaInu
{
	public class Launcher : MonoBehaviour
	{
		
		void Awake()
		{
			Screen.sleepTimeout = SleepTimeout.NeverSleep;
			Application.targetFrameRate = Constants.FrameRate;

			if (SceneManager.GetActiveScene ().name != Constants.LauncherSceneName)
				SceneManager.LoadScene (Constants.LauncherSceneName);

			StartCoroutine (Initialize ());
		}


		/// <summary>
		/// 初始化
		/// </summary>
		IEnumerator Initialize()
		{
			yield return new WaitForEndOfFrame ();

			Common.lua = Common.go.AddComponent<LuaManager> ();
			Common.looper = Common.go.AddComponent<StageLooper> ();

			Common.lua.Initialize ();

			Destroy (this);
		}

	}
}

