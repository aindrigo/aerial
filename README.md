# Aerial
A GMod weapon base originally intended to be [Longsword](https://github.com/vingard/longsword) [(also)](https://github.com/bitfielddev/longsword) 3.

[Content Pack](https://steamcommunity.com/sharedfiles/filedetails/?id=3092301722)

## License
Copyright (c) 2026 aindrigo. 
This library is licensed under the GNU Lesser General Public License version 3.0 or any later version.
See [LICENSE](LICENSE).

## Features
* Multiple attack types supported (Primary/Secondary/Tertiary/etc)
* Fire modes (current semiauto/auto)
* Charged attacks (either timer-based or hold time-based)
* Very customizable crosshair (requires support on custom gamemodes)

## Compatibility
Currently not compatible with Longsword (both old & new afaik), all public versions I know of use weapon metatables for Give/TakeAttachment methods.
Plutonic compatibility has not been tested. Other weapon bases *should* work fine.

## Crosshair
All crosshair console variables are under aerial_crosshair in console.
To implement the crosshair, implement this inside your crosshair draw function:
```lua
local weapon = LocalPlayer():GetActiveWeapon()
local shouldDrawWeaponCrosshair = IsValid(weapon) and isfunction(weapon.DoDrawCrosshair)

if shouldDrawWeaponCrosshair and weapon:DoDrawCrosshair(CROSSHAIR_X, CROSSHAIR_Y) then
    return
end
```

