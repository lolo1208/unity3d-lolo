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
			// 只修改 Assets/Res/Textures/UI 文件夹下的纹理
			if (!assetPath.StartsWith ("Assets/Res/Textures/UI"))
				return;
			
			TextureImporter textureImporter = (TextureImporter)assetImporter;

			// 只修改没有 PackingTag 的图片
			if (!string.IsNullOrEmpty (textureImporter.spritePackingTag))
				return;

			// 类型
			textureImporter.textureType = TextureImporterType.Sprite;

			// 打包 tag，最多两级："Assets/Res/Textures/UI/xxx/yyy/zzz.png"
			string[] dirs = assetPath.Split ('/');
			string tag = dirs [4];
			if (dirs.Length > 6)
				tag += "_" + dirs [5]; // xxx_yyy
			textureImporter.spritePackingTag = tag;
		}


		//
	}
}

