using System;
using System.Diagnostics;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 在 Start / Update / LateUpdate 触发时，调用 lua 层的 stage._loopHandler 函数。
	/// 更新 lua 层的 TimeUtil.time
	/// 该脚本只挂在 Common.go 上
	/// </summary>
	public class StageLooper : MonoBehaviour
	{
		private LuaFunction _loopHandler;
		private Stopwatch _stopwatch;



		void Start ()
		{
			_stopwatch = new Stopwatch ();
			_stopwatch.Start ();
			_loopHandler = Common.luaMgr.state.GetFunction ("Stage._loopHandler");// - View/Stage.lua
		}


		void Update ()
		{
			_loopHandler.BeginPCall ();
			_loopHandler.Push ("Update");
			_loopHandler.Push ((float)_stopwatch.ElapsedMilliseconds / 1000);
			_loopHandler.PCall ();
			_loopHandler.EndPCall ();
		}


		void LateUpdate ()
		{
			_loopHandler.BeginPCall ();
			_loopHandler.Push ("LateUpdate");
			_loopHandler.Push ((float)_stopwatch.ElapsedMilliseconds / 1000);
			_loopHandler.PCall ();
			_loopHandler.EndPCall ();
		}


		void FixedUpdate ()
		{
			_loopHandler.BeginPCall ();
			_loopHandler.Push ("FixedUpdate");
			_loopHandler.Push ((float)_stopwatch.ElapsedMilliseconds / 1000);
			_loopHandler.PCall ();
			_loopHandler.EndPCall ();
		}



		void OnDestroy ()
		{
			_stopwatch.Stop ();
			_stopwatch = null;
		}


		//
	}
}

