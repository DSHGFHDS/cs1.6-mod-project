/* 本插件由 AMXX-Studio 中文版自动生成*/
/* UTF-8 func by www.DT-Club.net */
#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGINNAME		"【ZR】进化基因"
#define VERSION			"1.0"
#define AUTHOR			"Fly"

new BuyBoss
new const ItemCost = 10000
new const ItemName[] = "进化基因"

public plugin_init()
{
	register_plugin(PLUGINNAME, VERSION, AUTHOR)
	static ItemInfo[64]
	formatex(ItemInfo, charsmax(ItemInfo), "%s %d$", ItemName, ItemCost)
	BuyBoss = zr_register_item(ItemInfo, ZOMBIE, 4)
}

public zr_item_event(iPlayer, item, Slot)
{
	if(item != BuyBoss)
	return
	
	new money = zr_get_user_money(iPlayer)
	if(money < ItemCost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金币!")
	return
	}
	
	if(zr_is_zombie_boss(zr_get_zombie_id(iPlayer)))
	{
	zr_print_chat(iPlayer, GREYCHAT, "你已经是BOSS,无法购买!")
	return
	}
	
	new Amount, boss[64]
	for(new i = 1; i <= zr_get_zombie_amount(); i ++)
	{
	new Type = zr_sequence_to_id(ZOMBIE, i)
	if(!zr_is_zombie_boss(Type) || zr_is_zombie_hidden(Type))
	continue
	
	Amount ++
	boss[Amount] = Type
	}
	
	if(!Amount)
	{
	zr_print_chat(iPlayer, GREYCHAT, "没有BOSS基因可购买!")
	return
	}
	
	new BossId = boss[random_num(1, Amount)]
	
	new netname[64], bossname[64]
	pev(iPlayer, pev_netname, netname, charsmax(netname))
	zr_get_zombie_name(BossId, bossname, charsmax(bossname))
	
	zr_print_chat(0, GREENCHAT, "%s购买了进化基因,成为了%s", netname, bossname)
	zr_set_user_zombie(iPlayer, BossId)
	zr_set_user_money(iPlayer, money-ItemCost, true)
}