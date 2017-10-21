using System;
using System.Diagnostics;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
	public class StageLooper : MonoBehaviour
	{
		private LuaFunction _loopHandler;
		private Stopwatch _stopwatch;



		void Start()
		{
			_stopwatch = new Stopwatch ();
			_stopwatch.Start ();
			_loopHandler = Common.lua.state.GetFunction ("stage._loopHandler");
		}


		void Update()
		{
			_loopHandler.BeginPCall ();
			_loopHandler.Push ("Update");
			_loopHandler.Push ((float)_stopwatch.ElapsedMilliseconds / 1000);
			_loopHandler.PCall ();
			_loopHandler.EndPCall ();
		}


		void LateUpdate()
		{
			_loopHandler.BeginPCall ();
			_loopHandler.Push ("LateUpdate");
			_loopHandler.Push ((float)_stopwatch.ElapsedMilliseconds / 1000);
			_loopHandler.PCall ();
			_loopHandler.EndPCall ();
		}


		void FixedUpdate()
		{
			_loopHandler.BeginPCall ();
			_loopHandler.Push ("FixedUpdate");
			_loopHandler.Push ((float)_stopwatch.ElapsedMilliseconds / 1000);
			_loopHandler.PCall ();
			_loopHandler.EndPCall ();
		}



		void Destroy() {
			_stopwatch.Stop ();
			_stopwatch = null;
		}


	}
}

