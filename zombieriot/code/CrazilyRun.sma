/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGIN "Crazily Run"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new Skill[33], Float:PlayerThink[33], Color[33][3], Float:SpeedRecorder[33]

new const CrazySound[] = "zombieriot/zombi_pressure.wav"

new const ZombieStyle[] = { -1, 1, 2, 3 } //拥有此技能的僵尸ID,后面可以不断加,前面的-1是为了顶格用的,不要修改,也不要删除
new const Float:SpeedTimes[] = { -1.0, 1.2, 1.15, 1.3 } //暴走的速度倍数,对应上面的僵尸ID的位置
new const Float:RuningTime[] = { -1.0, 6.0, 8.0, 5.0 } //暴走的时间,对应上面的僵尸ID的位置
new const Float:Cooldown[] = { -1.0, 6.0, 8.0, 15.0 } //暴走后的冷却时间,对应上面的僵尸ID的位置

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post",1)
}

public plugin_precache() engfunc(EngFunc_PrecacheSound, CrazySound)

public zr_being_zombie(iPlayer)
{
	Skill[iPlayer] = 0
	PlayerThink[iPlayer] = 0.0
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_connected(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || pev(iPlayer, pev_deadflag) != DEAD_NO || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(Skill[iPlayer])
	return
	
	new Style = GetZombieStyle(iPlayer)
	if(!Style)
	return
	
	new Enemy = get_tr2(iTrace, TR_pHit)
	if(!is_user_alive(Enemy))
	return
	
	if(zr_is_user_zombie(Enemy))
	return
	
	BeingCrazily(iPlayer, Style)
}

public fw_ClientCommand(iPlayer)
{
	static szCommand[24]
	read_argv(0, szCommand, charsmax(szCommand))
	
	if(strcmp(szCommand, "drop") || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return FMRES_IGNORED
	
	new Style = GetZombieStyle(iPlayer)
	if(!Style)
	return FMRES_IGNORED
	
	if(Skill[iPlayer] == 1)
	{
	zr_print_chat(iPlayer, REDCHAT, "暴走技能正在使用中!")
	return FMRES_IGNORED
	}
	
	if(Skill[iPlayer] == 2)
	{
	zr_print_chat(iPlayer, GREYCHAT, "暴走技能正在冷却!")
	return FMRES_IGNORED
	}
	
	BeingCrazily(iPlayer, Style)
	
	return FMRES_SUPERCEDE
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pSet)
{
	if(!player || !is_user_alive(host))
	return
	
	new Style = GetZombieStyle(iEntity)
	if(!Style)
	return
	
	if(Skill[iEntity] != 1)
	return
	
	set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
	set_es(es_handle, ES_RenderColor, Color[iEntity])
	set_es(es_handle, ES_RenderAmt, 1)
	set_es(es_handle, ES_RenderMode, kRenderNormal)
}

public BeingCrazily(iPlayer, Style)
{
	Skill[iPlayer] = 1
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	PlayerThink[iPlayer] = fCurTime + RuningTime[Style]
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, CrazySound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	for(new i = 0; i < 3; i ++) Color[iPlayer][i] = random_num(0, 255)
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	SpeedRecorder[iPlayer] = maxspeed*SpeedTimes[Style] - maxspeed
	maxspeed += SpeedRecorder[iPlayer]
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	new Style = GetZombieStyle(iPlayer)
	if(!Style)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(Skill[iPlayer] == 2)
	{
	if(PlayerThink[iPlayer] > fCurTime)
	return
	
	Skill[iPlayer] = 0
	zr_print_chat(iPlayer, BLUECHAT, "暴走技能冷却完毕!")
	
	return
	}
	
	if(Skill[iPlayer] != 1)
	return
	
	if(PlayerThink[iPlayer] > fCurTime)
	return
	
	Skill[iPlayer] = 2
	PlayerThink[iPlayer] = fCurTime + Cooldown[Style]
	zr_print_chat(iPlayer, GREYCHAT, "暴走技能使用结束!")
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	maxspeed = floatmax(0.0, maxspeed-SpeedRecorder[iPlayer])
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
	SpeedRecorder[iPlayer] = 0.0
}

public GetZombieStyle(iPlayer)
{
	if(!is_user_alive(iPlayer) || !zr_is_user_zombie(iPlayer))
	return 0
	
	for(new i = 1; i < sizeof ZombieStyle; i ++)
	{
	if(zr_get_zombie_id(iPlayer) != ZombieStyle[i])
	continue
	
	return i
	}
	
	return 0
}