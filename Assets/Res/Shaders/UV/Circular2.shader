//
// 圆角（圆形）裁剪
// 四个角可单独调整
// 2018/7/21
// Author LOLO
//
Shader "ShibaInu/UV/Circular2"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Round1("左上圆角范围", Range(0, 0.5)) = 0.3
		_Round2("右上圆角范围", Range(0, 0.5)) = 0.3
		_Round3("左下圆角范围", Range(0, 0.5)) = 0.3
		_Round4("右下圆角范围", Range(0, 0.5)) = 0.3
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
	half _Round1;
	half _Round2;
	half _Round3;
	half _Round4;


	fixed4 frag_circular (v2f_img i) : SV_Target
	{
		fixed2 uv = i.uv;
		fixed4 col = tex2D(_MainTex, uv);

		// 左上
		if(uv.x < _Round1 && uv.y > 1 - _Round1) {
			fixed2 r = fixed2(
				uv.x - _Round1,
				uv.y + _Round1 - 1
			);
			if(length(r) > _Round1) col.a = 0;
		}

		// 右上
		else if(uv.x > 1 - _Round2 && uv.y > 1 - _Round2) {
			fixed2 r = fixed2(
				uv.x + _Round2 - 1,
				uv.y + _Round2 - 1
			);
			if(length(r) > _Round2) col.a = 0;
		}

		// 左下
		else if(uv.x < _Round3 && uv.y < _Round3) {
			fixed2 r = fixed2(
				uv.x - _Round3,
				uv.y - _Round3
			);
			if(length(r) > _Round3) col.a = 0;
		}

		// 右下
		else if(uv.x > 1 - _Round4 && uv.y < _Round4) {
			fixed2 r = fixed2(
				uv.x + _Round4 - 1,
				uv.y - _Round4
			);
			if(length(r) > _Round4) col.a = 0;
		}

		return col;
	}

	
	//
	ENDCG

	//
	FallBack "Diffuse"
}
