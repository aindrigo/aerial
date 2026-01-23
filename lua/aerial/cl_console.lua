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

-- Convars
aerial.console = aerial.console or {}
aerial.console.firemodeBind = aerial.console.firemodeBind or CreateClientConVar("aerial_bind_firemode", "24", true, true, "Firemode bind, see aerial_set_bind_firemode", 0)
aerial.console.debug = aerial.console.debug or CreateClientConVar("aerial_debug", "0", true, true, "Developer mode", 0, 1)
aerial.console.reloadCameraEnabled = aerial.console.reloadCameraEnabled or CreateClientConVar("aerial_reload_camera_enabled", "1", true, false, "Enable moving reload camera", 0, 1)

-- Crosshair convars
aerial.console.crosshair = aerial.console.crosshair or {}
aerial.console.crosshair.enabled = aerial.console.crosshair.enabled or CreateClientConVar("aerial_crosshair_enabled", "1", true, false, "Dynamic crosshair enabled. May not work on some servers")

aerial.console.crosshair.gap = aerial.console.crosshair.gap or CreateClientConVar("aerial_crosshair_gap", "128", true, false, "Crosshair gap multiplier", 0, 512)
aerial.console.crosshair.gapAdditive = aerial.console.crosshair.gapAdditive or CreateClientConVar("aerial_crosshair_gap_additive", "0", true, false, "Crosshair gap additive", -5, 5)
aerial.console.crosshair.gapMinimum = aerial.console.crosshair.gapMinimum or CreateClientConVar("aerial_crosshair_gap_minimum", "0", true, false, "Crosshair gap minimum", 0, 5)

aerial.console.crosshair.thickness = aerial.console.crosshair.thickness or CreateClientConVar("aerial_crosshair_thickness", "2", true, false, "Crosshair thickness", 0, 5)
aerial.console.crosshair.length = aerial.console.crosshair.length or CreateClientConVar("aerial_crosshair_length", "6", true, false, "Crosshair length", 0, 25)

aerial.console.crosshair.colorRed = aerial.console.crosshair.colorRed or CreateClientConVar("aerial_crosshair_r", "255", true, false, "Crosshair color red value", 0, 255)
aerial.console.crosshair.colorGreen = aerial.console.crosshair.colorGreen or CreateClientConVar("aerial_crosshair_g", "255", true, false, "Crosshair color green value", 0, 255)
aerial.console.crosshair.colorBlue = aerial.console.crosshair.colorBlue or CreateClientConVar("aerial_crosshair_b", "255", true, false, "Crosshair color blue value", 0, 255)
aerial.console.crosshair.colorAlpha = aerial.console.crosshair.colorAlpha or CreateClientConVar("aerial_crosshair_a", "255", true, false, "Crosshair color alpha value", 0, 255)

aerial.console.crosshair.static = aerial.console.crosshair.static or CreateClientConVar("aerial_crosshair_static", "0", true, false, "Whether or not the crosshair is static", 0, 1)
aerial.console.crosshair.dotEnabled = aerial.console.crosshair.dotEnabled or CreateClientConVar("aerial_crosshair_dot_enabled", "1", true, false, "Crosshair dot enabled state", 0, 1)

aerial.console.crosshair.outline = aerial.console.crosshair.outline or CreateClientConVar("aerial_crosshair_outline", "0", true, false, "Crosshair outline thickness, 0 = disabled", 0, 8)

-- Commands
concommand.Add("aerial_set_bind_firemode", function(ply, cmd, args, argStr)
    local code = input.GetKeyCode(argStr)
    if code == BUTTON_CODE_INVALID then
        print("Invalid keycode")
        return
    end

    aerial.console.firemodeBind:SetInt(code)
end)