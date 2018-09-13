/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Berserker"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const BerserkerID = 5		//狂战士ID

new const ChopperModels[2][] = { "models/zombieriot/v_machete.mdl", "models/zombieriot/p_machete.mdl" }
new const ChopperSounds[3][] = { "zombieriot/Kucri_Attack_1.wav", "zombieriot/Kucri_Attack_2.wav", "zombieriot/Kucri_Select.wav" }

new Float:g_vecLastEnd[33][3], Float:g_vecLastNewEnd[33][3]
new cvar_distance[2], cvar_rate[2], cvar_damage, cvar_knockback
new g_fwBotForwardRegister

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_TraceLine, "fw_TraceLine")
	register_forward(FM_TraceHull, "fw_TraceHull")
	register_forward(FM_EmitSound, "fw_EmitSound")
	g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "HAM_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "HAM_Weapon_SecondaryAttack_Post", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "HAM_ItemDeploy_Post", 1)
	cvar_distance[0] = register_cvar("zr_chopper_slash", "52")			//轻击距离
	cvar_distance[1] = register_cvar("zr_chopper_stab", "48")			//重击距离
	cvar_rate[0] = register_cvar("zr_chopper_slashrate_times", "0.8")	//轻击速度
	cvar_rate[1] = register_cvar("zr_chopper_stabrate_times", "0.7")	//重击速度
	cvar_damage = register_cvar("zr_chopper_damage", "3.0")				//伤害倍数
	cvar_knockback = register_cvar("zr_chopper_knockback", "2.0")		//击退倍数
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, ChopperModels[0])
	engfunc(EngFunc_PrecacheModel, ChopperModels[1])
	engfunc(EngFunc_PrecacheSound, ChopperSounds[0])
	engfunc(EngFunc_PrecacheSound, ChopperSounds[1])
	engfunc(EngFunc_PrecacheSound, ChopperSounds[2])
}

public fw_TraceLine(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return FMRES_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) == ZOMBIE)
	return FMRES_IGNORED
	
	if(zr_get_human_id(iPlayer) != BerserkerID)
	return FMRES_IGNORED
	
	new iWeapon = get_pdata_cbase(iPlayer, 373, 5)
	
	if(iWeapon <= 0)
	return FMRES_IGNORED
	
	if(get_pdata_int(iWeapon, 43, 4) != CSW_KNIFE)
	return FMRES_IGNORED
	
	static Float:angles[3]
	pev(iPlayer, pev_v_angle, angles)
	engfunc(EngFunc_MakeVectors, angles)
	
	static Float:v_forward[3]
	global_get(glb_v_forward, v_forward)
	
	xs_vec_sub(vecEnd, vecStart, angles)
	
	angles[0] /= v_forward[0]
	angles[1] /= v_forward[1]
	angles[2] /= v_forward[2]
	
	new Float:dstance
	if(floatround(angles[0]) == 48 && floatround(angles[1]) == 48 && floatround(angles[2]) == 48) dstance = get_pcvar_float(cvar_distance[0])
	else if(floatround(angles[0]) == 32 && floatround(angles[1]) == 32 && floatround(angles[2]) == 32) dstance = get_pcvar_float(cvar_distance[1])
	else return FMRES_IGNORED
	
	xs_vec_copy(vecEnd, g_vecLastEnd[iPlayer])
	xs_vec_mul_scalar(v_forward, dstance, v_forward)
	xs_vec_add(vecStart, v_forward, vecEnd)
	xs_vec_copy(vecEnd, g_vecLastNewEnd[iPlayer])
	engfunc(EngFunc_TraceLine, vecStart, vecEnd, iConditions, iPlayer, iTrace)
	
	return FMRES_SUPERCEDE
}

public fw_TraceHull(Float:start[3], Float:end[3], iHullNumber, iNoMonsters, iPlayer, tr)
{
	if(!is_user_alive(iPlayer))
	return FMRES_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) == ZOMBIE)
	return FMRES_IGNORED
	
	if(zr_get_human_id(iPlayer) != BerserkerID)
	return FMRES_IGNORED
	
	new iWeapon = get_pdata_cbase(iPlayer, 373, 5)
	
	if(iWeapon <= 0)
	return FMRES_IGNORED
	
	if(get_pdata_int(iWeapon, 43, 4) != CSW_KNIFE)
	return FMRES_IGNORED
	
	if(g_vecLastEnd[iPlayer][0] != end[0] || g_vecLastEnd[iPlayer][1] != end[1] || g_vecLastEnd[iPlayer][2] != end[2])
	return FMRES_IGNORED
	
	g_vecLastEnd[iPlayer] = Float:{ 0.0, 0.0, 0.0 }
	engfunc(EngFunc_TraceHull, start, g_vecLastNewEnd[iPlayer], iHullNumber, iNoMonsters, iPlayer, tr)
	
	return FMRES_SUPERCEDE
}

public fw_EmitSound(iPlayer, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(!is_user_connected(iPlayer))
	return FMRES_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) == ZOMBIE)
	return FMRES_IGNORED
	
	if(zr_get_human_id(iPlayer) != BerserkerID)
	return FMRES_IGNORED
	
	if(!strcmp(sample, "weapons/knife_deploy1.wav"))
	{
	engfunc(EngFunc_EmitSound, iPlayer, channel, ChopperSounds[2], volume, attn, flags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(!strcmp(sample, "weapons/knife_slash1.wav"))
	{
	engfunc(EngFunc_EmitSound, iPlayer, channel, ChopperSounds[0], volume, attn, flags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(!strcmp(sample, "weapons/knife_slash2.wav"))
	{
	engfunc(EngFunc_EmitSound, iPlayer, channel, ChopperSounds[1], volume, attn, flags, pitch)
	return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_alive(attacker))
	return HAM_IGNORED
	
	if(get_pdata_int(attacker, 114, 5) == ZOMBIE)
	return HAM_IGNORED
	
	if(zr_get_human_id(attacker) != BerserkerID)
	return HAM_IGNORED
	
	if(attacker != inflictor)
	return HAM_IGNORED
	
	new iEntity = get_pdata_cbase(attacker, 373, 5)
	
	if(iEntity <= 0)
	return HAM_IGNORED
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return HAM_IGNORED
	
	SetHamParamFloat(4, damage*get_pcvar_float(cvar_damage))
	
	return HAM_IGNORED
}

public HAM_Weapon_PrimaryAttack_Post(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_human_id(iPlayer) != BerserkerID)
	return
	
	set_pdata_float(iEntity, 46, get_pdata_float(iEntity, 46, 4)*get_pcvar_float(cvar_rate[0]), 4)
}

public HAM_Weapon_SecondaryAttack_Post(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(zr_get_human_id(iPlayer) != BerserkerID)
	return
	
	set_pdata_float(iEntity, 47, get_pdata_float(iEntity, 47, 4)*get_pcvar_float(cvar_rate[1]), 4)
}

public HAM_ItemDeploy_Post(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_human_id(iPlayer) != BerserkerID)
	return
	
	set_pev(iPlayer, pev_viewmodel2, ChopperModels[0])
	set_pev(iPlayer, pev_weaponmodel2, ChopperModels[1])
}

public zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
{
	if(!is_user_alive(Knocker))
	return ZR_IGNORED
	
	if(zr_is_user_zombie(Knocker))
	return ZR_IGNORED
	
	if(zr_get_human_id(Knocker) != BerserkerID)
	return ZR_IGNORED
	
	if(Knocker != inflictor)
	return ZR_IGNORED
	
	new iEntity = get_pdata_cbase(Knocker, 373, 5)
	
	if(iEntity <= 0)
	return ZR_IGNORED
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return ZR_IGNORED
	
	zr_set_knockback(Knocker, victim, Speed*get_pcvar_float(cvar_knockback))
	
	return ZR_SUPERCEDE
}

public zr_being_human(iPlayer)
{
	if(zr_get_human_id(iPlayer) != BerserkerID)
	return
	
	set_pev(iPlayer, pev_armorvalue, zr_get_human_health(BerserkerID))
	set_pdata_int(iPlayer, 112, 2, 5)
	
	new iEntity = get_pdata_cbase(iPlayer, 373, 5)
	
	if(iEntity <= 0)
	return
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return
	
	set_pev(iPlayer, pev_viewmodel2, ChopperModels[0])
	set_pev(iPlayer, pev_weaponmodel2, ChopperModels[1])
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage")
}