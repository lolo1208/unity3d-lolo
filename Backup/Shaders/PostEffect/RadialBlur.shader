//
// 径向模糊
// 2018/7/20
// Author LOLO
//
Shader "ShibaInu/Post Effect/Radial Blur"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurFactor ("模糊强度", Range(1, 50)) = 10
		_CenterX ("径向中心点X", Range(0, 1)) = 0.5
		_CenterY ("径向中心点Y", Range(0, 1)) = 0.5
	}


	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			Fog { Mode Off }
			ZTest Always
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_radialBlur
			ENDCG
		}
	}


	//
	CGINCLUDE
	#include "UnityCG.cginc"


	sampler2D _MainTex;
	half _BlurFactor;
	half _CenterX;
	half _CenterY;


	fixed4 frag_radialBlur(v2f_img i) : SV_Target
	{
		fixed2 center = fixed2(_CenterX, _CenterY);
		fixed2 uv = i.uv - center;
		fixed3 c = fixed3(0, 0, 0);
		for(fixed j = 0; j < _BlurFactor; j++) {
			c += tex2D(_MainTex, uv * (1 - 0.01 * j) + center).rgb;
		}

		fixed4 col;
		col.rgb = c / _BlurFactor;
		col.a = 1;
		return col;
	}


	//
	ENDCG
}
