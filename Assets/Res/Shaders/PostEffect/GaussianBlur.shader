//
// 高斯模糊
// 2018/8/13
// Author LOLO
//
Shader "ShibaInu/Post Effect/Gaussian Blur"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

 
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			Fog{ Mode Off }
 
			CGPROGRAM
			#pragma vertex vert_gaussianBlur
			#pragma fragment frag_gaussianBlur
			ENDCG
		}
		//
	}


	//
	CGINCLUDE
	#include "UnityCG.cginc"


	sampler2D _MainTex;
	// XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，x = 1/width, y = 1/height, z = width, w = height
	float4 _MainTex_TexelSize;
	// 给一个offset，这个offset可以在外面设置，是我们设置横向和竖向blur的关键参数
	float4 _offsets;


	// blur结构体，从blur的vert函数传递到frag函数的参数
	struct v2f_blur
	{
		float4 pos  : SV_POSITION;	// 顶点位置
		float2 uv   : TEXCOORD0;	// 纹理坐标
		float4 uv01 : TEXCOORD1;	// 一个vector4存储两个纹理坐标
		float4 uv23 : TEXCOORD2;	// 一个vector4存储两个纹理坐标
		float4 uv45 : TEXCOORD3;	// 一个vector4存储两个纹理坐标
	};


	v2f_blur vert_gaussianBlur(appdata_img v)
	{
		v2f_blur o;
		o.pos = UnityObjectToClipPos(v.vertex);
		// uv坐标
		o.uv = v.texcoord.xy;
 
		// 计算一个偏移值，offset可能是（0，1，0，0）也可能是（1，0，0，0）这样就表示了横向或者竖向取像素周围的点
		_offsets *= _MainTex_TexelSize.xyxy;
		
		// 由于uv可以存储4个值，所以一个uv保存两个vector坐标，_offsets.xyxy * float4(1,1,-1,-1)可能表示(0,1,0-1)，表示像素上下两个
		// 坐标，也可能是(1,0,-1,0)，表示像素左右两个像素点的坐标，下面*2.0，*3.0同理
		o.uv01 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1);
		o.uv23 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 2.0;
		o.uv45 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 3.0;
 
		return o;
	}


	fixed4 frag_gaussianBlur(v2f_blur i) : SV_Target
	{
		fixed4 color = fixed4(0, 0, 0, 0);
		// 将像素本身以及像素左右（或者上下，取决于vertex shader传进来的uv坐标）像素值的加权平均
		color += 0.40 * tex2D(_MainTex, i.uv);
		color += 0.15 * tex2D(_MainTex, i.uv01.xy);
		color += 0.15 * tex2D(_MainTex, i.uv01.zw);
		color += 0.10 * tex2D(_MainTex, i.uv23.xy);
		color += 0.10 * tex2D(_MainTex, i.uv23.zw);
		color += 0.05 * tex2D(_MainTex, i.uv45.xy);
		color += 0.05 * tex2D(_MainTex, i.uv45.zw);
		return color;
	}


	//
	ENDCG
}