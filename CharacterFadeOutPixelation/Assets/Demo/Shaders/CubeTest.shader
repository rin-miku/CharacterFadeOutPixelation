Shader "Custom/URP_MainColorSimple"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)

        _GridTex ("Grid Pattern", 2D) = "white" {}
        _GridPixelSize ("Grid Pixel Size", Float) = 64
        _AlphaClipThreshold ("Alpha Clip Threshold", Range(0, 1)) = 0.5
        _ObstructionIntensity ("Obstruction Intensity", Float) = 12
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200

        Cull Off
        ZWrite On
        ZTest LEqual

        Pass
        {
            Name "FORWARD"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _Color;

            TEXTURE2D(_GridTex);
            SAMPLER(sampler_GridTex);
            float _GridPixelSize;
            float _AlphaClipThreshold;
            float _ObstructionIntensity;

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.uv = input.uv;
                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);

                float2 uv = input.uv;

                float2 screenUV = input.positionCS.xy / input.positionCS.w;

                float2 gridUV = frac(screenUV / _GridPixelSize);
                //float2 screenUV = uv * _ScreenParams.xy / _GridPixelSize;

                float grid = SAMPLE_TEXTURE2D(_GridTex, sampler_GridTex, gridUV).a;
                
                float alpha = saturate(grid * _ObstructionIntensity);
                
                clip(alpha - _AlphaClipThreshold);

                return texColor * _Color;
            }

            ENDHLSL
        }
    }

    FallBack "Universal Forward"
}
