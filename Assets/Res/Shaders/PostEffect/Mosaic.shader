//
// 马赛克
// 2018/7/20
// Author LOLO
//
Shader "ShibaInu/Post Effect/Mosaic"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TileSize ("马赛克块尺寸", Range(0.001, 1)) = 0.05
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
			#pragma fragment frag_mosaic
			ENDCG
		}
		//
	}


	//
	CGINCLUDE
	#include "UnityCG.cginc"


	sampler2D _MainTex;
	half _TileSize;


	fixed4 frag_mosaic(v2f_img i) : SV_Target
	{
		i.uv.x = ceil(i.uv.x / _TileSize) * _TileSize;
        i.uv.y = ceil(i.uv.y / _TileSize) * _TileSize;
        fixed4 col = tex2D(_MainTex, i.uv);
        return col;
	}


	//
	ENDCG
}
