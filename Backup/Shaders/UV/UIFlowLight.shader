//
// UI 流光效果
// 2020/12/01
// Author LOLO
//
Shader "ShibaInu/UV/UI Flow Light"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1, 1, 1, 1)
		_SpeedX ("水平方向滚动速度", Range(-1, 1)) = 1
		_SpeedY ("垂直方向滚动速度", Range(-1, 1)) = -1
        _AniLen ("动画时长", Float) = 1
        _StartTime ("开始时间", Float) = 0
	}


	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		Blend SrcAlpha OneMinusSrcAlpha

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

		fixed4 col = tex2D(_MainTex, uv) * _Color;
		return col;
	}


	//
	ENDCG

	//
	FallBack "Diffuse"
}
