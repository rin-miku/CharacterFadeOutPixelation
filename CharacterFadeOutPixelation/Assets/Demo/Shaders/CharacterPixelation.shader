Shader "Custom/CharacterPixelation"
{
    Properties
    {
        _MaskTex ("Mask", 2D) = "white" {}
        _PixelSize ("Pixel Size", Range(1, 10)) = 1.0
    }
   SubShader
   {
       Blend SrcAlpha OneMinusSrcAlpha
       Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
       ZWrite Off Cull Off
       Pass
       {
           Name "CharacterPixelation"

           HLSLPROGRAM
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
           #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

           #pragma vertex Vert
           #pragma fragment Frag

           TEXTURE2D(_MaskTex);
           SAMPLER(sampler_MaskTex);
           float _PixelSize;
 
           float4 Frag(Varyings input) : SV_Target0
           {
               UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

               float2 uv = input.texcoord.xy;
               half4 originalColor = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearRepeat, uv, _BlitMipLevel);
               
               float mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv).r;
               if (mask < 0.5) return originalColor;

               float2 screenSize = _ScreenParams.xy;

               float2 screenUV = uv * screenSize;

               screenUV = floor(screenUV / _PixelSize) * _PixelSize;

               float2 pixelUV = screenUV / screenSize;

               float4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearRepeat, pixelUV);

               return color;
           }
           ENDHLSL
       }
   }
}