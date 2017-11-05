using System;
using System.IO;


namespace ShibaInu
{

	/// <summary>
	/// 文件相关操作工具
	/// </summary>
	public class FileHelper
	{


		/// <summary>
		/// 获取文件的字节内容
		/// </summary>
		/// <returns>The file bytes.</returns>
		/// <param name="path">文件的真实完整路径</param>
		public static byte[] GetBytes (string path)
		{
			#if UNITY_ANDROID

			return null;

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
			#if UNITY_ANDROID

			return false;

			#else

			return File.Exists (path);

			#endif
		}




	}
}

