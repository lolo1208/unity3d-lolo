using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// 对 UI 使用的 Camera 进行相关设置
    /// 需将该脚本挂在对应的 Camera 上
    /// </summary>
    [AddComponentMenu("ShibaInu/UI Camera", 201)]
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
            float scale, size;
            if (Common.IsFixedWidth)
            {
                scale = (float)Screen.width / Common.FixedValue;
                size = Screen.height / 100f / 2f / scale;
            }
            else
            {
                scale = (float)Screen.height / Common.FixedValue;
                size = Screen.width / 100f / 2f / scale;
            }
            gameObject.GetComponent<Camera>().orthographicSize = size;
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

