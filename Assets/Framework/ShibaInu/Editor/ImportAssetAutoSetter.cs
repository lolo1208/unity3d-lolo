using System;
using System.IO;
using UnityEditor;


namespace ShibaInu
{
    public class ImportAsetAutoSetting : AssetPostprocessor
    {
        private const string ROOT_DIR = "Assets/Res/Textures/";


        /// <summary>
        /// Raises the preprocess texture event.
        /// </summary>
        void OnPreprocessTexture()
        {
            if (!assetPath.StartsWith(ROOT_DIR, StringComparison.Ordinal))
                return;

            TextureImporter textureImporter = (TextureImporter)assetImporter;

            // 修改类型
            textureImporter.textureType = TextureImporterType.Sprite;

            // 根据目录来设置 spritePackingTag
            string fileName = Path.GetFileName(assetPath);
            string tag = assetPath
                .Replace(ROOT_DIR, "")
                .Replace("/" + fileName, "")
                .Replace("/", "_");

            if (tag == fileName)
                tag = "texture";

            textureImporter.spritePackingTag = tag;
            UnityEngine.Debug.Log("[" + assetPath + "] set spritePackingTag: [" + tag + "]");
        }


        //
    }
}
