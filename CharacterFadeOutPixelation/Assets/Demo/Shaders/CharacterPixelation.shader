Shader "Custom/CharacterPixelation"
{
    Properties
    {
        _MaskTex ("Mask", 2D) = "white" {}
        _GridTex ("Grid Pattern", 2D) = "white" {}
        _GridTiling ("Grid Tiling", Vector) = (256,256,0,0)
        _AlphaClipThreshold ("Alpha Clip Threshold", Range(0, 1)) = 0.5
        _ObstructionIntensity ("Obstruction Intensity", Float) = 12
    }
   SubShader
   {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        Blend SrcAlpha OneMinusSrcAlpha
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
           TEXTURE2D(_GridTex);
           SAMPLER(sampler_GridTex);
           float4 _GridTiling;
           float _AlphaClipThreshold;
           float _ObstructionIntensity;
 
           float4 Frag(Varyings input) : SV_Target0
           {
               UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

               float2 uv = input.texcoord.xy;
               half4 originalColor = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearRepeat, uv, _BlitMipLevel);

               float mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv).r;
               if (mask < 0.5) return originalColor;

               float2 screenUV;
               screenUV.x = uv.x * 1920 / _GridTiling.x;
               screenUV.y = uv.y * 1080 / _GridTiling.y;
               float grid = SAMPLE_TEXTURE2D(_GridTex, sampler_GridTex, screenUV).a;
                
               float alpha = saturate(grid * _ObstructionIntensity);
                
               clip(alpha - _AlphaClipThreshold);
                
               return originalColor;
           }
           ENDHLSL
       }
   }
}