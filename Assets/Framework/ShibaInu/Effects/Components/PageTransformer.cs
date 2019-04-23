using System;
using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// ViewPager 页面转换效果类型枚举
    /// </summary>
    public enum PageTransformerType
    {
        Scroll,
        Fade,
        ZoomOut,
        Depth
    }



    /// <summary>
    /// ViewPager 页面转换效果
    /// </summary>
    public static class PageTransformer
    {
        /// 临时使用的 Vector3 对象
        private static Vector3 tmpVec3 = new Vector3();



        /// <summary>
        /// 滚动
        /// 效果 = 位移
        /// </summary>
        public static void Scroll(GameObject view, float pos, float size, bool isVertical)
        {
            RectTransform tra = (RectTransform)view.transform;
            float val = pos * size;
            Vector3 cp = tra.localPosition;// 保持 z 不变
            if (isVertical)
            {
                cp.x = 0;
                cp.y = -val;// y 取反
            }
            else
            {
                cp.x = val;
                cp.y = 0;
            }
            tra.localPosition = cp;
        }



        /// <summary>
        /// 渐隐渐显
        /// 效果 = 位移 + 淡入淡出
        /// </summary>
        public static void Fade(GameObject view, float pos, float size, bool isVertical)
        {
            RectTransform tra = (RectTransform)view.transform;
            float val = pos * size;
            Vector3 cp = tra.localPosition;// 保持 z 不变
            if (isVertical)
            {
                cp.x = 0;
                cp.y = -val;// y 取反
            }
            else
            {
                cp.x = val;
                cp.y = 0;
            }
            tra.localPosition = cp;

            val = pos < 0 ? pos + 1 : 1 - pos;
            CanvasGroup cg = view.GetComponent<CanvasGroup>();
            if (cg == null)
                cg = view.AddComponent<CanvasGroup>();
            cg.alpha = val * 0.6f + 0.4f;
        }



        /// <summary>
        /// 缩放
        /// 效果 = 位移 + 淡入淡出 + 放大缩小
        /// </summary>
        public static void ZoomOut(GameObject view, float pos, float size, bool isVertical)
        {
            RectTransform tra = (RectTransform)view.transform;
            float val = pos * size;
            Vector3 cp = tra.localPosition;// 保持 z 不变
            if (isVertical)
            {
                cp.x = 0;
                cp.y = -val;// y 取反
            }
            else
            {
                cp.x = val;
                cp.y = 0;
            }
            tra.localPosition = cp;

            val = pos < 0 ? pos + 1 : 1 - pos;

            CanvasGroup cg = view.GetComponent<CanvasGroup>();
            if (cg == null)
                cg = view.AddComponent<CanvasGroup>();
            cg.alpha = val * 0.5f + 0.5f;

            float scale = val * 0.15f + 0.85f;
            tmpVec3.Set(scale, scale, 1);
            tra.localScale = tmpVec3;
        }



        /// <summary>
        /// 深度切换
        /// 效果 = 前（左）一张缩放不变 + 位移，后（右）一张位置不变 + 缩放
        /// </summary>
        public static void Depth(GameObject view, float pos, float size, bool isVertical)
        {
            RectTransform tra = (RectTransform)view.transform;
            float val = pos < 0 ? pos + 1 : 1 - pos;
            Vector3 cp = tra.localPosition;// 保持 z 不变

            CanvasGroup cg = view.GetComponent<CanvasGroup>();
            if (cg == null)
                cg = view.AddComponent<CanvasGroup>();
            cg.alpha = val * 0.7f + 0.3f;

            if (pos < 0)
            {
                val = pos * size;
                if (isVertical)
                {
                    cp.x = 0;
                    cp.y = -val;// y 取反
                }
                else
                {
                    cp.x = val;
                    cp.y = 0;
                }
                tra.SetAsLastSibling();

            }
            else
            {
                float scale = val * 0.25f + 0.75f;
                tmpVec3.Set(scale, scale, 1);
                tra.localScale = tmpVec3;
                tra.SetAsFirstSibling();

                cp.x = cp.y = 0;
            }
            tra.localPosition = cp;
        }



        //
    }
}

