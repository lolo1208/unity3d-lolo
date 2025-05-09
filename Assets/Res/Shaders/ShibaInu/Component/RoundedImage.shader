//
// 圆角矩形图片 - 四个角的半径相同（统一调整）
// 2023/12/29
// Author LOLO
//
Shader "ShibaInu/Component/RoundedImage"
{

	Properties
	{
        // x: width, y: height, z: radius*2
        [HideInInspector] _SizeRadius ("SizeRadius", Vector) = (0,0,0,0)

        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}

        // 支持遮罩
        [HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil ("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask ("Color Mask", Float) = 15
        [HideInInspector] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}


	SubShader
	{
        Tags { 
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
		Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
		
		Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        ColorMask [_ColorMask]

		// 支持遮罩
        Stencil {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
            ENDCG
        }
    }


    //
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "UnityUI.cginc"
    #include "RoundedImage.cginc"


    float4 _SizeRadius;
    sampler2D _MainTex;
    float4 _ClipRect;
    fixed4 _TextureSampleAdd;


    fixed4 frag (v2f i) : SV_Target {
        half4 color = (tex2D(_MainTex, i.uv) + _TextureSampleAdd) * i.color;

        #ifdef UNITY_UI_CLIP_RECT
        color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
        #endif

        #ifdef UNITY_UI_ALPHACLIP
        clip(color.a - 0.001);
        #endif

        if (color.a <= 0) {
            return color;
        }

        float alpha = CalcAlpha(i.uv, _SizeRadius.xy, _SizeRadius.z);

        #ifdef UNITY_UI_ALPHACLIP
        clip(alpha - 0.001);
        #endif

        return mixAlpha(tex2D(_MainTex, i.uv), i.color, alpha);
    }

    ENDCG
    //
}
