//
// UI 流光效果
// 2020/12/01
// Author LOLO
//
Shader "ShibaInu/Effect/UI Flow Light"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1, 1, 1, 1)
		_SpeedX ("水平方向滚动速度", Range(-1, 1)) = 0.5
		_SpeedY ("垂直方向滚动速度", Range(-1, 1)) = -0.5
        _AniLen ("动画时长", Float) = 1
        _StartTime ("开始时间", Float) = 0

		// 支持遮罩
        [HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil ("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask ("Color Mask", Float) = 15
        [HideInInspector] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}


	SubShader
	{
		Tags { 
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
		Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
		
		Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        ColorMask [_ColorMask]

		// 支持遮罩
        Stencil {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			ENDCG
		}
	}


	//
	CGINCLUDE
	#include "UnityCG.cginc"


	sampler2D _MainTex;
	fixed4 _Color;
	half _SpeedX;
	half _SpeedY;
    half _AniLen;
    float _StartTime;


	fixed4 frag (v2f_img i) : SV_Target
	{
        fixed p = (_Time.y - _StartTime) / _AniLen;
        p = p * 2 - 1;
		fixed2 uv = fixed2(_SpeedX * p, _SpeedY * p);
		uv = i.uv + uv;

		fixed4 color = tex2D(_MainTex, uv) * _Color;

		#ifdef UNITY_UI_CLIP_RECT
        color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
        #endif

        #ifdef UNITY_UI_ALPHACLIP
        clip(color.a - 0.001);
        #endif
		
		return color;
	}


	//
	ENDCG

	//
	FallBack "Diffuse"
}
