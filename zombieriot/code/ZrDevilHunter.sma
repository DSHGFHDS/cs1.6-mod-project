/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGIN "Zr Devil Hunter"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new HunterID = 11

new const SkillSound[] = "zombieriot/zombi_pressure.wav"

new SkillMode[33], Float:NextThink[33], Color[33][3], Float:MaxSpeedRecorder[33]
new cvar_time, cvar_cooldown, cvar_speedtimes, cvar_knockbacktimes

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post",1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	cvar_time = register_cvar("zr_devilhunter_time", "3.0")							//技能持续时间
	cvar_cooldown = register_cvar("zr_devilhunter_cooldown", "10.0")				//技能冷却时间
	cvar_speedtimes = register_cvar("zr_devilhunter_speedtimes", "1.5")				//速度增大倍数
	cvar_knockbacktimes = register_cvar("zr_devilhunter_knockbacktimes", "0.2")		//被击退的倍数
}

public plugin_precache() engfunc(EngFunc_PrecacheSound, SkillSound)

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(SkillMode[iPlayer])
	return
	
	if(zr_get_zombie_id(iPlayer) != HunterID)
	return
	
	new Enemy = get_tr2(iTrace, TR_pHit)
	if(!is_user_alive(Enemy))
	return
	
	if(zr_is_user_zombie(Enemy))
	return
	
	UseSkill(iPlayer)
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
	
	if(zr_get_zombie_id(iPlayer) != HunterID)
	return FMRES_IGNORED
	
	if(SkillMode[iPlayer] == 1)
	{
	zr_print_chat(iPlayer, GREYCHAT, "装甲突进技能正在使用!")
	return FMRES_SUPERCEDE
	}
	
	if(SkillMode[iPlayer] == 2)
	{
	zr_print_chat(iPlayer, GREYCHAT, "装甲突进技能正在冷却!")
	return FMRES_SUPERCEDE
	}
	
	UseSkill(iPlayer)
	
	return FMRES_SUPERCEDE
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pSet)
{
	if(!player || !is_user_alive(host))
	return
	
	if(!zr_is_user_zombie(iEntity))
	return
	
	if(zr_get_zombie_id(iEntity) != HunterID)
	return
	
	if(SkillMode[iEntity] != 1)
	return
	
	set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
	set_es(es_handle, ES_RenderColor, Color[iEntity])
	set_es(es_handle, ES_RenderAmt, 1)
	set_es(es_handle, ES_RenderMode, kRenderNormal)
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != HunterID)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(SkillMode[iPlayer] == 2)
	{
	if(NextThink[iPlayer] > fCurTime)
	return
	
	SkillMode[iPlayer] = 0
	zr_print_chat(iPlayer, BLUECHAT, "装甲突进技能冷却完毕!")
	
	return
	}
	
	if(SkillMode[iPlayer] != 1 || NextThink[iPlayer] > fCurTime)
	return
	
	SkillMode[iPlayer] = 2
	NextThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	zr_print_chat(iPlayer, GREYCHAT, "装甲突进技能使用结束!")
	
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	maxspeed = floatmax(1.0, maxspeed-MaxSpeedRecorder[iPlayer])
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
	MaxSpeedRecorder[iPlayer] = 0.0
}

public zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
{
	if(!is_user_alive(victim))
	return ZR_IGNORED
	
	if(!zr_is_user_zombie(victim))
	return ZR_IGNORED
	
	if(zr_get_zombie_id(victim) != HunterID)
	return ZR_IGNORED
	
	if(SkillMode[victim] != 1)
	return ZR_IGNORED
	
	zr_set_knockback(Knocker, victim, Speed*get_pcvar_float(cvar_knockbacktimes))
	
	return ZR_SUPERCEDE
}

public zr_being_zombie(iPlayer)
{
	SkillMode[iPlayer] = 0
	NextThink[iPlayer] = 0.0
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public UseSkill(iPlayer)
{
	SkillMode[iPlayer] = 1
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	NextThink[iPlayer] = fCurTime+get_pcvar_float(cvar_time)
	for(new i = 0; i < 3; i ++) Color[iPlayer][i] = random_num(0, 255)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, SkillSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	MaxSpeedRecorder[iPlayer] = maxspeed*get_pcvar_float(cvar_speedtimes) - maxspeed
	maxspeed += MaxSpeedRecorder[iPlayer]
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
}