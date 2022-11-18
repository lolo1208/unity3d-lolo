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
        /// 目标平台名称 iOS Android
        private static readonly string[] Platforms = { "iPhone", "Android" };
        /// 已导入过的资源标记
        private const string UD_IMPORTED = "Imported";



        #region 纹理相关设置 和 spritePackingTag

        void OnPreprocessTexture()
        {
            if (Application.isBatchMode) return;
            if (Path.GetExtension(assetPath).ToLower() == ".dds")
            {
                LogError("警告：iOS 不支持 .dds 格式的纹理！" + assetPath);
                return;
            }
            if (IsImported()) return;

            TextureImporter importer = (TextureImporter)assetImporter;
            importer.isReadable = false;

            // ASTC 支持情况
            //   iOS: A8 - iphone6, iPad mini 4 开始支持
            //   Android: 部分 OpenGL ES 3.0 开始支持
            TextureImporterFormat textureFormat = importer.DoesSourceTextureHaveAlpha() ? TextureImporterFormat.ASTC_6x6 : TextureImporterFormat.ASTC_8x8;
            TextureCompressionQuality compressionQuality = TextureCompressionQuality.Normal;
            string upperPath = assetPath.ToUpper();
            string upperName = Path.GetFileNameWithoutExtension(upperPath);
            int maxTextureSize = 0;
            bool isSingleChannel = false;
            bool overridden = true;


            // UI - 目录或文件名包含 "UI" 字符
            if (upperPath.Contains("UI/") || upperPath.Contains("UI_") || upperPath.Contains("_UI"))
            {
                importer.textureType = TextureImporterType.Sprite;
                importer.mipmapEnabled = false;
                textureFormat = TextureImporterFormat.ASTC_6x6;
                // 根据目录来设置 spritePackingTag
                string tag = assetPath
                    .Replace(Constants.ResDirPath, "")
                    .Replace("/" + Path.GetFileName(assetPath), "")
                    .Replace("/", "_");
                importer.spritePackingTag = tag;
                Debug.LogFormat("{0} [spritePackingTag]: {1}", assetPath, tag);
            }
            else
            {
                importer.textureType = TextureImporterType.Default;
                importer.spritePackingTag = "";
                importer.mipmapEnabled = true;
                importer.streamingMipmaps = true;
                maxTextureSize = 1024;

                // 按文件名后缀来识别贴图类型，忽略大小写
                // Diffuse - 漫反射/颜色 贴图
                if (upperName.EndsWith("_D", StringComparison.Ordinal))
                {
                    importer.sRGBTexture = true;
                    compressionQuality = TextureCompressionQuality.Best;
                }

                // Normal - 法线贴图
                else if (upperName.EndsWith("_N", StringComparison.Ordinal))
                {
                    importer.textureType = TextureImporterType.NormalMap;
                    importer.sRGBTexture = true;
                    compressionQuality = TextureCompressionQuality.Best;
                    textureFormat = TextureImporterFormat.ASTC_5x5;
                }

                // Distort - 光照贴图
                else if (upperName.EndsWith("_LIGHTMAP", StringComparison.Ordinal))
                {
                    importer.textureType = TextureImporterType.Lightmap;
                    // overridden = false;
                }

                // Mask - 蒙版/遮罩 贴图
                else if (upperName.EndsWith("_M", StringComparison.Ordinal))
                {
                    importer.sRGBTexture = true;
                    compressionQuality = TextureCompressionQuality.Best;
                }

                // Thickness - 厚度贴图
                else if (upperName.EndsWith("_THICKNESS", StringComparison.Ordinal))
                {
                    isSingleChannel = true;
                    maxTextureSize = 128;
                }

                // Distort - 扭曲/变形 贴图
                else if (upperName.EndsWith("_DISTORT", StringComparison.Ordinal))
                {
                    isSingleChannel = true;
                    maxTextureSize = 128;
                }
            }

            // 单通道贴图设置
            if (isSingleChannel)
            {
                importer.textureType = TextureImporterType.SingleChannel;
                TextureImporterSettings importerSetting = new TextureImporterSettings();
                importer.ReadTextureSettings(importerSetting);
                importerSetting.singleChannelComponent = TextureImporterSingleChannelComponent.Red;
                importer.SetTextureSettings(importerSetting);
            }


            // 设置 Android 与 iOS
            foreach (string platform in Platforms)
            {
                TextureImporterPlatformSettings platformSettings = importer.GetPlatformTextureSettings(platform);
                importer.SetPlatformTextureSettings(new TextureImporterPlatformSettings
                {
                    allowsAlphaSplitting = platformSettings.allowsAlphaSplitting,
                    crunchedCompression = platformSettings.crunchedCompression,
                    name = platformSettings.name,
                    resizeAlgorithm = platformSettings.resizeAlgorithm,
                    textureCompression = TextureImporterCompression.Compressed,
                    compressionQuality = (int)compressionQuality,
                    maxTextureSize = maxTextureSize > 0 ? maxTextureSize : platformSettings.maxTextureSize,
                    format = textureFormat,
                    overridden = overridden
                });
            }
            MarkImported();
        }

        #endregion



        #region 音频压缩相关设置

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

        #endregion



        #region 模型，动画 相关设置

        void OnPreprocessModel()
        {
            if (IsImported()) return;
            ModelImporter importer = assetImporter as ModelImporter;

            // Scene
            importer.useFileScale = true;
            importer.importVisibility = false;
            importer.importCameras = false;
            importer.importLights = false;
            importer.preserveHierarchy = false;
            importer.sortHierarchyByName = false;

            // Mesh
            importer.meshCompression = ModelImporterMeshCompression.Off;// 开启该选项可节省本地磁盘空间，与运行时无关
            importer.optimizeMeshPolygons = true;
            importer.optimizeMeshVertices = true;
            importer.addCollider = false;
            importer.isReadable = false;

            // Geometry
            importer.importNormals = ModelImporterNormals.Import;
            importer.importBlendShapeNormals = ModelImporterNormals.Import;
            importer.keepQuads = false;
            importer.weldVertices = true;
            // importer.generateSecondaryUV = true;

            // Animation
            importer.animationCompression = ModelImporterAnimationCompression.Optimal;

            MarkImported();
        }

        #endregion



        #region 在 AssetImporter 中标记该资源是否已导入过

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
                Debug.LogFormat("{0} 已被导入过，本次导入过程将会被忽略！若要恢复默认设置，请右键点击该文件或目录，然后点击菜单项 [Reimport With Default Setting]", assetPath);
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

        #endregion



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
