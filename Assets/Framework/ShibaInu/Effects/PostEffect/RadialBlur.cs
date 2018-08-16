using System;
using UnityEngine;
using UnityEngine.Serialization;


namespace ShibaInu
{
	/// <summary>
	/// 后处理效果 - 径向模糊
	/// </summary>
	[ExecuteInEditMode]
	public class RadialBlur : MonoBehaviour
	{
		public Shader shader = null;
		public Material material = null;

		/// 当前模糊强度
		private float m_curBlurFactor = 1f;
		/// 每秒递增的模糊强度
		private float m_addBlurFactor = 0f;
		/// 上次更新模糊强度的时间
		private float m_lastTime = 0f;
		/// 剩余持续时间
		private float m_remainTime = 0f;
		/// 结束时的回调
		private Action m_callback;


		//
		public float blurFactor {
			set {
				m_blurFactor = m_curBlurFactor = value;
				m_remainTime = 0f;
				m_callback = null;

				if (value >= 1) {
					this.enabled = false;
				} else {
					if (material != null)
						material.SetFloat ("_BlurFactor", value);
					this.enabled = true;
				}
			}

			get { return m_blurFactor; }
		}

		[Tooltip ("模糊强度")]
		[Range (1, 50)]
		[FormerlySerializedAs ("blurFactor"), SerializeField]
		private float m_blurFactor = 25f;
		//


		//
		public float centerX {
			set {
				m_centerX = value;
				if (material != null)
					material.SetFloat ("_CenterX", value);
			}

			get { return m_centerX; }
		}

		[Tooltip ("径向中心点X")]
		[Range (0, 1)]
		[FormerlySerializedAs ("centerX"), SerializeField]
		private float m_centerX = 0.5f;
		//


		//
		public float centerY {
			set {
				m_centerY = value;
				if (material != null)
					material.SetFloat ("_CenterY", value);
			}

			get { return m_centerY; }
		}

		[Tooltip ("径向中心点Y")]
		[Range (0, 1)]
		[FormerlySerializedAs ("centerY"), SerializeField]
		private float m_centerY = 0.5f;
		//



		public RadialBlur ()
		{
		}




		public void Play (float toBlurFactor, float duration, Action callback = null)
		{
			if (toBlurFactor < 1)
				toBlurFactor = 1;
			m_lastTime = TimeUtil.GetTimeSec ();
			m_remainTime = duration;
			m_addBlurFactor = (toBlurFactor - m_curBlurFactor) / duration;
			m_blurFactor = toBlurFactor;
			m_callback = callback;
			enabled = true;
		}



		void OnRenderImage (RenderTexture src, RenderTexture dest)
		{
			if (material == null) {
				if (shader != null && shader.isSupported) {
					material = new Material (shader);
					material.SetFloat ("_BlurFactor", m_curBlurFactor);
					material.SetFloat ("_CenterX", m_centerX);
					material.SetFloat ("_CenterY", m_centerY);
				}
			}

			if (material == null) {
				Graphics.Blit (src, dest);
				this.enabled = false;
				InvokeCallback ();
				return;
			}


			if (m_remainTime > 0) {
				float deltaTime = TimeUtil.GetTimeSec () - m_lastTime;
				if (deltaTime < m_remainTime) {
					m_remainTime -= deltaTime;
					m_lastTime = TimeUtil.timeSec;
				} else {
					deltaTime = m_remainTime;
					m_remainTime = 0f;
				}

				m_curBlurFactor += m_addBlurFactor * deltaTime;
				material.SetFloat ("_BlurFactor", m_curBlurFactor);

				// 无需再渲染了
				if (m_remainTime == 0) {
					if (m_blurFactor <= 1) {
						Graphics.Blit (src, dest);
						this.enabled = false;
						InvokeCallback ();
						return;
					}
					InvokeCallback ();
				}
			}

			Graphics.Blit (src, dest, material);
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

