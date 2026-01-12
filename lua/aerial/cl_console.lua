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

aerial.console = aerial.console or {}
aerial.console.firemodeBind = aerial.console.firemodeBind or CreateConVar("aerial_bind_firemode", "24", bit.bor(FCVAR_ARCHIVE, FCVAR_USERINFO))
aerial.console.debug = aerial.console.debug or CreateClientConVar("aerial_debug", "0", true, true, "Developer mode", 0, 1)

concommand.Add("aerial_set_bind_firemode", function(ply, cmd, args, argStr)
    local code = input.GetKeyCode(argStr)
    if code == BUTTON_CODE_INVALID then
        print("Invalid keycode")
        return
    end

    aerial.console.firemodeBind:SetInt(code)
end)