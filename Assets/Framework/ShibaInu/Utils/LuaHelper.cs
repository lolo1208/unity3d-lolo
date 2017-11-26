using System;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{

	/// <summary>
	/// 提供给 lua 调用的相关接口
	/// </summary>
	public static class LuaHelper
	{


		/// <summary>
		/// 在指定的 gameObject 上添加 DestroyEventDispatcher 脚本。
		/// 当 gameObject 销毁时，在 lua 层（gameObject上）派发 DestroyEvent.DESTROY 事件。
		/// </summary>
		/// <param name="go">Go.</param>
		/// <param name="ed">Ed.</param>
		public static void AddDestroyEvent (GameObject go, LuaTable ed)
		{
			if (go.GetComponent<DestroyEventDispatcher> () == null)
				go.AddComponent<DestroyEventDispatcher> ().ed = ed;
		}


		/// <summary>
		/// 在指定的 gameObject 上添加 PointerEventDispatcher 脚本。
		/// 当 gameObject 与鼠标指针（touch）交互时，派发相关事件。
		/// </summary>
		/// <param name="go">Go.</param>
		/// <param name="ed">Ed.</param>
		public static void AddPointerEvent (GameObject go, LuaTable ed)
		{
			if (go.GetComponent<PointerEventDispatcher> () == null)
				go.AddComponent<PointerEventDispatcher> ().ed = ed;
		}



		//
	}
}

