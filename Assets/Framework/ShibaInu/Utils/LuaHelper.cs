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
		/// 临时使用的 Vector3 对象
		private static Vector3 tmpVec3 = new Vector3 ();




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


		/// <summary>
		/// 在指定的 gameObject 上添加 DragDropEventDispatcher 脚本。
		/// 当 gameObject 与鼠标指针（touch）交互时，派发拖放相关事件。
		/// </summary>
		/// <param name="go">Go.</param>
		/// <param name="ed">Ed.</param>
		public static void AddDragDropEvent (GameObject go, LuaTable ed)
		{
			if (go.GetComponent<DragDropEventDispatcher> () == null)
				go.AddComponent<DragDropEventDispatcher> ().ed = ed;
		}


		/// <summary>
		/// 创建并返回一个空 GameObject
		/// </summary>
		/// <returns>The game object.</returns>
		/// <param name="name">名称</param>
		/// <param name="parent">父节点</param>
		/// <param name="notUI">是否不是 UI 对象</param>
		public static GameObject CreateGameObject (string name, Transform parent, bool notUI)
		{
			GameObject go;
			if (notUI)
				go = new GameObject (name);
			else {
				go = new GameObject (name, typeof(RectTransform));
				go.layer = LayerMask.NameToLayer ("UI");
			}
			
			if (parent != null) {
				SetParent (go.transform, parent);
			}

			return go;
		}


		/// <summary>
		/// 设置 target 的父节点为 parent。
		/// 设置 target.layer 属性。
		/// 并将 localScale, localPosition 属性重置。
		/// </summary>
		/// <param name="target">Target.</param>
		/// <param name="parent">Parent.</param>
		public static void SetParent (Transform target, Transform parent)
		{
			SetLayerRecursively (target, parent.gameObject.layer);
			target.SetParent (parent, true);
			target.localScale = Vector3.one;
			target.localPosition = Vector3.zero;
		}


		/// <summary>
		/// 设置目标对象，以及子节点的所属图层
		/// </summary>
		/// <param name="target">Target.</param>
		/// <param name="layer">Layer.</param>
		public static void SetLayerRecursively (Transform target, int layer)
		{
			target.gameObject.layer = layer;
			foreach (Transform child in target)
				SetLayerRecursively (child, layer);
		}


		/// <summary>
		/// 将世界（主摄像机）坐标转换成 UICanvas 的坐标
		/// </summary>
		/// <returns>The to canvas point.</returns>
		/// <param name="pos">world position</param>
		public static Vector3 WorldToCanvasPoint(Vector3 pos)
		{
			pos = Camera.main.WorldToScreenPoint (pos);
			pos = Stage.canvas.worldCamera.ScreenToWorldPoint (pos);
			Vector3 s = Stage.uiCanvas.localScale;
			tmpVec3.Set (pos.x / s.x, pos.y / s.y, Stage.uiCanvas.anchoredPosition3D.z);
			return tmpVec3;
		}


		/// <summary>
		/// 发送一条 http 请求，并返回对应 HttpRequest 实例
		/// </summary>
		/// <returns>The http request.</returns>
		/// <param name="url">URL.</param>
		/// <param name="callback">Callback.</param>
		/// <param name="postData">Post data.</param>
		public static HttpRequest SendHttpRequest (string url, LuaFunction callback, string postData)
		{
			HttpRequest req = new HttpRequest ();
			req.url = url;

			if (postData != null) {
				req.method = HttpRequestMethod.POST;
				req.postData = postData;
			}

			if (callback != null)
				req.SetLuaCallback (callback);

			req.Send ();
			return req;
		}


		//
	}
}

