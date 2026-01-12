--[[
    Aerial, a weapon base designed to ease the creation of realistic weapons within Garry's Mod.
    Copyright (C) 2026  aindrigo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

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
