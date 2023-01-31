using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// 瀑布流列表（目前只支持单行或单列），需配合 Waterfall.lua 使用
    /// </summary>
    [AddComponentMenu("ShibaInu/Waterfall", 104)]
    [DisallowMultipleComponent]
    public class Waterfall : ScrollList
    {


        public Waterfall()
        {
            m_columnCount = m_rowCount = 1;
        }


        //
    }
}

