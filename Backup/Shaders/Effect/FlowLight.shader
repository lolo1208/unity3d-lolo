//
// 流光特效
// 2018/8/1
// Author LOLO
//
Shader "ShibaInu/Effect/Flow Light"
{

	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
        _LightColor ("流光颜色", Color) = (1, 1, 1, 1)
        _Angle ("流光角度", Range(0, 180)) = 65
        _Width ("流光宽度", Range(0, 1)) = 0.3
        _Duration ("持续时间", Range(0.01, 10)) = 0.7
        _Interval ("间隔时间", Range(0, 10)) = 1
	}


	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
        #pragma surface surf Lambert alpha exclude_path:prepass noforwardadd


        struct Input {
        	half2 uv_MainTex;
        };


        sampler2D _MainTex;
        fixed4 _LightColor;
        half _Angle;
        half _Width;
        half _Duration;
        half _Interval;


        half inFlash(half2 uv)
        {   
            half brightness = 0;

            half angleInRad = 0.0174444 * _Angle;
            half tanInverseInRad = 1 / tan(angleInRad);

            half currentTime = _Time.y;
            half totalTime = (_Interval + _Duration) * (1 + _Width);// 求总时间需要将流光宽度计算进去
            half currentTurnStartTime = (int)((currentTime / totalTime)) * totalTime;
            half currentTurnTimePassed = currentTime - currentTurnStartTime - _Interval;

            bool onLeft = (tanInverseInRad > 0);
            half xBottomFarLeft = onLeft? 0 : tanInverseInRad;
            half xBottomFarRight = onLeft? (1 + tanInverseInRad) : 1;

            half percent = currentTurnTimePassed / _Duration;
            half xBottomRightBound = xBottomFarLeft + percent * (xBottomFarRight - xBottomFarLeft);
            half xBottomLeftBound = xBottomRightBound - _Width;

            half xProj = uv.x + uv.y * tanInverseInRad;

            if(xProj > xBottomLeftBound && xProj < xBottomRightBound) {
                brightness = 1 - abs(2 * xProj - (xBottomLeftBound + xBottomRightBound)) / _Width;
            }

            return brightness;
        }


        void surf (Input IN, inout SurfaceOutput o)
        {                
            fixed4 texCol = tex2D(_MainTex, IN.uv_MainTex);
            half brightness = inFlash(IN.uv_MainTex);

            o.Emission = texCol.rgb + _LightColor.rgb * brightness;
            o.Alpha = texCol.a;
        }

        ENDCG  
	}

	//
	FallBack "Diffuse"
}
