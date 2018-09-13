/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGIN "Zr Butcher"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const Butcher = 8		//屠夫僵尸类型ID

new TrapSPR, TrapIndex
new const TrappedSound[] = "zombieriot/butcherskill.wav"

new bool:TrapSkill[33], Float:NextThink[33], Float:Position[33][3], KeepTrap[33]
new cvar_livetime, cvar_time, cvar_cooldown

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	register_forward(FM_Think, "fw_Think_Post", 1)
	register_forward(FM_Touch, "fw_Touch_Post", 1)
	cvar_livetime = register_cvar("zr_butcher_livetime", "30.0")		//陷阱未触发时存在的最大时间
	cvar_time = register_cvar("zr_butcher_traptime", "10.0")			//陷阱作用时间
	cvar_cooldown = register_cvar("zr_butcher_cooldown", "8.0")		//陷阱技能冷却时间
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, TrappedSound)
	TrapIndex = engfunc(EngFunc_PrecacheModel, "models/zombieriot/butcherskill.mdl")
	TrapSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/butcherskill.spr")
}

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
	
	if(zr_get_zombie_id(iPlayer) != Butcher)
	return FMRES_IGNORED
	
	if(TrapSkill[iPlayer])
	{
	zr_print_chat(iPlayer, GREYCHAT, "陷阱技能正在冷却中!")
	return FMRES_IGNORED
	}
	
	SetTrap(iPlayer)
	
	return FMRES_SUPERCEDE
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(zr_get_zombie_id(iPlayer) != Butcher)
	return
	
	if(TrapSkill[iPlayer])
	{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	if(NextThink[iPlayer] > fCurTime)
	return
	
	TrapSkill[iPlayer] = false
	zr_print_chat(iPlayer, BLUECHAT, "陷阱技能冷却完毕!")
	return
	}
	
	if(!is_user_bot(iPlayer))
	return
	
	SetTrap(iPlayer)
}

public fw_ClientDisconnect_Post(iPlayer) RemoveTrapEffect(iPlayer)

public fw_Think_Post(iEntity)
{
	if(!pev_valid(iEntity))
	return
	
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, "zrtrap"))
	return
	
	new iPlayer = pev(iEntity, pev_iuser2)
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	new Float:ThinkTime
	pev(iEntity, pev_fuser1, ThinkTime)
	if(fCurTime >= ThinkTime)
	{
	if(is_user_alive(iPlayer)) RemoveTrapEffect(iPlayer)
	else RemoveTrap(iEntity)
	return
	}
	
	set_pev(iEntity, pev_nextthink, fCurTime+0.01)
	
	if(!is_user_alive(iPlayer))
	return
	
	set_pev(iPlayer, pev_origin, Position[iPlayer])
	set_pev(iPlayer, pev_velocity, {0.0, 0.0, 0.0})
	
	new Float:Frame
	pev(iEntity, pev_frame, Frame)
	if(Frame < 230.0) set_pev(iEntity, pev_frame, Frame+0.5)
	else set_pev(iEntity, pev_frame, 14.0)
}

public fw_Touch_Post(iEntity, iPtd)
{
	if(!pev_valid(iEntity) || !is_user_alive(iPtd) || zr_is_user_zombie(iPtd) || pev_valid(KeepTrap[iPtd]))
	return
	
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, "zrtrap"))
	return
	
	if(pev(iEntity, pev_iuser2))
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, iPtd)
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<14)
	message_end()
	
	pev(iEntity, pev_origin, Position[iPtd])
	Position[iPtd][2] += 36.0
	set_pev(iPtd, pev_origin, Position[iPtd])
	new Float:origin[3]
	origin[0] = Position[iPtd][0]
	origin[1] = Position[iPtd][1]
	origin[2] = Position[iPtd][2] + 35.0
	
	new bEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(bEntity, pev_classname, "zrtrapSPR")
	set_pev(bEntity, pev_modelindex, TrapSPR)
	set_pev(bEntity, pev_rendermode, kRenderTransAdd)
	set_pev(bEntity, pev_renderamt, 100.0)
	set_pev(bEntity, pev_scale, 0.1)
	engfunc(EngFunc_SetOrigin, bEntity, origin)
	
	KeepTrap[iPtd] = iEntity
	
	set_pev(iPtd, pev_velocity, {0.0, 0.0, 0.0})
	
	client_print(pev(iEntity, pev_owner), print_center, "你的陷阱抓住了人类!")
	engfunc(EngFunc_EmitSound, iPtd, CHAN_AUTO, TrappedSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(iEntity, pev_sequence, 1)
	set_pev(iEntity, pev_frame, 0.0)
	set_pev(iEntity, pev_iuser2, iPtd)
	set_pev(iEntity, pev_iuser3, bEntity)
	set_pev(iEntity, pev_fuser1, fCurTime+get_pcvar_float(cvar_time))
	set_pev(iEntity, pev_nextthink, fCurTime+0.01)
}

public SetTrap(iPlayer)
{
	new Float:origin[3], classname[33]
	pev(iPlayer, pev_origin, origin)
	
	if(!(pev(iPlayer, pev_flags) & FL_ONGROUND))
	{
	zr_print_chat(iPlayer, GREYCHAT, "无法在空中设置陷阱!")
	return
	}
	
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityInSphere, iEntity, origin, 35.0)) > 0)
	{
	if(!pev_valid(iEntity))
	continue
	
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, "zrtrap"))
	continue
	
	zr_print_chat(iPlayer, GREYCHAT, "附近已有陷阱!不能再设置.")
	return
	}
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEntity, pev_classname, "zrtrap")
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_owner, iPlayer)
	set_pev(iEntity, pev_modelindex, TrapIndex)
	set_pev(iEntity, pev_iuser2, 0)
	set_pev(iEntity, pev_nextthink, fCurTime+get_pcvar_float(cvar_livetime))
	engfunc(EngFunc_SetSize, iEntity, {-4.0, -4.0, -4.0}, {4.0, 4.0, 4.0})
	engfunc(EngFunc_SetOrigin, iEntity, origin)
	engfunc(EngFunc_DropToFloor, iEntity)
	
	if(!(pev(iEntity, pev_flags) & FL_ONGROUND))
	{
	zr_print_chat(iPlayer, GREYCHAT, "无法在空中设置陷阱!")
	RemoveTrap(iEntity)
	return
	}
	
	NextThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	TrapSkill[iPlayer] = true
	zr_print_chat(iPlayer, BLUECHAT, "陷阱设置成功!")
}

public RemoveTrapEffect(iPlayer)
{
	if(pev_valid(KeepTrap[iPlayer])) RemoveTrap(KeepTrap[iPlayer])
	KeepTrap[iPlayer] = 0
}

public RemoveTrap(iEntity)
{
	new SPREnt = pev(iEntity, pev_iuser3)
	if(pev_valid(SPREnt)) set_pev(SPREnt, pev_flags, FL_KILLME)
	set_pev(iEntity, pev_flags, FL_KILLME)
}

public zr_roundbegin_event(Weather)
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "zrtrap"))) RemoveTrap(iEntity)
}

public zr_being_zombie(iPlayer)
{
	RemoveTrapEffect(iPlayer)
	TrapSkill[iPlayer] = false
	NextThink[iPlayer] = 0.0
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public zr_hook_spawnbody(iPlayer) RemoveTrapEffect(iPlayer)

public zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
{
	if(zr_is_user_zombie(victim))
	return ZR_IGNORED
	
	if(!pev_valid(KeepTrap[victim]))
	return ZR_IGNORED
	
	return ZR_SUPERCEDE
}