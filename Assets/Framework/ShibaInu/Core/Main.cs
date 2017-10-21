using System;
using UnityEngine;


namespace ShibaInu 
{
	public class Main : MonoBehaviour
	{
		private static bool _initialized = false;


		void Start()
		{
			if (_initialized) {
				Destroy (this.gameObject);
				return;
			}
			_initialized = true;

			Common.go = new GameObject (Constants.GameObjectName);
			DontDestroyOnLoad (Common.go);
			Common.go.AddComponent<Launcher> ();

			Destroy (this.gameObject);
		}


	}
}

