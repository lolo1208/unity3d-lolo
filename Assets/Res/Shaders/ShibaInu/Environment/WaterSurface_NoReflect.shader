//
// 无反射倒影的水面
// 2019/09/30
// Author LOLO
//
Shader "Environment/Water Surface(No Reflect)"
{

    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _RefractTex ("Refract Texture", 2D) = "white" {}
        _BumpTex ("Bump Texture", 2D) = "white" {}
        _BumpStrength ("Bump Strength", Range(0.0, 10.0)) = 2.1
        _BumpDirection ("Bump Direction(2 wave)", Vector) = (0.25, 0.25, -0.1, -0.1)
        _BumpTiling ("Bump Tiling", Vector) = (0.25, 0.25, 0.25, 0.25)
        _FresnelTex("Fresnel Texture", 2D) = "white" {}
        _Skybox("Skybox", Cube) = "white"{}
        _Specular("Specular Color", Color) = (1, 1, 1, 0.5)
        _Params("Shiness, Refract Perturb, Reflect Perturb", Vector) = (128, 0.005, 0.025, 1)
        _SunDir("Sun Direction", Vector) = (-0.12, 0.05, 0.11, 0)
    }


    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            offset 1, 1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#pragma multi_compile_fwdbase
            ENDCG
        }
    }


    //
    CGINCLUDE
    #include "UnityCG.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 bumpCoords : TEXCOORD1;
        float3 viewVector : TEXCOORD2;
    };


    half4 _Color;
    sampler2D _RefractTex;
    sampler2D _BumpTex;
    half _BumpStrength;
    half4 _BumpDirection;
    half4 _BumpTiling;
    sampler2D _FresnelTex;
    samplerCUBE _Skybox;
    half4 _Specular;
    half4 _Params;
    half4 _SunDir;


    v2f vert (appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        half3 worldPos = mul(unity_ObjectToWorld, v.vertex);
        half4 screenPos = ComputeScreenPos(o.vertex);
        o.uv.xy = v.uv;
        o.bumpCoords.xyzw = (worldPos.xzxz + _Time.yyyy * _BumpDirection.xyzw) * _BumpTiling.xyzw;
        o.viewVector = (worldPos - _WorldSpaceCameraPos.xyz);
        return o;
    }


    fixed4 frag (v2f i) : SV_Target
    {
        half2 bump = (UnpackNormal(tex2D(_BumpTex, i.bumpCoords.xy)) + UnpackNormal(tex2D(_BumpTex, i.bumpCoords.zw))) * 0.5;
        half3 worldNormal = half3(0, 0, 0);
        worldNormal.xz = bump.xy * _BumpStrength;
        worldNormal.y = 1;
        worldNormal = normalize(worldNormal);

        fixed4 result = fixed4(0, 0, 0,1);
        half3 viewVector = normalize(i.viewVector);
        half3 halfVector = normalize((normalize(_SunDir.xyz) - viewVector));

        half2 offsets = worldNormal.xz * viewVector.y;
        half4 refractColor = tex2D(_RefractTex, i.uv.xy + offsets * _Params.y) * _Color;

        half3 reflUV = reflect( viewVector, worldNormal);
        half3 reflectColor = texCUBE(_Skybox, reflUV);

        half2 fresnelUV = half2(saturate(dot(-viewVector, worldNormal)), 0.5);
        half fresnel = tex2D(_FresnelTex, fresnelUV).r;
        if(IsGammaSpace()) fresnel = pow(fresnel, 2.2);
        result.xyz = lerp(refractColor.xyz, reflectColor.xyz, fresnel);

        half3 specularColor = _Specular.w * pow(max(0, dot(worldNormal, halfVector)), _Params.x);
        result.xyz += _Specular.xyz * specularColor;

        return result;
    }


    //
    ENDCG
}
