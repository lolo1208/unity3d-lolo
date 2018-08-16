using System;
using UnityEngine;
using UnityEngine.Serialization;


namespace ShibaInu
{
	/// <summary>
	/// 后处理效果 - 马赛克
	/// </summary>
	[RequireComponent (typeof(Camera))]
	public class Mosaic : MonoBehaviour
	{

		public Shader shader = null;
		public Material material = null;

		/// 当前马赛克块尺寸
		private float m_curTileSize = 0.001f;
		/// 每秒递增的马赛克块尺寸
		private float m_addTileSize = 0f;
		/// 上次更新马赛克块尺寸的时间
		private float m_lastTime = 0f;
		/// 剩余持续时间
		private float m_remainTime = 0f;
		/// 结束时的回调
		private Action m_callback;


		//
		public float tileSize {
			set {
				m_tileSize = m_curTileSize = value;
				m_remainTime = 0f;
				m_callback = null;

				if (value >= 0) {
					this.enabled = false;
				} else {
					if (material != null)
						material.SetFloat ("_TileSize", value);
					this.enabled = true;
				}
			}

			get { return m_tileSize; }
		}

		[Tooltip ("马赛克块尺寸")]
		[Range (0, 1)]
		[FormerlySerializedAs ("tileSize"), SerializeField]
		private float m_tileSize = 0.05f;
		//



		public Mosaic ()
		{
		}


		public void Play (float toTileSize, float duration, Action callback = null)
		{
			if (toTileSize < 0.001)
				toTileSize = 0.001f;
			m_lastTime = TimeUtil.GetTimeSec ();
			m_remainTime = duration;
			m_addTileSize = (toTileSize - m_curTileSize) / duration;
			m_tileSize = toTileSize;
			m_callback = callback;
			enabled = true;
		}



		void OnRenderImage (RenderTexture src, RenderTexture dest)
		{
			if (material == null) {
				if (shader != null && shader.isSupported) {
					material = new Material (shader);
					material.SetFloat ("_TileSize", m_curTileSize);
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

				m_curTileSize += m_addTileSize * deltaTime;
				material.SetFloat ("_TileSize", m_curTileSize);

				// 无需再渲染了
				if (m_remainTime == 0) {
					if (m_tileSize <= 0.001) {
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

