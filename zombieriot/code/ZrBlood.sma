/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>

#define PLUGIN "Zr Blood"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const BloodId = 6	//血腥玛丽ID

new const SkillSound[] = "zombieriot/bloodskill.wav"

new Float:PlayerThink[33], BloodMode[33], Float:BloodSuckRate[33]
new cvar_holdingtime, cvar_cooldown, cvar_suckrate, cvar_sucklitre, cvar_suckrange

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post",1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	cvar_holdingtime = register_cvar("zr_blood_holdingtime", "10.0")		//吸血技能持续时间
	cvar_cooldown = register_cvar("zr_blood_cooldown", "15.0")			//吸血技能冷却时间
	cvar_suckrate = register_cvar("zr_blood_rate", "0.3")				//吸血频率
	cvar_sucklitre = register_cvar("zr_blood_litre", "10.0")				//吸血量
	cvar_suckrange = register_cvar("zr_blood_range", "100.0")			//吸血范围
}

public plugin_precache() engfunc(EngFunc_PrecacheSound, SkillSound)

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !zr_is_user_zombie(iPlayer) || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return
	
	if(BloodMode[iPlayer])
	return
	
	if(zr_get_zombie_id(iPlayer) != BloodId)
	return
	
	new Enemy = get_tr2(iTrace, TR_pHit)
	if(!is_user_alive(Enemy))
	return
	
	if(zr_is_user_zombie(Enemy))
	return
	
	new Float:origin[3]
	get_tr2(iTrace, TR_vecEndPos, origin)
	
	if(get_distance_f(vecStart, origin) > get_pcvar_float(cvar_suckrange))
	return
	
	SuckBlood(iPlayer)
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pSet)
{
	if(!player || !is_user_alive(host))
	return
	
	if(BloodMode[iEntity] != 1)
	return
	
	if(!zr_is_user_zombie(iEntity))
	return
	
	if(zr_get_zombie_id(iEntity) != BloodId)
	return
	
	set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
	set_es(es_handle, ES_RenderColor, {255, 0, 0})
	set_es(es_handle, ES_RenderAmt, 1)
	set_es(es_handle, ES_RenderMode, kRenderNormal)
}

public fw_PlayerPostThink_Post(iPlayer, Float:maxspeed)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(!zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_zombie_id(iPlayer) != BloodId)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(BloodMode[iPlayer] == 2)
	{
	if(PlayerThink[iPlayer] > fCurTime)
	return
	
	BloodMode[iPlayer] = 0
	zr_print_chat(iPlayer, BLUECHAT, "吸血技能已冷却!")
	
	return
	}
	
	if(BloodMode[iPlayer] != 1)
	return
	
	if(PlayerThink[iPlayer] <= fCurTime)
	{
	BloodMode[iPlayer] = 2
	PlayerThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	zr_print_chat(iPlayer, GREYCHAT, "吸血技能已结束!")
	return
	}
	
	if(BloodSuckRate[iPlayer] > fCurTime)
	return
	
	BloodSuckRate[iPlayer] = fCurTime+get_pcvar_float(cvar_suckrate)
	
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	
	for(new i = 1 ; i < 33; i ++)
	{
	if(i == iPlayer || !is_user_alive(i) || zr_is_user_zombie(i))
	continue
	
	new Float:Torigin[3]
	pev(i, pev_origin, Torigin)
	
	if(get_distance_f(Torigin, origin) > get_pcvar_float(cvar_suckrange))
	continue
	
	new Float:health, Float:zhealth, Float:SuckLitre = get_pcvar_float(cvar_sucklitre)
	pev(i, pev_health, health)
	pev(iPlayer, pev_health, zhealth)
	set_pev(iPlayer, pev_health, zhealth+(health < SuckLitre ? health : SuckLitre))
	health <= SuckLitre ? ExecuteHamB(Ham_TakeDamage, i, iPlayer, iPlayer, SuckLitre, DMG_GENERIC) : set_pev(i, pev_health, health-SuckLitre)
	CreateBloodTrail(origin, Torigin)
	}
	
	if (!(pev(iPlayer, pev_flags) & FL_ONGROUND))
	return
	
	new Float:end[3]
	for(new i = 0; i < 2; i ++) end[i] = origin[i]
	end[2] = origin[2] - 36.0
	engfunc(EngFunc_TraceLine, origin, end, IGNORE_MONSTERS, iPlayer, 0)
	get_tr2(0, TR_vecEndPos, end)
	
	CreateBloodDecal(end)
}

public fw_ClientCommand(iPlayer)
{
	static szCommand[24]
	read_argv(0, szCommand, charsmax(szCommand))
	
	if(!strcmp(szCommand, "weapon_hegrenade") || !strcmp(szCommand, "lastinv"))
	{
	if(BloodMode[iPlayer] != 1)
	return FMRES_IGNORED
	
	return FMRES_SUPERCEDE
	}
	
	if(strcmp(szCommand, "drop") || (pev(iPlayer, pev_flags) & FL_FROZEN))
	return FMRES_IGNORED
	
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return FMRES_IGNORED
	
	if(!zr_is_user_zombie(iPlayer))
	return FMRES_IGNORED
	
	if(zr_get_zombie_id(iPlayer) != BloodId)
	return FMRES_IGNORED
	
	if(BloodMode[iPlayer] == 1)
	{
	zr_print_chat(iPlayer, GREYCHAT, "吸血技能正在使用中!")
	return FMRES_IGNORED
	}
	
	if(BloodMode[iPlayer] == 2)
	{
	zr_print_chat(iPlayer, GREYCHAT, "吸血技能正在冷却中!")
	return FMRES_IGNORED
	}
	
	SuckBlood(iPlayer)
	
	return FMRES_SUPERCEDE
}

public SuckBlood(iPlayer)
{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	PlayerThink[iPlayer] = fCurTime + get_pcvar_float(cvar_holdingtime)
	BloodMode[iPlayer] = 1
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, SkillSound, VOL_NORM, 0.6, 0, PITCH_NORM)
}

public zr_being_zombie(iPlayer)
{
	BloodMode[iPlayer] = 0
	PlayerThink[iPlayer] = 0.0
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public CreateBloodTrail(const Float:origin[3], const Float:Torigin[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, Torigin, 0)
	switch(random_num(0, 1))
	{
	case 0: write_byte(TE_BLOODSTREAM)
	case 1: write_byte(TE_BLOOD)
	}
	engfunc(EngFunc_WriteCoord, Torigin[0]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, Torigin[1]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, Torigin[2]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, origin[0]-Torigin[0]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, origin[1]-Torigin[1]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, origin[2]-Torigin[2]+random_float(40.0, 60.0))
	write_byte(70)
	write_byte(random_num(get_pcvar_num(cvar_suckrange), get_pcvar_num(cvar_suckrange)*2))
	message_end()
}

public CreateBloodDecal(const Float:origin[3])
{
	static BloodDecal[16]
	formatex(BloodDecal, charsmax(BloodDecal), "{blood%d", random_num(1, 6))
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_WORLDDECAL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_byte(engfunc(EngFunc_DecalIndex, BloodDecal))
	message_end()
}