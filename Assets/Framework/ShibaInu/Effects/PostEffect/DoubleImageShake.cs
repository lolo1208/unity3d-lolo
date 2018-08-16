using System;
using UnityEngine;
using UnityEngine.Serialization;


namespace ShibaInu
{
	/// <summary>
	/// 后处理效果 - 叠影抖动
	/// </summary>
	[RequireComponent (typeof(Camera))]
	public class DoubleImageShake : MonoBehaviour
	{

		public Shader shader = null;
		public Material material = null;

		/// 剩余持续时间
		private float m_remainTime = 0f;
		/// 该时间后进行下一次抖动
		private float m_intervalTime = 0f;
		/// 结束时的回调
		private Action m_callback;

		private Vector4 m_tmpVec4 = new Vector4 ();


		//
		public Vector2 shakeRange {
			set {
				m_shakeRange = value;
				m_remainTime = 0f;
				m_callback = null;
				this.enabled = true;
			}

			get { return m_shakeRange; }
		}

		[Tooltip ("抖动范围")]
		[FormerlySerializedAs ("shakeRange"), SerializeField]
		private Vector2 m_shakeRange = new Vector2 (35, 10);
		//


		//
		public float shakeInterval {
			set {
				m_intervalTime = 0f;
				m_shakeInterval = value;
			}

			get { return m_shakeInterval; }
		}

		[Tooltip ("抖动间隔时间")]
		[Range (0, 1)]
		[FormerlySerializedAs ("shakeInterval"), SerializeField]
		private float m_shakeInterval = 0.045f;
		//


		void Start ()
		{
		}



		public void Play (float duration, Action callback = null, float x = 35f, float y = 10f, float interval = 0.045f)
		{
			m_shakeRange.Set (x, y);
			m_remainTime = duration;
			m_shakeInterval = interval;
			m_intervalTime = 0f;
			m_callback = callback;
			this.enabled = true;
		}



		void OnRenderImage (RenderTexture src, RenderTexture dest)
		{
			if (material == null) {
				if (shader != null && shader.isSupported)
					material = new Material (shader);
			}

			if (material == null) {
				Graphics.Blit (src, dest);
				this.enabled = false;
				InvokeCallback ();
				return;
			}


			// 持续时间控制
			bool endFlag = false;
			if (m_remainTime > 0) {
				m_remainTime -= Time.deltaTime;
				endFlag = m_remainTime <= 0;
			}


			// 间隔控制
			m_intervalTime -= Time.deltaTime;
			if (m_intervalTime > 0 && !endFlag) {
				Graphics.Blit (src, dest, material);
				return;
			} else {
				m_intervalTime = m_shakeInterval;
			}


			float x = m_shakeRange.x / Screen.width;
			float y = m_shakeRange.y / Screen.height;
			m_tmpVec4.Set (
				UnityEngine.Random.Range (-x, x),
				UnityEngine.Random.Range (-y, y),
				UnityEngine.Random.Range (-x / 2, x / 2),
				UnityEngine.Random.Range (-y / 2, y / 2)
			);
			material.SetVector ("_ShakePosition", m_tmpVec4);
			Graphics.Blit (src, dest, material);


			// 无需再渲染了
			if (endFlag) {
				Graphics.Blit (src, dest);
				this.enabled = false;
				InvokeCallback ();
			}
		}



		/// <summary>
		/// Invokes the callback.
		/// </summary>
		private void InvokeCallback ()
		{
			var callback = m_callback;
			if (callback != null) {
				m_callback = null;
				callback ();
			}
		}


		//
	}
}

