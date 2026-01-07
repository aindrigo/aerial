aerial.console = aerial.console or {}
aerial.console.firemodeBind = aerial.console.firemodeBind or CreateConVar("aerial_bind_firemode", "24", bit.bor(FCVAR_ARCHIVE, FCVAR_USERINFO))

concommand.Add("aerial_set_bind_firemode", function(ply, cmd, args, argStr)
    local code = input.GetKeyCode(argStr)
    if code == BUTTON_CODE_INVALID then
        print("Invalid keycode")
        return
    end

    aerial.console.firemodeBind:SetInt(code)
end)