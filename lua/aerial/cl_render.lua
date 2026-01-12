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

aerial.render = aerial.render or {}


--- Clears stencil data
-- @realm client
function aerial.render.ClearStencil()
    render.SetStencilReferenceValue(0)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()
end

--- Enables a mask that only allows objects to draw on top of a specified entity. You should run aerial.render.Unmask afterwards
-- @realm client
-- @entity entity Entity to permit drawing on top of
function aerial.render.MaskEntity(entity)
    aerial.render.ClearStencil()
    render.SetStencilEnable(true)

    render.ClearStencilBufferRectangle(0, 0, ScrW(), ScrH(), 0x00)

    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)

    render.SetStencilReferenceValue(0x61)
    entity:DrawModel()

    render.SetStencilCompareFunction(STENCIL_EQUAL)
end

--- Disables MaskEntity
-- @realm client
function aerial.render.Unmask()
    render.SetStencilEnable(false)
end