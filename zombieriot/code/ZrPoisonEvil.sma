/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr PoisonEvil"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const PoisonEvil = 15	//飓风毒魔ID

new const PoisonHurricane[] = "zombieriot/poisonhurricane.wav"
new const PoisonExplosion[] = "zombieriot/poisonwave.wav"
new HurricaneIndex, PoisonSPR, ShockSPR

new g_fwBotForwardRegister
new WaveSkill[33], Float:NextThink[33], KeepHurricane[33]
new cvar_cooldown, cvar_range, cvar_drawrange, cvar_velocity, cvar_damage

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage")
	RegisterHam(Ham_Killed, "player", "HAM_Killed_Post", 1)
	g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	cvar_cooldown = register_cvar("zr_poisonevil_cooldown", "10.0")			//技能冷却时间
	cvar_range = register_cvar("zr_poisonevil_range", "250.0")				//技能伤害范围
	cvar_drawrange = register_cvar("zr_poisonevil_drawrange", "280.0")		//技能吸引范围
	cvar_velocity = register_cvar("zr_poisonevil_velocity", "550.0")		//技能吸引速度
	cvar_damage = register_cvar("zr_poisonevil_damage", "500.0")			//技能伤害
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, PoisonExplosion)
	engfunc(EngFunc_PrecacheSound, PoisonHurricane)
	HurricaneIndex = engfunc(EngFunc_PrecacheModel, "models/zombieriot/poisonhurricane.mdl")
	PoisonSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/poison_exp.spr")
	ShockSPR = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
}

public fw_ClientCommand(iPlayer)
{
	static szCommand[24]
	read_argv(0, szCommand, charsmax(szCommand))
	
	if(contain(szCommand, "weapon_") != 1 && 0 < WaveSkill[iPlayer] < 3)
	return FMRES_SUPERCEDE
	
	if(strcmp(szCommand, "drop") || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return FMRES_IGNORED
	
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return FMRES_IGNORED
	
	if(!zr_is_user_zombie(iPlayer))
	return FMRES_IGNORED
	
	if(zr_get_zombie_id(iPlayer) != PoisonEvil)
	return FMRES_IGNORED
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return FMRES_SUPERCEDE
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return FMRES_SUPERCEDE
	
	if(WaveSkill[iPlayer])
	{
	if(WaveSkill[iPlayer] == 3) zr_print_chat(iPlayer, GREYCHAT, "毒爆技能正在冷却中!")
	return FMRES_SUPERCEDE
	}
	
	WaveBegin(iPlayer)
	
	return FMRES_SUPERCEDE
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != PoisonEvil)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(WaveSkill[iPlayer] == 1 && fCurTime >= NextThink[iPlayer])
	{
	WaveSkill[iPlayer] = 2
	NextThink[iPlayer] = get_gametime() + 1.6
	WaveExplosion(iPlayer)
	return
	}
	
	if(WaveSkill[iPlayer] == 2 && fCurTime >= NextThink[iPlayer])
	{
	set_pdata_float(iPlayer, 83, 0.0, 5)
	set_pev(iPlayer, pev_flags, (pev(iPlayer, pev_flags) & ~FL_FROZEN))
	WaveSkill[iPlayer] = 3
	NextThink[iPlayer] = get_gametime() + get_pcvar_float(cvar_cooldown)
	return
	}
	
	if(WaveSkill[iPlayer] == 3 && fCurTime >= NextThink[iPlayer])
	{
	WaveSkill[iPlayer] = 0
	zr_print_chat(iPlayer, REDCHAT, "毒爆技能已冷却完毕!")
	return
	}
	
}

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(WaveSkill[iPlayer])
	return
	
	if(zr_get_zombie_id(iPlayer) != PoisonEvil)
	return
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return
	
	new Enemy = get_tr2(iTrace, TR_pHit)
	if(!is_user_alive(Enemy))
	return
	
	if(zr_is_user_zombie(Enemy))
	return
	
	new Float:origin[3]
	get_tr2(iTrace, TR_vecEndPos, origin)
	
	if(get_distance_f(vecStart, origin) > get_pcvar_float(cvar_range))
	return
	
	WaveBegin(iPlayer)
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_alive(victim))
	return HAM_IGNORED
	
	if(!zr_is_user_zombie(victim))
	return HAM_IGNORED
	
	if(zr_get_zombie_id(victim) != PoisonEvil)
	return HAM_IGNORED
	
	if((damage_type & DMG_POISON) || (damage_type & DMG_ACID))
	return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

public HAM_Killed_Post(iPlayer, attacker, shouldgib)
{
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != PoisonEvil)
	return
	
	if(!pev_valid(KeepHurricane[iPlayer]))
	return
	
	set_pev(iPlayer, pev_flags, (pev(iPlayer, pev_flags) & ~FL_FROZEN))
	set_pev(KeepHurricane[iPlayer], pev_flags, FL_KILLME)
	KeepHurricane[iPlayer] = 0
}

public WaveBegin(iPlayer)
{
	if(!(pev(iPlayer, pev_flags) & FL_ONGROUND))
	{
	zr_print_chat(iPlayer, GREYCHAT, "无法在空中使用毒爆技能!")
	return
	}
	
	WaveSkill[iPlayer] = 1
	NextThink[iPlayer] = get_gametime() + 0.7
	set_pdata_float(iPlayer, 83, 2.3, 5)
	SendWeaponAnim(iPlayer, 8)
	zr_set_user_anim(iPlayer, 2.3, 111)
	CreateHurricane(iPlayer)
	set_pev(iPlayer, pev_velocity, {0.0, 0.0, 0.0})
	set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags)|FL_FROZEN)
}

public CreateHurricane(iPlayer)
{
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	KeepHurricane[iPlayer] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(KeepHurricane[iPlayer], pev_classname, "zrhurricane")
	set_pev(KeepHurricane[iPlayer], pev_solid, SOLID_NOT)
	set_pev(KeepHurricane[iPlayer], pev_movetype, MOVETYPE_NONE)
	set_pev(KeepHurricane[iPlayer], pev_owner, iPlayer)
	set_pev(KeepHurricane[iPlayer], pev_modelindex, HurricaneIndex)
	set_pev(KeepHurricane[iPlayer], pev_sequence, 0)
	set_pev(KeepHurricane[iPlayer], pev_animtime, get_gametime())
	set_pev(KeepHurricane[iPlayer], pev_frame, 0.0)
	set_pev(KeepHurricane[iPlayer], pev_framerate, 2.0)
	engfunc(EngFunc_SetOrigin, KeepHurricane[iPlayer], origin)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, PoisonHurricane, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_ELIGHT)
	write_short(iPlayer)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, 5.0)
	write_byte(80)
	write_byte(255)
	write_byte(80)
	write_byte(10000)
	engfunc(EngFunc_WriteCoord, 0.0)
	message_end()
	
	for(new i = 1; i < 33; i ++)
	{
	if(i == iPlayer)
	continue
	
	if(!is_user_alive(i))
	continue
	
	if(zr_is_user_zombie(i))
	continue
	
	new Float:iOrigin[3]
	pev(i, pev_origin, iOrigin)
	
	if(get_distance_f(origin, iOrigin) > get_pcvar_float(cvar_drawrange))
	continue
	
	new Float:velocity[3]
	GetVelocityToOrigin(iOrigin, origin, get_pcvar_float(cvar_velocity), velocity)
	velocity[2] += 150.0
	set_pev(i, pev_velocity, velocity)
	}
}

public WaveExplosion(iPlayer)
{
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2]-10.0)
	engfunc(EngFunc_WriteCoord, origin[0]-150.0)
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2]+300.0)
	write_short(ShockSPR)
	write_byte(0)
	write_byte(0)
	write_byte(3)
	write_byte(350)
	write_byte(0)
	write_byte(120)
	write_byte(255)
	write_byte(100)
	write_byte(200)
	write_byte(2)
	message_end()
	
	new Float:Distance = get_pcvar_float(cvar_range)/4.0
	origin[2] += 180.0
	SendExplosionMSG(origin)
	origin[2] -= 50.0
	origin[0] += Distance
	SendExplosionMSG(origin)
	origin[0] -= Distance*2.0
	SendExplosionMSG(origin)
	origin[0] += Distance
	origin[1] += Distance
	SendExplosionMSG(origin)
	origin[1] -= Distance*2.0
	SendExplosionMSG(origin)
	
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, PoisonExplosion, 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(KeepHurricane[iPlayer], pev_flags, FL_KILLME)
	KeepHurricane[iPlayer] = 0
	
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, get_pcvar_float(cvar_range))) > 0)
	{
	if(!pev_valid(i) || iPlayer == i)
	continue
	
	if(pev(i, pev_takedamage) == DAMAGE_NO)
	continue
	
	new Float:origin2[3]
	pev(i, pev_origin, origin2)
	engfunc(EngFunc_TraceLine, origin, origin2, IGNORE_MONSTERS, iPlayer, 0)
	new Float:fraction
	get_tr2(0, TR_flFraction, fraction)
	if(fraction != 1.0)
	continue
	
	static classname[33]
	pev(i, pev_classname, classname, charsmax(classname))
	if(!strcmp(classname, "func_breakable"))
	{
	dllfunc(DLLFunc_Use, i, iPlayer)
	continue
	}
	
	if(!is_user_alive(i))
	continue
	
	if(zr_is_user_zombie(i))
	continue
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, i)
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<14)
	message_end()
	
	ExecuteHamB(Ham_TakeDamage, i, 0, iPlayer, get_pcvar_float(cvar_damage), DMG_ACID|DMG_POISON)
	new Float:velocity[3]
	velocity[2] = random_float(250.0, 350.0)
	set_pev(i, pev_velocity, velocity)
	}
}

public SendExplosionMSG(Float:origin[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(PoisonSPR)
	write_byte(15)
	write_byte(255)
	message_end()
}

public zr_being_zombie(iPlayer)
{
	NextThink[iPlayer] = 0.0
	WaveSkill[iPlayer] = 0
	if(pev_valid(KeepHurricane[iPlayer]))
	{
	set_pev(KeepHurricane[iPlayer], pev_flags, FL_KILLME)
	KeepHurricane[iPlayer] = 0
	}
	set_pev(iPlayer, pev_flags, (pev(iPlayer, pev_flags) & ~FL_FROZEN))
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public zr_roundbegin_event(Weather)
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "zrhurricane"))) set_pev(iEntity, pev_flags, FL_KILLME)
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage")
	RegisterHamFromEntity(Ham_Killed, iPlayer, "HAM_Killed_Post", 1)
}

stock SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0,0,0}, iPlayer)
	write_byte(iAnim)
	write_byte(1)
	message_end()
}

stock GetVelocityToOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin2, origin1, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}