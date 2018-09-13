/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zombie Toxin"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define ANTIDOTESKEY 633423

new const models[][] = { "models/zombieriot/v_antidotes.mdl", "models/zombieriot/x_antidotes.mdl" }

new const AntidotesName[] = "毒素解毒剂"	//物品名称
new const AntidotesCost = 1000				//物品价格

new g_fwBotForwardRegister
new AntidotesID
new Float:NextThink[2][33], Float:MaxSpeedRecorder[33]
new cvar_speedtimes, cvar_possibility, cvar_time, cvar_damage, cvar_damagetime, cvar_distance

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	static AntidotesInfo[64]
	formatex(AntidotesInfo, charsmax(AntidotesInfo), "%s %d$", AntidotesName, AntidotesCost)
	AntidotesID = zr_register_item(AntidotesInfo, HUMAN, 4)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_flashbang", "HAM_Weapon_PrimaryAttack")
	RegisterHam(Ham_Item_PostFrame, "weapon_flashbang", "HAM_Item_PostFrame")
	RegisterHam(Ham_Item_Deploy, "weapon_flashbang", "HAM_ItemDeploy_Post", 1)
	RegisterHam(Ham_Item_Holster, "weapon_flashbang", "HAM_ItemHolster_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage")
	if(zr_zbot_supported()) g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	cvar_speedtimes = register_cvar("zr_toxin_speedtimes", "0.8")		//中毒后的速度倍数
	cvar_possibility = register_cvar("zr_toxin_possibility", "0.1")		//中毒的机率
	cvar_time = register_cvar("zr_toxin_time", "30.0")					//中毒时间
	cvar_damage = register_cvar("zr_toxin_damage", "10.0")				//中毒的伤害
	cvar_damagetime = register_cvar("zr_toxin_damagetime", "1.0")		//中毒的伤害间隔
	cvar_distance = register_cvar("zr_antidotes_distance", "80.0")		//给解毒剂队友的距离
}

public plugin_precache() for(new i = 0; i < 2; i ++) engfunc(EngFunc_PrecacheModel, models[i])

public zr_being_zombie(iPlayer)
{
	NextThink[0][iPlayer] = -1.0
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusIcon"), {0,0,0}, iPlayer)
	write_byte(0)
	write_string("dmg_poison")
	message_end()
}

public zr_being_ghost(iPlayer) zr_being_zombie(iPlayer)

public zr_being_human(iPlayer) zr_being_zombie(iPlayer)

public zr_item_event(iPlayer, item, Slot)
{
	if(item != AntidotesID)
	return
	
	new money = zr_get_user_money(iPlayer)
	
	if(money < AntidotesCost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金币无法购买!")
	return
	}
	
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "weapon_flashbang")) != 0)
	{
	if(pev(iEntity, pev_owner) != iPlayer)
	continue
	
	zr_print_chat(iPlayer, GREYCHAT, "装备栏已满!")
	return
	}
	
	iEntity = fm_give_item(iPlayer, "weapon_flashbang")
	set_pev(iEntity, pev_weapons, ANTIDOTESKEY)
	
	zr_set_user_money(iPlayer, money-AntidotesCost, true)
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一支%s!", AntidotesName)
}

public fw_SetModel(iEntity, szModel[])
{
	if(strlen(szModel) < 8)
	return FMRES_IGNORED
	
	if(szModel[7] != 'w' || szModel[8] != '_')
	return FMRES_IGNORED
	
	new szClassName[32]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	
	if(strcmp(szClassName, "grenade"))
	return FMRES_IGNORED
	
	new iEntity2 = get_pdata_cbase(iEntity, 38, 4)
	if(iEntity2 < 0)
	return FMRES_IGNORED
	
	if(pev(iEntity2, pev_weapons) != ANTIDOTESKEY)
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_flags, FL_KILLME)
	
	return FMRES_SUPERCEDE
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(zr_is_user_zombie(iPlayer))
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(NextThink[0][iPlayer] <= 0.0)
	return
	
	if(NextThink[1][iPlayer] <= fCurTime)
	{
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_BLOODSTREAM)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, random_float(-50.0, 50.0))
	engfunc(EngFunc_WriteCoord, random_float(-50.0, 50.0))
	engfunc(EngFunc_WriteCoord, random_float(-50.0, 50.0))
	write_byte(55)
	write_byte(10)
	message_end()
	ExecuteHamB(Ham_TakeDamage, iPlayer, 0, 0, get_pcvar_float(cvar_damage), DMG_GENERIC)
	NextThink[1][iPlayer] = fCurTime+get_pcvar_float(cvar_damagetime)
	}
	
	if(NextThink[0][iPlayer] > fCurTime)
	return
	
	NextThink[0][iPlayer] = -1.0
	client_print(iPlayer, print_center, "僵尸毒素已完全消退!")
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusIcon"), {0,0,0}, iPlayer)
	write_byte(0)
	write_string("dmg_poison")
	message_end()
	
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	maxspeed += MaxSpeedRecorder[iPlayer]
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
	MaxSpeedRecorder[iPlayer] = 0.0
}

public Event_CurWeapon(iPlayer)
{
	if(zr_is_user_zombie(iPlayer))
	return PLUGIN_CONTINUE
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(pev(iEntity, pev_weapons) != ANTIDOTESKEY)
	return PLUGIN_CONTINUE
	
	set_pev(iPlayer, pev_viewmodel2, models[0])
	set_pev(iPlayer, pev_weaponmodel2, models[1])
	
	return PLUGIN_CONTINUE
}

public fw_UpdateClientData_Post(iPlayer, iSendWeapon, CD_Handle)
{
	if(get_cd(CD_Handle, CD_DeadFlag) != DEAD_NO)
	return
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	
	if(iEntity <= 0)
	return
	
	if(pev(iEntity, pev_weapons) != ANTIDOTESKEY)
	return
	
	set_cd(CD_Handle, CD_iUser3, 0)
}

public HAM_Weapon_PrimaryAttack(iEntity)
{
	if(pev(iEntity, pev_weapons) != ANTIDOTESKEY)
	return HAM_IGNORED
	
	if(pev(iEntity, pev_iuser2) == ANTIDOTESKEY)
	return HAM_SUPERCEDE
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(NextThink[0][iPlayer] <= 0.0)
	{
	client_print(iPlayer, print_center, "现在不需要使用!")
	return HAM_SUPERCEDE
	}
	
	set_pdata_float(iEntity, 46, 0.4, 4)
	set_pdata_float(iEntity, 47, 0.4, 4)
	set_pdata_float(iEntity, 48, 0.4, 4)
	set_pev(iEntity, pev_iuser2, ANTIDOTESKEY)
	SendWeaponAnim(iPlayer, 2)
	
	return HAM_SUPERCEDE
}

public HAM_Item_PostFrame(iEntity)
{
	if(pev(iEntity, pev_weapons) != ANTIDOTESKEY)
	return HAM_IGNORED
	
	if(get_pdata_float(iEntity, 47, 4) > 0.0)
	return HAM_IGNORED
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	new button = pev(iPlayer, pev_button)
	if(button & IN_ATTACK2)
	{
	GiveAwayAntidotes(iPlayer, iEntity)
	return HAM_IGNORED
	}
	
	if(pev(iEntity, pev_iuser2) != ANTIDOTESKEY)
	return HAM_IGNORED
	
	ExecuteHamB(Ham_Weapon_RetireWeapon, iEntity)
	ExecuteHamB(Ham_RemovePlayerItem, iPlayer, iEntity)
	ExecuteHamB(Ham_Item_Kill, iEntity)
	set_pev(iPlayer, pev_weapons, pev(iPlayer, pev_weapons) & ~(1<<get_pdata_int(iEntity, 43, 4)))
	
	NextThink[0][iPlayer] = -1.0
	client_print(iPlayer, print_center, "僵尸毒素已完全消退!")
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusIcon"), {0,0,0}, iPlayer)
	write_byte(0)
	write_string("dmg_poison")
	message_end()
	
	new Float:maxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	maxspeed += MaxSpeedRecorder[iPlayer]
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed)
	set_pev(iPlayer, pev_maxspeed, maxspeed)
	MaxSpeedRecorder[iPlayer] = 0.0
	
	return HAM_SUPERCEDE
}

public HAM_ItemDeploy_Post(iEntity)
{
	if(pev(iEntity, pev_weapons) != ANTIDOTESKEY)
	return
	
	set_pev(iEntity, pev_iuser2, 0)
}

public HAM_ItemHolster_Post(iEntity)
{
	if(pev(iEntity, pev_weapons) != ANTIDOTESKEY)
	return
	
	set_pev(iEntity, pev_iuser2, 0)
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(victim) || !is_user_connected(attacker))
	return HAM_IGNORED
	
	if(NextThink[0][victim] > 0.0)
	return HAM_IGNORED
	
	if(zr_is_user_zombie(victim) || !zr_is_user_zombie(attacker))
	return HAM_IGNORED
	
	if(random_float(0.0, 100.0) > 100.0*get_pcvar_float(cvar_possibility))
	return HAM_IGNORED
	
	new Float:armorvalue
	pev(victim, pev_armorvalue, armorvalue)
	
	if(armorvalue > 0.0)
	{
	client_print(victim, print_center, "防护甲为你抵挡了僵尸毒素的感染!")
	return HAM_IGNORED
	}
	
	client_print(victim, print_center, "你被感染了僵尸毒素!")
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	NextThink[0][victim] = fCurTime+get_pcvar_float(cvar_time)
	NextThink[1][victim] = fCurTime+get_pcvar_float(cvar_damagetime)
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusIcon"), {0, 0, 0}, victim)
	write_byte(2)
	write_string("dmg_poison")
	write_byte(0)
	write_byte(150)
	write_byte(0)
	message_end()
	
	new Float:maxspeed
	pev(victim, pev_maxspeed, maxspeed)
	MaxSpeedRecorder[victim] = maxspeed-floatmax(maxspeed*get_pcvar_float(cvar_speedtimes), floatmin(140.0, maxspeed))
	maxspeed -= MaxSpeedRecorder[victim]
	engfunc(EngFunc_SetClientMaxspeed, victim, maxspeed)
	set_pev(victim, pev_maxspeed, maxspeed)
	
	return HAM_IGNORED
}

public GiveAwayAntidotes(iPlayer, iEntity)
{
	new Float:start[3], Float:view_ofs[3], Float:end[3]
	pev(iPlayer, pev_origin, start)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	
	pev(iPlayer, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, get_pcvar_float(cvar_distance), end)
	xs_vec_add(start, end, end)
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, iPlayer, 0)
	
	new TeamMate = get_tr2(0, TR_pHit)
	if(!is_user_alive(TeamMate))
	return
	
	if(zr_is_user_zombie(TeamMate))
	return
	
	new bEntity = -1
	while((bEntity = engfunc(EngFunc_FindEntityByString, bEntity, "classname", "weapon_flashbang")) != 0)
	{
	if(pev(bEntity, pev_owner) != TeamMate)
	continue
	
	client_print(iPlayer, print_center, "队友装备栏已满!")
	return
	}
	
	ExecuteHamB(Ham_Weapon_RetireWeapon, iEntity)
	ExecuteHamB(Ham_RemovePlayerItem, iPlayer, iEntity)
	ExecuteHamB(Ham_Item_Kill, iEntity)
	set_pev(iPlayer, pev_weapons, pev(iPlayer, pev_weapons) & ~(1<<get_pdata_int(iEntity, 43, 4)))
	
	bEntity = fm_give_item(TeamMate, "weapon_flashbang")
	set_pev(bEntity, pev_weapons, ANTIDOTESKEY)
	
	new netname[32]
	pev(iPlayer, pev_netname, netname, charsmax(netname))
	zr_print_chat(TeamMate, BLUECHAT, "%s赠送了一支%s给你!", netname, AntidotesName)
	pev(TeamMate, pev_netname, netname, charsmax(netname))
	zr_print_chat(iPlayer, BLUECHAT, "你赠送了一支%s给%s", AntidotesName, netname)
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage")
}

stock fm_give_item(iPlayer, const wEntity[])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, wEntity))
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	set_pev(iEntity, pev_origin, origin)
	set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, iEntity)
	new save = pev(iEntity, pev_solid)
	dllfunc(DLLFunc_Touch, iEntity, iPlayer)
	if(pev(iEntity, pev_solid) != save)
	return iEntity
	engfunc(EngFunc_RemoveEntity, iEntity)
	return -1
}

stock SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, iPlayer)
	write_byte(iAnim)
	write_byte(1)
	message_end()
}