Shader "Custom/CharacterAlphaClip"
{
    Properties
    {
        _GridTex ("Grid Pattern", 2D) = "white" {}
        _GridPixelSize ("Grid Pixel Size", Float) = 64
        _GridAlphaIntensity ("Grid Alpha Intensity", Float) = 12
        _AlphaClipThreshold ("Alpha Clip Threshold", Range(0, 1)) = 0.5

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

           TEXTURE2D(_GridTex);
           SAMPLER(sampler_GridTex);
           float _GridPixelSize;
           float _GridAlphaIntensity;
           float _AlphaClipThreshold;
 
           float4 Frag(Varyings input) : SV_Target0
           {
               UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

               float2 uv = input.texcoord.xy;

               half4 color = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearRepeat, uv, _BlitMipLevel);

               float2 screenUV = uv * _ScreenParams.xy / _GridPixelSize;

               float grid = SAMPLE_TEXTURE2D(_GridTex, sampler_GridTex, screenUV).a;
                
               float alpha = saturate(grid * _GridAlphaIntensity);
               
               clip(alpha - _AlphaClipThreshold);

               return color;
           }
           ENDHLSL
       }
   }
}