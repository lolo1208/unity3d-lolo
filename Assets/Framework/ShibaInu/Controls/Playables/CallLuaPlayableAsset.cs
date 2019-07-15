using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Serialization;


namespace ShibaInu
{
    /// <summary>
    /// 在 Timeline Playable 轨道中，调用 lua 全局函数
    /// </summary>
    public class CallLuaPlayableAsset : PlayableAsset
    {

        [Tooltip("Lua 函数（全局变量）")]
        [FormerlySerializedAs("method"), SerializeField]
        public string method;

        [Tooltip("附带的参数列表。执行 lua 函数时，在该列表之前，第一个参数为 boolean 值（ true:play, flase:pause ）")]
        [FormerlySerializedAs("args"), SerializeField]
        public string[] args;



        // Factory method that generates a playable based on this asset
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = ScriptPlayable<CallLuaPlayable>.Create(graph);
            //playable.GetBehaviour ().nameText = nameText.Resolve (graph.GetResolver ());
            playable.GetBehaviour().method = method;
            playable.GetBehaviour().args = args;
            return playable;
        }


        //
    }
}

