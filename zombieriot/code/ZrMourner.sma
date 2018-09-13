/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "ZR Mourner"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const Mourner = 9		//送葬者僵尸类型ID

new ShockSPR, StopSPR, SkillSPR, SkillIndex, WoodIndex
new const SkillSounds[][] = { "zombieriot/mournerskill_start.wav", "zombieriot/mournerskill_over.wav" }

new bool:InStuck[33], SkillMode[33], Float:NextThink[33], Float:MaxSpeedRecorder[33], KeepIcon[33]

new cvar_health, cvar_livetime, cvar_range, cvar_knockback, cvar_stucktime, cvar_speedtimes, cvar_cooldown
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	RegisterHam(Ham_Think, "info_target", "HAM_SPRThink")
	RegisterHam(Ham_Think, "info_target", "HAM_Think")
	RegisterHam(Ham_TraceAttack, "info_target", "HAM_TraceAttack")
	RegisterHam(Ham_Killed, "info_target", "HAM_Killed")
	cvar_health = register_cvar("zr_mourner_coffinhealth", "150.0")			//铁处女的生命
	cvar_livetime = register_cvar("zr_mourner_livetime", "10.0")			//铁处女的存在时间
	cvar_range = register_cvar("zr_mourner_range", "150.0")					//铁处女爆炸影响范围
	cvar_knockback = register_cvar("zr_mourner_knockback", "1000.0")		//铁处女爆炸击退
	cvar_stucktime = register_cvar("zr_mourner_stucktime", "8.0")			//铁处女速度影响时间
	cvar_speedtimes = register_cvar("zr_mourner_speedtimes", "0.5")			//受影响时的行走速度倍数
	cvar_cooldown = register_cvar("zr_mourner_cooldown", "8.0")				//技能冷却时间
}

public plugin_precache()
{
	for(new i = 0; i < 2; i ++) engfunc(EngFunc_PrecacheSound, SkillSounds[i])
	ShockSPR = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
	StopSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/butcherskill.spr")
	SkillSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/skillexplosion.spr")
	SkillIndex = engfunc(EngFunc_PrecacheModel, "models/zombieriot/mournerskill.mdl")
	WoodIndex = engfunc(EngFunc_PrecacheModel, "models/woodgibs.mdl")
}

public zr_roundbegin_event(Weather)
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "zrcoffin"))) set_pev(iEntity, pev_flags, FL_KILLME)
	iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "zrcoffinSPR"))) set_pev(iEntity, pev_flags, FL_KILLME)
}

public Event_CurWeapon(iPlayer) if(SkillMode[iPlayer] == 1) SkillMode[iPlayer] = 0

public fw_ClientCommand(iPlayer)
{
	static szCommand[24]
	read_argv(0, szCommand, charsmax(szCommand))
	
	if(strcmp(szCommand, "drop") || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return FMRES_IGNORED
	
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return FMRES_IGNORED
	
	if(!zr_is_user_zombie(iPlayer))
	return FMRES_IGNORED
	
	if(zr_get_zombie_id(iPlayer) != Mourner)
	return FMRES_IGNORED
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return FMRES_SUPERCEDE
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return FMRES_SUPERCEDE
	
	if(SkillMode[iPlayer] == 1)
	{
	zr_print_chat(iPlayer, GREYCHAT, "铁处女技能正在使用!")
	return FMRES_SUPERCEDE
	}
	
	if(SkillMode[iPlayer] == 2)
	{
	zr_print_chat(iPlayer, GREYCHAT, "铁处女技能正在冷却!")
	return FMRES_SUPERCEDE
	}
	
	SkillBegin(iPlayer)
	
	return FMRES_SUPERCEDE
}

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(SkillMode[iPlayer])
	return
	
	if(zr_get_zombie_id(iPlayer) != Mourner)
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
	
	SkillBegin(iPlayer)
}

public HAM_SPRThink(iEntity)
{
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, "zrcoffinSPR"))
	return HAM_IGNORED
	
	new Float:origin[3]
	pev(pev(iEntity, pev_owner), pev_origin, origin)
	origin[2] += 35.0
	set_pev(iEntity, pev_origin, origin)
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.01)
	
	return HAM_SUPERCEDE
}

public HAM_Think(iEntity)
{
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, "zrcoffin"))
	return HAM_IGNORED
	
	BreakCoffin(iEntity)
	
	return HAM_SUPERCEDE
}

public HAM_TraceAttack(iEntity, attacker, Float:damage, Float:direction[3], tracehandle, damagetype)
{
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, "zrcoffin"))
	return HAM_IGNORED
	
	new Float:origin[3]
	get_tr2(tracehandle, TR_vecEndPos, origin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()
	
	return HAM_IGNORED
}

public HAM_Killed(iEntity, attacker, shouldgib)
{
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, "zrcoffin"))
	return HAM_IGNORED
	
	BreakCoffin(iEntity)
	
	return HAM_SUPERCEDE
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(!zr_is_user_zombie(iPlayer))
	{
	if(!InStuck[iPlayer])
	return
	
	if(NextThink[iPlayer] > fCurTime)
	return
	
	InStuck[iPlayer] = false
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	maxspeed += MaxSpeedRecorder[iPlayer]
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
	MaxSpeedRecorder[iPlayer] = 0.0
	set_pev(KeepIcon[iPlayer], pev_flags, FL_KILLME)
	KeepIcon[iPlayer] = 0
	
	return
	}
	
	if(zr_get_zombie_id(iPlayer) != Mourner)
	return
	
	if(SkillMode[iPlayer] == 1 && NextThink[iPlayer] <= fCurTime)
	{
	SetCoffin(iPlayer)
	SkillMode[iPlayer] = 2
	return
	}
	
	if(SkillMode[iPlayer] != 2 || NextThink[iPlayer] > fCurTime)
	return
	
	zr_print_chat(iPlayer, BLUECHAT, "铁处女技能冷却完毕!")
	SkillMode[iPlayer] = 0
}

public SkillBegin(iPlayer)
{
	if(!(pev(iPlayer, pev_flags) & FL_ONGROUND))
	{
	zr_print_chat(iPlayer, GREYCHAT, "无法在空中放置铁处女!")
	return
	}
	
	SkillMode[iPlayer] = 1
	NextThink[iPlayer] = get_gametime() + 0.5
	set_pdata_float(iPlayer, 83, 1.1, 5)
	SendWeaponAnim(iPlayer, 2)
	zr_set_user_anim(iPlayer, 1.1, 85)
}

public SetCoffin(iPlayer)
{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	new Float:angles[3]
	pev(iPlayer, pev_angles, angles)
	angles[0] = 0.0
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEntity, pev_classname, "zrcoffin")
	set_pev(iEntity, pev_modelindex, SkillIndex)
	set_pev(iEntity, pev_solid, SOLID_BBOX)
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_takedamage, DAMAGE_YES)
	set_pev(iEntity, pev_gravity, 2.0)
	set_pev(iEntity, pev_gamestate, 0.0)
	set_pev(iEntity, pev_health, get_pcvar_float(cvar_health))
	set_pev(iEntity, pev_angles, angles)
	set_pev(iEntity, pev_nextthink, fCurTime+get_pcvar_float(cvar_livetime))
	SetPenetrationToGhost(iEntity, true)
	engfunc(EngFunc_SetSize, iEntity, {-14.0, -10.0, -36.0}, {14.0, 10.0, 36.0})
	
	new Float:origin[3], Float:view_ofs[3]
	pev(iPlayer, pev_origin, origin)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(origin, view_ofs, origin)
	pev(iPlayer, pev_angles, angles)
	engfunc(EngFunc_MakeVectors, angles)
	global_get(glb_v_forward, angles)
	xs_vec_mul_scalar(angles, 40.0, angles)
	xs_vec_add(origin, angles, angles)
	engfunc(EngFunc_TraceLine, origin, angles, DONT_IGNORE_MONSTERS, iPlayer, 0)
	get_tr2(0, TR_vecEndPos, origin)
	
	if(pev(iPlayer, pev_flags) & FL_DUCKING) origin[2] += 25.0
	engfunc(EngFunc_SetOrigin, iEntity, origin)
	engfunc(EngFunc_DropToFloor, iEntity)
	
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	if(InStuck[i])
	continue
	
	if(zr_is_user_zombie(i))
	continue
	
	new Float:iOrigin[3]
	pev(i, pev_origin, iOrigin)
	if(get_distance_f(iOrigin, origin) > get_pcvar_float(cvar_range))
	continue
	
	iOrigin[2] += 35.0
	
	new bEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(bEntity, pev_classname, "zrcoffinSPR")
	set_pev(bEntity, pev_modelindex, StopSPR)
	set_pev(bEntity, pev_rendermode, kRenderTransAdd)
	set_pev(bEntity, pev_renderamt, 100.0)
	set_pev(bEntity, pev_scale, 0.1)
	set_pev(bEntity, pev_owner, i)
	set_pev(bEntity, pev_nextthink, get_gametime() + 0.01)
	engfunc(EngFunc_SetOrigin, bEntity, iOrigin)
	
	KeepIcon[i] = bEntity
	
	InStuck[i] = true
	NextThink[i] = fCurTime + get_pcvar_float(cvar_stucktime)
	
	new Float:maxspeed
	pev(i, pev_maxspeed, maxspeed)
	MaxSpeedRecorder[i] = maxspeed-floatmax(maxspeed*get_pcvar_float(cvar_speedtimes), floatmin(140.0, maxspeed))
	maxspeed -= MaxSpeedRecorder[i]
	engfunc(EngFunc_SetClientMaxspeed, i, maxspeed)
	set_pev(i, pev_maxspeed, maxspeed)
	}
	
	NextThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	SkillMode[iPlayer] = 2
	
	pev(iEntity, pev_origin, origin)
	engfunc(EngFunc_TraceHull, origin, origin, DONT_IGNORE_MONSTERS, HULL_HUMAN, iEntity, 0)
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
	{
	BreakCoffin(iEntity)
	return
	}
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, SkillSounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
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
	write_byte(2)
	write_byte(20)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(100)
	write_byte(2)
	message_end()
}

public BreakCoffin(iEntity)
{
	new Float:origin[3], Float:origin2[3], Float:velocity[3], classname[33]
	pev(iEntity, pev_origin, origin)
	
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, get_pcvar_float(cvar_range))) > 0)
	{
	if(!pev_valid(i) || iEntity == i)
	continue
	
	if(pev(i, pev_takedamage) == DAMAGE_NO)
	continue
	
	pev(i, pev_classname, classname, charsmax(classname))
	if(!strcmp(classname, "func_breakable"))
	{
	dllfunc(DLLFunc_Use, i, iEntity)
	continue
	}
	
	if(!is_user_alive(i))
	continue
	
	pev(i, pev_origin, origin2)
	GetVelocityFromOrigin(origin2, origin, get_pcvar_float(cvar_knockback), velocity)
	set_pev(i, pev_velocity, velocity)
	}
	
	pev(iEntity, pev_origin, origin2)
	origin2[2] += 36.0
	GetVelocityFromOrigin(origin2, origin, 50.0, velocity)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, velocity[0])
	engfunc(EngFunc_WriteCoord, velocity[1])
	engfunc(EngFunc_WriteCoord, velocity[2])
	write_byte(10)
	write_short(WoodIndex)
	write_byte(10)
	write_byte(25)
	write_byte(0x08)
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(SkillSPR)
	write_byte(18)
	write_byte(255)
	message_end()
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, SkillSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	set_pev(iEntity, pev_flags, FL_KILLME)
}

public zr_being_zombie(iPlayer)
{
	zr_hook_spawnbody(iPlayer)
	NextThink[iPlayer] = 0.0
	SkillMode[iPlayer] = 0
	KeepIcon[iPlayer] = 0
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public zr_hook_spawnbody(iPlayer)
{
	if(!InStuck[iPlayer])
	return ZR_IGNORED
	
	InStuck[iPlayer] = false
	
	if(!pev_valid(KeepIcon[iPlayer]))
	return ZR_IGNORED
	
	set_pev(KeepIcon[iPlayer], pev_flags, FL_KILLME)
	KeepIcon[iPlayer] = 0
	
	return ZR_IGNORED
}

stock GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}

stock SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0,0,0}, iPlayer)
	write_byte(iAnim)
	write_byte(1)
	message_end()
}