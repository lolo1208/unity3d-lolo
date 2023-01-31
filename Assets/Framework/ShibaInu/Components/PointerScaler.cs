using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 当 gameObject 与鼠标指针（touch）交互时，播放缩放缓动效果。
    /// </summary>
    [AddComponentMenu("ShibaInu/Pointer Scaler", 301)]
    [DisallowMultipleComponent]
    public class PointerScaler : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler
    {

        [Tooltip("正常状态下的缩放比例。默认值：0,0,0 表示在 Awake() 时获取 localScale")]
        public Vector3 normalScale = Vector3.zero;

        [Tooltip("OnPointerDown 时的缩放比例")]
        public float downScale = 0.95f;

        [Tooltip("OnPointerEnter 时的缩放比例")]
        public float enterScale = 1;

        [Tooltip("缓动效果的持续时间：秒")]
        public float tweenDuration = 0.06f;


        private Vector3 m_downScale = new Vector3();
        private Vector3 m_enterScale = new Vector3();
        private Tweener m_tweener;
        private bool m_pressed;


        void Awake()
        {
            UpdateScale();
        }


        /// <summary>
        /// 更新 normalScale 值。null = transform.localScale
        /// </summary>
        /// <param name="normalScale">Normal scale.</param>
        public void UpdateScale(Vector3? normalScale = null)
        {
            this.normalScale = normalScale ?? transform.localScale;
            float x = this.normalScale.x, y = this.normalScale.y, z = this.normalScale.z;
            m_downScale.Set(x * downScale, y * downScale, z);
            m_enterScale.Set(x * enterScale, y * enterScale, z);
        }


        [NoToLua]
        public void OnPointerEnter(PointerEventData eventData)
        {
            if (m_pressed)
                return;

            if (m_tweener != null)
                m_tweener.Kill();
            m_tweener = transform.DOScale(m_enterScale, tweenDuration);
        }


        [NoToLua]
        public void OnPointerExit(PointerEventData eventData)
        {
            if (m_pressed)
                return;

            if (m_tweener != null)
                m_tweener.Kill();
            m_tweener = transform.DOScale(normalScale, tweenDuration);
        }


        [NoToLua]
        public void OnPointerDown(PointerEventData eventData)
        {
            m_pressed = true;

            if (m_tweener != null)
                m_tweener.Kill();
            m_tweener = transform.DOScale(m_downScale, tweenDuration);
        }


        [NoToLua]
        public void OnPointerUp(PointerEventData eventData)
        {
            m_pressed = false;

            if (m_tweener != null)
                m_tweener.Kill();

            List<GameObject> hovered = eventData.hovered;
            m_tweener = transform.DOScale((hovered.Count > 0 && hovered[hovered.Count - 1] == gameObject) ? m_enterScale : normalScale, tweenDuration);
        }


        void OnDisable()
        {
            if (m_tweener != null)
            {
                m_tweener.Kill();
                m_tweener = null;
            }
            m_pressed = false;
            transform.localScale = normalScale;
        }

        //
    }
}

