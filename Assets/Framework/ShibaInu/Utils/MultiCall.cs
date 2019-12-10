using System;
using System.Collections.Generic;


namespace ShibaInu
{

    /// <summary>
    /// Multiple calls at once.
    /// 维护一个回调列表，在执行 Call() 时，调用列表中所有的回调，并传递一个类型为 T 的参数。
    /// 类似事件多播委托，差别在于：
    /// * 可重复添加或移除同一个 Action。
    /// * 在执行调用的过程中，如果回调出现异常，将会从列表中移除该回调，并且不会影响后续回调的执行。
    /// </summary>
    public class MultiCall<T>
    {
        /// 需要被调用的回调列表
        private readonly HashSet<Action<T>> m_callbacks = new HashSet<Action<T>>();
        /// 待移除的回调列表
        private readonly HashSet<Action<T>> m_addList = new HashSet<Action<T>>();
        /// 待添加的回调列表
        private readonly HashSet<Action<T>> m_removeList = new HashSet<Action<T>>();



        /// <summary>
        /// 添加回调
        /// 可重复调用，只会被添加一次
        /// </summary>
        /// <param name="callback">Callback.</param>
        public void Add(Action<T> callback)
        {
            m_addList.Add(callback);
            m_removeList.Remove(callback);
        }


        /// <summary>
        /// 移除回调
        /// 可重复调用
        /// </summary>
        /// <param name="callback">Callback.</param>
        public void Remove(Action<T> callback)
        {
            m_removeList.Add(callback);
            m_addList.Remove(callback);
        }


        /// <summary>
        /// 执行调用
        /// </summary>
        /// <param name="data">[可选] 附带的数据</param>
        public void Call(T data = default)
        {
            // 先移除
            foreach (var observer in m_removeList)
                m_callbacks.Remove(observer);
            m_removeList.Clear();

            // 再添加
            foreach (var observer in m_addList)
                m_callbacks.Add(observer);
            m_addList.Clear();

            // 执行所有回调
            foreach (var observer in m_callbacks)
            {
                try
                {
                    observer(data);
                }
                catch (Exception e)
                {
                    Remove(observer);
                    Logger.LogException(e);
                }
            }
        }


        //
    }
}

