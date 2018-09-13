/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Venom"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const Venom = 12	//毒液僵尸类型ID

new const SkillSounds[][] = { "zombieriot/venomshoot.wav", "zombieriot/venomsound.wav" }

new Float:CoolDown[33]
new ModelIndex, SPRIndex, m_iTrail
new cvar_time, cvar_damagetime, cvar_damage, cvar_livetime, cvar_velocity

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	register_forward(FM_Think, "fw_Think_Post", 1)
	register_forward(FM_Touch, "fw_Touch_Post", 1)
	cvar_time = register_cvar("zr_venom_cooldown", "15.0")			//毒液技能冷却时间
	cvar_damagetime = register_cvar("zr_venom_damagetime", "0.5")	//毒液伤害间隔
	cvar_damage = register_cvar("zr_venom_damage", "10.0")		//毒液伤害
	cvar_livetime = register_cvar("zr_venom_livetime", "10.0")		//毒液存在时间
	cvar_velocity = register_cvar("zr_venom_velocity", "1200.0")		//喷射毒液速度
}

public plugin_precache()
{
	for(new i = 0; i < 2; i ++) engfunc(EngFunc_PrecacheSound, SkillSounds[i])
	ModelIndex = engfunc(EngFunc_PrecacheModel, "models/zombieriot/venomball.mdl")
	SPRIndex = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/venomskill.spr")
	m_iTrail = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
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
	
	if(zr_get_zombie_id(iPlayer) != Venom)
	return FMRES_IGNORED
	
	if(CoolDown[iPlayer] > 0.0)
	{
	zr_print_chat(iPlayer, GREYCHAT, "毒液技能正在冷却中!")
	return FMRES_SUPERCEDE
	}
	
	ShootVenom(iPlayer)
	
	return FMRES_SUPERCEDE
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != Venom)
	return
	
	if(CoolDown[iPlayer] <= 0.0)
	return
	
	if(CoolDown[iPlayer] > get_gametime())
	return
	
	CoolDown[iPlayer] = -1.0
	zr_print_chat(iPlayer, BLUECHAT, "毒液技能已冷却!")
}

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(CoolDown[iPlayer] > 0.0)
	return
	
	if(zr_get_zombie_id(iPlayer) != Venom)
	return
	
	new Enemy = get_tr2(iTrace, TR_pHit)
	if(!is_user_alive(Enemy))
	return
	
	if(zr_is_user_zombie(Enemy))
	return
	
	ShootVenom(iPlayer)
}

public fw_Think_Post(iEntity)
{
	if(!pev_valid(iEntity))
	return
	
	new classname[32]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "zrvenom"))
	return
	
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(pev(iEntity, pev_solid) == SOLID_TRIGGER)
	{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_BLOODSTREAM)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, random_float(-30.0, 30.0))
	engfunc(EngFunc_WriteCoord, random_float(-30.0, 30.0))
	engfunc(EngFunc_WriteCoord, random_float(-50.0, 0.0))
	write_byte(55)
	write_byte(20)
	message_end()
	new Float:angles[3], Float:velocity[3]
	pev(iEntity, pev_velocity, velocity)
	vector_to_angle(velocity, angles)
	set_pev(iEntity, pev_angles, angles)
	set_pev(iEntity, pev_nextthink, fCurTime+0.1)
	return
	}
	
	new Float:fuser1
	pev(iEntity, pev_fuser1, fuser1)
	if(fuser1 <= fCurTime)
	{
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, SkillSounds[1], 1.0, ATTN_NORM, SND_CHANGE_PITCH, PITCH_NORM)
	set_pev(iEntity, pev_flags, FL_KILLME)
	return
	}
	
	new Float:fuser2, Float:fuser3, Float:fuser4
	pev(iEntity, pev_fuser2, fuser2)
	if(fuser2 <= fCurTime)
	{
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, SkillSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(iEntity, pev_fuser2, fCurTime+5.0)
	}
	
	pev(iEntity, pev_fuser3, fuser3)
	if(fuser3 <= fCurTime)
	{
	origin[0] += random_float(-50.0, 50.0)
	origin[1] += random_float(-50.0, 50.0)
	origin[2] += 30.0
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(SPRIndex)
	write_byte(5)
	write_byte(255)
	message_end()
	set_pev(iEntity, pev_fuser3, fCurTime+0.1)
	}
	
	pev(iEntity, pev_fuser4, fuser4)
	if(fuser4 <= fCurTime)
	{
	new Float:origin2[3]
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	if(zr_is_user_zombie(i))
	continue
	
	pev(i, pev_origin, origin2)
	if(get_distance_f(origin, origin2) > 100.0)
	continue
	
	ExecuteHamB(Ham_TakeDamage, i, iEntity, pev(iEntity, pev_owner), get_pcvar_float(cvar_damage), DMG_ACID)
	}
	set_pev(iEntity, pev_fuser4, fCurTime+get_pcvar_float(cvar_damagetime))
	}
	
	set_pev(iEntity, pev_nextthink, fCurTime+0.01)
}

public fw_Touch_Post(iEntity, iPtd)
{
	if(!pev_valid(iEntity))
	return
	
	static classname[32]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "zrvenom") || iPtd == pev(iEntity, pev_owner))
	return
	
	set_pev(iEntity, pev_gravity, 1.0)
	set_pev(iEntity, pev_velocity, {0.0, 0.0, -200.0})
	
	new Float:origin[3], Float:end[3]
	pev(iEntity, pev_origin, origin)
	pev(iEntity, pev_origin, end)
	end[2] -= 10.0
	engfunc(EngFunc_TraceLine, origin, end, DONT_IGNORE_MONSTERS, iEntity, 0)
	get_tr2(0, TR_vecEndPos, end)
	
	if(origin[2]-end[2] > 2.0)
	return
	
	origin[2] += 40.0
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(SPRIndex)
	write_byte(12)
	write_byte(255)
	message_end()
	
	set_pev(iEntity, pev_solid, SOLID_NOT)
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE)
	set_pev(iEntity, pev_nextthink, get_gametime()+0.01)
	set_pev(iEntity, pev_fuser1, get_gametime()+get_pcvar_float(cvar_livetime))
	set_pev(iEntity, pev_effects, EF_NODRAW)
}

public ShootVenom(iPlayer)
{
	screen_shake(iPlayer, -3.0, 0.6, 5.0)
	new Float:punchangle[3]
	pev(iPlayer, pev_punchangle, punchangle)
	punchangle[0] -= 1.0
	set_pev(iPlayer, pev_punchangle, punchangle)
	
	CoolDown[iPlayer] = get_gametime()+get_pcvar_float(cvar_time)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, SkillSounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	new Float:origin[3], Float:angles[3]
	pev(iPlayer, pev_angles, angles)
	angles[0] *= 3.0
	get_aim_origin_vector(iPlayer, 20.0, 0.0, 10.0, origin)
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEntity, pev_classname, "zrvenom")
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_owner, iPlayer)
	set_pev(iEntity, pev_angles, angles)
	set_pev(iEntity, pev_modelindex, ModelIndex)
	set_pev(iEntity, pev_gravity, 0.05)
	set_pev(iEntity, pev_nextthink, get_gametime()+0.1)
	set_pev(iEntity, pev_renderfx, kRenderFxGlowShell)
	set_pev(iEntity, pev_rendercolor, {0.0, 255.0, 0.0})
	set_pev(iEntity, pev_renderamt, 3.0)
	set_pev(iEntity, pev_rendermode, kRenderNormal)
	SetPenetrationToGhost(iEntity, true)
	engfunc(EngFunc_SetOrigin, iEntity, origin)
	engfunc(EngFunc_SetSize, iEntity, {-1.0, -1.0, -1.0}, {1.0, 1.0, 1.0})
	
	new Float:start[3], Float:view_ofs[3], Float:end[3]
	pev(iPlayer, pev_origin, start)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	
	pev(iPlayer, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, 8120.0, end)
	xs_vec_add(start, end, end)
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, iPlayer, 0)
	get_tr2(0, TR_vecEndPos, end)
	
	new Float:velocity[3]
	get_speed_vector(origin, end, get_pcvar_float(cvar_velocity), velocity)
	set_pev(iEntity, pev_velocity, velocity)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(iEntity) 
	write_short(m_iTrail)
	write_byte(5)
	write_byte(3)
	write_byte(0)
	write_byte(255)
	write_byte(0)
	write_byte(255)
	message_end()
}

public zr_being_zombie(iPlayer) CoolDown[iPlayer] = -1.0

public zr_roundbegin_event(Weather)
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "zrvenom"))) set_pev(iEntity, pev_flags, FL_KILLME)
}

stock get_aim_origin_vector(iPlayer, Float:forw, Float:right, Float:up, Float:vStart[])
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(iPlayer, pev_origin, vOrigin)
	pev(iPlayer, pev_view_ofs, vUp)
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(iPlayer, pev_v_angle, vAngle)
	
	angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward)
	angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle, ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	xs_vec_sub(origin2, origin1, new_velocity)
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	xs_vec_mul_scalar(new_velocity, num, new_velocity)
}

stock screen_shake(iPlayer, Float:amplitude, Float:duration, Float:frequency)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, iPlayer)
	write_short(floatround(4096.0*amplitude))
	write_short(floatround(4096.0*duration))
	write_short(floatround(4096.0*frequency))
	message_end()
}