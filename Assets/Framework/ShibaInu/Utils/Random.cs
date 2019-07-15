using System;


namespace ShibaInu
{
    /// <summary>
    /// 随机数
    /// 使用 System.Random 随机库（线性同余法）
    /// </summary>
    public class Random
    {
        private System.Random m_rnd;
        private int m_seed;


        /// <summary>
        /// 随机种子
        /// 设置值小于等于 0 时，使用 DateTime.Now.Ticks 作为随机种子
        /// </summary>
        /// <value>The seed.</value>
        public int Seed
        {
            set
            {
                if (value <= 0)
                    value = (int)DateTime.Now.Ticks;
                m_seed = value;
                m_rnd = new System.Random(value);
            }
            get { return m_seed; }
        }



        public Random(int seed = 0)
        {
            Seed = seed;
        }


        /// <summary>
        /// 返回一个非负随机整数
        /// </summary>
        /// <returns>The next.</returns>
        public int Next()
        {
            return m_rnd.Next();
        }


        /// <summary>
        /// 返回一个小于所指定最大值的非负随机整数
        /// </summary>
        /// <returns>The next.</returns>
        /// <param name="max">Max.</param>
        public int Next(int max)
        {
            return m_rnd.Next(max);
        }


        /// <summary>
        /// 返回在指定范围内的任意整数
        /// </summary>
        /// <returns>The next.</returns>
        /// <param name="min">Minimum.</param>
        /// <param name="max">Max.</param>
        public int Next(int min, int max)
        {
            return m_rnd.Next(min, max);
        }



        /// <summary>
        /// 返回一个大于或等于 0.0 且小于 1.0 的随机浮点数
        /// </summary>
        /// <returns>The float.</returns>
        public float NextFloat()
        {
            return (float)m_rnd.NextDouble();
        }


        /// <summary>
        /// 返回一个 0.0 到 max 的随机浮点数
        /// </summary>
        /// <returns>The float.</returns>
        /// <param name="max">Max.</param>
        public float NextFloat(float max)
        {
            return (float)m_rnd.NextDouble() * max;
        }


        /// <summary>
        /// 返回一个 min 到 max 之间的随机浮点数
        /// </summary>
        /// <returns>The float.</returns>
        /// <param name="min">Minimum.</param>
        /// <param name="max">Max.</param>
        public float NextFloat(float min, float max)
        {
            float range = max - min;
            return (float)m_rnd.NextDouble() * range + min;
        }


        /// <summary>
        /// 随机一个分子，并返回该分子是否在分母范围内
        /// 例如: Chance(30, 100) 会有百分之三十的几率返回 true
        /// </summary>
        /// <returns>The chance.</returns>
        /// <param name="numerator">Numerator.</param>
        /// <param name="denominator">Denominator.</param>
        public bool Chance(float numerator = 50, float denominator = 100)
        {
            return (float)m_rnd.NextDouble() * denominator <= numerator;
        }


        //
    }
}
