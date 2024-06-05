//
// UI 2D 贴图
// 2024/06/05
// Author LOLO
//
Shader "UIParticle/UITexture"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)

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

        // 支持遮罩
        Stencil {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZTest [unity_GUIZTestMode]
        ColorMask [_ColorMask]


        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZWrite Off


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


    struct appdata_t
    {
        float4 vertex   : POSITION;
        float4 color    : COLOR;
        float2 texcoord : TEXCOORD0;
    };

    struct v2f
    {
        float4 vertex        : SV_POSITION;
        fixed4 color         : COLOR;
        half2 texcoord       : TEXCOORD0;
        float4 worldPosition : TEXCOORD1;
    };


    fixed4 _Color;
    sampler2D _MainTex;
    float4 _MainTex_ST;
    float4 _ClipRect;


    v2f vert(appdata_t IN)
    {
        v2f OUT;
        OUT.worldPosition = IN.vertex;
        OUT.vertex = UnityObjectToClipPos(IN.vertex);
        OUT.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex);

        #ifdef UNITY_HALF_TEXEL_OFFSET
        OUT.vertex.xy += (_ScreenParams.zw - 1.0) * float2(-1, 1);
        #endif

        OUT.color = IN.color * _Color;
        return OUT;
    }


    fixed4 frag(v2f IN) : SV_Target
    {
        half4 color = tex2D(_MainTex, IN.texcoord) * IN.color;

        #ifdef UNITY_UI_CLIP_RECT
        color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
        #endif

        #ifdef UNITY_UI_ALPHACLIP
        clip(color.a - 0.001);
        #endif

        return color;
    }

    ENDCG
    //
}
