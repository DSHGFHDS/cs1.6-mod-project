/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGIN "Zr Witchcraft"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const Witchcraft = 7	//巫蛊术尸僵尸类型ID

new HealSPR
new const HealSound[] = "zombieriot/healsound.wav"

new bool:HealSkill[33], Float:NextThink[33]
new cvar_health, cvar_range, cvar_cooldown

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink", 1)
	cvar_health = register_cvar("zr_witchcraft_healtimes", "0.6")		//恢复生命的倍数
	cvar_range = register_cvar("zr_witchcraft_range", "350.0")			//恢复生命的范围
	cvar_cooldown = register_cvar("zr_witchcraft_cooldown", "8.0")		//技能冷却时间
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, HealSound)
	HealSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/heal.spr")
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
	
	if(zr_get_zombie_id(iPlayer) != Witchcraft)
	return FMRES_IGNORED
	
	if(HealSkill[iPlayer])
	{
	zr_print_chat(iPlayer, GREYCHAT, "治疗技能正在冷却中!")
	return FMRES_IGNORED
	}
	
	Healing(iPlayer)
	
	return FMRES_SUPERCEDE
}

public fw_PlayerPostThink(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != Witchcraft)
	return
	
	if(HealSkill[iPlayer])
	{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	if(NextThink[iPlayer] > fCurTime)
	return
	
	HealSkill[iPlayer] = false
	zr_print_chat(iPlayer, BLUECHAT, "治疗技能冷却完毕!")
	}
	
	if(!is_user_bot(iPlayer))
	return
	
	new Float:health
	pev(iPlayer, pev_health, health)
	if(health > zr_get_zombie_health(zr_get_zombie_id(iPlayer))*get_pcvar_float(cvar_health))
	return
	
	Healing(iPlayer)
}

public Healing(iPlayer)
{
	new Float:health, Float:MaxHealth, Float:origin[2][3], netname[33], bool:Valve
	pev(iPlayer, pev_netname, netname, charsmax(netname))
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
	
	pev(i, pev_health, health)
	MaxHealth = zr_get_zombie_health(zr_get_zombie_id(i))
	
	if(health >= MaxHealth)
	continue
	
	MaxHealth = floatmin(health+MaxHealth*get_pcvar_float(cvar_health), MaxHealth)
	set_pev(i, pev_health, MaxHealth)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin[1], 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[1][0])
	engfunc(EngFunc_WriteCoord, origin[1][1])
	engfunc(EngFunc_WriteCoord, origin[1][2])
	write_short(HealSPR)
	write_byte(10)
	write_byte(255)
	message_end()
	Valve = true
	
	if(i == iPlayer)
	continue
	
	zr_print_chat(i, REDCHAT, "[%s]使用了治疗技能!", netname)
	}
	
	if(!Valve)
	{
	zr_print_chat(iPlayer, GREYCHAT, "目前不需要使用治疗技能!")
	return
	}
	
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, HealSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	NextThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	HealSkill[iPlayer] = true
}

public zr_being_zombie(iPlayer)
{
	HealSkill[iPlayer] = false
	NextThink[iPlayer] = 0.0
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)