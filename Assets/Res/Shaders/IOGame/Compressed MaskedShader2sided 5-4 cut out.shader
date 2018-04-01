Shader "Compressed Masked shader 2 sided cut out" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0)
	_Shininess ("Shininess", Range (0.01, 2)) = 0.078125
	_SpecPower ("SpecPower", Range (0.01, 5)) = 0.078125
	_MainTex ("Base (RGB))", 2D) = "white" {}
	_EffectTex ("Effect Texture (RGB)", 2D) = "white" {}
}
// Blinn
SubShader {
//	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	AlphaTest Greater 0.1
	cull off
	LOD 300

CGPROGRAM
#pragma surface surf BlinnPhong alphatest:_Cutoff addshadow 

sampler2D _MainTex, _EffectTex;
float4 _Color;
float _Shininess, _SpecPower;

struct Input {
	float2 uv_MainTex;	
};

void surf (Input IN, inout SurfaceOutput o) {
	half4 color = tex2D(_MainTex, IN.uv_MainTex);
	half4 effectColor = tex2D(_EffectTex, IN.uv_MainTex);
	float spec = effectColor.r;
	spec=spec*spec;
	o.Albedo = color.rgb *  (half3(1,1,1)*(1-effectColor.g) + _Color.rgb*effectColor.g);
	o.Gloss = _SpecPower * spec;
	o.Alpha = color.a * effectColor.b;
	o.Specular = _Shininess * effectColor.r;
}
ENDCG
}
// Lambert
SubShader {
	Tags {"Queue"="Geometry"}
	AlphaTest Greater 0.1
	Blend SrcAlpha OneMinusSrcAlpha
	cull off
	LOD 300

CGPROGRAM
#pragma surface surf Lambert alphatest:_Cutoff

sampler2D _MainTex, _EffectTex;
float4 _Color;
float _Shininess, _SpecPower;

struct Input {
	float2 uv_MainTex;
};

void surf (Input IN, inout SurfaceOutput o) {
	half4 color = tex2D(_MainTex, IN.uv_MainTex);
	half4 effectColor = tex2D(_EffectTex, IN.uv_MainTex);
	o.Albedo = color.rgb *  (half3(1,1,1)*(1-effectColor.g) + _Color.rgb*effectColor.g);
	o.Gloss = _SpecPower * effectColor.r;
	o.Alpha = color.a * _Color.a * effectColor.b;
	o.Specular = _Shininess * effectColor.r;
}
ENDCG
}
}
