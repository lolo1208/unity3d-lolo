using System;
using System.IO;
using UnityEngine;


namespace ShibaInu
{
	public class ResManager
	{


		public static GameObject test ()
		{
			AssetBundle.LoadFromFile ("Assets/StreamingAssets/Res/texture/test_bar_123.unity3d");


			AssetBundle ab = AssetBundle.LoadFromFile ("Assets/StreamingAssets/Res/prefab/test/testui.unity3d");
			GameObject prefab = (GameObject)ab.LoadAsset ("Assets/Res/Prefab/Test/TestUI.prefab");
			return prefab;

//			AssetBundle ab = AssetBundle.LoadFromFile ("Assets/StreamingAssets/Res/Scene/BBB.unity3d");
//			ab.Unload (true);
//			UnityEngine.SceneManagement.SceneManager.LoadScene ("BBB");

			return null;
		}


		//
	}
}

