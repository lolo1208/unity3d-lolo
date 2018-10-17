//
// 3D 文本
// 2018/8/22
// Author LOLO
//
Shader "ShibaInu/UI/3DText"
{

	Properties
	{
		_MainTex ("Font Texture", 2D) = "white" {}
        _Color ("Text Color", Color) = (1, 1, 1, 1)
	}


	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		Lighting Off Cull Off ZWrite On Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha


        Pass
		{
		    Color [_Color]
		    SetTexture [_MainTex]
		    {
		        combine primary, texture * primary
		    }
		}
	}


    //
}
