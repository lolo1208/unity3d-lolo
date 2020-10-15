//#define REINPORT_LUA_ON_PLAYING


using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using ShibaInu;


namespace App
{
    /// <summary>
    /// 项目添加新资源时，进行一些默认设置
    /// </summary>
    public class ImportAssetSettings : AssetPostprocessor
    {
        /// Android 平台名称
        private const string PLATFORM_ANDROID = "Android";
        /// iOS 平台名称
        private const string PLATFORM_IOS = "iPhone";
        /// 已导入过的资源标记
        private const string UD_IMPORTED = "Imported";



        /// <summary>
        /// 当前处理的资源是否已经导入过了
        /// </summary>
        /// <returns><c>true</c>, if ignored was caned, <c>false</c> otherwise.</returns>
        private bool IsImported()
        {
            if (Application.isBatchMode) return true;
            if (!assetPath.StartsWith(Constants.ResDirPath, StringComparison.Ordinal)) return true;
            if (assetImporter.userData == UD_IMPORTED)
            {
                Debug.Log(assetPath + " 已被导入过，本次导入过程将会被忽略！若要恢复默认设置，请右键点击该文件或目录，然后点击菜单项 [Reimport With Default Setting]");
                return true;
            }
            return false;
        }


        /// <summary>
        /// 标记该资源已经被导入过了
        /// </summary>
        private void MarkImported()
        {
            assetImporter.userData = UD_IMPORTED;
        }



        /// <summary>
        /// 设置纹理资源格式和 spritePackingTag
        /// </summary>
        void OnPreprocessTexture()
        {
            if (Path.GetExtension(assetPath).ToLower() == ".dds")
            {
                LogError("警告：iOS 不支持 .dds 格式的纹理！" + assetPath);
                return;
            }

            TextureImporter importer = (TextureImporter)assetImporter;
            // Sprite Texture（目录或文件名是否包含 UI 字符）
            bool isSprite = assetPath.Contains("UI/") || assetPath.Contains("UI_") || assetPath.Contains("_UI");

            // 验证纹理宽高是否为 4 的倍数（Android ETC2）
            if (!isSprite)
            {
                Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>(importer.assetPath);
                if (texture == null && importer.textureShape == TextureImporterShape.Texture2D)
                {
                    importer.SaveAndReimport();// 加载纹理数据失败（添加新文件）时，重新再来
                    return;
                }
                importer.spritePackingTag = "";

                if (texture != null && (texture.width % 4 != 0 || texture.height % 4 != 0))
                    LogWarning(assetPath + " 的宽高不是 4 的倍数，这将导致在打包 Android 时，无法压缩该图像！");
            }

            if (IsImported()) return;

            // 根据目录来设置 spritePackingTag
            if (isSprite)
            {
                importer.textureType = TextureImporterType.Sprite;
                importer.mipmapEnabled = false;

                string fileName = Path.GetFileName(assetPath);
                string tag = assetPath
                    .Replace(Constants.ResDirPath, "")
                    .Replace("/" + fileName, "")
                    .Replace("/", "_");
                importer.spritePackingTag = tag;
                Debug.Log(assetPath + " set spritePackingTag: " + tag);
            }

            // 设置各平台压缩格式
            SetTexturePlatformSetting(importer, PLATFORM_IOS);
            SetTexturePlatformSetting(importer, PLATFORM_ANDROID);
            importer.isReadable = false;
            MarkImported();
        }


        /// <summary>
        /// 设置纹理指定平台的格式，默认压缩
        /// </summary>
        /// <param name="importer">Importer.</param>
        /// <param name="platform">Platform.</param>
        private void SetTexturePlatformSetting(TextureImporter importer, string platform)
        {
            TextureImporterPlatformSettings platformSettings = importer.GetPlatformTextureSettings(platform);
            TextureImporterPlatformSettings settings = new TextureImporterPlatformSettings
            {
                allowsAlphaSplitting = platformSettings.allowsAlphaSplitting,
                crunchedCompression = platformSettings.crunchedCompression,
                maxTextureSize = platformSettings.maxTextureSize,
                name = platformSettings.name,
                resizeAlgorithm = platformSettings.resizeAlgorithm,

                textureCompression = TextureImporterCompression.Compressed,
                compressionQuality = (int)UnityEditor.TextureCompressionQuality.Normal,
                overridden = true
            };

            bool isAndroid = platform == PLATFORM_ANDROID;
            if (importer.DoesSourceTextureHaveAlpha())
                settings.format = isAndroid ? TextureImporterFormat.ETC2_RGBA8 : TextureImporterFormat.ASTC_RGBA_6x6;
            else
                settings.format = isAndroid ? TextureImporterFormat.ETC2_RGB4 : TextureImporterFormat.ASTC_RGB_6x6;
            importer.SetPlatformTextureSettings(settings);
        }



        /// <summary>
        /// 音频的压缩相关设置
        /// </summary>
        void OnPreprocessAudio()
        {
            if (IsImported()) return;

            AudioImporter importer = assetImporter as AudioImporter;

            // 根据音频时长来设置压缩方式
            AudioClip clip = AssetDatabase.LoadAssetAtPath<AudioClip>(importer.assetPath);
            if (clip == null)
            {
                importer.SaveAndReimport();// 加载音频数据失败（添加新文件）时，重新再来
                return;
            }

            AudioImporterSampleSettings setting = new AudioImporterSampleSettings
            {
                sampleRateSetting = AudioSampleRateSetting.OptimizeSampleRate,
                quality = 0.8f
            };

            float length = clip.length;
            if (length < 5)
            {
                // 短音效
                setting.loadType = AudioClipLoadType.DecompressOnLoad;
                setting.compressionFormat = AudioCompressionFormat.PCM;
            }
            else if (length < 15)
            {
                // 中等长度音效
                setting.loadType = AudioClipLoadType.CompressedInMemory;
                setting.compressionFormat = AudioCompressionFormat.ADPCM;
            }
            else
            {
                // BGM
                setting.loadType = AudioClipLoadType.CompressedInMemory;
                setting.compressionFormat = AudioCompressionFormat.Vorbis;
            }

            importer.forceToMono = true;
            importer.preloadAudioData = true;
            importer.defaultSampleSettings = setting;
            MarkImported();
        }



        /// <summary>
        /// 模型，动画的压缩相关设置
        /// </summary>
        void OnPreprocessModel()
        {
            if (IsImported()) return;

            ModelImporter importer = assetImporter as ModelImporter;
            importer.animationCompression = ModelImporterAnimationCompression.Optimal;
            importer.meshCompression = ModelImporterMeshCompression.Medium;
            //importer.importNormals = ModelImporterNormals.None;
            //importer.importMaterials = false;
            importer.optimizeMesh = true;
            //importer.optimizeGameObjects = true;
            importer.isReadable = false;
            MarkImported();
        }



        #region 在运行时动态更新（re-require）lua 文件
#if REINPORT_LUA_ON_PLAYING

        /// 动态更新的 lua 代码
        private const string UPDATE_LUA = @"
            local oldtable = package.loaded[{0}] or package.preload[{0}]
            if oldtable ~= nil then
                for k, v in pairs(oldtable) do
                    oldtable[k] = nil
                end
                package.loaded[{0}] = nil
                package.preload[{0}] = nil
                local newtable = require({0})
                setmetatable(oldtable, newtable)
                oldtable.__index = newtable
            end
        ";

        static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
        {
            if (!Application.isPlaying) return;

            foreach (string assetPath in importedAssets)
            {
                if (!assetPath.EndsWith(".lua", StringComparison.Ordinal)) continue;
                string luaPath = assetPath.Replace("\\", ".").Replace("/", ".");
                if (!luaPath.StartsWith("Assets.Lua", StringComparison.Ordinal)) continue;
                luaPath = luaPath.Substring(11, luaPath.Length - 15);// 去掉前面 "Assets.Lua." 和后面 ".lua"
                luaPath = "\"" + luaPath + "\"";
                Common.luaMgr.state.DoString(string.Format(UPDATE_LUA, luaPath));
            }
        }

#endif
        #endregion


        //
    }
}
