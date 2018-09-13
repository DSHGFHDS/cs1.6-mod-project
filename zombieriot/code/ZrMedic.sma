/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Medic"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS & REX"
#define PAINPILLSKEY 321564 

new const online = 1	//是否让客户端下载声音文件(开服请开启)

new const PainpillsName[] = "止痛药"	//物品名称
new const PainpillsCost = 5000				//物品价格
new const models[][] = { "models/zombieriot/v_painpills.mdl", "models/zombieriot/x_painpills.mdl" }
new const sounds[][] = { "weapons/pills_deploy_1.wav", "weapons/pills_use_1.wav", "zombieriot/healsound.wav"}
new PainpillsId, HealSPR
new bool:HealSkill[33], Float:NextThink[33]
new cvar_health, cvar_distance, cvar_heal, cvar_range, cvar_cooldown, cvar_botheal

new const MedicID = 2		//医疗兵ID

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_smokegrenade", "HAM_Weapon_PrimaryAttack")
	RegisterHam(Ham_Item_PostFrame, "weapon_smokegrenade", "HAM_Item_PostFrame")
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "HAM_ItemDeploy_Post", 1)
	RegisterHam(Ham_Item_Holster, "weapon_smokegrenade", "HAM_ItemHolster_Post", 1)
	static PainpillsInfo[64]
	formatex(PainpillsInfo, charsmax(PainpillsInfo), "%s %d$", PainpillsName, PainpillsCost)
	PainpillsId = zr_register_item(PainpillsInfo, HUMAN, 4)
	cvar_health = register_cvar("painpills_recover_health", "0.85")			//服用恢复血量百分比
	cvar_distance = register_cvar("painpills_giveaway_distance", "60.0")	//赠送队友的距离
	cvar_heal = register_cvar("zr_medic_healtimes", "0.2")					//恢复生命的倍数
	cvar_range = register_cvar("zr_medic_range", "350.0")					//恢复生命的范围
	cvar_cooldown = register_cvar("zr_medic_cooldown", "25.0")				//技能冷却时间
	cvar_botheal = register_cvar("zr_medic_bot_heal", "0.5")				//BOT在多少倍血时使用技能
}

public plugin_precache()
{
	for(new i = 0; i < 2; i ++) engfunc(EngFunc_PrecacheModel, models[i])
	if(online) for(new i = 0; i < 3; i ++) engfunc(EngFunc_PrecacheSound, sounds[i])
	HealSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/heal.spr")
}

public fw_CmdStart(iPlayer, uc_handle, seed)
{
	if(zr_is_user_zombie(iPlayer))
	return FMRES_IGNORED
	
	if(zr_get_human_id(iPlayer) != MedicID)
	return FMRES_IGNORED
	
	if(get_uc(uc_handle, UC_Impulse) != 201)
	return FMRES_IGNORED
	
	if(HealSkill[iPlayer])
	{
	zr_print_chat(iPlayer, GREYCHAT, "治疗技能正在冷却!")
	return FMRES_IGNORED
	}
	
	Healing(iPlayer)
	set_uc(uc_handle, UC_Impulse, 0)
	
	return FMRES_IGNORED
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(zr_is_user_zombie(iPlayer))
	return
	
	if(zr_get_human_id(iPlayer) != MedicID)
	return
	
	if(HealSkill[iPlayer])
	{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	if(NextThink[iPlayer] > fCurTime)
	return
	
	HealSkill[iPlayer] = false
	zr_print_chat(iPlayer, BLUECHAT, "治疗技能冷却完毕!")
	}
	
	if(!is_user_bot(iPlayer))
	return 
	
	new Float:health
	pev(iPlayer, pev_health, health)
	if(health > zr_get_human_health(MedicID)*get_pcvar_float(cvar_botheal))
	return
	
	Healing(iPlayer)
}

public Healing(iPlayer)
{
	new Float:health, Float:MaxHealth, Float:origin[2][3], netname[33], bool:Valve
	pev(iPlayer, pev_netname, netname, charsmax(netname))
	pev(iPlayer, pev_origin, origin[0])
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	if(zr_is_user_zombie(i))
	continue
	
	pev(i, pev_origin, origin[1])
	if(get_distance_f(origin[0], origin[1]) > get_pcvar_float(cvar_range))
	continue
	
	pev(i, pev_health, health)
	MaxHealth = zr_get_human_health(zr_get_human_id(i))
	
	if(health >= MaxHealth)
	continue
	
	MaxHealth = floatmin(health+MaxHealth*get_pcvar_float(cvar_heal), MaxHealth)
	set_pev(i, pev_health, MaxHealth)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin[1], 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[1][0])
	engfunc(EngFunc_WriteCoord, origin[1][1])
	engfunc(EngFunc_WriteCoord, origin[1][2])
	write_short(HealSPR)
	write_byte(15)
	write_byte(255)
	message_end()
	Valve = true
	
	if(i == iPlayer)
	continue
	
	zr_print_chat(i, BLUECHAT, "[%s]使用了治疗技能!", netname)
	}
	
	if(!Valve)
	{
	zr_print_chat(iPlayer, GREYCHAT, "目前不需要使用治疗技能!")
	return
	}
	
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, sounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	NextThink[iPlayer] = fCurTime + get_pcvar_float(cvar_cooldown)
	HealSkill[iPlayer] = true
}

public Event_CurWeapon(iPlayer)
{
	if(zr_is_user_zombie(iPlayer))
	return PLUGIN_CONTINUE
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(pev(iEntity, pev_weapons) != PAINPILLSKEY)
	return PLUGIN_CONTINUE
	
	set_pev(iPlayer, pev_viewmodel2, models[0])
	set_pev(iPlayer, pev_weaponmodel2, models[1])
	
	return PLUGIN_CONTINUE
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
	
	if(pev(iEntity2, pev_weapons) != PAINPILLSKEY)
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_flags, FL_KILLME)
	
	return FMRES_SUPERCEDE
}

public HAM_Weapon_PrimaryAttack(iEntity)
{
	if(pev(iEntity, pev_weapons) != PAINPILLSKEY)
	return HAM_IGNORED
	
	if(pev(iEntity, pev_iuser2) == PAINPILLSKEY)
	return HAM_SUPERCEDE
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	new Float:health
	pev(iPlayer, pev_health, health)
	if(health >= zr_get_human_health(zr_get_human_id(iPlayer)))
	{
	client_print(iPlayer, print_center, "已达到最大恢复量!")
	return HAM_SUPERCEDE
	}
	
	set_pdata_float(iEntity, 46, 0.4, 4)
	set_pdata_float(iEntity, 47, 0.4, 4)
	set_pdata_float(iEntity, 48, 0.4, 4)
	set_pev(iEntity, pev_iuser2, PAINPILLSKEY)
	SendWeaponAnim(iPlayer, 2)
	
	return HAM_SUPERCEDE
}

public HAM_Item_PostFrame(iEntity)
{
	if(pev(iEntity, pev_weapons) != PAINPILLSKEY)
	return HAM_IGNORED
	
	if(get_pdata_float(iEntity, 47, 4) > 0.0)
	return HAM_IGNORED
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(get_pdata_int(iPlayer, 246, 5) & IN_ATTACK2)
	{
	GiveAwayPainpills(iPlayer, iEntity)
	return HAM_IGNORED
	}
	
	if(pev(iEntity, pev_iuser2) != PAINPILLSKEY)
	return HAM_IGNORED
	
	ExecuteHamB(Ham_Weapon_RetireWeapon, iEntity)
	ExecuteHamB(Ham_RemovePlayerItem, iPlayer, iEntity)
	ExecuteHamB(Ham_Item_Kill, iEntity)
	set_pev(iPlayer, pev_weapons, pev(iPlayer, pev_weapons) & ~(1<<get_pdata_int(iEntity, 43, 4)))
	
	new Float:health, Float:Recoverhealth = zr_get_human_health(zr_get_human_id(iPlayer))*get_pcvar_float(cvar_health)
	pev(iPlayer, pev_health, health)
	set_pev(iPlayer, pev_health, floatmax(health, Recoverhealth))
	zr_print_chat(iPlayer, BLUECHAT, "已恢复到%d %的生命!", floatround(get_pcvar_float(cvar_health)*100.0))
	
	return HAM_SUPERCEDE
}

public HAM_ItemDeploy_Post(iEntity)
{
	if(pev(iEntity, pev_weapons) != PAINPILLSKEY)
	return
	
	set_pev(iEntity, pev_iuser2, 0)
}

public HAM_ItemHolster_Post(iEntity)
{
	if(pev(iEntity, pev_weapons) != PAINPILLSKEY)
	return
	
	set_pev(iEntity, pev_iuser2, 0)
}

public fw_UpdateClientData_Post(iPlayer, iSendWeapon, CD_Handle)
{
	if(get_cd(CD_Handle, CD_DeadFlag) != DEAD_NO)
	return
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	
	if(iEntity <= 0)
	return
	
	if(pev(iEntity, pev_weapons) != PAINPILLSKEY)
	return
	
	set_cd(CD_Handle, CD_iUser3, 0)
}

public GiveAwayPainpills(iPlayer, iEntity)
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
	while((bEntity = engfunc(EngFunc_FindEntityByString, bEntity, "classname", "weapon_smokegrenade")) != 0)
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
	
	bEntity = fm_give_item(TeamMate, "weapon_smokegrenade")
	set_pev(bEntity, pev_weapons, PAINPILLSKEY)
	
	new netname[32]
	pev(iPlayer, pev_netname, netname, charsmax(netname))
	zr_print_chat(TeamMate, BLUECHAT, "%s赠送了一瓶%s给你!", netname, PainpillsName)
	pev(TeamMate, pev_netname, netname, charsmax(netname))
	zr_print_chat(iPlayer, BLUECHAT, "你赠送了一瓶%s给%s", PainpillsName, netname)
}

public zr_item_event(iPlayer, item, Slot)
{
	if(item != PainpillsId)
	return
	
	if(zr_get_human_id(iPlayer) != MedicID)
	{
	zr_print_chat(iPlayer, GREYCHAT, "只有医疗兵能够购买!")
	return
	}
	
	new money = zr_get_user_money(iPlayer)
	
	if(money < PainpillsCost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金币无法购买!")
	return
	}
	
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "weapon_smokegrenade")) != 0)
	{
	if(pev(iEntity, pev_owner) != iPlayer)
	continue
	
	zr_print_chat(iPlayer, GREYCHAT, "装备栏已满!")
	return
	}
	
	iEntity = fm_give_item(iPlayer, "weapon_smokegrenade")
	set_pev(iEntity, pev_weapons, PAINPILLSKEY)
	
	zr_set_user_money(iPlayer, money-PainpillsCost, true)
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一瓶%s!", PainpillsName)
}

public zr_being_human(iPlayer)
{
	if(zr_get_human_id(iPlayer) != MedicID)
	return
	
	new iEntity = fm_give_item(iPlayer, "weapon_smokegrenade")
	
	if(!pev_valid(iEntity))
	return
	
	set_pev(iEntity, pev_weapons, PAINPILLSKEY)
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