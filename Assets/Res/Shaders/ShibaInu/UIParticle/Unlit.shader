//
// 不受光照影响（没有明暗面的）可调颜色的 3D 对象
// 2024/06/05
// Author LOLO
//
Shader "UIParticle/Unlit"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
    }


    SubShader
    {
        Tags { 
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
        }
        LOD 100
    
        ZWrite Off
        // Blend Off


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    
    
    //
    CGINCLUDE
    #include "UnityCG.cginc"


    struct appdata_t {
        float4 vertex : POSITION;
        float2 texcoord : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f
    {
        float2 uv  : TEXCOORD0;
        float4 pos : SV_POSITION;
        UNITY_VERTEX_OUTPUT_STEREO
    };


    fixed4 _Color;
    sampler2D _MainTex;
    float4 _MainTex_ST;


    v2f vert (appdata_t v)
    {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
        return o;
    }

    fixed4 frag (v2f i) : SV_Target
    {
        fixed4 texcol = tex2D(_MainTex, i.uv);
        return texcol * _Color;
    }


    ENDCG
    //
}
