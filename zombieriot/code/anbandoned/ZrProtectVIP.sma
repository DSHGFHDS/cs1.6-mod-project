/* 本插件由 AMXX-Studio 中文版自动生成*/
/* UTF-8 func by www.DT-Club.net */

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>

#define PLUGINNAME		"【ZR】保护VIP"
#define VERSION			"1.0"
#define AUTHOR			"Fly"

new cvar_random_vip, cvar_health, cvar_maxspeed, cvar_gravity

new VIPID
new const VIPmodel[] = "vip"	//VIP的身体模型

public plugin_init()
{
	register_plugin(PLUGINNAME, VERSION, AUTHOR)
	register_message(get_user_msgid("DeathMsg"), "Message_DeathMsg")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	cvar_random_vip = register_cvar("zr_vip_chance", "0.1")		//VIP局产生几率
	cvar_health = register_cvar("zr_vip_health", "2000.0")		//VIP生命
	cvar_maxspeed = register_cvar("zr_vip_maxspeed", "280.0")	//VIP最大移动速度
	cvar_gravity = register_cvar("zr_vip_gravity", "0.5")		//VIP重力
}

public plugin_precache()
{
	static model[64]
	formatex(model, charsmax(model), "models/player/%s/%s.mdl", VIPmodel, VIPmodel)
	engfunc(EngFunc_PrecacheModel, model)
}

public Message_DeathMsg(msg_id, msg_dest, msg_entity) if(VIPID && VIPID == get_msg_arg_int(2)) GameEnd()

public zr_roundbegin_event(Weather) VIPID = 0

public zr_being_zombie(iPlayer) if(iPlayer == VIPID) GameEnd()

public zr_riotbegin_event() if(random_float(0.0, 100.0) <= get_pcvar_float(cvar_random_vip)*100.0) ChooseVIP()

public fw_ClientDisconnect_Post(iPlayer) if(VIPID == iPlayer) ChooseVIP()

public ChooseVIP()
{
	new VIP[33], Amount
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	if(zr_is_user_zombie(i))
	continue
	
	Amount ++
	VIP[Amount] = i
	}
	
	if(!Amount)
	return
	
	VIPID = VIP[random_num(1, Amount)]
	set_pev(VIPID, pev_health, get_pcvar_float(cvar_health))
	set_pev(VIPID, pev_gravity, get_pcvar_float(cvar_gravity))
	engfunc(EngFunc_SetClientMaxspeed, VIPID, get_pcvar_float(cvar_maxspeed))
	set_pev(VIPID, pev_maxspeed, get_pcvar_float(cvar_maxspeed))
	set_pev(VIPID, pev_armorvalue, get_pcvar_float(cvar_health))
	set_pdata_int(VIPID, 112, 2, 5)
	zr_set_user_model(VIPID, VIPmodel)
	static netname[64]
	pev(VIPID, pev_netname, netname, charsmax(netname))
	client_print(0, print_center, "%s成为了VIP!", netname)
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
	write_byte(VIPID)
	write_byte(4)
	message_end()
}

public GameEnd()
{
	VIPID = 0
	zr_set_round_end(ZOMBIE)
	client_print(0, print_center, "VIP已死亡!")
}
