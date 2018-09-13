/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Wildfire"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const Wildfire = 10

new const ShakePass[] = { 6, 7 }	//抵抗震枪效果的人类类型(可以自己增加)

new const FireBall[] = "models/zombieriot/fireball.mdl"
new const FireSound[] = "zombieriot/fire_loop_1.wav"
new const FireBallExplosion[] = "zombieriot/fireball.wav"

new g_fwBotForwardRegister, FireSPR, FireBallIndex, TrailSPR
new Float:SoundThink[33], Float:SPRThink[33], Float:SkillThink[33], Float:BurnThink[33], Float:BurnTime[33], SkillMode[33], Burning[33], bool:GameStarted
new cvar_cooldown, cvar_velocity, cvar_knockback, cvar_range, cvar_time, cvar_interval, cvar_damage
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink", 1)
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post",1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	register_forward(FM_Think, "fw_Think_Post", 1)
	register_forward(FM_Touch, "fw_Touch_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage")
	if(zr_zbot_supported()) g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	cvar_cooldown = register_cvar("zr_wildfire_cooldown", "15.0")			//技能冷却时间
	cvar_velocity = register_cvar("zr_wildfire_velocity", "2000.0")			//火球飞行速度
	cvar_knockback = register_cvar("zr_wildfire_knockback", "500.0")		//火球击退力
	cvar_range = register_cvar("zr_wildfire_range", "350.0")				//火球爆炸范围
	cvar_time = register_cvar("zr_wildfire_burntime", "5.0")				//燃烧时间
	cvar_interval = register_cvar("zr_wildfire_interval", "0.5")			//燃烧伤害时间间隔
	cvar_damage = register_cvar("zr_wildfire_damage", "20.0")				//燃烧伤害
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, FireSound)
	engfunc(EngFunc_PrecacheSound, FireBallExplosion)
	FireBallIndex = engfunc(EngFunc_PrecacheModel, FireBall)
	FireSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/flame.spr")
	TrailSPR = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage")
}

public zr_roundbegin_event(Weather)
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "Wildfire"))) set_pev(iEntity, pev_flags, FL_KILLME)
	GameStarted = true
}

public zr_being_zombie(iPlayer)
{
	ResetData(iPlayer)
	if(zr_get_zombie_id(iPlayer) == Wildfire) Burning[iPlayer] = 1
	else Burning[iPlayer] = 0
}

public zr_being_ghost(iPlayer) ResetData(iPlayer)

public zr_being_human(iPlayer)
{
	Burning[iPlayer] = 0
	ResetData(iPlayer)
}

public Event_CurWeapon(iPlayer) if(SkillMode[iPlayer] == 1) SkillMode[iPlayer] = 0

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(SkillMode[iPlayer])
	return
	
	if(zr_get_zombie_id(iPlayer) != Wildfire)
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
	
	ThrowFireBall(iPlayer)
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
	
	if(zr_get_zombie_id(iPlayer) != Wildfire)
	return FMRES_IGNORED
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return FMRES_SUPERCEDE
	
	if(get_pdata_int(iEntity, 43, 4) != CSW_KNIFE)
	return FMRES_SUPERCEDE
	
	if(SkillMode[iPlayer] == 1)
	{
	zr_print_chat(iPlayer, GREYCHAT, "火球技能正在使用!")
	return FMRES_SUPERCEDE
	}
	
	if(SkillMode[iPlayer] == 2)
	{
	zr_print_chat(iPlayer, GREYCHAT, "火球技能正在冷却!")
	return FMRES_SUPERCEDE
	}
	
	ThrowFireBall(iPlayer)
	
	return FMRES_SUPERCEDE
}

public fw_PlayerPostThink(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO || !GameStarted)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	if(Burning[iPlayer])
	{
	if(SoundThink[iPlayer] <= fCurTime)
	{
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, FireSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	SoundThink[iPlayer] = fCurTime+4.0
	}
	
	if(SPRThink[iPlayer] <= fCurTime)
	{
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0]+random_float(-25.0, 25.0))
	engfunc(EngFunc_WriteCoord, origin[1]+random_float(-25.0, 25.0))
	engfunc(EngFunc_WriteCoord, origin[2]+random_float(10.0, 20.0))
	write_short(FireSPR)
	write_byte(random_num(8, 10))
	write_byte(100)
	message_end()
	SPRThink[iPlayer] = fCurTime+0.1
	}
	
	if(!zr_is_user_zombie(iPlayer))
	{
	if(BurnTime[iPlayer] <= fCurTime)
	{
	Burning[iPlayer] = 0
	return
	}
	if(BurnThink[iPlayer] > fCurTime)
	return
	BurnThink[iPlayer] = fCurTime+get_pcvar_float(cvar_interval)
	ExecuteHamB(Ham_TakeDamage, iPlayer, 0, Burning[iPlayer], get_pcvar_float(cvar_damage), DMG_SLOWBURN)
	return
	}
	}
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != Wildfire)
	return
	
	if(SkillMode[iPlayer] == 1)
	{
	if(SkillThink[iPlayer] > fCurTime)
	return
	SkillThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	SkillMode[iPlayer] = 2
	MakeFireBall(iPlayer)
	return
	}
	
	if(SkillMode[iPlayer] != 2)
	return
	
	if(SkillThink[iPlayer] > fCurTime)
	return
	
	SkillMode[iPlayer] = 0
	zr_print_chat(iPlayer, BLUECHAT, "火球技能已经冷却!")
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pSet)
{
	if(!player || !is_user_alive(host))
	return
	
	if(!zr_is_user_zombie(iEntity))
	return
	
	if(zr_get_zombie_id(iEntity) != Wildfire)
	return
	
	set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
	set_es(es_handle, ES_RenderColor, {255, 0, 0})
	set_es(es_handle, ES_RenderAmt, 15)
	set_es(es_handle, ES_RenderMode, kRenderNormal)
}

public fw_Think_Post(iEntity)
{
	if(!pev_valid(iEntity))
	return
	
	new classname[32]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "Wildfire"))
	return
	
	new Float:velocity[3]
	pev(iEntity, pev_velocity, velocity)
	set_pev(iEntity, pev_avelocity, velocity)
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.01)
}

public fw_Touch_Post(iEntity, iPtd)
{
	if(!pev_valid(iEntity))
	return
	
	new classname[32]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "Wildfire"))
	return
	
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	if(engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY)
	{
	set_pev(iEntity, pev_flags, FL_KILLME)
	return
	}
	
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, get_pcvar_float(cvar_range))) > 0)
	{
	if(!pev_valid(i) || iEntity == i)
	continue
	
	if(pev(i, pev_takedamage) == DAMAGE_NO)
	continue
	
	new Float:origin2[3]
	pev(i, pev_origin, origin2)
	engfunc(EngFunc_TraceLine, origin, origin2, IGNORE_MONSTERS, iEntity, 0)
	new Float:fraction
	get_tr2(0, TR_flFraction, fraction)
	if(fraction != 1.0)
	continue
	
	pev(i, pev_classname, classname, charsmax(classname))
	if(!strcmp(classname, "func_breakable"))
	{
	dllfunc(DLLFunc_Use, i, iEntity)
	continue
	}
	
	if(!is_user_alive(i))
	continue
	
	if(CheckIgnore(i))
	continue
	
	new Float:velocity[3]
	GetVelocityFromOrigin(origin2, origin, get_pcvar_float(cvar_knockback), velocity)
	set_pev(i, pev_velocity, velocity)
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, i)
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<14)
	message_end()
	
	if(zr_is_user_zombie(i))
	continue
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	Burning[i] = pev(iEntity, pev_owner)
	BurnTime[i] = fCurTime+get_pcvar_float(cvar_time)
	new wEntity = get_pdata_cbase(i, 368)
	
	if(!pev_valid(wEntity)) wEntity = get_pdata_cbase(i, 369)
	
	if(!pev_valid(wEntity))
	continue
	
	pev(wEntity, pev_classname, classname, charsmax(classname))
	engclient_cmd(i, "drop", classname)
	}
	
	new Float:Distance = get_pcvar_float(cvar_range)/4.0
	origin[2] += 180.0
	SendExplosionMSG(origin)
	origin[2] -= 50.0
	origin[0] += Distance
	SendExplosionMSG(origin)
	origin[0] -= Distance*2.0
	SendExplosionMSG(origin)
	origin[0] += Distance
	origin[1] += Distance
	SendExplosionMSG(origin)
	origin[1] -= Distance*2.0
	SendExplosionMSG(origin)
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, FireBallExplosion, 1.0, 0.3, 0, PITCH_NORM)
	
	set_pev(iEntity, pev_flags, FL_KILLME)
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(victim))
	return HAM_IGNORED
	
	if(!zr_is_user_zombie(victim))
	return HAM_IGNORED
	
	if(zr_get_zombie_id(victim) != Wildfire)
	return HAM_IGNORED
	
	if(inflictor && pev(inflictor, pev_iuser1) == DATAKEY_1)
	{
	SetHamParamFloat(4, damage*3.0)
	return HAM_IGNORED
	}
	
	if(!(damage_type & DMG_BURN) && !(damage_type & DMG_SLOWBURN))
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public SendExplosionMSG(Float:origin[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(FireSPR)
	write_byte(22)
	write_byte(200)
	message_end()
}

public ThrowFireBall(iPlayer)
{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	SkillMode[iPlayer] = 1
	SkillThink[iPlayer] = fCurTime + 0.25
	set_pdata_float(iPlayer, 83, 1.35, 5)
	SendWeaponAnim(iPlayer, 5)
	zr_set_user_anim(iPlayer, 1.35, 76)
}

public MakeFireBall(iPlayer)
{
	new Float:origin[3], Float:angles[3]
	pev(iPlayer, pev_angles, angles)
	angles[0] *= 3.0
	get_aim_origin_vector(iPlayer, 10.0, 7.0, 6.0, origin)
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEntity, pev_classname, "Wildfire")
	set_pev(iEntity, pev_solid, SOLID_BBOX)
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_owner, iPlayer)
	set_pev(iEntity, pev_angles, angles)
	set_pev(iEntity, pev_modelindex, FireBallIndex)
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.01)
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
	write_short(TrailSPR)
	write_byte(10)
	write_byte(5)
	write_byte(255)
	write_byte(50)
	write_byte(0)
	write_byte(255)
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_ELIGHT)
	write_short(iEntity)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, 5.0)
	write_byte(255)
	write_byte(50)
	write_byte(0)
	write_byte(10000)
	engfunc(EngFunc_WriteCoord, 0.0)
	message_end()
}

public ResetData(iPlayer)
{
	SoundThink[iPlayer] = 0.0
	SPRThink[iPlayer] = 0.0
	SkillMode[iPlayer] = 0
	BurnThink[iPlayer] = 0.0
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, FireSound, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
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