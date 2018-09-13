/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Devil"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const DevilId = 5	//恶魔之子ID
new Float:AnimThink[33], SkillMode[33]
new m_iTrail, m_skill, SkillIndex
new cvar_cooldown, cvar_velocity, cvar_range, cvar_knockback

new const ShakePass[] = { 6, 7 }	//抵抗震荡技能的人类类型(可以自己增加)
new const SkillModel[] = "models/zombieriot/devilskill.mdl"
new const Sounds[][] = { "zombieriot/deimos_skill_start.wav", "zombieriot/deimos_skill_hit.wav" }

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	register_forward(FM_Touch, "fw_Touch_Post", 1)
	cvar_cooldown = register_cvar("zr_devil_cooldown", "10.0")		//毒刺技能冷却时间
	cvar_velocity = register_cvar("zr_devil_velocity", "2000.0")	//毒刺的飞行速度
	cvar_range = register_cvar("zr_devil_range", "100.0")			//毒刺技能的影响范围
	cvar_knockback = register_cvar("zr_devil_knockback", "500.0")	//毒刺技能的击退
}

public plugin_precache()
{
	SkillIndex = engfunc(EngFunc_PrecacheModel, SkillModel)
	m_iTrail = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
	m_skill = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/skillexplosion.spr")
	for(new i = 0; i < 2; i ++) engfunc(EngFunc_PrecacheSound, Sounds[i])
}

public zr_roundbegin_event(Weather)
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "devil_skill"))) set_pev(iEntity, pev_flags, FL_KILLME)
}

public zr_being_zombie(iPlayer)
{
	AnimThink[iPlayer] = 0.0
	SkillMode[iPlayer] = 0
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public Event_CurWeapon(iPlayer) if(SkillMode[iPlayer] == 1) SkillMode[iPlayer] = 0

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(SkillMode[iPlayer])
	return
	
	if(zr_get_zombie_id(iPlayer) != DevilId)
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
	
	iEntity = get_pdata_cbase(Enemy, 373)
	if(iEntity <= 0)
	return
	
	if(get_pdata_int(iEntity, 43, 4) == CSW_KNIFE)
	return
	
	SkillStarts(iPlayer)
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
	
	if(zr_get_zombie_id(iPlayer) != DevilId)
	return FMRES_IGNORED
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return FMRES_SUPERCEDE
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return FMRES_SUPERCEDE
	
	if(SkillMode[iPlayer] == 1)
	{
	zr_print_chat(iPlayer, GREYCHAT, "毒刺技能正在使用!")
	return FMRES_SUPERCEDE
	}
	
	if(SkillMode[iPlayer] == 2)
	{
	zr_print_chat(iPlayer, GREYCHAT, "毒刺技能正在冷却!")
	return FMRES_SUPERCEDE
	}
	
	SkillStarts(iPlayer)
	
	return FMRES_SUPERCEDE
}

public SkillStarts(iPlayer)
{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	SkillMode[iPlayer] = 1
	AnimThink[iPlayer] = fCurTime + 0.5
	set_pdata_float(iPlayer, 83, 1.5, 5)
	SendWeaponAnim(iPlayer, 2)
	zr_set_user_anim(iPlayer, 1.5, 10)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != DevilId)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(AnimThink[iPlayer] <= fCurTime && SkillMode[iPlayer] == 2)
	{
	zr_print_chat(iPlayer, BLUECHAT, "毒刺技能冷却完毕!")
	SkillMode[iPlayer] = 0
	return
	}
	
	if(SkillMode[iPlayer] != 1)
	return
	
	if(AnimThink[iPlayer] > fCurTime)
	return
	
	SkillOut(iPlayer)
	SkillMode[iPlayer] = 2
	AnimThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
}

public SkillOut(iPlayer)
{
	new Float:origin[3], Float:angles[3]
	pev(iPlayer, pev_angles, angles)
	angles[0] *= 3.0
	get_aim_origin_vector(iPlayer, 30.0, 0.0, 20.0, origin)
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEntity, pev_classname, "devil_skill")
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)
	set_pev(iEntity, pev_movetype, MOVETYPE_FLY)
	set_pev(iEntity, pev_owner, iPlayer)
	set_pev(iEntity, pev_angles, angles)
	set_pev(iEntity, pev_modelindex, SkillIndex)
	SetPenetrationToGhost(iEntity, true)
	engfunc(EngFunc_SetSize, iEntity, {-2.0, -2.0, -2.0}, {2.0, 2.0, 2.0})
	engfunc(EngFunc_SetOrigin, iEntity, origin)
	
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
	write_byte(10)
	write_byte(1)
	write_byte(255)
	write_byte(255)
	write_byte(0)
	write_byte(255)
	message_end()
}

public fw_Touch_Post(iEntity, iPtd)
{
	if(!pev_valid(iEntity))
	return
	
	new classname[32]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "devil_skill"))
	return
	
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	if(engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY)
	{
	set_pev(iEntity, pev_flags, FL_KILLME)
	return
	}
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(m_skill)
	write_byte(18)
	write_byte(255)
	message_end()
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, Sounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	set_pev(iEntity, pev_flags, FL_KILLME)
	
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	new Float:origin2[3]
	pev(i, pev_origin, origin2)
	new Float:distance = get_distance_f(origin, origin2)
	if(distance > get_pcvar_float(cvar_range))
	continue
	
	if(CheckIgnore(i))
	continue
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, i)
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<14)
	message_end()
	
	new Float:velocity[3]
	GetVelocityFromOrigin(origin2, origin, get_pcvar_float(cvar_knockback), velocity)
	set_pev(i, pev_velocity, velocity)
	
	if(zr_is_user_zombie(i))
	continue
	
	new wEntity = get_pdata_cbase(i, 368)
	
	if(!pev_valid(wEntity)) wEntity = get_pdata_cbase(i, 369)
	
	if(!pev_valid(wEntity))
	continue
	
	pev(wEntity, pev_classname, classname, charsmax(classname))
	engclient_cmd(i, "drop", classname)
	}
}

public bool:CheckIgnore(iPlayer)
{
	if(zr_is_user_zombie(iPlayer))
	return false
	
	for(new i = 0; i < sizeof ShakePass; i ++)
	{
	if(zr_get_human_id(iPlayer) != ShakePass[i])
	continue
	
	return true
	}
	
	return false
}

stock SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0,0,0}, iPlayer)
	write_byte(iAnim)
	write_byte(1)
	message_end()
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

stock GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}