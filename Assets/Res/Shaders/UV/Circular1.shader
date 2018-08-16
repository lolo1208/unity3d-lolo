//
// 圆角（圆形）裁剪
// 四个角整体调整
// 2018/7/21
// Author LOLO
//
Shader "ShibaInu/UV/Circular1"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Round("圆角范围", Range(0, 0.5)) = 0.3
	}


	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_circular
			ENDCG
		}
	}


	//
	CGINCLUDE
	#include "UnityCG.cginc"


	sampler2D _MainTex;
	half _Round;


	fixed4 frag_circular (v2f_img i) : SV_Target
	{
		fixed2 uv = i.uv;
		fixed4 col = tex2D(_MainTex, uv);

		uv.x = abs(uv.x - 0.5);
		uv.y = abs(uv.y - 0.5);
		fixed h1 = 0.5 - _Round;
		fixed h2 = _Round - 0.5;

		fixed x = step(h1, uv.x);
		fixed y = step(h1, uv.y);
		fixed r = step(_Round, length(fixed2(uv.x + h2, uv.y + h2)));
		col.a *= 1 - x * y * r;

		return col;
	}


	//
	ENDCG

	//
	FallBack "Diffuse"
}
