using System;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine.Serialization;


namespace ShibaInu
{
    /// <summary>
    /// 摄像机相关工具
    /// 该工具类只在 Editor Play Mode 使用
    /// </summary>
    [AddComponentMenu("ShibaInu/Camera Tool", 501)]
    [DisallowMultipleComponent]
    public class CameraTool : MonoBehaviour
    {

        void Awake()
        {
#if !UNITY_EDITOR
            Destroy(this);
#endif
        }



#if UNITY_EDITOR

        //
        public bool alignSceneView
        {
            set { m_alignSceneView = value; }
            get { return m_alignSceneView; }
        }

        [Tooltip("将相机的视角同步到 Editor Scene View")]
        [FormerlySerializedAs("alignSceneView"), SerializeField]
        protected bool m_alignSceneView = false;
        //


        //
        public string copyFormat
        {
            set { m_copyFormat = value; }
            get { return m_copyFormat; }
        }

        [Tooltip("拷贝到剪切板的字符串格式。p = localPosition。r = localEulerAngles")]
        [FormerlySerializedAs("copyFormat"), SerializeField]
        protected string m_copyFormat = "{ pos = Vector3.New(p.x, p.y, p.z), rot = Vector3.New(r.x, r.y, r.z) }";
        //



        void Update()
        {
            if (m_alignSceneView)
            {
                SceneView sv = SceneView.lastActiveSceneView;
                if (sv != null)
                    sv.AlignViewToObject(transform);
            }
        }

#endif


        //
    }
}

