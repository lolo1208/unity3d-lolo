using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace ShibaInu
{
	public class ImportAsetAutoSetting:AssetPostprocessor
	{


		/// <summary>
		/// Raises the preprocess texture event.
		/// </summary>
		void OnPreprocessTexture ()
		{
			TextureImporter textureImporter = (TextureImporter)assetImporter;
			if (!string.IsNullOrEmpty (textureImporter.spritePackingTag))
				return; // 只修改第一次导入的图片

			// 类型
			textureImporter.textureType = TextureImporterType.Sprite;

			// 打包 tag，最多两级："Assets/Res/Textures/xxx/xxx"
			string[] dirs = assetPath.Split ('/');
			string tag = dirs [3];
			if (dirs.Length > 5)
				tag += "_" + dirs [4];
			textureImporter.spritePackingTag = tag;
		}


		//
	}
}

