//
// 垂直方向裁剪（遮罩效果）
// 2018/7/26
// Author LOLO
//
Shader "ShibaInu/UV/ClippingY"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Value("显示范围", Range(0, 1)) = 0.3
		[Toggle] _Reverse("反向裁剪", Float) = 0
	}


	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_clippingY
			ENDCG
		}
	}


	//
	CGINCLUDE
	#include "UnityCG.cginc"


	sampler2D _MainTex;
	half _Value;
	half _Reverse;


	fixed4 frag_clippingY (v2f_img i) : SV_Target
	{
		fixed2 uv = i.uv;
		fixed4 col = tex2D(_MainTex, uv);
		col.a = abs(_Reverse - uv.y) <= _Value;
		return col;
	}


	//
	ENDCG

	//
	FallBack "Diffuse"
}
