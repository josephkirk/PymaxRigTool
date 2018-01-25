'''
    Lists all of the assets in a file.
'''
import MaxPlus

assetTypes = {
    MaxPlus.AssetType.OtherAsset: "other",
    MaxPlus.AssetType.BitmapAsset: "bitmap",
    MaxPlus.AssetType.XRefAsset: "xref",
    MaxPlus.AssetType.PhotometricAsset: "photometric",
    MaxPlus.AssetType.AnimationAsset: "animation",
    MaxPlus.AssetType.VideoPost: "video post",
    MaxPlus.AssetType.BatchRender: "batch render",
    MaxPlus.AssetType.ExternalLink: "external link",
    MaxPlus.AssetType.RenderOutput: "render output",
    MaxPlus.AssetType.PreRenderScript: "pre-render script",
    MaxPlus.AssetType.PostRenderScript: "post-render script",
    MaxPlus.AssetType.SoundAsset: "sound",
    MaxPlus.AssetType.ContainerAsset: "container",
}

assets = MaxPlus.AssetManager.GetAssets()
print "There are ", len(assets), " assets"
for i in range(len(assets)):
    a = assets[i]
    print "Asset", i, a.ResolvedFileName, " is a ", assetTypes[a.Type]
    print "     ", a.SpecifiedFileName
