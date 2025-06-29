using UnityEngine;
using UnityEngine.Rendering.Universal;

public class CharacterFadeOutPixelationRendererFeature : ScriptableRendererFeature
{
    public CharacterFadeOutPixelationRenderPass renderPass;

    public Material alphaBlendMaterial;
    public Material maskMaterial;
    public Material pixelationMaterial;

    public override void Create()
    {
        renderPass = new CharacterFadeOutPixelationRenderPass(alphaBlendMaterial, maskMaterial, pixelationMaterial);
        renderPass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(renderPass);
    }
}
