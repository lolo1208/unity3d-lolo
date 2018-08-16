//
// 水平和垂直滚动（可调整光照）
// 2018/7/21
// Author LOLO
//
Shader "ShibaInu/UV/Scrolling2"
{

	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_SpeedX("水平方向滚动速度", Range(-5, 5)) = 1
		_SpeedY("垂直方向滚动速度", Range(-5, 5)) = -1
	}


	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0


		struct Input {
			float2 uv_MainTex;
		};


		fixed4 _Color;
		sampler2D _MainTex;
		half _Glossiness;
		half _Metallic;
		half _SpeedX;
		half _SpeedY;


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)


		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed2 uv = fixed2(_SpeedX * _Time.y, _SpeedY * _Time.y);
			uv = frac(IN.uv_MainTex + uv);

			fixed4 col = tex2D(_MainTex, uv) * _Color;
			o.Albedo = col.rgb;
			o.Alpha = col.a;

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}

		ENDCG
	}

	//
	FallBack "Diffuse"
}
