//
// 叠影抖动
// 2018/7/20
// Author LOLO
//
Shader "ShibaInu/Post Effect/Double Image Shake"
{

	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_ShakePosition("抖动位置", Vector) = (0, 0, 0, 0)
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
			#pragma fragment frag_doubleImageShake
			ENDCG
		}
		//
	}


	//
	CGINCLUDE
	#include "UnityCG.cginc"


	sampler2D _MainTex;
	fixed4 _ShakePosition;


	fixed4 frag_doubleImageShake(v2f_img i) : SV_Target
	{
		fixed4 c1 = tex2D(_MainTex, i.uv + _ShakePosition.xy);
		fixed4 c2 = tex2D(_MainTex, i.uv + _ShakePosition.zw);
		return c1 * 0.3 + c2 * 0.7;
	}


	//
	ENDCG
}