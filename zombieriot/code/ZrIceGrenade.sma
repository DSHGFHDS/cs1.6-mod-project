#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN_NAME		"ZrIceGrenade"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"DSHGFHDS"

new const ExploSound[] = "zombieriot/iceexplode.wav"
new Float:Nextthink[33], Float:Angles[33][3], Aim[33][2], Float:Frame[33]
new cvar_time, cvar_damage, cvar_range
new SPRIndex, GlassIndex, FleshIndex
new g_fwBotForwardRegister

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_Think, "fw_Think")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink_Post", 1)
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post",1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage_Post", 1)
	RegisterHam(Ham_BloodColor, "player", "HAM_BloodColor")
	g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	cvar_time = register_cvar("zr_frozen_time", "8.0")				//冰冻时间
	cvar_damage = register_cvar("zr_frozen_damage", "200.0")		//冰冻伤害
	cvar_range = register_cvar("zr_frozen_range", "180.0")			//冰冻范围
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, ExploSound)
	SPRIndex = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
	GlassIndex = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl")
	FleshIndex= engfunc(EngFunc_PrecacheModel, "models/fleshgibs.mdl")
}

public zr_roundbegin_event(Weather) for(new i = 1; i < 33; i ++) Nextthink[i] = 0.0

public fw_SetModel(iEntity,szModel[])
{
	if(strcmp(szModel,"models/w_smokegrenade.mdl"))
	return FMRES_IGNORED
	
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, "grenade"))
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_dmgtime, 99999.0)
	set_pev(iEntity, pev_nextthink, get_gametime()+1.0)
	set_pev(iEntity, pev_iuser1, DATAKEY_1)
	
	return FMRES_IGNORED
}

public fw_Think(iEntity)
{
	static szClassName[33]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	
	if(strcmp(szClassName, "grenade"))
	return FMRES_IGNORED
	
	if(pev(iEntity, pev_iuser1) != DATAKEY_1)
	return FMRES_IGNORED
	
	Explode(iEntity)
	
	return FMRES_SUPERCEDE
}

public fw_PlayerPreThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(Nextthink[iPlayer] == 0.0)
	return
	
	if(Nextthink[iPlayer] > get_gametime())
	{
	set_pev(iPlayer, pev_angles, Angles[iPlayer])
	ZR_SetAnimation(iPlayer, 1.0, Aim[iPlayer][0], Aim[iPlayer][1])
	set_pev(iPlayer, pev_frame, Frame[iPlayer])
	set_pev(iPlayer, pev_framerate, 0.0)
	set_pdata_float(iPlayer, 83, 9999.0, 5)
	set_pev(iPlayer, pev_velocity, { 0.0, 0.0, -500.0 } )
	return
	}
	
	SetFree(iPlayer)
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pSet)
{
	if(!player || !is_user_alive(host))
	return
	
	if(Nextthink[iEntity] <= get_gametime())
	return
	
	set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
	set_es(es_handle, ES_RenderColor, { 80, 80, 100 })
	set_es(es_handle, ES_RenderAmt, 50)
	set_es(es_handle, ES_RenderMode, kRenderNormal)
}

public HAM_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!(damage_type & DMG_FREEZE))
	return
	
	if(!is_user_alive(victim) || !zr_is_user_zombie(victim))
	return
	
	if(!inflictor)
	return
	
	if(pev(inflictor, pev_iuser1) != DATAKEY_1)
	return
	
	GetFrozen(victim)
}

public HAM_BloodColor(iPlayer)
{
	if(!zr_is_user_zombie(iPlayer))
	return HAM_IGNORED
	
	if(Nextthink[iPlayer] <= get_gametime())
	return HAM_IGNORED
	
	SetHamReturnInteger(15)
	
	return HAM_SUPERCEDE
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage_Post", 1)
	RegisterHamFromEntity(Ham_BloodColor, iPlayer, "HAM_BloodColor")
}

public Explode(iEntity)
{
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2] + 700.0)
	write_short(SPRIndex)
	write_byte(0)
	write_byte(0)
	write_byte(2)
	write_byte(60)
	write_byte(0)
	write_byte(100)
	write_byte(100)
	write_byte(255)
	write_byte(150)
	write_byte(0)
	message_end()
	
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, get_pcvar_float(cvar_range))) > 0)
	{
	if(!pev_valid(i) || iEntity == i)
	continue
	
	if(pev(i, pev_takedamage) == DAMAGE_NO)
	continue
	
	if(is_user_alive(i) && zr_is_user_zombie(i))
	{
		Aim[i][0] = pev(i, pev_sequence)
		Aim[i][1] = pev(i, pev_gaitsequence)
		pev(i, pev_frame, Frame[i])
		pev(i, pev_angles, Angles[i])
	}
	
	ExecuteHamB(Ham_TakeDamage, i, iEntity, pev(iEntity, pev_owner), get_pcvar_float(cvar_damage), DMG_FREEZE)
	}
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, ExploSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(iEntity, pev_flags, FL_KILLME)
}

public GetFrozen(iPlayer)
{
	Nextthink[iPlayer] = get_gametime()+get_pcvar_float(cvar_time)
	set_pev(iPlayer, pev_flags, (pev(iPlayer, pev_flags) | FL_FROZEN))
}

public SetFree(iPlayer)
{
	set_pdata_float(iPlayer, 83, 0.0, 5)
	set_pev(iPlayer, pev_flags, (pev(iPlayer, pev_flags) & ~ FL_FROZEN))
	set_pev(iPlayer, pev_framerate, 1.0)
	if(Nextthink[iPlayer] == 0.0)
	return
	
	IceBroken(iPlayer, false)
	Nextthink[iPlayer] = 0.0
}

public IceBroken(iPlayer, bool:Dead)
{
	new Float:origin[3], Float:origin2[3], Float:velocity[3]
	pev(iPlayer, pev_origin, origin)
	pev(iPlayer, pev_origin, origin2)
	origin2[2] += 36.0
	
	GetVelocityFromOrigin(origin2, origin, 50.0, velocity)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, 1.5)
	engfunc(EngFunc_WriteCoord, 1.5)
	engfunc(EngFunc_WriteCoord, 1.5)
	engfunc(EngFunc_WriteCoord, velocity[0])
	engfunc(EngFunc_WriteCoord, velocity[1])
	engfunc(EngFunc_WriteCoord, velocity[2])
	write_byte(20)
	Dead ? write_short(FleshIndex) : write_short(GlassIndex) 
	write_byte(12)
	write_byte(25)
	Dead ? write_byte(0x04) : write_byte(0x01)
	message_end()
}

public zr_being_human(iPlayer) SetFree(iPlayer)

public zr_being_zombie(iPlayer) SetFree(iPlayer)

public zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
{
	if(!zr_is_user_zombie(victim))
	return ZR_IGNORED
	
	if(Nextthink[victim] <= get_gametime())
	return ZR_IGNORED
	
	return ZR_SUPERCEDE
}

public zr_hook_spawnbody(iPlayer)
{
	if(!zr_is_user_zombie(iPlayer))
	return ZR_IGNORED
	
	if(Nextthink[iPlayer] <= get_gametime())
	return ZR_IGNORED
	
	Nextthink[iPlayer] = 0.0
	IceBroken(iPlayer, true)
	
	return ZR_SUPERCEDE
}

stock GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}