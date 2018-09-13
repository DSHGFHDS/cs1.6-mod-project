/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Helmet"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const Helmet = 4	//钢盔僵尸类型ID

new g_fwBotForwardRegister
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_TraceAttack, "player", "HAM_TraceAttack")
	if(zr_zbot_supported()) g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
}

public HAM_TraceAttack(iEntity, attacker, Float:damage, Float:direction[3], tracehandle, damagetype)
{
	if(is_user_alive(attacker))
	{
	if(zr_is_user_zombie(attacker) && zr_get_zombie_id(attacker) == Helmet)
	{
	new Float:origin1[3], Float:origin2[3], Float:velocity[3]
	pev(attacker, pev_origin, origin1)
	pev(iEntity, pev_origin, origin2)
	GetVelocityFromOrigin(origin2, origin1, 1000.0, velocity)
	set_pev(iEntity, pev_velocity, velocity)
	}
	}
	
	if(!zr_is_user_zombie(iEntity))
	return HAM_IGNORED
	
	if(zr_get_zombie_id(iEntity) != Helmet)
	return HAM_IGNORED
	
	if(get_tr2(tracehandle, TR_iHitgroup) != HIT_HEAD)
	return HAM_IGNORED
	
	new Float:origin[3]
	get_tr2(tracehandle, TR_vecEndPos, origin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_ITEM, "weapons/ric_metal-1.wav", 0.5, ATTN_STATIC, 0, PITCH_NORM)
	
	return HAM_SUPERCEDE
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TraceAttack, iPlayer, "HAM_TraceAttack")
}

stock GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}