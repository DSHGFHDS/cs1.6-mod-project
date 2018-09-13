/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <aiwalker>
#include <xs>

#define PLUGIN "ZR Ai"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define AINAME "zrai"
#define MAXPOSITION 50

new const OpenCommand[] = "opensaving" //保存模式命令
new const SavePoint[] = "save_point" //保存复活点命令

new Float:MAXHULL[3] = { -16.0, -10.0, -36.0 }
new Float:MINHULL[3] = { 16.0, 10.0, 36.0 }

new Float:szOrigin[MAXPOSITION][3], PositionConst, Float:NextThink[33], HavingFile, bool:RoundBegin, modelindex, g_fwBotForwardRegister
new cvar_open, cvar_maxai, cvar_health, cvar_speed, cvar_gravity, cvar_damage, cvar_range, cvar_attackrate, cvar_money

new const HitSound[][] = { "zombieriot/claw_hit_flesh_1.wav", "zombieriot/claw_hit_flesh_2.wav", "zombieriot/claw_hit_flesh_3.wav" }
new const HurtedSound[][] = { "zombieriot/been_shot_01.wav", "zombieriot/been_shot_02.wav", "zombieriot/been_shot_03.wav", "zombieriot/been_shot_04.wav" }
new const DieSound[][] = { "zombieriot/headless_1.wav", "zombieriot/headless_2.wav", "zombieriot/headless_3.wav", "zombieriot/headless_4.wav" }

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_StartFrame, "fw_StartFrame_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage_Post", 1)
	if(zr_zbot_supported()) g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	cvar_open = register_cvar(OpenCommand, "0") //保存模式默认开关(0=关闭 1=开启)
	cvar_maxai = register_cvar("ai_max_ai", "30") //一次最多出现多少个AI
	cvar_health = register_cvar("ai_max_health", "100.0") //AI最大生命
	cvar_speed = register_cvar("ai_max_speed", "280.0") //AI最大速度
	cvar_gravity = register_cvar("ai_gravity", "1.0") //AI重力
	cvar_damage = register_cvar("ai_max_damage", "20.0") //AI最大伤害
	cvar_range = register_cvar("ai_hit_range", "48.0") //AI攻击最大范围
	cvar_attackrate = register_cvar("ai_attackrate", "1.0") //AI攻击速度
	cvar_money = register_cvar("ai_killed_money", "50") //人类杀死AI奖励的金钱
}

public plugin_precache()
{
	static szFile[256], szCfgdir[32], szMapName[32]
	global_get(glb_mapname, szMapName, charsmax(szMapName))
	get_localinfo("amxx_configsdir", szCfgdir, charsmax(szCfgdir))
	formatex(szFile, charsmax(szFile), "%s/aispawn/%s.ini", szCfgdir, szMapName)
	HavingFile = file_exists(szFile)
	if(HavingFile)
	{
	load_files(szFile)
	modelindex = engfunc(EngFunc_PrecacheModel, "models/zombieriot/zombie.mdl")
	for(new i = 0; i < sizeof HitSound; i ++) engfunc(EngFunc_PrecacheSound, HitSound[i])
	for(new i = 0; i < sizeof HurtedSound; i ++) engfunc(EngFunc_PrecacheSound, HurtedSound[i])
	for(new i = 0; i < sizeof DieSound; i ++) engfunc(EngFunc_PrecacheSound, DieSound[i])
	}
}

public load_files(files[])
{
	static linedata[512], fOrigin[3][32]
	new file = fopen(files, "rt")
	while(!feof(file))
	{
	if(PositionConst >= MAXPOSITION)
	break
	fgets(file, linedata, charsmax(linedata))
	replace(linedata, charsmax(linedata), "^n", "")
	
	if(!linedata[0] || linedata[0] == ';')
	continue
	
	parse(linedata, fOrigin[0], 31, fOrigin[1], 31, fOrigin[2], 31)
	szOrigin[PositionConst][0] = str_to_float(fOrigin[0])
	szOrigin[PositionConst][1] = str_to_float(fOrigin[1])
	szOrigin[PositionConst][2] = str_to_float(fOrigin[2])
	PositionConst ++
	}
	fclose(file)
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage_Post", 1)
}

public fw_ClientCommand(iPlayer)
{
	static szCommand[24]
	read_argv(0, szCommand, charsmax(szCommand))
	
	if(strcmp(szCommand, SavePoint) || !get_pcvar_num(cvar_open) || (pev(iPlayer, pev_flags) & FL_DUCKING))
	return FMRES_IGNORED
	
	static files[256], config[128], MapName[32]
	global_get(glb_mapname, MapName, charsmax(MapName))
	get_localinfo("amxx_configsdir", config, charsmax(config))
	formatex(files, charsmax(files), "%s/aispawn/%s.ini", config, MapName)
	
	static Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	formatex(config, charsmax(config), "%d %d %d", floatround(origin[0]), floatround(origin[1]), floatround(origin[2]))
	write_file(files, config, -1)
	zr_print_chat(0, REDCHAT, "成功保存了重生点:%s", config)
	
	return FMRES_SUPERCEDE
}

public zr_roundbegin_event(Weather) RemoveAllAi()

public zr_riotbegin_event()
{
	if(!HavingFile)
	{
	zr_print_chat(0, GREYCHAT, "此地图没有AI重生点文件!")
	return
	}
	
	RoundBegin = true
}

public zr_roundend_event(WinTeam) RoundBegin = false

public fw_StartFrame_Post()
{
	if(!RoundBegin)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(NextThink[0] > fCurTime)
	return
	
	NextThink[0] = fCurTime + 0.5
	
	if(GetAllAIAmount() >= get_pcvar_num(cvar_maxai))
	return
	
	for(new i = 0; i < PositionConst; i ++)
	{
	if(is_visible(szOrigin[i]))
	continue
	
	new iEntity = CreateAi(szOrigin[i], AINAME, modelindex, MAXHULL, MINHULL, get_pcvar_float(cvar_health), get_pcvar_float(cvar_speed), get_pcvar_float(cvar_gravity), get_pcvar_float(cvar_damage), get_pcvar_float(cvar_range), get_pcvar_float(cvar_attackrate), 0.2, 2.0, ZOMBIE)
	if(is_stucked(iEntity))
	{
	engfunc(EngFunc_RemoveEntity, iEntity)
	continue
	}
	SetAiAnim(iEntity, 1, 2, 3, 4, {5, 6, 7})
	}
}

public HAM_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(victim))
	return
	
	if(!IsAi(attacker))
	return
	
	engfunc(EngFunc_EmitSound, attacker, CHAN_WEAPON, HitSound[random_num(0, sizeof HitSound - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public AI_PostHurted(iEntity, attacker, Float:damage, tracehandle, damagetype) engfunc(EngFunc_EmitSound, iEntity, CHAN_BODY, HurtedSound[random_num(0, sizeof HurtedSound - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

public AI_PostKilled(iEntity, killer)
{
	engfunc(EngFunc_EmitSound, iEntity, CHAN_BODY, DieSound[random_num(0, sizeof DieSound - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	if(!is_user_alive(killer))
	return
	
	if(zr_is_user_zombie(killer))
	return
	
	zr_set_user_money(killer, zr_get_user_money(killer)+get_pcvar_num(cvar_money), 1)
}

stock bool:is_stucked(iEntity)
{
	static Float:origin[3]
	pev(iEntity, pev_origin, origin)
	
	engfunc(EngFunc_TraceHull, origin, origin, DONT_IGNORE_MONSTERS, HULL_HUMAN, iEntity, 0)
	
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
	return true
	
	return false
}

stock bool:is_visible(const Float:origin[3])
{
	new Float:start[3], Float:view_ofs[3]
	
	for(new iPlayer = 1; iPlayer < 33; iPlayer ++)
	{
	if(!is_user_alive(iPlayer))
	continue
	
	pev(iPlayer, pev_origin, start)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	engfunc(EngFunc_TraceLine, start, origin, DONT_IGNORE_MONSTERS, iPlayer, 0)
	get_tr2(0, TR_vecEndPos, start)
	if(xs_vec_equal(start, origin))
	return true
	}
	
	return false
}