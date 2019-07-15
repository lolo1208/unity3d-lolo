//
// 依照 _AniTex 中包含的顶点数据播放动画
// 给定播放速度等参数，自动切换帧实现动画播放
// 2019/6/3
// Author LOLO
//
Shader "ShibaInu/Component/GpuAnimation"
{

	Properties
	{
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _AniTex ("动画纹理", 2D) = "white" {}
        _AniLen ("动画时长", Float) = 1
        _StartTime ("开始时间", Float) = 0
        _Speed ("播放速度", Float) = 1
        [Toggle] _Loop ("是否循环播放", Float) = 0
	}
    
    
	SubShader
	{
        Tags { "RenderType" = "Opaque" }
        
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            ENDCG
        }
    }
    
    
    //
    CGINCLUDE
    #include "UnityCG.cginc"
    
    
    struct appdata
    {
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };
    

    sampler2D _MainTex;
    sampler2D _AniTex;
    
    UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float, _StartTime)
    UNITY_DEFINE_INSTANCED_PROP(float, _Loop)
    UNITY_DEFINE_INSTANCED_PROP(float, _Speed)
    UNITY_INSTANCING_BUFFER_END(Props)
    
    half _AniLen;
    
    float4 _MainTex_ST;
    float4 _AniTex_TexelSize;// x == 1 / width
    
    
    v2f vert (appdata v, uint vid : SV_VertexID)
    {
        UNITY_SETUP_INSTANCE_ID(v);
        
        float startTime = UNITY_ACCESS_INSTANCED_PROP(Props, _StartTime);
        float loop = UNITY_ACCESS_INSTANCED_PROP(Props, _Loop);
        float speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
        
        //half aniLen = _AniTex_TexelSize.w / fps;
        half x = (vid + 0.5) * _AniTex_TexelSize.x;
        half y = (_Time.y - startTime) / _AniLen * speed;
        half first = step(1, abs(y)); // true = 0
        loop = step(loop, 0); // true = 0
        half reverse = step(0, speed);// true = 0
        half m = fmod(y, 1);
        m = m + 1 + reverse;
        y = max(m, first * loop * 3);
        
        // 前面 +半帧，后面 -半帧
        half h = _AniTex_TexelSize.w;
        h = (h - (_AniTex_TexelSize.y * h)) / h;
        y = y * h + _AniTex_TexelSize.y * 0.5;
        
        fixed4 pos = tex2Dlod(_AniTex, fixed4(x, y, 0, 0));
        
        v2f o;
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.vertex = UnityObjectToClipPos(pos);
        return o;
    }
    
    
    fixed4 frag (v2f i) : SV_Target
    {
        UNITY_SETUP_INSTANCE_ID(i);
        fixed4 col = tex2D(_MainTex, i.uv);
        return col;
    }


    //
    ENDCG
}
