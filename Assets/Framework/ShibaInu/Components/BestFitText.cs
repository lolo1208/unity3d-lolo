using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


namespace ShibaInu
{
    /// <summary>
    /// 在启用 Best Fit 时，更准确找到适合渲染区域的文本 Size
    /// 与 Text 的差异在于：看上去是优先换行，而不是优先减少文本 Size
    /// </summary>
    public class BestFitText : Text
    {
        private readonly UIVertex[] _tmpVerts = new UIVertex[4];


        private void UseFitSettings()
        {
            TextGenerationSettings settings = GetGenerationSettings(rectTransform.rect.size);
            settings.resizeTextForBestFit = false;

            if (!resizeTextForBestFit)
            {
                cachedTextGenerator.PopulateWithErrors(text, settings, gameObject);
                return;
            }

            int txtLen = text.Length;
            int minSize = resizeTextMinSize;

            // 从大到小，寻找合适的 size
            for (int i = resizeTextMaxSize; i >= minSize; --i)
            {
                settings.fontSize = i;
                cachedTextGenerator.PopulateWithErrors(text, settings, gameObject);
                if (cachedTextGenerator.characterCountVisible == txtLen) break;
            }
        }


        protected override void OnPopulateMesh(VertexHelper toFill)
        {
            if (null == font) return;

            m_DisableFontTextureRebuiltCallback = true;
            UseFitSettings();

            IList<UIVertex> verts = cachedTextGenerator.verts;
            float unitsPerPixel = 1 / pixelsPerUnit;
            int vertCount = verts.Count;

            if (vertCount <= 0)
            {
                toFill.Clear();
                return;
            }

            Vector2 roundingOffset = new Vector2(verts[0].position.x, verts[0].position.y) * unitsPerPixel;
            roundingOffset = PixelAdjustPoint(roundingOffset) - roundingOffset;
            toFill.Clear();

            for (int i = 0; i < vertCount; ++i)
            {
                int tempVertsIndex = i & 3;
                _tmpVerts[tempVertsIndex] = verts[i];
                _tmpVerts[tempVertsIndex].position *= unitsPerPixel;
                if (roundingOffset != Vector2.zero)
                {
                    _tmpVerts[tempVertsIndex].position.x += roundingOffset.x;
                    _tmpVerts[tempVertsIndex].position.y += roundingOffset.y;
                }
                if (tempVertsIndex == 3)
                    toFill.AddUIVertexQuad(_tmpVerts);
            }

            m_DisableFontTextureRebuiltCallback = false;
        }
    }
}