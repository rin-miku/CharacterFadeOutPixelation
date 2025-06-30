using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RendererUtils;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;
using static UnityEngine.Rendering.RenderGraphModule.Util.RenderGraphUtils;

public class CharacterAlphaClipRenderPass : ScriptableRenderPass
{
    private Material alphaClipMat;

    class AlphaBlendPassData
    {
        public RendererListHandle rendererListHandle;
    }


    public CharacterAlphaClipRenderPass(Material alphaClipMaterial)
    {
        alphaClipMat = alphaClipMaterial;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        UniversalRenderingData renderingData = frameData.Get<UniversalRenderingData>();
        UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

        TextureHandle activeColorTexture = resourceData.activeColorTexture;

        // Alpha Clip
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

        BlitMaterialParameters blitParams = new BlitMaterialParameters(playerRT, activeColorTexture, alphaClipMat, 0);
        renderGraph.AddBlitPass(blitParams, "Character Alpha Clip");
        resourceData.cameraColor = activeColorTexture;
    }
}
