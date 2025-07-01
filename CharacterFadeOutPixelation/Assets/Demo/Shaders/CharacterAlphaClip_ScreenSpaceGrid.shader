Shader "Custom/CharacterAlphaClip_ScreenSpaceGrid"
{
    Properties
    {
        _GridTex ("Grid Pattern", 2D) = "white" {}
        _GridPixelSize ("Grid Pixel Size", Float) = 64
        _AlphaClipThreshold ("Alpha Clip Threshold", Range(0, 1)) = 0.5
        _ObstructionIntensity ("Obstruction Intensity", Float) = 12
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off 
        ZWrite Off

        Pass
        {
            Name "CharacterAlphaClip"

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #pragma vertex Vert
            #pragma fragment Frag

            struct VertInput
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings2
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_GridTex);
            SAMPLER(sampler_GridTex);

            float _GridPixelSize;
            float _AlphaClipThreshold;
            float _ObstructionIntensity;

            Varyings2 Vert(VertInput input)
            {
                Varyings2 output;
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.uv = input.uv;
                return output;
            }

            half4 Frag(Varyings2 input) : SV_Target0
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // 使用屏幕空间像素坐标
                float2 screenUV = input.positionCS.xy / input.positionCS.w;

                // 以 _GridPixelSize 为单元划分网格坐标，并循环UV
                float2 gridUV = frac(screenUV / _GridPixelSize);

                // 采样 Grid 纹理
                float grid = SAMPLE_TEXTURE2D(_GridTex, sampler_GridTex, gridUV).a;

                // 采样原图
                half4 color = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearRepeat, input.uv, _BlitMipLevel);

                float alpha = saturate(grid * _ObstructionIntensity);
                clip(alpha - _AlphaClipThreshold);

                return color;
            }
            ENDHLSL
        }
    }
}
