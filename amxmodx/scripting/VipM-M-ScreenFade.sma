#include <amxmodx>
#include <reapi>
#include <VipModular>

new const MODULE_NAME[] = "ScreenFade";

public VipM_OnInitModules() {
    register_plugin("[VipM-M] ScreenFade", "1.0.0", "ArKaNeMaN");

    VipM_Modules_Register(MODULE_NAME);
    VipM_Modules_AddParams(MODULE_NAME,
        "Red", ptInteger, false,
        "Green", ptInteger, false,
        "Blue", ptInteger, false
    );
    VipM_Modules_RegisterEvent(MODULE_NAME, Module_OnActivated, "@OnModuleActivated");
}

@OnModuleActivated() {
    RegisterHookChain(RG_CBasePlayer_Killed, "@OnPlayerKilled", .post = true);
}

@OnPlayerKilled(const victimIndex, inflictorIndex, killerIndex) {
    if (!is_user_alive(killerIndex) || rg_is_player_blind(killerIndex)) {
        return;
    }

    new Trie:params = VipM_Modules_GetParams(MODULE_NAME, killerIndex);

    ScreenFade(
        .playerIndex = killerIndex,
        .red = VipM_Params_GetInt(params, "Red", 0),
        .green = VipM_Params_GetInt(params, "Green", 0),
        .blue = VipM_Params_GetInt(params, "Blue", 0),
        .alpha = 50,
        .fxTime = 0.3,
        .holdTime = 0.4
    );
}

// В край уже обленился))
// https://dev-cs.ru/resources/41/field?field=source
stock ScreenFade(const playerIndex, const red, const green, const blue, const alpha, const Float:fxTime = 1.0, const Float:holdTime = 1.0) {
    const FFADE_IN = 0x0000;
    static screenFadeMessage;

    if (screenFadeMessage > 0 || (screenFadeMessage = get_user_msgid("ScreenFade"))) {
        message_begin(MSG_ONE_UNRELIABLE, screenFadeMessage, .player = playerIndex);
        write_short(FixedUnsigned16(fxTime));
        write_short(FixedUnsigned16(holdTime));
        write_short(FFADE_IN);
        write_byte(red);
        write_byte(green);
        write_byte(blue);
        write_byte(alpha);
        message_end();
    }
}

stock bool:rg_is_player_blind(const playerIndex) {
    return bool:(Float:get_member(playerIndex, m_blindStartTime) + Float:get_member(playerIndex, m_blindFadeTime) >= get_gametime())
}

stock FixedUnsigned16(const Float:value, const scale = (1 << 12)) {
    return clamp(floatround(value * scale), 0, 0xFFFF)
}
