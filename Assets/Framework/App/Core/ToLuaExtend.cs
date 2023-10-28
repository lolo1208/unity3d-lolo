using System.Collections.Generic;


namespace App
{
    /// <summary>
    /// ToLua 框架在游戏中的扩展
    /// </summary>
    public static class ToLuaExtend
    {


#if UNITY_EDITOR

        /// <summary>
        /// 在生成 Wraps 时，需要排除的内容
        /// </summary>
        public static List<string> MEMBER_FILTER = new List<string>
        {
            "String.Chars",
            "Directory.SetAccessControl",
            "File.GetAccessControl",
            "File.SetAccessControl",

            //UnityEngine
            "AnimationClip.averageDuration",
            "AnimationClip.averageAngularSpeed",
            "AnimationClip.averageSpeed",
            "AnimationClip.apparentSpeed",
            "AnimationClip.isLooping",
            "AnimationClip.isAnimatorMotion",
            "AnimationClip.isHumanMotion",
            "AnimatorOverrideController.PerformOverrideClipListCleanup",
            "AnimatorControllerParameter.name",
            "Caching.SetNoBackupFlag",
            "Caching.ResetNoBackupFlag",
            "Light.areaSize",
            "Light.lightmappingMode",
            "Light.lightmapBakeType",
            "Light.shadowAngle",
            "Light.shadowRadius",
            "Light.SetLightDirty",
            "Security.GetChainOfTrustValue",
            "Texture2D.alphaIsTransparency",
            "WWW.movie",
            "WWW.GetMovieTexture",
            "WebCamTexture.MarkNonReadable",
            "WebCamTexture.isReadable",
            "Graphic.OnRebuildRequested",
            "Text.OnRebuildRequested",
            "Resources.LoadAssetAtPath",
            "Application.ExternalEval",
            "Handheld.SetActivityIndicatorStyle",
            "CanvasRenderer.OnRequestRebuild",
            "CanvasRenderer.onRequestRebuild",
            "Terrain.bakeLightProbesForTrees",
            "MonoBehaviour.runInEditMode",
            "TextureFormat.DXT1Crunched",
            "TextureFormat.DXT5Crunched",
            "Texture.imageContentsHash",
            "QualitySettings.streamingMipmapsMaxLevelReduction",
            "QualitySettings.streamingMipmapsRenderersPerFrame",
	
            //NGUI
            "UIInput.ProcessEvent",
            "UIWidget.showHandlesWithMoveTool",
            "UIWidget.showHandles",
            "Input.IsJoystickPreconfigured",
            "UIDrawCall.isActive",
            "Dictionary.TryAdd",
            "KeyValuePair.Deconstruct",
            "ParticleSystem.SetJob",
            "Type.IsSZArray",

            // Upgrade Unity
            "ParticleSystem.SetParticles", // 2018.4.25
            "ParticleSystem.GetParticles",
            "LineRenderer.GetPositions", // 2020.3.12
            "TrailRenderer.GetPositions",
            "TrailRenderer.AddPositions",
            "MeshRenderer.scaleInLightmap",
            "MeshRenderer.stitchLightmapSeams",
            "MeshRenderer.receiveGI",
            "AudioSource.PlayOnGamepad", // 2020.3.29
            "AudioSource.DisableGamepadOutput",
            "AudioSource.GamepadSpeakerSupportsOutputType",
            "AudioSource.SetGamepadSpeakerMixLevel",
            "AudioSource.SetGamepadSpeakerMixLevelDefault",
            "AudioSource.SetGamepadSpeakerRestrictedAudio",
            "AudioSource.gamepadSpeakerOutputType",
            "DateTime.Parse", // 2021.3.6
            "DateTime.ParseExact",
            "DateTime.TryParse",
            "DateTime.TryFormat",
            "DateTime.TryParseExact",
            "TrailRenderer.GetVisiblePositions",// 2021.3.31
            "QualitySettings.GetAllRenderPipelineAssetsForPlatform",
        };

#endif


        //
    }
}