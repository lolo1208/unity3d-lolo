using System;
using UnityEngine;


namespace ShibaInu
{
	/// <summary>
	/// 对 UI 使用的 Camera 进行相关设置
	/// 需将该脚本挂在对应的 Camera 上
	/// </summary>
	[AddComponentMenu ("ShibaInu/UICamera", 201)]
	[DisallowMultipleComponent]
	public class UICamera : MonoBehaviour
	{


		void Awake ()
		{
			float scale = (float)Screen.width / (float)Constants.FixedWidth;
			float size = (float)Screen.height / 100f / 2f / scale;
			Camera camera = gameObject.GetComponent<Camera> ();
			camera.orthographicSize = size;

			Destroy (this);
		}


		//
	}
}

