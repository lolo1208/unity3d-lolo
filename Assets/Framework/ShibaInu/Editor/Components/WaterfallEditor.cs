using System;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
    [CustomEditor(typeof(Waterfall))]
    public class WaterfallEditor : ScrollListEditor
    {


        public WaterfallEditor()
        {
            m_c_count = new GUIContent("Count", "排列（目前仅支持单行或单列）");
            m_c_autoCount = new GUIContent("Auto", "Waterfall 不支持该选项");
            m_c_autoGap = new GUIContent("Auto", "Waterfall 不支持该选项");
            m_c_isAutoSize = new GUIContent("Auto Size", "Waterfall 不支持该选项");
        }


        public override bool RowCountEnabled
        {
            get { return false; }
        }

        public override bool ColumnCountEnabled
        {
            get { return false; }
        }


        public override bool HGapEnabled
        {
            get { return !m_scrollList.isVertical; }
        }

        public override bool VGapEnabled
        {
            get { return m_scrollList.isVertical; }
        }


        public override bool AutoItemCountEnabled
        {
            get { return false; }
        }

        public override bool AutoItemGapEnabled
        {
            get { return false; }
        }

        public override bool AutoSizeEnabled
        {
            get { return false; }
        }


        //
    }
}

