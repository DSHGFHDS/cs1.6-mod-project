/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Juggernaut"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const JuggernautID = 6		//无畏者ID

new const ShockSound[] = "zombieriot/ShockSkill.wav"

new g_fwBotForwardRegister
new cvar_damageweaken, cvar_range, cvar_cooldown, cvar_power
new Float:NextThink[33]
new WaveSPR

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage")
	RegisterHam(Ham_BloodColor, "player", "HAM_BloodColor")
	cvar_damageweaken = register_cvar("zr_juggernaut_damageweaken", "0.4")		//受特殊伤害减弱倍数
	cvar_range = register_cvar("zr_juggernaut_range", "150.0")					//震撼技能范围
	cvar_cooldown = register_cvar("zr_juggernaut_cooldown", "20.0")				//震撼技能冷却时间
	cvar_power = register_cvar("zr_juggernaut_power", "800.0")					//震撼技能击退力度
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, ShockSound)
	WaveSPR = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
}

public fw_CmdStart(iPlayer, uc_handle, seed)
{
	if(zr_is_user_zombie(iPlayer))
	return FMRES_IGNORED
	
	if(zr_get_human_id(iPlayer) != JuggernautID)
	return FMRES_IGNORED
	
	if(get_uc(uc_handle, UC_Impulse) != 201)
	return FMRES_IGNORED
	
	if(NextThink[iPlayer] > 0.0)
	{
	zr_print_chat(iPlayer, GREYCHAT, "震撼技能正在冷却!")
	return FMRES_IGNORED
	}
	
	Shocking(iPlayer)
	set_uc(uc_handle, UC_Impulse, 0)
	
	return FMRES_IGNORED
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_human_id(iPlayer) != JuggernautID)
	return
	
	if(NextThink[iPlayer] <= 0.0)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(NextThink[iPlayer] > fCurTime)
	return
	
	NextThink[iPlayer] = -1.0
	zr_print_chat(iPlayer, BLUECHAT, "震撼技能已冷却完毕!")
}

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_human_id(iPlayer) != JuggernautID)
	return
	
	if(NextThink[iPlayer] > 0.0)
	return
	
	new Enemy = get_tr2(iTrace, TR_pHit)
	if(!is_user_alive(Enemy))
	return
	
	if(!zr_is_user_zombie(Enemy))
	return
	
	new Float:origin[3]
	get_tr2(iTrace, TR_vecEndPos, origin)
	
	if(get_distance_f(vecStart, origin) > get_pcvar_float(cvar_range))
	return
	
	Shocking(iPlayer)
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_alive(victim))
	return HAM_IGNORED
	
	if(get_pdata_int(victim, 114, 5) == ZOMBIE)
	return HAM_IGNORED
	
	if(zr_get_human_id(victim) != JuggernautID)
	return HAM_IGNORED
	
	if(!(damage_type & DMG_BLAST) && !(damage_type & DMG_CRUSH) && !(damage_type & DMG_BURN) && !(damage_type & DMG_SLOWBURN))
	return HAM_IGNORED
	
	SetHamParamFloat(4, damage*get_pcvar_float(cvar_damageweaken))
	
	return HAM_IGNORED
}

public HAM_BloodColor(iPlayer)
{
	if(!is_user_alive(iPlayer))
	return HAM_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) == ZOMBIE)
	return HAM_IGNORED
	
	if(zr_get_human_id(iPlayer) != JuggernautID)
	return HAM_IGNORED
	
	SetHamReturnInteger(-1)
	
	return HAM_SUPERCEDE
}

public zr_being_human(iPlayer)
{
	if(zr_get_human_id(iPlayer) != JuggernautID)
	return
	
	set_pev(iPlayer, pev_armorvalue, zr_get_human_health(JuggernautID))
	set_pdata_int(iPlayer, 112, 2, 5)
	
	fm_give_item(iPlayer, "weapon_m249")
	ExecuteHamB(Ham_GiveAmmo, iPlayer, 200, "556natobox", 200)
}

public Shocking(iPlayer)
{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	NextThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	
	new Float:origin[2][3]
	pev(iPlayer, pev_origin, origin[0])
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	if(!zr_is_user_zombie(i))
	continue
	
	pev(i, pev_origin, origin[1])
	
	if(get_distance_f(origin[0], origin[1]) > get_pcvar_float(cvar_range))
	continue
	
	new Float:velocity[3]
	GetVelocityFromOrigin(origin[1], origin[0], get_pcvar_float(cvar_power), velocity)
	velocity[2] += 200.0
	set_pev(i, pev_velocity, velocity)
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, i)
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<14)
	message_end()
	}
	
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, ShockSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin[0], 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, origin[0][0])
	engfunc(EngFunc_WriteCoord, origin[0][1])
	engfunc(EngFunc_WriteCoord, origin[0][2])
	engfunc(EngFunc_WriteCoord, origin[0][0])
	engfunc(EngFunc_WriteCoord, origin[0][1])
	engfunc(EngFunc_WriteCoord, origin[0][2]+300.0)
	write_short(WaveSPR)
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(0)
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin[0], 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, origin[0][0])
	engfunc(EngFunc_WriteCoord, origin[0][1])
	engfunc(EngFunc_WriteCoord, origin[0][2])
	engfunc(EngFunc_WriteCoord, origin[0][0])
	engfunc(EngFunc_WriteCoord, origin[0][1])
	engfunc(EngFunc_WriteCoord, origin[0][2]+200.0)
	write_short(WaveSPR)
	write_byte(0)
	write_byte(0)
	write_byte(3)
	write_byte(40)
	write_byte(0)
	write_byte(80)
	write_byte(100)
	write_byte(255)
	write_byte(255)
	write_byte(0)
	message_end()
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage")
	RegisterHamFromEntity(Ham_BloodColor, iPlayer, "HAM_BloodColor")
}

stock fm_give_item(iPlayer, const wEntity[])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, wEntity))
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	set_pev(iEntity, pev_origin, origin)
	set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, iEntity)
	new save = pev(iEntity, pev_solid)
	dllfunc(DLLFunc_Touch, iEntity, iPlayer)
	if(pev(iEntity, pev_solid) != save)
	return iEntity
	engfunc(EngFunc_RemoveEntity, iEntity)
	return -1
}

stock GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}