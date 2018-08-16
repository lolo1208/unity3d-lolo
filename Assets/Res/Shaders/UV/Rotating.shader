//
// 绕中心旋转
// 2018/7/21
// Author LOLO
//
Shader "ShibaInu/UV/Rotating"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RotateSpeed("旋转速度", Range(-20, 20)) = 5
	}


	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_rotating
			ENDCG
		}
	}


	//
	CGINCLUDE
	#include "UnityCG.cginc"

			
	sampler2D _MainTex;
	half _RotateSpeed;


	fixed4 frag_rotating (v2f_img i) : SV_Target
	{
		// 绕中心旋转
		fixed2 pivot = fixed2(0.5, 0.5);
		fixed2 uv = i.uv - pivot;
		fixed speed = _RotateSpeed * _Time.y;
		uv = fixed2(
			uv.x * cos(speed) - uv.y * sin(speed),
			uv.x * sin(speed) + uv.y * cos(speed)
		);
		uv += pivot;
		
		fixed4 col = tex2D(_MainTex, uv);
		return col;
	}


	//
	ENDCG

	//
	FallBack "Diffuse"
}
