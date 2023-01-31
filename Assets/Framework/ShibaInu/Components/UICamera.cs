using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// 设置 UI 使用的 Camera 的（正交）尺寸
    /// 需将该脚本挂在对应的 Camera 上
    /// </summary>
    [AddComponentMenu("ShibaInu/UI Camera", 401)]
    [DisallowMultipleComponent]
    [RequireComponent(typeof(Camera))]
    public class UICamera : MonoBehaviour
    {

        void Start()
        {
            if (Common.looper == null)
                return;

            ResizeCamera();

#if UNITY_EDITOR
            Common.looper.ResizeHandler.Add(ResizeCamera);
#else
			Destroy (this);
#endif
        }



        /// <summary>
        /// 重置相机尺寸
        /// </summary>
        public void ResizeCamera(object data = null)
        {
            Vector2 resolution = Stage.uiCanvasScaler.referenceResolution;
            int sw = Screen.width;
            int sh = Screen.height;
            float scale = (resolution.x / sw > resolution.y / sh) ? sw / resolution.x : sh / resolution.y;
            // size 的值是屏幕高度的一半；不用除 100，最终 canvas 的 scale 值为 1；粒子特效使用 UIParticle；
            gameObject.GetComponent<Camera>().orthographicSize = sh / 2f / scale;
        }



#if UNITY_EDITOR
        void OnDestroy()
        {
            if (Common.looper != null)
                Common.looper.ResizeHandler.Remove(ResizeCamera);
        }
#endif


        //
    }
}

