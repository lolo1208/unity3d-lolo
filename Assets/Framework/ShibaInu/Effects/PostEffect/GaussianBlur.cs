using System;
using UnityEngine;
using UnityEngine.Serialization;


namespace ShibaInu
{
	/// <summary>
	/// 后处理效果 - 高斯模糊
	/// </summary>
	[ExecuteInEditMode]
	[RequireComponent (typeof(Camera))]
	public class GaussianBlur : MonoBehaviour
	{
		public Shader shader = null;
		public Material material = null;


		[Tooltip ("模糊半径")]
		[Range (0, 1)]
		public float blurRadius = 0.6f;

		[Tooltip ("降分辨率")]
		[Range (0, 5)]
		public int downSample = 2;

		[Tooltip ("迭代次数")]
		[Range (0, 8)]
		public int iteration = 1;



		public GaussianBlur ()
		{
		}



		void OnRenderImage (RenderTexture src, RenderTexture dest)
		{
			if (material == null) {
				if (shader != null && shader.isSupported) {
					material = new Material (shader);
				}
			}

			if (material == null) {
				Graphics.Blit (src, dest);
				return;
			}

			// 申请RenderTexture，RT 的分辨率按照 downSample 降低
			int w = src.width >> downSample;
			int h = src.height >> downSample;
			RenderTexture rt1 = RenderTexture.GetTemporary (w, h, 0, src.format);
			RenderTexture rt2 = RenderTexture.GetTemporary (w, h, 0, src.format);

			// 直接将原图拷贝到降分辨率的RT上
			Graphics.Blit (src, rt1);

			// 进行迭代高斯模糊
			for (int i = 0; i < iteration; i++) {
				// 竖向模糊
				material.SetVector ("_offsets", new Vector4 (0, blurRadius, 0, 0));
				Graphics.Blit (rt1, rt2, material);
				// 横向模糊
				material.SetVector ("_offsets", new Vector4 (blurRadius, 0, 0, 0));
				Graphics.Blit (rt2, rt1, material);
			}

			// 将结果输出
			Graphics.Blit (rt1, dest);

			// 释放 RenderBuffer
			RenderTexture.ReleaseTemporary (rt1);
			RenderTexture.ReleaseTemporary (rt2);
		}


		//
	}
}