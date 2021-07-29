//
// 水平和垂直滚动
// 2018/7/21
// Author LOLO
//
Shader "ShibaInu/UV/Scrolling1"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SpeedX("水平方向滚动速度", Range(-5, 5)) = 1
		_SpeedY("垂直方向滚动速度", Range(-5, 5)) = -1
	}


	SubShader
	{
		Tags { "RenderType" = "Opaque" }

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
	half _SpeedX;
	half _SpeedY;


	fixed4 frag (v2f_img i) : SV_Target
	{
		fixed2 uv = fixed2(_SpeedX * _Time.y, _SpeedY * _Time.y);
		uv = frac(i.uv + uv);

		fixed4 col = tex2D(_MainTex, uv);
		return col;
	}


	//
	ENDCG

	//
	FallBack "Diffuse"
}
