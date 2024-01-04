using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;
using UnityEngine.Sprites;


namespace ShibaInu
{
    /// <summary>
    /// 圆形图片。
    /// 可以是整圆，也可以是圆环。
    /// 	基于 MaskableGraphic 实现，不会影响到图集 Drawcall。
    /// 	精确点击，基于 Ray-Crossing 算法。
    /// </summary>
    [AddComponentMenu("ShibaInu/Circle Image", 202)]
    [DisallowMultipleComponent]
    [RequireComponent(typeof(CanvasRenderer))]
    public class CircleImage : MaskableGraphic, ICanvasRaycastFilter
    {
        #region Inspector 可编辑属性

        public Sprite sourceImage
        {
            set
            {
                if (value != m_sourceImage)
                {
                    m_sourceImage = value;
                    SetAllDirty();
                }
            }
            get { return m_sourceImage; }
        }

        [Tooltip("源图像")]
        [FormerlySerializedAs("sourceImage"), SerializeField]
        protected Sprite m_sourceImage;


        public float fan
        {
            set
            {
                if (value != m_fan)
                {
                    m_fan = value;
                    SetVerticesDirty();
                }
            }
            get { return m_fan; }
        }

        [Tooltip("扇形比例，0=整圆")]
        [Range(0, 1)]
        [FormerlySerializedAs("fan"), SerializeField]
        protected float m_fan = 0f;


        public float ring
        {
            set
            {
                if (value != m_ring)
                {
                    m_ring = value;
                    SetVerticesDirty();
                }
            }
            get { return m_ring; }
        }

        [Tooltip("圆环比例，0=整圆")]
        [Range(0, 1)]
        [FormerlySerializedAs("ring"), SerializeField]
        protected float m_ring = 0f;


        public int sides
        {
            set
            {
                if (value != m_sides)
                {
                    m_sides = value;
                    SetVerticesDirty();
                }
            }
            get { return m_sides; }
        }

        [Tooltip("边数，值越大越接近圆形")]
        [Range(3, 100)]
        [FormerlySerializedAs("sides"), SerializeField]
        protected int m_sides = 30;

        #endregion



        /// <summary>
        /// Gets the main texture. override!
        /// </summary>
        /// <value>The main texture.</value>
        public override Texture mainTexture
        {
            get
            {
                return sourceImage == null ? s_WhiteTexture : sourceImage.texture;
            }
        }

        public Sprite sprite
        {
            set { sourceImage = value; }
            get { return m_sourceImage; }
        }

        public float pixelsPerUnit
        {
            get
            {
                float num = 100f;
                if (m_sourceImage)
                {
                    num = m_sourceImage.pixelsPerUnit;
                }
                float num2 = 100f;
                if (canvas)
                {
                    num2 = canvas.referencePixelsPerUnit;
                }
                return num / num2;
            }
        }

        /// <summary>
        /// Sets the size to match the content.
        /// </summary>
        public override void SetNativeSize()
        {
            if (m_sourceImage != null)
            {
                float pixelsPerUnit = this.pixelsPerUnit;
                rectTransform.sizeDelta = new Vector2(
                    m_sourceImage.rect.width / pixelsPerUnit,
                    m_sourceImage.rect.height / pixelsPerUnit
                );
                rectTransform.anchorMax = rectTransform.anchorMin;
                SetAllDirty();
            }
        }



        #region 实现圆形图像

        // 内环
        private List<Vector3> m_innerVertices = new List<Vector3>();
        // 外环
        private List<Vector3> m_outterVertices = new List<Vector3>();


        protected override void OnPopulateMesh(VertexHelper vh)
        {
            vh.Clear();

            m_innerVertices.Clear();
            m_outterVertices.Clear();

            float degreeDelta = (float)(2 * Mathf.PI / sides);
            int curSegements = (int)(sides * (1 - fan));

            float tw = rectTransform.rect.width;
            float th = rectTransform.rect.height;
            float outerRadius = rectTransform.pivot.x * tw;
            float innerRadius = rectTransform.pivot.x * tw - ((1 - ring) * rectTransform.rect.width / 2);

            Vector4 uv = sourceImage != null ? DataUtility.GetOuterUV(sourceImage) : Vector4.zero;

            float uvCenterX = (uv.x + uv.z) * 0.5f;
            float uvCenterY = (uv.y + uv.w) * 0.5f;
            float uvScaleX = (uv.z - uv.x) / tw;
            float uvScaleY = (uv.w - uv.y) / th;

            float curDegree = 0;
            UIVertex uiVertex;
            int verticeCount;
            int triangleCount;
            Vector2 curVertice;

            if (ring == 1)
            {
                //圆形
                curVertice = Vector2.zero;
                verticeCount = curSegements + 1;
                uiVertex = new UIVertex
                {
                    color = color,
                    position = curVertice,
                    uv0 = new Vector2(curVertice.x * uvScaleX + uvCenterX, curVertice.y * uvScaleY + uvCenterY)
                };
                vh.AddVert(uiVertex);

                for (int i = 1; i < verticeCount; i++)
                {
                    float cosA = Mathf.Cos(curDegree);
                    float sinA = Mathf.Sin(curDegree);
                    curVertice = new Vector2(cosA * outerRadius, sinA * outerRadius);
                    curDegree += degreeDelta;

                    uiVertex = new UIVertex
                    {
                        color = color,
                        position = curVertice,
                        uv0 = new Vector2(curVertice.x * uvScaleX + uvCenterX, curVertice.y * uvScaleY + uvCenterY)
                    };
                    vh.AddVert(uiVertex);

                    m_outterVertices.Add(curVertice);
                }

                triangleCount = curSegements * 3;
                for (int i = 0, vIdx = 1; i < triangleCount - 3; i += 3, vIdx++)
                {
                    vh.AddTriangle(vIdx, 0, vIdx + 1);
                }
                if (fan == 0)
                {
                    //首尾顶点相连
                    vh.AddTriangle(verticeCount - 1, 0, 1);
                }
            }
            else
            {
                //圆环
                verticeCount = curSegements * 2;
                for (int i = 0; i < verticeCount; i += 2)
                {
                    float cosA = Mathf.Cos(curDegree);
                    float sinA = Mathf.Sin(curDegree);
                    curDegree += degreeDelta;

                    curVertice = new Vector3(cosA * innerRadius, sinA * innerRadius);
                    uiVertex = new UIVertex
                    {
                        color = color,
                        position = curVertice,
                        uv0 = new Vector2(curVertice.x * uvScaleX + uvCenterX, curVertice.y * uvScaleY + uvCenterY)
                    };
                    vh.AddVert(uiVertex);
                    m_innerVertices.Add(curVertice);

                    curVertice = new Vector3(cosA * outerRadius, sinA * outerRadius);
                    uiVertex = new UIVertex
                    {
                        color = color,
                        position = curVertice,
                        uv0 = new Vector2(curVertice.x * uvScaleX + uvCenterX, curVertice.y * uvScaleY + uvCenterY)
                    };
                    vh.AddVert(uiVertex);
                    m_outterVertices.Add(curVertice);
                }

                triangleCount = curSegements * 3 * 2;
                for (int i = 0, vIdx = 0; i < triangleCount - 6; i += 6, vIdx += 2)
                {
                    vh.AddTriangle(vIdx + 1, vIdx, vIdx + 3);
                    vh.AddTriangle(vIdx, vIdx + 2, vIdx + 3);
                }
                if (fan == 0)
                {
                    //首尾顶点相连
                    vh.AddTriangle(verticeCount - 1, verticeCount - 2, 1);
                    vh.AddTriangle(verticeCount - 2, 0, 1);
                }
            }
        }


        public bool IsRaycastLocationValid(Vector2 screenPoint, Camera eventCamera)
        {
            if (sourceImage == null)
                return true;

            Vector2 pos;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, screenPoint, eventCamera, out pos);

            var crossNumber = 0;
            RayCrossing(pos, m_innerVertices, ref crossNumber);// 检测内环
            RayCrossing(pos, m_outterVertices, ref crossNumber);// 检测外环
            return (crossNumber & 1) == 1;
        }


        /// <summary>
        /// 判断点击是否在多边形内部
        /// </summary>
        /// <param name="p"></param>
        /// <param name="vertices"></param>
        /// <param name="crossNumber"></param>
        private void RayCrossing(Vector2 p, List<Vector3> vertices, ref int crossNumber)
        {
            for (int i = 0, count = vertices.Count; i < count; i++)
            {
                var v1 = vertices[i];
                var v2 = vertices[(i + 1) % count];

                // 点击点水平线必须与两顶点线段相交
                if (((v1.y <= p.y) && (v2.y > p.y))
                    || ((v1.y > p.y) && (v2.y <= p.y)))
                {
                    // 只考虑点击点右侧方向，点击点水平线与线段相交，且交点 x > 点击点 x，则 crossNumber+1
                    if (p.x < v1.x + (p.y - v1.y) / (v2.y - v1.y) * (v2.x - v1.x))
                    {
                        crossNumber += 1;
                    }
                }
            }
        }

        #endregion


        //
    }
}

