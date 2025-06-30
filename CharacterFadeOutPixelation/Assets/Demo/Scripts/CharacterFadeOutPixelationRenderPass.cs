using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RendererUtils;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;
using static UnityEngine.Rendering.RenderGraphModule.Util.RenderGraphUtils;

public class CharacterFadeOutPixelationRenderPass : ScriptableRenderPass
{
    private Material alphaBlendMat;
    private Material maskMat;
    private Material pixelationMat;

    class AlphaBlendPassData
    {
        public RendererListHandle rendererListHandle;
    }

    class MaskPassData
    {
        public Material material;
        public TextureHandle sourceTex;
        public TextureHandle maskTex;
    }

    public CharacterFadeOutPixelationRenderPass(Material alphaBlendMaterial, Material maskMaterial, Material pixelationMaterial)
    {
        alphaBlendMat = alphaBlendMaterial;
        maskMat = maskMaterial;
        pixelationMat = pixelationMaterial;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        UniversalRenderingData renderingData = frameData.Get<UniversalRenderingData>();
        UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

        TextureHandle activeColorTexture = resourceData.activeColorTexture;

        // AlphaBlend
        RenderTextureDescriptor descriptor = cameraData.cameraTargetDescriptor;
        descriptor.depthBufferBits = 0;
        descriptor.graphicsFormat = GraphicsFormat.R8G8B8A8_UNorm;
        TextureHandle playerRT = UniversalRenderer.CreateRenderGraphTexture(renderGraph, descriptor, "PlayerRT", false);

        FilteringSettings filterSettings = new FilteringSettings(RenderQueueRange.opaque)
        {
            layerMask = LayerMask.GetMask("Player")
        };

        RendererListDesc rendererListDesc = new RendererListDesc(new ShaderTagId("UniversalForward"), renderingData.cullResults, cameraData.camera)
        {
            sortingCriteria = SortingCriteria.CommonOpaque,
            renderQueueRange = RenderQueueRange.opaque,
            layerMask = filterSettings.layerMask
        };

        RendererListHandle renderList = renderGraph.CreateRendererList(rendererListDesc);

        using (IRasterRenderGraphBuilder builder = renderGraph.AddRasterRenderPass<AlphaBlendPassData>("Player Renderer", out var passData))
        {
            builder.SetRenderAttachment(playerRT, 0, AccessFlags.Write);
            builder.SetRenderAttachmentDepth(resourceData.cameraDepth, AccessFlags.ReadWrite);

            passData.rendererListHandle = renderList;
            builder.UseRendererList(renderList);

            builder.SetRenderFunc((AlphaBlendPassData data, RasterGraphContext context) =>
            {
                context.cmd.DrawRendererList(data.rendererListHandle);
            });
        }

        BlitMaterialParameters blitParams = new BlitMaterialParameters(playerRT, activeColorTexture, pixelationMat, 0);
        renderGraph.AddBlitPass(blitParams, "Blend PlayerRT To CameraColor");
        resourceData.cameraColor = activeColorTexture;

        /*
        // Mask
        TextureHandle playerMaskRT = renderGraph.CreateTexture(new TextureDesc(descriptor)
        {
            name = "PlayerMaskRT",
            clearBuffer = true,
            clearColor = Color.black,
        });
        blitParams = new BlitMaterialParameters(playerRT, playerMaskRT, maskMat, 0);
        renderGraph.AddBlitPass(blitParams, "Blend PlayerRT To MaskRT");

        // Pixelation
        TextureHandle playerPixelationRT = renderGraph.CreateTexture(new TextureDesc(descriptor)
        {
            name = "PlayerPixelationRT",
            clearBuffer = true
        });

        using (var builder = renderGraph.AddRasterRenderPass<MaskPassData>("Player Pixelation", out var passData))
        {
            passData.material = pixelationMat;
            passData.sourceTex = resourceData.cameraColor;
            passData.maskTex = playerMaskRT;

            builder.UseTexture(playerMaskRT, AccessFlags.Read);
            builder.UseTexture(resourceData.cameraColor, AccessFlags.Read);
            builder.SetRenderAttachment(playerPixelationRT, 0);
            builder.AllowGlobalStateModification(true);

            builder.SetRenderFunc((MaskPassData data, RasterGraphContext context) =>
            {
                data.material.SetTexture("_MaskTex", data.maskTex);
                Blitter.BlitTexture(context.cmd, data.sourceTex, new Vector4(1, 1, 0, 0), data.material, 0);
            });
        }

        resourceData.cameraColor = playerPixelationRT;
        */
    }
}
