using System;
using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// 标记点
    /// </summary>
    [AddComponentMenu("ShibaInu/Mark Point", 502)]
    [DisallowMultipleComponent]
    public class MarkPoint : MonoBehaviour
    {

        [Tooltip("半径")]
        [Range(0.01f, 1f)]
        public float radius = 0.15f;

        [Tooltip("颜色")]
        public Color color = Color.yellow;



#if UNITY_EDITOR
        void OnDrawGizmos()
        {
            Gizmos.color = color;
            Gizmos.DrawWireSphere(transform.position, radius);
        }
#endif

        //
    }
}

