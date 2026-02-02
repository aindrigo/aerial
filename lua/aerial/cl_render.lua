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