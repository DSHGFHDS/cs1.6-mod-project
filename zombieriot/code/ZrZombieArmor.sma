/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGIN "Zr Zombie Armor"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new ArmorId
new const ArmorCost = 800						//购买费用
new const ArmorName[] = "体能护甲(一局有效)"	//物品名称
new bool:BuyArmor[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	static ArmorInfo[64]
	formatex(ArmorInfo, charsmax(ArmorInfo), "%s %d$", ArmorName, ArmorCost)
	ArmorId = zr_register_item(ArmorInfo, ZOMBIE, 3)
}

public zr_roundbegin_event(Weather) for(new i = 1; i < 33; i ++) BuyArmor[i] = false

public zr_item_event(iPlayer, item, Slot)
{
	if(item != ArmorId)
	return
	
	if(BuyArmor[iPlayer])
	{
	zr_print_chat(iPlayer, GREYCHAT, "已经购买了%s!", ArmorName)
	return
	}
	
	new money = zr_get_user_money(iPlayer)
	if(money < ArmorCost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金钱!")
	return
	}
	
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一个%s!", ArmorName)
	BuyArmor[iPlayer] = true
	set_pev(iPlayer, pev_armorvalue, zr_get_zombie_health(zr_get_zombie_id(iPlayer)))
	set_pdata_int(iPlayer, 112, 2, 5)
	zr_set_user_money(iPlayer, money-ArmorCost, 1)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public zr_being_zombie(iPlayer)
{
	if(!BuyArmor[iPlayer])
	return
	
	set_pev(iPlayer, pev_armorvalue, zr_get_zombie_health(zr_get_zombie_id(iPlayer)))
	set_pdata_int(iPlayer, 112, 2, 5)
}