Shader "Custom/CharacterAlphaBlend"
{
   Properties
   {
       _Alpha("Blend Alpha", Range(0, 1)) = 0.0
   }

   SubShader
   {
       Blend SrcAlpha OneMinusSrcAlpha
       Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
       ZWrite Off Cull Off
       Pass
       {
           Name "AlphaBlend"

           HLSLPROGRAM
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
           #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

           #pragma vertex Vert
           #pragma fragment Frag

           float _Alpha;

           float4 Frag(Varyings input) : SV_Target0
           {
               UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

               float2 uv = input.texcoord.xy;
               half4 color = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearRepeat, uv, _BlitMipLevel);
               
               return half4(1, 1, 1, _Alpha) * color;
           }

           ENDHLSL
       }
   }
}