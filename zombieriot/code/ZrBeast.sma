/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Beast"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const BeastSound[] = "zombieriot/beast_skill.wav"

new g_fwBotForwardRegister
new const Beast = 13
new Jumping[33], Float:NextThink[33], Float:ReCover[33], FixClient[33], bool:DamagedRecord[33][33]
new cvar_velocity, cvar_recover[2], cvar_damage

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_Touch, "fw_Touch_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "HAM_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "HAM_Weapon_SecondaryAttack")
	cvar_velocity = register_cvar("zr_beast_velocity", "600.0")				//突进速度
	cvar_recover[0] = register_cvar("zr_beast_recover_rate", "0.5")			//生命恢复时间间隔
	cvar_recover[1] = register_cvar("zr_beast_recover_times", "0.02")		//每次恢复的血量倍数
	cvar_damage = register_cvar("zr_beast_damage", "100.0")					//冲击伤害
	g_fwBotForwardRegister = zr_zbot_supported()
}

public plugin_precache() engfunc(EngFunc_PrecacheSound, BeastSound)

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(zr_get_zombie_id(iPlayer) != Beast)
	return
	
	new Enemy = get_tr2(iTrace, TR_pHit)
	if(!is_user_alive(Enemy))
	return
	
	if(zr_is_user_zombie(Enemy))
	return
	
	new Float:origin[3]
	get_tr2(iTrace, TR_vecEndPos, origin)
	
	new Float:Distance = get_distance_f(vecStart, origin)
	if(Distance > get_pcvar_float(cvar_velocity) || Distance < get_pcvar_float(cvar_velocity)*0.35)
	return
	
	BeastSkill(iPlayer)
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(is_user_bot(iPlayer) && g_fwBotForwardRegister)
	{
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage")
	g_fwBotForwardRegister = false
	}
	
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != Beast)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(ReCover[iPlayer] <= fCurTime)
	{
	new Float:health, Float:maxhealth
	pev(iPlayer, pev_health, health)
	maxhealth = zr_get_zombie_health(Beast)
	if(health < maxhealth) set_pev(iPlayer, pev_health, floatmin(health*(1.0+get_pcvar_float(cvar_recover[1])), maxhealth))
	ReCover[iPlayer] = fCurTime + get_pcvar_float(cvar_recover[0])
	}
	
	if(!Jumping[iPlayer] && FixClient[iPlayer])
	{
	SendWeaponAnim(iPlayer, 0)
	FixClient[iPlayer] --
	}
	
	if(Jumping[iPlayer] == 1 && NextThink[iPlayer] <= fCurTime)
	{
	set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) &~ FL_FROZEN)
	Jumping[iPlayer] = 0
	SendWeaponAnim(iPlayer, 0)
	return
	}
	
	if(Jumping[iPlayer] != 2)
	return
	
	if(!(pev(iPlayer, pev_flags) & FL_ONGROUND) && !(pev(iPlayer, pev_flags) & FL_INWATER) && !(pev(iPlayer, pev_flags) & FL_ONTRAIN) && pev(iPlayer, pev_movetype) != MOVETYPE_FLY)
	return
	
	set_pev(iPlayer, pev_punchangle, {0.0, 0.0, 0.0})
	set_pev(iPlayer, pev_velocity, {0.0, 0.0, 0.0})
	set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) | FL_FROZEN)
	SendWeaponAnim(iPlayer, 9)
	zr_set_user_anim(iPlayer, 0.9, 113, 113)
	NextThink[iPlayer] = fCurTime + 0.9
	for(new i = 1; i < 33; i ++) DamagedRecord[iPlayer][i] = false
	Jumping[iPlayer] = 1
}

public fw_UpdateClientData_Post(iPlayer, iSendWeapon, CD_Handle)
{
	if(get_cd(CD_Handle, CD_DeadFlag) != DEAD_NO)
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != Beast)
	return
	
	if(!Jumping[iPlayer])
	return
	
	set_cd(CD_Handle, CD_ID, 0)
}

public fw_Touch_Post(iPlayer, iPtd)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != Beast)
	return
	
	if(Jumping[iPlayer] != 2)
	return
	
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	
	if(is_user_alive(iPtd))
	{
	new Float:origin2[3], Float:velocity[3]
	pev(iPtd, pev_origin, origin2)
	GetVelocityFromOrigin(origin2, origin, get_pcvar_float(cvar_velocity)*1.5, velocity)
	velocity[2] = floatmax(0.0, velocity[2])+200.0
	set_pev(iPtd, pev_velocity, velocity)
	if(DamagedRecord[iPlayer][iPtd])
	return
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, iPtd)
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<14)
	message_end()
	ExecuteHamB(Ham_TakeDamage, iPtd, get_pdata_cbase(iPlayer, 370, 5), iPlayer, get_pcvar_float(cvar_damage), DMG_CRUSH)
	DamagedRecord[iPlayer][iPtd] = true
	return
	}
	
	if(!pev_valid(iPtd))
	return
	
	static classname[32]
	pev(iPtd, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "func_breakable"))
	return
	
	dllfunc(DLLFunc_Use, iPtd, iPlayer)
}

public HAM_Weapon_PrimaryAttack(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(!zr_is_user_zombie(iPlayer))
	return HAM_IGNORED
	
	if(zr_get_zombie_id(iPlayer) != Beast)
	return HAM_IGNORED
	
	if(!Jumping[iPlayer])
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public HAM_Weapon_SecondaryAttack(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	if(get_pdata_float(iEntity, 46, 4) > 0.0)
	return HAM_IGNORED
	
	if(!zr_is_user_zombie(iPlayer))
	return HAM_IGNORED
	
	if(zr_get_zombie_id(iPlayer) != Beast)
	return HAM_IGNORED
	
	if(is_user_bot(iPlayer))
	return HAM_SUPERCEDE
	
	BeastSkill(iPlayer)
	
	return HAM_SUPERCEDE
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_alive(victim))
	return HAM_IGNORED
	
	if(!zr_is_user_zombie(victim))
	return HAM_IGNORED
	
	if(zr_get_zombie_id(victim) != Beast)
	return HAM_IGNORED
	
	if(Jumping[victim] != 2)
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public BeastSkill(iPlayer)
{
	if(!(pev(iPlayer, pev_flags) & FL_ONGROUND))
	{
	if(Jumping[iPlayer])
	return
	FixClient[iPlayer] = 3
	return
	}
	
	if(Jumping[iPlayer])
	return
	
	Jumping[iPlayer] = 2
	
	new Float:origin[3], Float:start[3], Float:view_ofs[3], Float:end[3]
	pev(iPlayer, pev_origin, origin)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(origin, view_ofs, start)
	
	pev(iPlayer, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, 8120.0, end)
	xs_vec_add(start, end, end)
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, iPlayer, 0)
	get_tr2(0, TR_vecEndPos, end)
	
	new Float:Velocity[3]
	get_speed_vector(origin, end, get_pcvar_float(cvar_velocity), Velocity)
	Velocity[2] = floatmax(0.0, Velocity[2])+250.0
	set_pev(iPlayer, pev_velocity, Velocity)
	set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) &~ FL_ONGROUND)
	SendWeaponAnim(iPlayer, 8)
	zr_set_user_anim(iPlayer, 99999.0, 112, 112)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, BeastSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public zr_being_zombie(iPlayer)
{
	FixClient[iPlayer] = 0
	NextThink[iPlayer] = 0.0
	Jumping[iPlayer] = 0
	set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) &~ FL_FROZEN)
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public zr_hook_velocitycheck(iPlayer)
{
	if(Jumping[iPlayer] != 2)
	return ZR_IGNORED
	
	if(!zr_is_user_zombie(iPlayer))
	return ZR_IGNORED
	
	if(zr_get_zombie_id(iPlayer) != Beast)
	return ZR_IGNORED
	
	return ZR_SUPERCEDE
}

public zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
{
	if(!is_user_alive(victim))
	return ZR_IGNORED
	
	if(Jumping[victim] != 2)
	return ZR_IGNORED
	
	if(!zr_is_user_zombie(victim))
	return ZR_IGNORED
	
	if(zr_get_zombie_id(victim) != Beast)
	return ZR_IGNORED
	
	return ZR_SUPERCEDE
}

stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	xs_vec_sub(origin2, origin1, new_velocity)
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	xs_vec_mul_scalar(new_velocity, num, new_velocity)
}

stock SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0,0,0}, iPlayer)
	write_byte(iAnim)
	write_byte(1)
	message_end()
}

stock GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}