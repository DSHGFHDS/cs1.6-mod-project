/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGIN "Zr Menu"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new MainMenuWords[33], BuyMenu[5][33], ZombieMenu[32], HumanMenu[32], ChangeTeanMenu[33], AdminMenu[64], MotdMenu[64], AdminChangeTeam[64], AdminChangeGhost[64], AdminResetRound[64], TeamListWords[64], GhostListWords[64], ClientMark[3][64]
new AddMenuID, AddMenuName[33][64], MenuEvent, HookMenuData, g_fwDummyResult

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("chooseteam", "MainMenu")
	MenuEvent = CreateMultiForward("zr_addmenu_event", ET_IGNORE, FP_CELL, FP_CELL)
	HookMenuData = CreateMultiForward("zr_hook_menudata", ET_CONTINUE, FP_CELL, FP_STRING,  FP_STRING)
}

public plugin_natives() register_native("zr_register_menu", "native_register_menu")

public plugin_precache()
{
	static file[256], config[32]
	get_localinfo("amxx_configsdir", config, charsmax(config))
	formatex(file, charsmax(file), "%s/zrmenu.ini", config)
	if(file_exists(file)) zrmenufile(file)
}

public zrmenufile(files[])
{
	static linedata[512], key[256], value[256]
	new file = fopen(files, "rt")
	while(file && !feof(file))
	{
	fgets(file, linedata, charsmax(linedata))
	if(!linedata[0] || linedata[0] == ';' || linedata[0] == '^n')
	continue
	
	strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
	trim(key)
	trim(value)
	
	if(!strcmp(key, "主菜单")) copy(MainMenuWords, charsmax(MainMenuWords), value)
	else if(!strcmp(key, "物品菜单一")) copy(BuyMenu[1], charsmax(BuyMenu[]), value)
	else if(!strcmp(key, "物品菜单二")) copy(BuyMenu[2], charsmax(BuyMenu[]), value)
	else if(!strcmp(key, "物品菜单三")) copy(BuyMenu[3], charsmax(BuyMenu[]), value)
	else if(!strcmp(key, "物品菜单四")) copy(BuyMenu[4], charsmax(BuyMenu[]), value)
	else if(!strcmp(key, "僵尸类型菜单")) copy(ZombieMenu, charsmax(ZombieMenu), value)
	else if(!strcmp(key, "人类类型菜单")) copy(HumanMenu, charsmax(HumanMenu), value)
	else if(!strcmp(key, "更换队伍菜单")) copy(ChangeTeanMenu, charsmax(ChangeTeanMenu), value)
	else if(!strcmp(key, "管理员菜单")) copy(AdminMenu, charsmax(AdminMenu), value)
	else if(!strcmp(key, "介绍菜单")) copy(MotdMenu, charsmax(MotdMenu), value)
	else if(!strcmp(key, "管理员更换队伍")) copy(AdminChangeTeam, charsmax(AdminChangeTeam), value)
	else if(!strcmp(key, "管理员设置幽灵")) copy(AdminChangeGhost, charsmax(AdminChangeGhost), value)
	else if(!strcmp(key, "管理员重置游戏")) copy(AdminResetRound, charsmax(AdminResetRound), value)
	else if(!strcmp(key, "物品提示")) copy(ClientMark[0], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "权限提示")) copy(ClientMark[1], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "重置游戏提示")) copy(ClientMark[2], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "管理员队伍菜单")) copy(TeamListWords, charsmax(TeamListWords), value)
	else if(!strcmp(key, "管理员幽灵菜单")) copy(GhostListWords, charsmax(GhostListWords), value)
	}
	fclose(file)
}

public MainMenu(iPlayer)
{
	new menuid = menu_create(MainMenuWords, "MainMenuThouch")
	CreatMenu(menuid, BuyMenu[1], "")
	CreatMenu(menuid, BuyMenu[2], "")
	CreatMenu(menuid, BuyMenu[3], "")
	CreatMenu(menuid, BuyMenu[4], "")
	CreatMenu(menuid, ZombieMenu, "")
	CreatMenu(menuid, HumanMenu, "")
	CreatMenu(menuid, ChangeTeanMenu, "")
	CreatMenu(menuid, AdminMenu, "")
	CreatMenu(menuid, MotdMenu, "")
	for(new i = 1; i <= AddMenuID; i ++) CreatMenu(menuid, AddMenuName[i], "")
	menu_setprop(menuid, MPROP_BACKNAME, "上一页")
	menu_setprop(menuid, MPROP_NEXTNAME, "下一页")
	menu_setprop(menuid, MPROP_EXITNAME, "离开")
	menu_display(iPlayer, menuid)
	
	return PLUGIN_HANDLED
}

public MainMenuThouch(iPlayer, menuid, item)
{
	if(item == MENU_EXIT)
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	if(item-8 > 0)
	{
	ExecuteForward(MenuEvent, g_fwDummyResult, iPlayer, item-8)
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	switch(item)
	{
	case 0: ItemMenu(iPlayer, 1)
	case 1: ItemMenu(iPlayer, 2)
	case 2: ItemMenu(iPlayer, 3)
	case 3: ItemMenu(iPlayer, 4)
	case 4: ChangeZombie(iPlayer)
	case 5: ChangeHuman(iPlayer)
	case 6: client_cmd(iPlayer, "zrchangeteam")
	case 7: ShowAdminMenu(iPlayer)
	case 8: show_motd(iPlayer, "zombieriot.txt", MotdMenu)
	}
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED
}

public ItemMenu(iPlayer, menuslot)
{
	new szItemId = zr_get_item_amount()
	if(!is_user_alive(iPlayer) || !szItemId)
	return PLUGIN_CONTINUE
	
	new team = get_pdata_int(iPlayer, 114, 5)
	
	new menuid, ItemID[10]
	
	menuid = menu_create(BuyMenu[menuslot], "BuyItem")
	
	for(new i = 1 ; i <= szItemId ; i++)
	{
	if(zr_get_item_slot(i) != menuslot)
	continue
	
	new ItemTeam = zr_get_item_team(i)
	if(ItemTeam != team && ItemTeam)
	continue
	
	new ItemName[64]
	zr_get_item_name(i, ItemName, charsmax(ItemName))
	num_to_str(i, ItemID, charsmax(ItemID))
	CreatMenu(menuid, ItemName, ItemID)
	}
	
	menu_setprop(menuid, MPROP_BACKNAME, "上一页")
	menu_setprop(menuid, MPROP_NEXTNAME, "下一页")
	menu_setprop(menuid, MPROP_EXITNAME, "离开")
	menu_display(iPlayer, menuid)
	
	return PLUGIN_CONTINUE
}

public BuyItem(iPlayer, menuid, item)
{
	if(item == MENU_EXIT || !is_user_alive(iPlayer))
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}

	new command[10], name[32], access, callback
	menu_item_getinfo(menuid, item, access, command, charsmax(command), name, charsmax(name), callback)
	new ItemID = str_to_num(command)

	if(ItemID < 1 || ItemID > zr_get_item_amount())
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	new ItemTeam = zr_get_item_team(ItemID)
	if(ItemTeam != get_pdata_int(iPlayer, 114, 5) && ItemTeam)
	{
	zr_print_chat(iPlayer, GREYCHAT, ClientMark[0])
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	client_cmd(iPlayer, "zritems_%d", ItemID)
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED
}

public ChangeZombie(iPlayer)
{
	new menuid, ZombieID[10]
	
	menuid = menu_create(ZombieMenu, "ChangeZombiestyle")
	for(new i = 1 ; i <= zr_get_zombie_amount() ; i++)
	{
	new Sequence = zr_sequence_to_id(ZOMBIE, i)
	if(zr_is_zombie_boss(Sequence) || zr_is_zombie_hidden(Sequence))
	continue
	
	new ZombieName[64]
	zr_get_zombie_name(Sequence, ZombieName, charsmax(ZombieName))
	num_to_str(i, ZombieID, charsmax(ZombieID))
	CreatMenu(menuid, ZombieName, ZombieID)
	}
	menu_setprop(menuid, MPROP_BACKNAME, "上一页")
	menu_setprop(menuid, MPROP_NEXTNAME, "下一页")
	menu_setprop(menuid, MPROP_EXITNAME, "离开")
	menu_display(iPlayer, menuid)
}

public ChangeZombiestyle(iPlayer, menuid, item)
{
	if(item == MENU_EXIT)
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}

	new command[10], name[32], access, callback
	menu_item_getinfo(menuid, item, access, command, charsmax(command), name, charsmax(name), callback)
	new ZombieID = str_to_num(command)

	if(1 <= ZombieID <= zr_get_zombie_amount()) client_cmd(iPlayer, "zrzombies_%d", ZombieID)
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED
}

public ChangeHuman(iPlayer)
{
	new menuid, HumanID[10]
	
	menuid = menu_create(HumanMenu, "ChangeHumanstyle")
	for(new i = 1 ; i <= zr_get_human_amount() ; i++)
	{
	new Sequence = zr_sequence_to_id(HUMAN, i)
	if(zr_is_human_hidden(Sequence))
	continue
	
	new HumanName[64]
	zr_get_human_name(Sequence, HumanName, charsmax(HumanName))
	num_to_str(i, HumanID, charsmax(HumanID))
	CreatMenu(menuid, HumanName, HumanID)
	}
	menu_setprop(menuid, MPROP_BACKNAME, "上一页")
	menu_setprop(menuid, MPROP_NEXTNAME, "下一页")
	menu_setprop(menuid, MPROP_EXITNAME, "离开")
	menu_display(iPlayer, menuid)
}

public ChangeHumanstyle(iPlayer, menuid, item)
{
	if(item == MENU_EXIT)
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}

	new command[10], name[32], access, callback
	menu_item_getinfo(menuid, item, access, command, charsmax(command), name, charsmax(name), callback)
	new HumanID = str_to_num(command)

	if(1 <= HumanID <= zr_get_human_amount()) client_cmd(iPlayer, "zrhumans_%d", HumanID)
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED
}

public ShowAdminMenu(iPlayer)
{
	if(!zr_check_admin(iPlayer))
	{
	client_print(iPlayer, print_center, ClientMark[1])
	return
	}
	
	new menuid = menu_create(AdminMenu, "AdminMenuThouch")
	CreatMenu(menuid, AdminChangeTeam, "")
	CreatMenu(menuid, AdminChangeGhost, "")
	CreatMenu(menuid, AdminResetRound, "")
	menu_setprop(menuid, MPROP_EXITNAME, "离开")
	menu_display(iPlayer, menuid)
}

public AdminMenuThouch(iPlayer, menuid, item)
{
	if(item == MENU_EXIT || !zr_check_admin(iPlayer))
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	switch(item)
	{
	case 0: TeamList(iPlayer)
	case 1: GhostList(iPlayer)
	case 2:
	{
	zr_reset_round()
	client_print(0, print_center, ClientMark[2])
	}
	}
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED
}

public TeamList(iPlayer)
{
	if(!zr_check_admin(iPlayer))
	return
	
	new netname[64], PlayerID[3]
	new menuid = menu_create(TeamListWords, "TeamListThouch")
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i))
	continue
	
	pev(i, pev_netname, netname, charsmax(netname))
	if(zr_is_user_zombie(i)) format(netname, charsmax(netname), "%s\r[%s]", netname, ZOMBIECALLED)
	else format(netname, charsmax(netname), "%s\y[%s]", netname, HUMANCALLED)
	num_to_str(i, PlayerID, charsmax(PlayerID))
	CreatMenu(menuid, netname, PlayerID)
	}
	menu_setprop(menuid, MPROP_BACKNAME, "上一页")
	menu_setprop(menuid, MPROP_NEXTNAME, "下一页")
	menu_setprop(menuid, MPROP_EXITNAME, "离开")
	menu_display(iPlayer, menuid)
}

public TeamListThouch(iPlayer, menuid, item)
{
	if(item == MENU_EXIT || !zr_check_admin(iPlayer))
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	new command[10], name[32], access, callback
	menu_item_getinfo(menuid, item, access, command, charsmax(command), name, charsmax(name), callback)
	new PlayerID = str_to_num(command)
	
	if(!is_user_connected(PlayerID))
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	if(zr_is_user_zombie(PlayerID)) zr_set_user_human(PlayerID, 0)
	else
	{
	zr_set_user_zombie(PlayerID, -1)
	zr_set_user_ghost(PlayerID, true)
	}
	zr_check_round()
	TeamList(iPlayer)
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED
}

public GhostList(iPlayer)
{
	if(!zr_check_admin(iPlayer))
	return
	
	new netname[64], PlayerID[3]
	new menuid = menu_create(GhostListWords, "GhostListThouch")
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i))
	continue
	
	if(!zr_is_user_ghost(i) && pev(i, pev_deadflag) != DEAD_NO)
	continue
	
	if(!zr_is_user_zombie(i))
	continue
	
	pev(i, pev_netname, netname, charsmax(netname))
	if(zr_is_user_ghost(i)) format(netname, charsmax(netname), "%s\r[幽灵]", netname)
	else format(netname, charsmax(netname), "%s\y[%s]", netname, ZOMBIECALLED)
	num_to_str(i, PlayerID, charsmax(PlayerID))
	CreatMenu(menuid, netname, PlayerID)
	}
	menu_setprop(menuid, MPROP_BACKNAME, "上一页")
	menu_setprop(menuid, MPROP_NEXTNAME, "下一页")
	menu_setprop(menuid, MPROP_EXITNAME, "离开")
	menu_display(iPlayer, menuid)
}

public GhostListThouch(iPlayer, menuid, item)
{
	if(item == MENU_EXIT || !zr_check_admin(iPlayer))
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	new command[10], name[32], access, callback
	menu_item_getinfo(menuid, item, access, command, charsmax(command), name, charsmax(name), callback)
	new PlayerID = str_to_num(command)
	
	if(!is_user_connected(PlayerID) || !zr_is_user_zombie(PlayerID))
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	if(zr_is_user_ghost(PlayerID)) zr_set_user_ghost(PlayerID, false)
	else if(pev(PlayerID, pev_deadflag) == DEAD_NO) zr_set_user_ghost(PlayerID, true)
	GhostList(iPlayer)
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED
}

public CreatMenu(MenuID, const MenuName[], const MenuInfo[])
{
	ExecuteForward(HookMenuData, g_fwDummyResult, MenuID, MenuName, MenuInfo)
	if(g_fwDummyResult)
	return
	
	menu_additem(MenuID, MenuName, MenuInfo, 0)
}

public native_register_menu(iPlugin, iParams)
{
	if(AddMenuID >= 33)
	return 0
	
	AddMenuID ++
	get_string(1, AddMenuName[AddMenuID], charsmax(AddMenuName[]))
	
	return AddMenuID
}