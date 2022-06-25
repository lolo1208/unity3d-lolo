//
// 均值模糊
// 2022/06/23
// Author LOLO
//
Shader "ShibaInu/Effect/BoxBlur"
{

    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurRadius ("模糊半径", Range(0.0, 10.0)) = 1.0
    }
    
    
    SubShader
    {
        ZTest Always
        Cull Off
        ZWrite Off
        Fog { Mode Off }
        Tags { "RenderType" = "Opaque" }
        
        
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
    
    
    struct VertexOutput
    {
        float4 pos : SV_POSITION;
        float2 uv  : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        float4 uv3 : TEXCOORD3;
        float4 uv4 : TEXCOORD4;
    };
    

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    float _BlurRadius;
    
    
    VertexOutput vert(appdata_img v)
    {
        VertexOutput o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xy;

        // 计算周围8个 UV
        o.uv1.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, 0) * _BlurRadius;
        o.uv1.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, 0) * _BlurRadius;

        o.uv2.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(0, 1) * _BlurRadius;
        o.uv2.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(0, -1) * _BlurRadius;

        o.uv3.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, 1) * _BlurRadius;
        o.uv3.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, 1) * _BlurRadius;

        o.uv4.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, -1) * _BlurRadius;
        o.uv4.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, -1) * _BlurRadius;
        return o;
    }


    fixed4 frag(VertexOutput i) : SV_Target
    {
        fixed4 color = fixed4(0, 0, 0, 0);
        color += tex2D(_MainTex, i.uv.xy);
        color += tex2D(_MainTex, i.uv1.xy);
        color += tex2D(_MainTex, i.uv1.zw);
        color += tex2D(_MainTex, i.uv2.xy);
        color += tex2D(_MainTex, i.uv2.zw);
        color += tex2D(_MainTex, i.uv3.xy);
        color += tex2D(_MainTex, i.uv3.zw);
        color += tex2D(_MainTex, i.uv4.xy);
        color += tex2D(_MainTex, i.uv4.zw);
        // 算出平均值
        return color / 9;
    }


    //
    ENDCG
}
