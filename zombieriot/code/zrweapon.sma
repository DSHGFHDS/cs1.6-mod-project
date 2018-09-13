/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>

#define PLUGIN "Zr Weapon"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const g_szGameWeaponAmmoTypeName[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "",
	"57mm" }

new const PrimaryName[][] = { "GALIL步枪", "FAMAS步枪", "M4A1卡宾枪", "AK47步枪", "SG552步枪", "AUG步枪", "SCOUT轻型狙击枪","M3单发散弹枪", "XM1014连发散弹枪", "TMP微型冲锋枪", "MAC10微型冲锋枪", "UMP45微型冲锋枪", "MP5微型冲锋枪", "P90微型冲锋枪", "SG550步枪", "AWP狙击枪", "G3SG1步枪", "M249机关枪" }
new const PrimaryCost[] = { 1450, 1450, 1500, 1550, 1650, 1650, 1500, 1800, 1900, 1300, 1300, 1250, 1350, 1400, 2500, 2500, 2500, 8000 }
new const PrimaryAmmo[] = { 180, 180, 180, 180, 180, 180, 90, 150, 180, 240, 240, 240, 240, 240, 180, 80, 180, 200 }
new const SecondaryName[][] = { "GLOCK18手枪", "USP手枪", "P228手枪", "沙漠之鹰", "FIVESEVEN手枪", "ELITE手枪" }
new const SecondaryCost[] = { 400, 550, 600, 900, 700, 800 }
new const SecondaryAmmo[] = { 240, 180, 240, 90, 240, 240 }

new const PrimaryEntity[][] = { "weapon_galil", "weapon_famas", "weapon_m4a1", "weapon_ak47", "weapon_sg552", "weapon_aug", "weapon_scout", "weapon_m3", "weapon_xm1014", "weapon_tmp", "weapon_mac10", "weapon_ump45", "weapon_mp5navy", "weapon_p90", "weapon_sg550", "weapon_awp", "weapon_g3sg1", "weapon_m249" }
new const SecondaryEntity[][] = { "weapon_glock18", "weapon_usp", "weapon_p228", "weapon_deagle", "weapon_fiveseven", "weapon_elite" }
new const GrenadeEntity[][] = { "weapon_hegrenade", "weapon_flashbang", "weapon_smokegrenade" }
new const GrenadeMax[] = { 1, 2, 1 }
new const EquipmentName[][] = { "防护服", "夜视仪", "手榴弹", "闪光弹", "急冻弹" }
new const Float:huamnarmor = 100.0
new const EquipmentCost[] = { 100, 2500, 800, 500, 1400 }
new const ClipName[][] = { "主弹夹", "副弹夹" }
new const ClipCost[] = { 1200, 1000 }

new Float:BOTThink[33]
new PrimaryId[18], SecondaryId[6], EquipmentId[5], ClipId[2]
new cvar_time
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	static weaponname[64]
	for(new i = 0; i < sizeof PrimaryName; i ++)
	{
	formatex(weaponname, charsmax(weaponname), "%s %d$", PrimaryName[i], PrimaryCost[i])
	PrimaryId[i] = zr_register_item(weaponname, HUMAN, 1)
	}
	for(new i = 0; i < sizeof SecondaryName; i ++)
	{
	formatex(weaponname, charsmax(weaponname), "%s %d$", SecondaryName[i], SecondaryCost[i])
	SecondaryId[i] = zr_register_item(weaponname, HUMAN, 2)
	}
	for(new i = 0; i < sizeof ClipName; i ++)
	{
	formatex(weaponname, charsmax(weaponname), "%s %d$", ClipName[i], ClipCost[i])
	ClipId[i] = zr_register_item(weaponname, HUMAN, 3)
	}
	for(new i = 0; i < sizeof EquipmentName; i ++)
	{
	formatex(weaponname, charsmax(weaponname), "%s %d$", EquipmentName[i], EquipmentCost[i])
	EquipmentId[i] = zr_register_item(weaponname, HUMAN, 3)
	}
	cvar_time = register_cvar("zrweapon_time", "60.0")	//武器在地上停留的时间
}

public fw_SetModel(iEntity, szModel[])
{
	if(strlen(szModel) < 8)
	return FMRES_IGNORED
	
	if(szModel[7] != 'w' || szModel[8] != '_')
	return FMRES_IGNORED
	
	static classname[32]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "weaponbox"))
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_nextthink, get_gametime()+get_pcvar_float(cvar_time))
	
	return FMRES_IGNORED
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(!is_user_bot(iPlayer))
	return
	
	if(zr_is_user_zombie(iPlayer))
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(BOTThink[iPlayer] > fCurTime)
	return
	
	zr_set_user_item(iPlayer, ClipId[0])
	zr_set_user_item(iPlayer, ClipId[1])
	
	new money = zr_get_user_money(iPlayer)
	new BuyWeapon[19], itemconst
	
	if(!pev_valid(get_pdata_cbase(iPlayer, 368, 4)))
	{
	for(new i = 0; i < sizeof PrimaryCost; i ++)
	{
	if(money < PrimaryCost[i])
	continue
	
	itemconst ++
	BuyWeapon[itemconst] = PrimaryId[i]
	}
	if(itemconst) zr_set_user_item(iPlayer, BuyWeapon[random_num(1, itemconst)])
	}
	
	if(!pev_valid(get_pdata_cbase(iPlayer, 369, 4)))
	{
	itemconst = 0
	for(new i = 0; i < sizeof SecondaryCost; i ++)
	{
	if(money < SecondaryCost[i])
	continue
	
	itemconst ++
	BuyWeapon[itemconst] = SecondaryId[i]
	}
	if(itemconst) zr_set_user_item(iPlayer, BuyWeapon[random_num(1, itemconst)])
	}
	
	new Float:armor
	pev(iPlayer, pev_armorvalue, armor)
	if(armor <= 0.0) zr_set_user_item(iPlayer, EquipmentId[0])
	
	BOTThink[iPlayer] = fCurTime + random_float(4.0, 6.0)
}

public zr_being_human(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	BOTThink[iPlayer] = get_gametime() + random_float(10.0, 15.0)
	
	new money = zr_get_user_money(iPlayer)
	new BuyWeapon[19], itemconst
	for(new i = 0; i < sizeof PrimaryCost; i ++)
	{
	if(money < PrimaryCost[i])
	continue
	
	itemconst ++
	BuyWeapon[itemconst] = PrimaryId[i]
	}
	if(itemconst) zr_set_user_item(iPlayer, BuyWeapon[random_num(1, itemconst)])
	
	itemconst = 0
	for(new i = 0; i < sizeof SecondaryCost; i ++)
	{
	if(money < SecondaryCost[i])
	continue
	
	itemconst ++
	BuyWeapon[itemconst] = SecondaryId[i]
	}
	
	if(itemconst) zr_set_user_item(iPlayer, BuyWeapon[random_num(1, itemconst)])
	
	zr_set_user_item(iPlayer, EquipmentId[0])
	zr_set_user_item(iPlayer, EquipmentId[2])
}

public zr_item_event(iPlayer, item, Slot)
{
	new money = zr_get_user_money(iPlayer)
	if(Slot == 1)
	{
	for(new i = 0; i < sizeof PrimaryName; i ++)
	{
	if(item != PrimaryId[i])
	continue
	
	if(money < PrimaryCost[i])
	{
	client_print(iPlayer, print_center, "没有足够的金钱!")
	break
	}
	
	DropWeapons(iPlayer, 1)
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一把%s!", PrimaryName[i])
	zr_set_user_money(iPlayer, money-PrimaryCost[i], 1)
	new iEntity = fm_give_item(iPlayer, PrimaryEntity[i])
	if(iEntity > 0) ExecuteHamB(Ham_GiveAmmo, iPlayer, PrimaryAmmo[i], g_szGameWeaponAmmoTypeName[get_pdata_int(iEntity, 43, 4)], PrimaryAmmo[i])
	break
	}
	return
	}
	
	if(Slot == 2)
	{
	for(new i = 0; i < sizeof SecondaryName; i ++)
	{
	if(item != SecondaryId[i])
	continue
	
	if(money < SecondaryCost[i])
	{
	client_print(iPlayer, print_center, "没有足够的金钱!")
	break
	}
	
	DropWeapons(iPlayer, 2)
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一把%s!", SecondaryName[i])
	zr_set_user_money(iPlayer, money-SecondaryCost[i], 1)
	new iEntity = fm_give_item(iPlayer, SecondaryEntity[i])
	if(iEntity > 0) ExecuteHamB(Ham_GiveAmmo, iPlayer, SecondaryAmmo[i], g_szGameWeaponAmmoTypeName[get_pdata_int(iEntity, 43, 4)], SecondaryAmmo[i])
	break
	}
	return
	}
	
	if(item == ClipId[0])
	{
	if(money < ClipCost[0])
	{
	client_print(iPlayer, print_center, "没有足够的金钱!")
	return
	}
	new iEntity = -1, bool:BeGiven
	for(new i = 0; i < sizeof PrimaryName; i ++)
	{
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", PrimaryEntity[i])))
	{
	if(pev(iEntity, pev_owner) != iPlayer)
	continue
	
	if(get_pdata_int(iPlayer, 376+get_pdata_int(iEntity, 49, 4) , 4) >= PrimaryAmmo[i])
	continue
	
	ExecuteHamB(Ham_GiveAmmo, iPlayer, PrimaryAmmo[i], g_szGameWeaponAmmoTypeName[get_pdata_int(iEntity, 43, 4)], PrimaryAmmo[i])
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 1, PITCH_NORM)
	BeGiven = true
	}
	}
	if(!BeGiven)
	{
	client_print(iPlayer, print_center, "无需补充主弹夹!")
	return
	}
	zr_set_user_money(iPlayer, money-ClipCost[0], 1)
	zr_print_chat(iPlayer, BLUECHAT, "主武器弹夹已补充满!")
	return
	}
	
	if(item == ClipId[1])
	{
	if(money < ClipCost[1])
	{
	client_print(iPlayer, print_center, "没有足够的金钱!")
	return
	}
	new iEntity = -1, bool:BeGiven
	for(new i = 0; i < sizeof SecondaryName; i ++)
	{
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", SecondaryEntity[i])))
	{
	if(pev(iEntity, pev_owner) != iPlayer)
	continue
	
	if(get_pdata_int(iPlayer, 376+get_pdata_int(iEntity, 49, 4) , 4) >= SecondaryAmmo[i])
	continue
	
	ExecuteHamB(Ham_GiveAmmo, iPlayer, SecondaryAmmo[i], g_szGameWeaponAmmoTypeName[get_pdata_int(iEntity, 43, 4)], SecondaryAmmo[i])
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 1, PITCH_NORM)
	BeGiven = true
	}
	}
	if(!BeGiven)
	{
	client_print(iPlayer, print_center, "无需补充副弹夹!")
	return
	}
	zr_set_user_money(iPlayer, money-ClipCost[1], 1)
	zr_print_chat(iPlayer, GREENCHAT, "副武器弹夹已补充满!")
	return
	}
	
	if(item == EquipmentId[0])
	{
	if(money < EquipmentCost[0])
	{
	client_print(iPlayer, print_center, "没有足够的金钱!")
	return
	}
	new Float:armorvalue, Float:MaxArmorValue = zr_get_human_health(zr_get_human_id(iPlayer))
	pev(iPlayer, pev_armorvalue, armorvalue)
	if(armorvalue >= MaxArmorValue)
	{
	zr_print_chat(iPlayer, REDCHAT, "%s已满,不能再购买!", EquipmentName[0])
	return
	}
	zr_print_chat(iPlayer, REDCHAT, "你购买了%d%s", floatround(huamnarmor), EquipmentName[0])
	zr_set_user_money(iPlayer, money-EquipmentCost[0], 1)
	set_pev(iPlayer, pev_armorvalue, floatmin(MaxArmorValue, huamnarmor+armorvalue))
	set_pdata_int(iPlayer, 112, 2, 5)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	return
	}
	
	if(item == EquipmentId[1])
	{
	if(money < EquipmentCost[1])
	{
	client_print(iPlayer, print_center, "没有足够的金钱!")
	return
	}
	
	if(get_pdata_int(iPlayer, 129, 5) & (1<<0))
	{
	zr_print_chat(iPlayer, REDCHAT, "你已经有%s了,不能再购买!", EquipmentName[1])
	return
	}
	zr_print_chat(iPlayer, REDCHAT, "你购买了一个%s!", EquipmentName[1])
	zr_set_user_money(iPlayer, money-EquipmentCost[1], 1)
	set_pdata_int(iPlayer, 129, get_pdata_int(iPlayer, 129, 5)|(1<<0), 5)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	return
	}
	
	for(new i = 2; i < 5; i ++)
	{
	if(item != EquipmentId[i])
	continue
	
	if(money < EquipmentCost[i])
	{
	client_print(iPlayer, print_center, "没有足够的金钱!")
	break
	}
	
	new iEntity = - 1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", GrenadeEntity[i-2])))
	{
	if(pev(iEntity, pev_owner) != iPlayer)
	continue
	
	if(get_pdata_int(iPlayer, 376+get_pdata_int(iEntity, 49, 4), 4) < GrenadeMax[i-2])
	continue
	
	zr_print_chat(iPlayer, REDCHAT, "%s已满,不能再购买了!", EquipmentName[i])
	return
	}
	
	zr_print_chat(iPlayer, REDCHAT, "你购买了一个%s!", EquipmentName[i])
	zr_set_user_money(iPlayer, money-EquipmentCost[i], 1)
	fm_give_item(iPlayer, GrenadeEntity[i-2])
	break
	}
}

stock DropWeapons(iPlayer, Slot)
{
	new item = get_pdata_cbase(iPlayer, 367+Slot, 4)
	while(item > 0)
	{
	static classname[24]
	pev(item, pev_classname, classname, charsmax(classname))
	engclient_cmd(iPlayer, "drop", classname)
	item = get_pdata_cbase(item, 42, 5)
	}
	set_pdata_cbase(iPlayer, 367, -1, 4)
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