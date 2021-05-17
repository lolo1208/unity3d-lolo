using System;
using UnityEngine;
using LuaInterface;
using ShibaInu;


namespace App
{
    /// <summary>
    /// 提供给 lua 调用的相关接口
    /// </summary>
    public class LuaHelper : ShibaInu.LuaHelper
    {

        #region 后处理效果

        /// <summary>
        /// 播放叠影抖动效果
        /// </summary>
        /// <returns>The double image shake.</returns>
        /// <param name="duration">Duration.</param>
        /// <param name="callback">Callback.</param>
        /// <param name="x">The x coordinate.</param>
        /// <param name="y">The y coordinate.</param>
        /// <param name="interval">Interval.</param>
        /// <param name="cam">Cam.</param>
        public static DoubleImageShake PlayDoubleImageShake(float duration, LuaFunction callback = null, float x = 35f, float y = 10f, float interval = 0.045f, Camera cam = null)
        {
            if (cam == null)
                cam = Camera.main;

            DoubleImageShake dis = (DoubleImageShake)AddOrGetComponent(cam.gameObject, typeof(DoubleImageShake));
            if (dis.shader == null)
                dis.shader = GetShader("Shaders/ShibaInu/PostEffect/DoubleImageShake.shader");

            Action action = null;
            if (callback != null)
                action = () =>
                {
                    callback.BeginPCall();
                    callback.Call();
                    callback.EndPCall();
                };
            dis.Play(duration, action, x, y, interval);
            return dis;
        }


        /// <summary>
        /// 播放马赛克效果
        /// </summary>
        /// <returns>The mosaic.</returns>
        /// <param name="toTileSize">To tile size.</param>
        /// <param name="duration">Duration.</param>
        /// <param name="callback">Callback.</param>
        /// <param name="cam">Cam.</param>
        public static Mosaic PlayMosaic(float toTileSize, float duration, LuaFunction callback = null, Camera cam = null)
        {
            if (cam == null)
                cam = Camera.main;

            Mosaic mosaic = (Mosaic)AddOrGetComponent(cam.gameObject, typeof(Mosaic));
            if (mosaic.shader == null)
                mosaic.shader = GetShader("Shaders/ShibaInu/PostEffect/Mosaic.shader");

            Action action = null;
            if (callback != null)
                action = () =>
                {
                    callback.BeginPCall();
                    callback.Call();
                    callback.EndPCall();
                };
            mosaic.Play(toTileSize, duration, action);
            return mosaic;
        }


        /// <summary>
        /// 播放径向模糊效果
        /// </summary>
        /// <returns>The radial blur.</returns>
        /// <param name="toBlurFactor">To blur factor.</param>
        /// <param name="duration">Duration.</param>
        /// <param name="callback">Callback.</param>
        /// <param name="cam">Cam.</param>
        public static RadialBlur PlayRadialBlur(float toBlurFactor, float duration, LuaFunction callback = null, Camera cam = null)
        {
            if (cam == null)
                cam = Camera.main;

            RadialBlur radialBlur = (RadialBlur)AddOrGetComponent(cam.gameObject, typeof(RadialBlur));
            if (radialBlur.shader == null)
                radialBlur.shader = GetShader("Shaders/ShibaInu/PostEffect/RadialBlur.shader");

            Action action = null;
            if (callback != null)
                action = () =>
                {
                    callback.BeginPCall();
                    callback.Call();
                    callback.EndPCall();
                };
            radialBlur.Play(toBlurFactor, duration, action);
            return radialBlur;
        }


        /// <summary>
        /// 启用或禁用高斯模糊效果
        /// </summary>
        /// <returns>The gaussian blur enabled.</returns>
        /// <param name="enabled">If set to <c>true</c> enabled.</param>
        /// <param name="blurRadius">Blur radius.</param>
        /// <param name="downSample">Down sample.</param>
        /// <param name="iteration">Iteration.</param>
        /// <param name="cam">Cam.</param>
        public static GaussianBlur SetGaussianBlurEnabled(bool enabled, float blurRadius = 0.6f, int downSample = 2, int iteration = 1, Camera cam = null)
        {
            if (cam == null)
                cam = Camera.main;

            GameObject camGO = cam.gameObject;
            GaussianBlur gaussianBlur = camGO.GetComponent<GaussianBlur>();

            if (enabled)
            {
                if (gaussianBlur == null)
                {
                    gaussianBlur = camGO.AddComponent<GaussianBlur>();
                    gaussianBlur.shader = GetShader("Shaders/ShibaInu/PostEffect/GaussianBlur.shader");
                }
                else
                    gaussianBlur.enabled = true;

                gaussianBlur.blurRadius = blurRadius;
                gaussianBlur.downSample = downSample;
                gaussianBlur.iteration = iteration;
            }

            //
            else
            {
                if (gaussianBlur != null)
                    gaussianBlur.enabled = false;
            }

            return gaussianBlur;
        }

        #endregion


        //
    }
}