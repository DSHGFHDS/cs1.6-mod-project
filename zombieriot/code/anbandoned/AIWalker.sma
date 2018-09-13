/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#define PLUGIN "AI Walker"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

#define AI "ai_walker"
#define pev_idle pev_iuser1
#define pev_move pev_iuser2
#define pev_jump pev_iuser3
#define pev_attack pev_iuser4
#define pev_die pev_vuser4

#define pev_damage pev_speed
#define pev_distance pev_fuser1
#define pev_attackrate pev_fuser2
#define pev_thinkrate pev_fuser3
#define pev_dyingtime pev_fuser4

#define ISJUMPING 1312

new g_fwDummyResult, g_fwPreThink, g_fwPostThink, g_fwPreKilled, g_fwPostKilled, g_fwPreHurted, g_fwPostHurted
new cvar_bodytime

new spr_blood_spray, spr_blood_drop

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_Think, "info_target", "HAM_AiThink")
	RegisterHam(Ham_TraceAttack, "info_target", "HAM_AiTraceAttack")
	RegisterHam(Ham_Killed, "info_target", "HAM_AiKilled")
	g_fwPreThink = CreateMultiForward("AI_PreThink", ET_CONTINUE, FP_CELL)
	g_fwPostThink = CreateMultiForward("AI_PostThink", ET_IGNORE, FP_CELL)
	g_fwPreHurted = CreateMultiForward("AI_PreHurted", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL, FP_CELL)
	g_fwPostHurted = CreateMultiForward("AI_PostHurted", ET_IGNORE, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL, FP_CELL)
	g_fwPreKilled = CreateMultiForward("AI_PreKilled", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwPostKilled = CreateMultiForward("AI_PostKilled", ET_IGNORE, FP_CELL, FP_CELL)
	cvar_bodytime = register_cvar("ai_body_time", "5.0") //尸体存在的时间
}

public plugin_natives()
{
	register_native("IsAi", "NativeIsAi", 1)
	register_native("CreateAi", "NativeCreateAi")
	register_native("SetAiAnim", "NativeSetAiAnim")
	register_native("RemoveAi", "NativeRemoveAi", 1)
	register_native("RemoveAllAi", "NativeRemoveAllAi", 1)
	register_native("GetAIAmount", "NativeGetAIAmount", 1)
	register_native("GetAllAIAmount", "NativeGetAllAIAmount", 1)
	register_native("SendAiAnim", "NativeSendAiAnim", 1)
}

public plugin_precache()
{
	spr_blood_spray = engfunc(EngFunc_PrecacheModel, "sprites/bloodspray.spr")
	spr_blood_drop = engfunc(EngFunc_PrecacheModel, "sprites/blood.spr")
}

public HAM_AiThink(iEntity)
{
	new classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, AI))
	return HAM_IGNORED
	
	ExecuteForward(g_fwPreThink, g_fwDummyResult, iEntity)
	
	if(g_fwDummyResult == 1)
	return HAM_SUPERCEDE
	
	new deadflag = pev(iEntity, pev_deadflag)
	
	if(deadflag == DEAD_DEAD)
	{
	engfunc(EngFunc_RemoveEntity, iEntity)
	return HAM_SUPERCEDE
	}
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(deadflag == DEAD_DYING)
	{
	set_pev(iEntity, pev_deadflag, DEAD_DEAD)
	set_pev(iEntity, pev_nextthink, fCurTime+get_pcvar_float(cvar_bodytime))
	return HAM_SUPERCEDE
	}
	
	new Float:szThinkRate
	pev(iEntity, pev_thinkrate, szThinkRate)
	set_pev(iEntity, pev_nextthink, fCurTime+szThinkRate)
	
	new iPlayer = pev(iEntity, pev_enemy)
	if(!iPlayer)
	{
	iPlayer = engfunc(EngFunc_FindClientInPVS, iEntity)
	set_pev(iEntity, pev_enemy, iPlayer)
	}
	
	if(iPlayer && get_pdata_int(iPlayer, 114, 5) != pev(iEntity, pev_team))
	{
	new Float:start[3], Float:end[3]
	pev(iEntity, pev_origin, start)
	pev(iPlayer, pev_origin, end)
	
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, iEntity, 0)
	new blocker = get_tr2(0, TR_pHit)
	if(0 < blocker < 33 && blocker != iPlayer)
	{
	iPlayer = blocker
	set_pev(iEntity, pev_enemy, iPlayer)
	pev(iPlayer, pev_origin, end)
	}
	if(blocker == iPlayer)
	{
	SetEntityTurn(iEntity, end)
	new Float:distance, Float:velocity[3], Float:velocity2[3]
	pev(iEntity, pev_distance, distance)
	pev(iEntity, pev_velocity, velocity)
	if(get_distance_f(start, end) <= distance)
	{
	velocity2[2] = velocity[2]
	set_pev(iEntity, pev_velocity, velocity2)
	new Float:damage, Float:attackrate
	pev(iEntity, pev_damage, damage)
	ExecuteHamB(Ham_TakeDamage, iPlayer, iEntity, iEntity, damage, DMG_CLUB)
	pev(iEntity, pev_attackrate, attackrate)
	set_pev(iEntity, pev_nextthink, fCurTime+attackrate)
	NativeSendAiAnim(iEntity, pev(iEntity, pev_attack))
	}
	else
	if(pev(iEntity, pev_playerclass) == ISJUMPING)
	{
	get_speed_vector(start, end, 50.0, velocity2)
	velocity2[0] += velocity[0]
	velocity2[1] += velocity[1]
	velocity2[2] = velocity[2]
	set_pev(iEntity, pev_velocity, velocity2)
	set_pev(iEntity, pev_playerclass, 0)
	}
	else
	if(pev(iEntity, pev_flags) & FL_ONGROUND)
	{
	new Float:dest[3], Float:size[3]
	pev(iEntity, pev_origin, start)
	pev(iEntity, pev_v_angle, dest)
	engfunc(EngFunc_MakeVectors, dest)
	global_get(glb_v_forward, dest)
	
	pev(iEntity, pev_size, size)
	xs_vec_mul_scalar(dest, 1.5*size[0], dest)
	xs_vec_add(start, dest, dest)
	engfunc(EngFunc_TraceHull, dest, dest, IGNORE_MONSTERS, HULL_HUMAN, iEntity, 0)
	new Float:maxspeed
	pev(iEntity, pev_maxspeed, maxspeed)
	get_speed_vector(start, end, maxspeed, velocity2)
	
	if(get_tr2(0, TR_StartSolid) && get_tr2(0, TR_AllSolid) && !get_tr2(0, TR_InOpen) && FootPlaneNormal(iEntity) == 1.0)
	{
	velocity2[0] *= 0.5
	velocity2[1] *= 0.5
	velocity2[2] = 300.0
	NativeSendAiAnim(iEntity, pev(iEntity, pev_jump))
	set_pev(iEntity, pev_nextthink, fCurTime+0.2)
	set_pev(iEntity, pev_playerclass, ISJUMPING)
	}
	else
	{
	velocity2[2] = velocity[2]
	NativeSendAiAnim(iEntity, pev(iEntity, pev_move))
	}
	
	set_pev(iEntity, pev_velocity, velocity2)
	if(pev(iEntity, pev_playerclass) != ISJUMPING)
	{
	pev(iEntity, pev_angles, dest)
	engfunc(EngFunc_WalkMove, iEntity, dest[1], 0.5, WALKMOVE_NORMAL)
	}
	}
	ExecuteForward(g_fwPostThink, g_fwDummyResult, iEntity)
	return HAM_SUPERCEDE
	}
	}
	
	if(pev(iEntity, pev_flags) & FL_ONGROUND)
	{
	new Float:start[3], Float:dest[3], Float:hullend[3]
	pev(iEntity, pev_origin, start)
	pev(iEntity, pev_v_angle, dest)
	engfunc(EngFunc_MakeVectors, dest)
	global_get(glb_v_forward, dest)
	
	new Float:size[3]
	pev(iEntity, pev_size, size)
	xs_vec_mul_scalar(dest, 1.5*size[0], hullend)
	xs_vec_add(start, hullend, hullend)
	
	engfunc(EngFunc_TraceHull, hullend, hullend, DONT_IGNORE_MONSTERS, HULL_HUMAN, 0, 0)
	
	new Float:velocity[3]
	pev(iEntity, pev_velocity, velocity)
	if((!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen)) || FootPlaneNormal(iEntity) != 1.0)
	{
	new Float:maxspeed, Float:velocity2[3]
	pev(iEntity, pev_maxspeed, maxspeed)
	get_speed_vector(start, hullend, maxspeed, velocity2)
	velocity2[2] = velocity[2]
	set_pev(iEntity, pev_velocity, velocity2)
	pev(iEntity, pev_angles, dest)
	engfunc(EngFunc_WalkMove, iEntity, dest[1], 0.5, WALKMOVE_NORMAL)
	SetEntityTurn(iEntity, hullend)
	NativeSendAiAnim(iEntity, pev(iEntity, pev_move))
	}
	else
	{
	new Float:v_angle[3]
	pev(iEntity, pev_v_angle, v_angle)
	v_angle[1] += random_float(-90.0, 90.0)
	set_pev(iEntity, pev_v_angle, v_angle)
	velocity[0] = 0.0
	velocity[1] = 0.0
	set_pev(iEntity, pev_velocity, velocity)
	NativeSendAiAnim(iEntity, pev(iEntity, pev_idle))
	}
	}
	set_pev(iEntity, pev_enemy, 0)
	
	ExecuteForward(g_fwPostThink, g_fwDummyResult, iEntity)
	
	return HAM_SUPERCEDE
}

public HAM_AiTraceAttack(iEntity, attacker, Float:damage, Float:direction[3], tracehandle, damagetype)
{
	new classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, AI))
	return HAM_IGNORED
	
	new HitGroup = get_tr2(tracehandle, TR_iHitgroup)
	
	new Float:Ndamage = damage
	if(HitGroup == HIT_HEAD) Ndamage *= random_float(1.5, 2.0)
	else if(HIT_CHEST <= HitGroup <= HIT_RIGHTARM) Ndamage *= random_float(0.8, 1.0)
	else if(HitGroup != HIT_GENERIC) Ndamage *= random_float(0.6, 0.8)
	
	ExecuteForward(g_fwPreHurted, g_fwDummyResult, iEntity, attacker, Ndamage, tracehandle, damagetype)
	
	if(g_fwDummyResult == 1)
	return HAM_SUPERCEDE
	
	new Float:origin_end[3]
	get_tr2(tracehandle, TR_vecEndPos, origin_end)
	
	new Float:velocity[3]
	pev(iEntity, pev_velocity, velocity)
	velocity[0] *= 0.3
	velocity[1] *= 0.3
	set_pev(iEntity, pev_velocity, velocity)
	set_pev(iEntity, pev_nextthink, get_gametime()+0.1)
	NativeSendAiAnim(iEntity, pev(iEntity, pev_idle))
	SpawnBlood(origin_end, 247, floatround(Ndamage))
	SetHamParamFloat(3, damage)
	
	ExecuteForward(g_fwPostHurted, g_fwDummyResult, iEntity, attacker, Ndamage, tracehandle, damagetype)
	
	return HAM_IGNORED
}

public HAM_AiKilled(iEntity, attacker, gib)
{
	new classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, AI))
	return HAM_IGNORED
	
	ExecuteForward(g_fwPreKilled, g_fwDummyResult, iEntity, attacker)
	if(g_fwDummyResult == 1)
	return HAM_SUPERCEDE
	
	set_pev(iEntity, pev_deadflag, DEAD_DYING)
	new Float:fdie[3], die[3]
	pev(iEntity, pev_die, fdie)
	FVecIVec(fdie, die)
	NativeSendAiAnim(iEntity, die[random_num(0, 2)])
	set_pev(iEntity, pev_velocity, {0.0, 0.0, 0.01})
	set_pev(iEntity, pev_takedamage, DAMAGE_NO)
	set_pev(iEntity, pev_solid, SOLID_NOT)
	new Float:dyingtime
	pev(iEntity, pev_dyingtime, dyingtime)
	set_pev(iEntity, pev_nextthink, get_gametime()+dyingtime)
	
	ExecuteForward(g_fwPostKilled, g_fwDummyResult, iEntity, attacker)
	
	return HAM_SUPERCEDE
}

public NativeCreateAi(plugin, param)
{
	static AiName[33]
	get_string(2, AiName, charsmax(AiName))
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEntity, pev_solid, SOLID_BBOX)
	set_pev(iEntity, pev_movetype, MOVETYPE_STEP)
	set_pev(iEntity, pev_takedamage, DAMAGE_YES)
	set_pev(iEntity, pev_classname, AI)
	set_pev(iEntity, pev_deadflag, DEAD_NO)
	set_pev(iEntity, pev_targetname, AiName)
	set_pev(iEntity, pev_team, get_param(14))
	set_pev(iEntity, pev_max_health, get_param_f(6))
	set_pev(iEntity, pev_health, get_param_f(6))
	set_pev(iEntity, pev_maxspeed, get_param_f(7))
	set_pev(iEntity, pev_gravity, get_param_f(8))
	set_pev(iEntity, pev_damage, get_param_f(9))
	set_pev(iEntity, pev_distance, get_param_f(10))
	set_pev(iEntity, pev_attackrate, get_param_f(11))
	set_pev(iEntity, pev_thinkrate, get_param_f(12))
	set_pev(iEntity, pev_dyingtime, get_param_f(13))
	set_pev(iEntity, pev_nextthink, get_gametime()+get_param_f(12))
	set_pev(iEntity, pev_modelindex, get_param(3))
	set_pev(iEntity, pev_gamestate, 1.0)
	new Float:origin[3], Float:maxhull[3], Float:minhull[3]
	get_array_f(1, origin, 3)
	get_array_f(4, maxhull, 3)
	get_array_f(5, minhull, 3)
	engfunc(EngFunc_SetSize, iEntity, maxhull, minhull)
	engfunc(EngFunc_SetOrigin, iEntity, origin)
	
	return iEntity
}

public NativeSetAiAnim(plugin, param)
{
	new iEntity = get_param(1)
	set_pev(iEntity, pev_idle, get_param(2))
	set_pev(iEntity, pev_move, get_param(3))
	set_pev(iEntity, pev_jump, get_param(4))
	set_pev(iEntity, pev_attack, get_param(5))
	new die[3], Float:fdie[3]
	get_array(6, die, 3)
	IVecFVec(die, fdie)
	set_pev(iEntity, pev_die, fdie)
}

public NativeRemoveAi(const AiName[])
{
	new targetname[33], iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", AI)))
	{
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	if(strcmp(targetname, AiName))
	continue
	
	engfunc(EngFunc_RemoveEntity, iEntity)
	}
}

public NativeRemoveAllAi()
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", AI))) engfunc(EngFunc_RemoveEntity, iEntity)
}

public NativeGetAIAmount(const AiName[])
{
	new targetname[33], iEntity = -1, Amount
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", AI)))
	{
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	if(strcmp(targetname, AiName))
	continue
	
	Amount ++
	}
	
	return Amount
}

public NativeGetAllAIAmount()
{
	new iEntity = -1, Amount
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", AI))) Amount ++
	
	return Amount
}

public NativeSendAiAnim(iEntity, anim)
{
	if(pev(iEntity, pev_sequence) == anim)
	return
	
	set_pev(iEntity, pev_sequence, anim)
	set_pev(iEntity, pev_animtime, get_gametime())
	set_pev(iEntity, pev_frame, 0.0)
	set_pev(iEntity, pev_framerate, 1.0)
}

public bool:NativeIsAi(iEntity)
{
	if(!pev_valid(iEntity))
	return false
	
	new classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, AI))
	return false
	
	return true
}

stock SetEntityTurn(iEntity, Float:target[3])
{
	new Float:angle[3], Float:origin[3]
	pev(iEntity, pev_angles, angle)
	pev(iEntity, pev_origin, origin)
	
	new Float:x = origin[0] - target[0]
	new Float:z = origin[1] - target[1]
	new Float:radians = floatatan(z/x, radian)
	angle[1] = radians * 180.0/3.141592654
	if(target[0] < origin[0]) angle[1] -= 180.0
	set_pev(iEntity, pev_angles, angle)
	set_pev(iEntity, pev_v_angle, angle)
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1
}

stock Float:FootPlaneNormal(iEntity)
{
	new Float:start[3], Float:end[3]
	pev(iEntity, pev_origin, start)
	xs_vec_sub(start, Float:{0.0, 0.0, 9999.0}, end)
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, iEntity, 0)
	get_tr2(0, TR_vecPlaneNormal, end)
	return end[2]
}

stock SpawnBlood(const Float:vecOrigin[3], iColor, iAmount)
{
	if(iAmount == 0)
	return
	iAmount *= 2
	if(iAmount > 255) iAmount = 255
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(iColor)
	write_byte(min(max(3, iAmount / 10), 16))
	message_end()
}