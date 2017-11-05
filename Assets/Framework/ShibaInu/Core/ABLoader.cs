using System;
using System.Collections.Generic;
using UnityEngine;


namespace ShibaInu
{

	/// <summary>
	/// AssetBundle Info Object
	/// </summary>
	public class ABI
	{
		/// 已加载好的 AssetBundle，值为null，表示未加载
		public AssetBundle ab;

		/// 文件路径
		public string path;
		/// 文件 MD5
		public string md5;
		/// 已拼接好的文件完整真实路径，路径包括文件 MD5 以及 后缀名（加载ab包用这个路径）
		public string filePath;

		/// 依赖的 AB文件路径MD5 列表
		public List<string> pedList = new List<string> ();


		public ABI (string path, string md5, string dir)
		{
			this.path = dir + path;
			this.md5 = md5;
		}
	}



	/// <summary>
	/// AssetBundle 资源加载器
	/// </summary>
	public class ABLoader
	{

		private static ABI _currentABI;


		/// <summary>
		/// 同步加载指定的 AssetBundle
		/// </summary>
		/// <param name="abi">ABI 对象</param>
		public static void Load (ABI abi)
		{
			if (abi.ab != null)
				return;// AssetBundle 文件已加载

			// 先加载依赖的 AssetBundle
			foreach (string pathMD5 in abi.pedList) {
				ABI pedABI = ResManager.GetABI (pathMD5);
				if (pedABI.ab == null) {
					Load (pedABI);
				}
			}

			if (abi.filePath == null) {
				string realPath = abi.path + "_" + abi.md5 + Constants.AbExtName;
				string filePath = Constants.PackageDir + realPath;
				if (!FileHelper.Exists (filePath))
					filePath = Constants.UpdateDir + realPath;
				abi.filePath = filePath;
			}

			abi.ab = AssetBundle.LoadFromFile (abi.filePath);
		}


		//
	}
}

