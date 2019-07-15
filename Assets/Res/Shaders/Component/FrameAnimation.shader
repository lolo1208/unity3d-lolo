//
// 依照 _AniTex 中包含的顶点数据帧显示指定帧
// 只显示给定帧号对应的画面，不会自动切换帧
// 2019/6/27
// Author LOLO
//
Shader "ShibaInu/Component/FrameAnimation"
{

	Properties
	{
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _AniTex ("动画纹理", 2D) = "white" {}
        _FrameCount ("总帧数", int) = 0
        _CurrentFrame ("当前帧", int) = 1
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
    UNITY_DEFINE_INSTANCED_PROP(int, _CurrentFrame)
    UNITY_INSTANCING_BUFFER_END(Props)
    
    int _FrameCount;
    
    float4 _MainTex_ST;
    float4 _AniTex_TexelSize;// x == 1 / width
    
    
    v2f vert (appdata v, uint vid : SV_VertexID)
    {
        UNITY_SETUP_INSTANCE_ID(v);
        
        int curFrame = UNITY_ACCESS_INSTANCED_PROP(Props, _CurrentFrame);
        
        half x = (vid + 0.5) * _AniTex_TexelSize.x;
        half y = ((half)curFrame - 1) / (_FrameCount - 1);
        
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
