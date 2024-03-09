using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;
using UnityEngine.Sprites;


namespace ShibaInu
{
    /// <summary>
    /// 圆角矩形。
    /// 可以四个角的半径相同（统一调整），也可以四个角的半径单独调整。
    /// </summary>
    [AddComponentMenu("ShibaInu/Rounded Image", 203)]
    [DisallowMultipleComponent]
    [RequireComponent(typeof(CanvasRenderer))]
    public class RoundedImage : MaskableGraphic
    {
        private const string SHADER_PATH_DEFAULT = "ShibaInu/Component/RoundedImage";
        private const string SHADER_PATH_INDEPENDENT = "ShibaInu/Component/RoundedImageIndependent";

        private static readonly int PROP_ID_SizeRadius = Shader.PropertyToID("_SizeRadius");
        private static readonly int PROP_ID_Radiuses = Shader.PropertyToID("_Radiuses");
        private static readonly int PROP_ID_HalfSize = Shader.PropertyToID("_HalfSize");
        private static readonly int PROP_ID_RectProps = Shader.PropertyToID("_RectProps");


        // Vector2.right rotated clockwise by 45 degrees
        private static readonly Vector2 s_wNorm = new Vector2(0.7071068f, -0.7071068f);
        // Vector2.right rotated counter-clockwise by 45 degrees
        private static readonly Vector2 s_hNorm = new Vector2(0.7071068f, 0.7071068f);


        private Material m_currentMaterial;
        private Texture m_texture;



        protected override void Awake()
        {
            RefreshMaterial();
        }



        #region Inspector 可编辑属性
        //


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


        // 是否单独设置四个角的半径
        public bool isIndependent
        {
            set
            {
                if (value != m_isIndependent)
                {
                    m_isIndependent = value;
                    RefreshMaterial();
                }
            }
            get { return m_isIndependent; }
        }

        [FormerlySerializedAs("isIndependent"), SerializeField]
        protected bool m_isIndependent;


        public uint Radius
        {
            set
            {
                if (value != m_radius)
                {
                    m_radius = value;
                    RefreshShader();
                }
            }
            get { return m_radius; }
        }

        [Tooltip("统一调整四个角的半径")]
        [FormerlySerializedAs("radius"), SerializeField]
        protected uint m_radius = 10;


        public Vector4 Radiuses
        {
            set
            {
                if (value != m_radiuses)
                {
                    m_radiuses = value;
                    RefreshShader();
                }
            }
            get { return m_radiuses; }
        }

        [Tooltip("单独调整四个角的半径，[x:左上, y:右上, z:右下, w:左下]")]
        [FormerlySerializedAs("radiuses"), SerializeField]
        protected Vector4 m_radiuses = new(10f, 10f, 10f, 10f);


        //
        #endregion



        /// <summary>
        /// Gets the main texture. override!
        /// </summary>
        /// <value>The main texture.</value>
        public override Texture mainTexture
        {
            get
            {
                if (m_texture == null)
                {
                    return sourceImage == null ? s_WhiteTexture : sourceImage.texture;
                }
                return m_texture;
            }
        }

        /// <summary>
        /// The RoundedImage's texture to be used.
        /// </summary>
        public Texture texture
        {
            set
            {
                if (value != m_texture)
                {
                    m_texture = value;
                    SetVerticesDirty();
                    SetMaterialDirty();
                }
            }
            get { return m_texture; }
        }

        /// <summary>
        /// The sprite that is used to render this image.
        /// </summary>
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



        /// <summary>
        /// 更新材质
        /// </summary>
        public void RefreshMaterial()
        {
            m_currentMaterial = new Material(Shader.Find(m_isIndependent ? SHADER_PATH_INDEPENDENT : SHADER_PATH_DEFAULT));
            material = m_currentMaterial;
            RefreshShader();
        }


        /// <summary>
        /// 更新 Shader 参数
        /// </summary>
        public void RefreshShader()
        {
            Rect rect = ((RectTransform)transform).rect;
            Material mat = material;

            if (m_isIndependent)
            {
                Vector2 size = rect.size;
                var rectProps = new Vector4();

                // Vector that goes from left to right sides of rect2
                var aVec = new Vector2(size.x, -size.y + m_radiuses.x + m_radiuses.z);
                // Project vector aVec to wNorm to get magnitude of rect2 width vector
                var halfWidth = Vector2.Dot(aVec, s_wNorm) * .5f;
                rectProps.z = halfWidth;
                // Vector that goes from bottom to top sides of rect2
                var bVec = new Vector2(size.x, size.y - m_radiuses.w - m_radiuses.y);
                // Project vector bVec to hNorm to get magnitude of rect2 height vector
                var halfHeight = Vector2.Dot(bVec, s_hNorm) * .5f;
                rectProps.w = halfHeight;
                // Vector that goes from left to top sides of rect2
                var efVec = new Vector2(size.x - m_radiuses.x - m_radiuses.y, 0);
                // Vector that goes from point E to point G, which is top-left of rect2
                var egVec = s_hNorm * Vector2.Dot(efVec, s_hNorm);
                // Position of point E relative to center of coord system
                var ePoint = new Vector2(m_radiuses.x - (size.x / 2), size.y / 2);
                // Origin of rect2 relative to center of coord system
                // ePoint + egVec == vector to top-left corner of rect2
                // wNorm * halfWidth + hNorm * -halfHeight == vector from top-left corner to center
                Vector2 origin = ePoint + egVec + s_wNorm * halfWidth + s_hNorm * -halfHeight;
                rectProps.x = origin.x;
                rectProps.y = origin.y;

                mat.SetVector(PROP_ID_RectProps, rectProps);
                mat.SetVector(PROP_ID_HalfSize, size * 0.5f);
                mat.SetVector(PROP_ID_Radiuses, m_radiuses);
            }
            else
            {
                mat.SetVector(PROP_ID_SizeRadius, new Vector4(rect.width, rect.height, m_radius * 2, 0));
            }
        }



#if UNITY_EDITOR

        protected override void OnValidate()
        {
            base.OnValidate();

            if (m_currentMaterial == null)
                RefreshMaterial();
            else
                RefreshShader();
        }

#endif


        //
    }
}