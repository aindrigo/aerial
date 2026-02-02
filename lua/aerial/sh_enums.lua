aerial.enums = aerial.enums or {}

aerial.enums.ATTACK_TYPE_NONE = 0
aerial.enums.ATTACK_TYPE_BULLET = 1
aerial.enums.ATTACK_TYPE_MELEE = 2
aerial.enums.ATTACK_TYPE_PROJECTILE = 3

aerial.enums.RELOAD_MODE_NORMAL = 0
aerial.enums.RELOAD_MODE_BULLET_BY_BULLET = 1

aerial.enums.FIRE_MODE_SEMIAUTOMATIC = 0
aerial.enums.FIRE_MODE_AUTOMATIC = 1

aerial.enums.CUSTOM_RECOIL_MODE_COMPENSATING = 0
aerial.enums.CUSTOM_RECOIL_MODE_KICKBACK = 1

aerial.enums.ATTACK_FLAGS_NONE = 0
aerial.enums.ATTACK_FLAGS_REMOVE_ON_ZERO_AMMO = 1
aerial.enums.ATTACK_FLAGS_NO_AMMO = 2

aerial.enums.CHARGE_TYPE_RELEASE = 0 -- Triggers on release
aerial.enums.CHARGE_TYPE_HOLD = 1 -- Triggers on ATTACK.Charge.HoldTime, canceled if released
