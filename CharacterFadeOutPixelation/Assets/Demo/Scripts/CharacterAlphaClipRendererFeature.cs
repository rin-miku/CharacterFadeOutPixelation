using UnityEngine;
using UnityEngine.Rendering.Universal;

public class CharacterAlphaClipRendererFeature : ScriptableRendererFeature
{
    public CharacterAlphaClipRenderPass renderPass;

    public Material alphaClipMaterial;

    public override void Create()
    {
        renderPass = new CharacterAlphaClipRenderPass(alphaClipMaterial);
        renderPass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(renderPass);
    }
}
