aerial.renderTarget = aerial.renderTarget or {}

aerial.renderTarget.widthConvar = CreateClientConVar("aerial_rt_width", "512", true, true, "Render target width. Used in scopes and such.", 0, 2048)
aerial.renderTarget.heightConvar = CreateClientConVar("aerial_rt_height", "512", true, true, "Render target height. Used in scopes and such.", 0, 2048)

aerial.renderTarget.rt = aerial.renderTarget.rt or GetRenderTarget(
    "aerialRenderTarget",
    aerial.renderTarget.widthConvar:GetInt(),
    aerial.renderTarget.heightConvar:GetInt()
)

aerial.renderTarget.material = aerial.renderTarget.material or CreateMaterial("aerialRenderTargetMaterial", "VertexLitGeneric", {
    ["$basetexture"] = aerial.renderTarget.rt:GetName(),
    ["$model"] = 1
})
