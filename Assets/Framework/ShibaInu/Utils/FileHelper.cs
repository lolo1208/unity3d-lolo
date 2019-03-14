using System;
using System.IO;
using UnityEngine;


namespace ShibaInu
{

	/// <summary>
	/// 文件相关操作工具
	/// </summary>
	public class FileHelper
	{
		#if UNITY_ANDROID && !UNITY_EDITOR
		private static readonly AndroidJavaClass m_androidStreamingAssets = new AndroidJavaClass ("shibaInu.util.StreamingAssets");
		#endif



		/// <summary>
		/// 获取文件的字节内容
		/// </summary>
		/// <returns>The file bytes.</returns>
		/// <param name="path">文件的真实完整路径</param>
		public static byte[] GetBytes (string path)
		{
			#if UNITY_ANDROID && !UNITY_EDITOR

			if (path.StartsWith (Constants.PackageDir))
				return m_androidStreamingAssets.CallStatic<byte[]> ("getFileBytes", path.Replace (Constants.PackageDir, ""));
			else
				return File.ReadAllBytes (path);

			#else

			return File.ReadAllBytes (path);

			#endif
		}



		/// <summary>
		/// 文件是否存在
		/// </summary>
		/// <returns><c>true</c>, if exists was filed, <c>false</c> otherwise.</returns>
		/// <param name="path">文件的真实完整路径</param>
		public static bool Exists (string path)
		{
			#if UNITY_ANDROID && !UNITY_EDITOR

			if(path.StartsWith(Constants.PackageDir))
				return m_androidStreamingAssets.CallStatic<bool> ("exists", path.Replace (Constants.PackageDir, ""));
			else
				return File.Exists (path);

			#else

			return File.Exists (path);

			#endif
		}



		//
	}
}

