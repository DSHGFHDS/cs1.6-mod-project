/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Painpills"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define PAINPILLSKEY 321564 

new const online = 1					//是否让客户端下载声音文件(开服请开启)

new const PainpillsName[] = "止痛药"	//物品名称
new const PainpillsCost = 5000			//物品价格
new const models[][] = { "models/zombieriot/v_painpills.mdl", "models/zombieriot/x_painpills.mdl" }
new const sounds[][] = { "weapons/pills_deploy_1.wav", "weapons/pills_use_1.wav" }
new PainpillsId
new cvar_health, cvar_distance

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	static PainpillsInfo[64]
	formatex(PainpillsInfo, charsmax(PainpillsInfo), "%s %d$", PainpillsName, PainpillsCost)
	PainpillsId = zr_register_item(PainpillsInfo, HUMAN, 3)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_smokegrenade", "HAM_Weapon_PrimaryAttack")
	RegisterHam(Ham_Item_PostFrame, "weapon_smokegrenade", "HAM_Item_PostFrame")
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "HAM_ItemDeploy_Post", 1)
	RegisterHam(Ham_Item_Holster, "weapon_smokegrenade", "HAM_ItemHolster_Post", 1)
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	cvar_health = register_cvar("painpills_add_health", "1000.0")			//服用恢复血量
	cvar_distance = register_cvar("painpills_giveaway_distance", "60.0")	//赠送队友的距离
}

public plugin_precache()
{
	for(new i = 0; i < 2; i ++)
	{
	engfunc(EngFunc_PrecacheModel, models[i])
	if(online) engfunc(EngFunc_PrecacheSound, sounds[i])
	}
}

public zr_item_event(iPlayer, item, Slot)
{
	if(item != PainpillsId)
	return
	
	new money = zr_get_user_money(iPlayer)
	
	if(money < PainpillsCost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金钱无法购买!")
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
	
	zr_set_user_money(iPlayer, money-PainpillsCost, 1)
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一瓶%s!", PainpillsName)
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
	
	engfunc(EngFunc_RemoveEntity, iEntity)
	
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
	client_print(iPlayer, print_center, "生命值已满,无法使用!")
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
	
	new button = pev(iPlayer, pev_button)
	if(button & IN_ATTACK2)
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
	
	new Float:health, Float:maxhealth
	pev(iPlayer, pev_health, health)
	maxhealth = floatmin(get_pcvar_float(cvar_health)+health, zr_get_human_health(zr_get_human_id(iPlayer)))
	set_pev(iPlayer, pev_health, maxhealth)
	zr_print_chat(iPlayer, BLUECHAT, "恢复了%d点生命!", floatround(maxhealth-health))
	
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
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, iPlayer)
	write_byte(iAnim)
	write_byte(1)
	message_end()
}