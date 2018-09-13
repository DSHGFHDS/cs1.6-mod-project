/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>

#define PLUGIN "Zr Barbie"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const BarbieId = 6	//芭比娃娃ID

new const ClawModel[] = "models/zombieriot/v_barbie_hiding.mdl"
new const SkillSound[] = "zombieriot/barbieskill.wav"

new Float:PlayerThink[33], HideMode[33], Float:MaxspeedRecorder[33]
new cvar_holdingtime, cvar_cooldown, cvar_speedtimes, cvar_transparency

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post",1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "HAM_Item_Deploy")
	cvar_holdingtime = register_cvar("zr_barbie_holdingtime", "10.0")		//隐身技能持续时间
	cvar_cooldown = register_cvar("zr_barbie_cooldown", "8.0")				//隐身技能冷却时间
	cvar_speedtimes = register_cvar("zr_barbie_speedtimes", "0.8")			//隐身时行走速度倍数
	cvar_transparency = register_cvar("zr_barbie_transparency", "15")		//隐身透明度
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, ClawModel)
	engfunc(EngFunc_PrecacheSound, SkillSound)
}

public Event_CurWeapon(iPlayer)
{
	if(!zr_is_user_zombie(iPlayer))
	return PLUGIN_CONTINUE
	
	if(zr_get_zombie_id(iPlayer) != BarbieId)
	return PLUGIN_CONTINUE
	
	if(HideMode[iPlayer] != 1)
	return PLUGIN_CONTINUE
	
	set_pev(iPlayer, pev_viewmodel2, ClawModel)
	
	return PLUGIN_CONTINUE
}

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer))
	return
	
	if(HideMode[iPlayer])
	return
	
	if(zr_get_zombie_id(iPlayer) != BarbieId)
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
	
	BeginHiding(iPlayer)
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pSet)
{
	if(!player || !is_user_alive(host))
	return
	
	if(HideMode[iEntity] != 1)
	return
	
	if(!zr_is_user_zombie(iEntity))
	return
	
	if(zr_get_zombie_id(iEntity) != BarbieId)
	return
	
	set_es(es_handle, ES_RenderMode, kRenderTransTexture)
	set_es(es_handle, ES_RenderAmt, 1)
	set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
	static Color[3]
	for(new i = 0; i < 3; i ++) Color[i] = get_pcvar_num(cvar_transparency)
	set_es(es_handle, ES_RenderColor, Color)
}

public fw_PlayerPostThink_Post(iPlayer, Float:maxspeed)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != BarbieId)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(HideMode[iPlayer] == 2)
	{
	if(PlayerThink[iPlayer] > fCurTime)
	return
	
	HideMode[iPlayer] = 0
	zr_print_chat(iPlayer, BLUECHAT, "隐身技能已冷却!")
	
	return
	}
	
	if(HideMode[iPlayer] != 1 || PlayerThink[iPlayer] > fCurTime)
	return
	
	HideMode[iPlayer] = 2
	PlayerThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	zr_print_chat(iPlayer, GREYCHAT, "隐身技能已结束!")
	static szmodel[64]
	zr_get_zombie_claw(BarbieId, szmodel, charsmax(szmodel))
	format(szmodel, charsmax(szmodel), "models/zombieriot/%s", szmodel)
	set_pev(iPlayer, pev_viewmodel2, szmodel)
	
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	maxspeed += MaxspeedRecorder[iPlayer]
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
	MaxspeedRecorder[iPlayer] = 0.0
}

public fw_ClientCommand(iPlayer)
{
	static szCommand[24]
	read_argv(0, szCommand, charsmax(szCommand))
	
	if(!strcmp(szCommand, "weapon_hegrenade") || !strcmp(szCommand, "lastinv"))
	{
	if(HideMode[iPlayer] != 1)
	return FMRES_IGNORED
	
	return FMRES_SUPERCEDE
	}
	
	if(strcmp(szCommand, "drop"))
	return FMRES_IGNORED
	
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return FMRES_IGNORED
	
	if(!zr_is_user_zombie(iPlayer))
	return FMRES_IGNORED
	
	if(zr_get_zombie_id(iPlayer) != BarbieId)
	return FMRES_IGNORED
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return FMRES_SUPERCEDE
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return FMRES_SUPERCEDE
	
	if(HideMode[iPlayer] == 1)
	{
	zr_print_chat(iPlayer, GREYCHAT, "隐身技能正在使用中!")
	return FMRES_IGNORED
	}
	
	if(HideMode[iPlayer] == 2)
	{
	zr_print_chat(iPlayer, GREYCHAT, "隐身技能正在冷却中中!")
	return FMRES_IGNORED
	}
	
	BeginHiding(iPlayer)
	
	return FMRES_SUPERCEDE
}

public HAM_Item_Deploy(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return HAM_IGNORED
	
	if(HideMode[iPlayer] != 1)
	return HAM_IGNORED
	
	engclient_cmd(iPlayer, "weapon_knife")
	
	return HAM_SUPERCEDE
}

public BeginHiding(iPlayer)
{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	PlayerThink[iPlayer] = fCurTime + get_pcvar_float(cvar_holdingtime)
	HideMode[iPlayer] = 1
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, SkillSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(iPlayer, pev_viewmodel2, ClawModel)
	
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	MaxspeedRecorder[iPlayer] = maxspeed - maxspeed*get_pcvar_float(cvar_speedtimes)
	maxspeed -= MaxspeedRecorder[iPlayer]
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
}

public zr_being_zombie(iPlayer)
{
	HideMode[iPlayer] = 0
	PlayerThink[iPlayer] = 0.0
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)