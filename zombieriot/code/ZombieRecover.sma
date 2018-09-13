/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGIN "Zombie Recover"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new Float:NextThink[33], bool:GameStarted
new RecoverSPR
new const RecoverSound[] = "zombieriot/heartbeatloop.wav"
new cvar_nextrecover, cvar_percentage

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_message(get_user_msgid("Damage"), "MSG_Damage")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink", 1)
	cvar_nextrecover = register_cvar("zr_next_recover", "1.5")			//恢复的速度
	cvar_percentage = register_cvar("zr_maxhealth_percentage", "0.2")	//每次恢复最大生命值的百分比
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, RecoverSound)
	RecoverSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/heal.spr")
}

public zr_roundbegin_event(Weather) GameStarted = true

public MSG_Damage(type, dest, iPlayer)
{
	if(!zr_is_user_zombie(iPlayer))
	return PLUGIN_CONTINUE
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	NextThink[iPlayer] = fCurTime+get_pcvar_float(cvar_nextrecover)
	
	return PLUGIN_CONTINUE
}

public fw_PlayerPostThink(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO || !zr_is_user_zombie(iPlayer) || !GameStarted || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	new Float:fCurTime, Float:velocity[3]
	global_get(glb_time, fCurTime)
	pev(iPlayer, pev_velocity, velocity)
	
	if(vector_length(velocity) > 0.0)
	{
	NextThink[iPlayer] = fCurTime+get_pcvar_float(cvar_nextrecover)
	return
	}
	
	if(NextThink[iPlayer] > fCurTime)
	return
	
	new Float:health, Float:maxhealth = zr_get_zombie_health(zr_get_zombie_id(iPlayer))
	pev(iPlayer, pev_health, health)
	if(health >= maxhealth)
	return
	
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(RecoverSPR)
	write_byte(10)
	write_byte(255)
	message_end()
	
	set_pev(iPlayer, pev_health, floatmin(maxhealth*get_pcvar_float(cvar_percentage)+health, maxhealth))
	client_cmd(iPlayer, "spk %s", RecoverSound)
	
	NextThink[iPlayer] = fCurTime+get_pcvar_float(cvar_nextrecover)
}