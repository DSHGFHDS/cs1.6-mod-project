/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <zrconst>

#define PLUGIN "Zombie Riot"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define TOUCHEDKEY 32145

new const g_szGameWeaponClassName[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife",
	"weapon_p90" }

new const teamname[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR"}

new const gBuyCommands[][] =
{
	"usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47",
	"galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1", "sg550", "m249", "vest", "vesthelm", "flash", "hegren",
	"sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "12gauge",
	"autoshotgun", "smg", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum", "d3au1", "krieg550",
	"buyammo1", "buyammo2", "buy", "chooseteam"
}

new const RemoveModelsPrecache[][] =
{
	"models/w_backpack.mdl",
	"models/w_thighpack.mdl",
	"models/w_kevlar.mdl",
	"models/w_shield.mdl",
	"models/w_antidote.mdl",
	"models/w_security.mdl",
	"models/w_longjump.mdl"
}

new const RemoveSoundsPrecache[][] =
{
	"items/suitcharge1.wav",
	"items/suitchargeno1.wav",
	"items/suitchargeok1.wav",
	"player/geiger6.wav",
	"player/geiger5.wav",
	"player/geiger4.wav",
	"player/geiger3.wav",
	"player/geiger2.wav",
	"player/geiger1.wav",
	"weapons/bullet_hit1.wav",
	"weapons/bullet_hit2.wav",
	"items/weapondrop1.wav",
	"weapons/generic_reload.wav",
	"buttons/bell1.wav",
	"buttons/blip1.wav",
	"buttons/blip2.wav",
	"buttons/button11.wav",
	"buttons/latchunlocked2.wav",
	"buttons/lightswitch2.wav",
	"ambience/quail1.wav",
	"events/tutor_msg.wav",
	"events/enemy_died.wav",
	"events/friend_died.wav",
	"events/task_complete.wav",
	"weapons/ak47_clipout.wav",
	"weapons/ak47_clipin.wav",
	"weapons/ak47_boltpull.wav",
	"weapons/aug_clipout.wav",
	"weapons/aug_clipin.wav",
	"weapons/aug_boltpull.wav",
	"weapons/aug_boltslap.wav",
	"weapons/aug_forearm.wav",
	"weapons/c4_click.wav",
	"weapons/c4_beep1.wav",
	"weapons/c4_beep2.wav",
	"weapons/c4_beep3.wav",
	"weapons/c4_beep4.wav",
	"weapons/c4_beep5.wav",
	"weapons/c4_explode1.wav",
	"weapons/c4_plant.wav",
	"weapons/c4_disarm.wav",
	"weapons/c4_disarmed.wav",
	"weapons/elite_reloadstart.wav",
	"weapons/elite_leftclipin.wav",
	"weapons/elite_clipout.wav",
	"weapons/elite_sliderelease.wav",
	"weapons/elite_rightclipin.wav",
	"weapons/elite_deploy.wav",
	"weapons/famas_clipout.wav",
	"weapons/famas_clipin.wav",
	"weapons/famas_boltpull.wav",
	"weapons/famas_boltslap.wav",
	"weapons/famas_forearm.wav",
	"weapons/g3sg1_slide.wav",
	"weapons/g3sg1_clipin.wav",
	"weapons/g3sg1_clipout.wav",
	"weapons/galil_clipout.wav",
	"weapons/galil_clipin.wav",
	"weapons/galil_boltpull.wav",
	"weapons/m4a1_clipin.wav",
	"weapons/m4a1_clipout.wav",
	"weapons/m4a1_boltpull.wav",
	"weapons/m4a1_deploy.wav",
	"weapons/m4a1_silencer_on.wav",
	"weapons/m4a1_silencer_off.wav",
	"weapons/m249_boxout.wav",
	"weapons/m249_boxin.wav",
	"weapons/m249_chain.wav",
	"weapons/m249_coverup.wav",
	"weapons/m249_coverdown.wav",
	"weapons/mac10_clipout.wav",
	"weapons/mac10_clipin.wav",
	"weapons/mac10_boltpull.wav",
	"weapons/mp5_clipout.wav",
	"weapons/mp5_clipin.wav",
	"weapons/mp5_slideback.wav",
	"weapons/p90_clipout.wav",
	"weapons/p90_clipin.wav",
	"weapons/p90_boltpull.wav",
	"weapons/p90_cliprelease.wav",
	"weapons/p228_clipout.wav",
	"weapons/p228_clipin.wav",
	"weapons/p228_sliderelease.wav",
	"weapons/p228_slidepull.wav",
	"weapons/scout_bolt.wav",
	"weapons/scout_clipin.wav",
	"weapons/scout_clipout.wav",
	"weapons/sg550_boltpull.wav",
	"weapons/sg550_clipin.wav",
	"weapons/sg550_clipout.wav",
	"weapons/sg552_clipout.wav",
	"weapons/sg552_clipin.wav",
	"weapons/sg552_boltpull.wav",
	"weapons/ump45_clipout.wav",
	"weapons/ump45_clipin.wav",
	"weapons/ump45_boltslap.wav",
	"weapons/usp_clipout.wav",
	"weapons/usp_clipin.wav",
	"weapons/usp_silencer_on.wav",
	"weapons/usp_silencer_off.wav",
	"weapons/usp_sliderelease.wav",
	"weapons/usp_slideback.wav"
}

new const g_remove_entities[][] = { "func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity",
		"monster_scientist", "func_hostage_rescue", "info_hostage_rescue", "env_fog", "env_rain", "env_snow", "armoury_entity" }

new const g_fog_density[] = { 0, 0, 0, 0, 111, 18, 3, 58, 111, 18, 125, 58, 66, 96, 27, 59, 90, 101, 60, 59, 90,
			101, 68, 59, 10, 41, 95, 59, 111, 18, 125, 59, 111, 18, 3, 60, 68, 116, 19, 60 }

new const lightsize[][] = { "", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "#" }

new const rainsound[][] = { "ambience/rainsound.wav", "ambience/stormrain.wav" }
new const thundersound[][] = { "ambience/thunder1.wav", "ambience/thunder2.wav", "ambience/thunder3.wav" }
new const thunderclap[][] = { "ambience/thunderflash1.wav", "ambience/thunderflash2.wav", "ambience/thunderflash3.wav", "ambience/thunderflash4.wav", "ambience/thunderflash5.wav"}
new const NvgSound[][] = { "items/nvg_off.wav", "items/nvg_on.wav"}

new g_fxbeam
new bool:ZbotSupported, bool:PrecacheTModel
new ZombieAmount, HumanAmount, ExtraZombie, ExtraHuman, ZombieIDSum, HumanIDSum
new BeginMusic[64], BeepSound[64], BeginSound[64], FirstPrompt[64], SecondPrompt[64], LastPrompt[64], ClientMark[8][64]
new Zombieslash[5][64], ZombieWall[5][64], ZombieNormal[5][64], ZombieStab[5][64], BossPain[5][64], ZombiePain[5][64], BossDie[5][64], ZombieDie[5][64], szWords[10][64], szWordsColor[6][3], GhostWillSpawn[64], GhostSpawn[64], WinSound[2][64], BeingGhost[64], ConnectionMark[2][64]
new SoundStock[8]
new Float:Playerthink[33], Float:BotThink[33], bool:ReSpawnPre[33], bool:IsGhost[33], bool:CanReSpawn[33] , Money[33], JoinTeam[33], Float:PostMaxSpeed[33], bool:DeathMSGFIX[33], bool:SetZombieFixed[33]
new BeingZombie[2][33], BeingHuman[2][33], flashing[33], bool:nvgstatus[33], bool:SoundRecord[33], Float:WeatherThink[4], ThunderLight[2], lightstyle[2], bool:CanChange[33], Float:g_vecLastEnd[33][3], Float:g_vecLastNewEnd[33][3], Float:KeepVelocity[33][2][3], bool:HookKnockBack[33], bool:SnapChange[33], bool:PointingBarrier[33], bool:Climbing[33], Float:SetModelPost[33], KeepModel[33][64]
new zr_spawn, cvar_reciprocal, cvar_ghostspeed, cvar_ghostgravity, cvar_ghostnvg[5], cvar_zombienvg[5], cvar_humannvg[5], cvar_spawndistance, cvar_winmoney, cvar_zombiegetmoney, cvar_humangetmoney, cvar_killedbossmoney, cvar_knifeaddition, cvar_headaddition, cvar_zombiehitmoney, cvar_holdTime, cvar_bosspbty, cvar_sparksize, cvar_enddeploy, cvar_humanrespawn, cvar_barrier[26], cvar_knockthreshold, cvar_gloweffect, cvar_modelindex, cvar_realfalldamage
new cvar_finish[3], cvar_botbuy, cvar_botbuytime, cvar_hedamage, cvar_hudmessage, cvar_healthhud, cvar_armorhud, cvar_linehud
new g_fwSpawn, g_fwPrecacheModel, g_fwPrecacheSound, g_fwBotForwardRegister, CurrentWeather, WeatherAmount, bool:roundended, bool:Waiting, WeatherStyle, RoundTime, Float:TimeThink, MaxTime, szPrompt, WonTeam, bool:HideAcross, bool:EscapeMode, KeepSection, SectionAmount
new szItemId
new Admins[24][3], AdminStock
new g_fwDummyResult, ItemEvent, RoundBeginEvent, RoundEndEvent, BeginRioting, BeingZombieEvent, BeingHumanEvent, BeingGhostEvent, GhostSpawnEvent, FinishEvent, ResetMaxspeedEvent, HookExchangeTeam, HookZombieSpawn, HookBalance, HookGameDisConnected, HookPlayerChangeTeam, HookRoundEnd, HookPlayerKnockBack, HookBotSetOrigin, HookVelocityCheck, HookBodyEvent, HookScreenFade, HookZombieSetSpawn, HookBecomingZombie, HookBecomingHuman, HookPrintWord
new HookHudMessage, HookLightStyle, HookFog
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

new Array:ZombieID, Array:HiddenZombie, Array:ZombieStyle, Array:ZombieMale, Array:ZombieName, Array:ZombieInfo, Array:ZombieModel, Array:ZombieVModel, Array:Zombiehealth, Array:ZombieMaxspeed, Array:ZombieGravity, Array:ZombieAttackSpeed[2], Array:ZombieAttackDist[2], Array:ZombieDamage, Array:ZombiePainFree
new Array:HumanID, Array:HiddenHuman, Array:HumanMale, Array:HumanName, Array:HumanInfo, Array:HumanModel, Array:HumanHealth, Array:HumanMaxSpeed, Array:HumanGravity, Array:HumanPainFree
new Array:Weather
new Array:szItemName, Array:ItemTeam, Array:ItemSlot

public ArrayStock()
{
	ZombieID = ArrayCreate(1, 1)
	HiddenZombie = ArrayCreate(1, 1)
	ZombieStyle = ArrayCreate(1, 1)
	ZombieMale = ArrayCreate(1, 1)
	ZombieName = ArrayCreate(64, 1)
	ZombieInfo = ArrayCreate(64, 1)
	ZombieModel = ArrayCreate(32, 1)
	ZombieVModel = ArrayCreate(32, 1)
	Zombiehealth = ArrayCreate(1, 1)
	ZombieMaxspeed = ArrayCreate(1, 1)
	ZombieGravity = ArrayCreate(1, 1)
	ZombieAttackSpeed[0] = ArrayCreate(1, 1)
	ZombieAttackSpeed[1] = ArrayCreate(1, 1)
	ZombieAttackDist[0] = ArrayCreate(1, 1)
	ZombieAttackDist[1] = ArrayCreate(1, 1)
	ZombieDamage = ArrayCreate(1, 1)
	ZombiePainFree = ArrayCreate(1, 1)
	HumanID = ArrayCreate(1, 1)
	HiddenHuman = ArrayCreate(1, 1)
	HumanMale = ArrayCreate(1, 1)
	HumanName = ArrayCreate(64, 1)
	HumanInfo = ArrayCreate(64, 1)
	HumanModel = ArrayCreate(32, 1)
	HumanHealth = ArrayCreate(1, 1)
	HumanMaxSpeed = ArrayCreate(1, 1)
	HumanGravity = ArrayCreate(1, 1)
	HumanPainFree = ArrayCreate(1, 1)
	Weather = ArrayCreate(3, 1)
	szItemName = ArrayCreate(64, 1)
	ItemTeam = ArrayCreate(1, 1)
	ItemSlot = ArrayCreate(1, 1)
}

public zombiefile(files[])
{
	static linedata[512], key[256], value[256]
	new file = fopen(files, "rt")
	while(file && !feof(file))
	{
	if(ZombieAmount >= ZOMBIEMAX)
	break
	
	fgets(file, linedata, charsmax(linedata))
	if(!linedata[0] || linedata[0] == ';' || linedata[0] == '^n')
	continue
	
	strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
	trim(key)
	trim(value)
	
	if(!strcmp(key, "ID"))
	{
	new ZID = str_to_num(value)
	static ErrorMGE[128]
	if(ZID <= 0)
	{
	formatex(ErrorMGE, charsmax(ErrorMGE), "%sID:%d注册失败,ID只能为非零正整数!", ZOMBIECALLED, ZID)
	set_fail_state(ErrorMGE)
	return
	}
	for(new i = 1; i <= ZombieAmount; i ++)
	{
	if(ZrArrayGetCell(ZombieID, i) == ZID)
	{
	formatex(ErrorMGE, charsmax(ErrorMGE), "%sID:%d注册失败,此ID已重复!", ZOMBIECALLED, ZID)
	set_fail_state(ErrorMGE)
	return
	}
	}
	ZombieAmount ++
	ArrayPushCell(ZombieID, ZID)
	ZombieIDSum += ZID
	}
	else if(!strcmp(key, "是否隐藏")) strcmp(value, "是")?ArrayPushCell(HiddenZombie, false):ArrayPushCell(HiddenZombie, true)
	else if(!strcmp(key, "类型")) strcmp(value, "BOSS")?ArrayPushCell(ZombieStyle, false):ArrayPushCell(ZombieStyle, true)
	else if(!strcmp(key, "性别")) strcmp(value, "男")?ArrayPushCell(ZombieMale, false):ArrayPushCell(ZombieMale, true)
	else if(!strcmp(key, "名称")) ArrayPushString(ZombieName, value)
	else if(!strcmp(key, "介绍")) ArrayPushString(ZombieInfo, value)
	else if(!strcmp(key, "人物模型")) ArrayPushString(ZombieModel, value)
	else if(!strcmp(key,"手臂模型")) ArrayPushString(ZombieVModel, value)
	else if(!strcmp(key, "生命")) ArrayPushCell(Zombiehealth, str_to_float(value))
	else if(!strcmp(key, "速度")) ArrayPushCell(ZombieMaxspeed, str_to_float(value))
	else if(!strcmp(key, "重量")) ArrayPushCell(ZombieGravity, str_to_float(value))
	else if(!strcmp(key, "轻击速度")) ArrayPushCell(ZombieAttackSpeed[0], str_to_float(value))
	else if(!strcmp(key, "重击速度")) ArrayPushCell(ZombieAttackSpeed[1], str_to_float(value))
	else if(!strcmp(key, "轻击范围")) ArrayPushCell(ZombieAttackDist[0], str_to_float(value))
	else if(!strcmp(key, "重击范围")) ArrayPushCell(ZombieAttackDist[1], str_to_float(value))
	else if(!strcmp(key, "攻击伤害倍数")) ArrayPushCell(ZombieDamage, str_to_float(value))
	else if(!strcmp(key, "抗击退")) ArrayPushCell(ZombiePainFree, str_to_float(value))
	}
	fclose(file)
}

public humanfile(files[])
{
	static linedata[512], key[256], value[256]
	new file = fopen(files, "rt")
	while(file && !feof(file))
	{
	if(HumanAmount >= HUMANMAX)
	break
	
	fgets(file, linedata, charsmax(linedata))
	if(!linedata[0] || linedata[0] == ';' || linedata[0] == '^n')
	continue
	
	strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
	trim(key)
	trim(value)
	
	if(!strcmp(key, "ID"))
	{
	new HID = str_to_num(value)
	static ErrorMGE[128]
	if(HID <= 0)
	{
	formatex(ErrorMGE, charsmax(ErrorMGE), "%sID:%d注册失败,ID只能为非零正整数!", HUMANCALLED, HID)
	set_fail_state(ErrorMGE)
	}
	for(new i = 1; i <= HumanAmount; i ++)
	{
	if(ZrArrayGetCell(HumanID, i) == HID)
	{
	formatex(ErrorMGE, charsmax(ErrorMGE), "%sID:%d注册失败,此ID已重复!", HUMANCALLED, HID)
	set_fail_state(ErrorMGE)
	}
	}
	HumanAmount ++
	ArrayPushCell(HumanID, HID)
	HumanIDSum += HID
	}
	else if(!strcmp(key, "是否隐藏")) strcmp(value, "是")?ArrayPushCell(HiddenHuman, false):ArrayPushCell(HiddenHuman, true)
	else if(!strcmp(key, "性别")) strcmp(value, "男")?ArrayPushCell(HumanMale, false):ArrayPushCell(HumanMale, true)
	else if(!strcmp(key, "名称")) ArrayPushString(HumanName, value)
	else if(!strcmp(key, "介绍")) ArrayPushString(HumanInfo, value)
	else if(!strcmp(key, "人物模型")) ArrayPushString(HumanModel, value)
	else if(!strcmp(key, "生命")) ArrayPushCell(HumanHealth, str_to_float(value))
	else if(!strcmp(key, "速度")) ArrayPushCell(HumanMaxSpeed, str_to_float(value))
	else if(!strcmp(key, "重量")) ArrayPushCell(HumanGravity, str_to_float(value))
	else if(!strcmp(key, "抗击退")) ArrayPushCell(HumanPainFree, str_to_float(value))
	}
	fclose(file)
}

public ambiencefile(files[])
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
	if(!strcmp(key, "亮度&天气"))
	{
	new szWeather[3]
	while(WeatherAmount < MAXWEATHER && value[0] && strtok(value, szWeather, charsmax(szWeather), value, charsmax(value), ','))
	{
	trim(szWeather)
	trim(value)
	ArrayPushString(Weather, szWeather)
	WeatherAmount ++
	}
	}
	else if(!strcmp(key, "天空贴图")) set_cvar_string("sv_skyname", value)
	}
	fclose(file)
}

public settingmenufile(files[])
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
	if(!strcmp(key, "是否支持ZBOT") && !strcmp(value, "是"))
	{
	ZbotSupported = true
	g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	}
	else if(!strcmp(key, "是否缓存玩家T模型") && !strcmp(value, "是")) PrecacheTModel = true
	else if(!strcmp(key, "隐藏僵尸准星") && !strcmp(value, "是")) HideAcross = true
	else if(!strcmp(key, "断局提示")) copy(ClientMark[0], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "自动平衡队伍(人类)")) copy(ClientMark[1], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "自动平衡队伍(僵尸)")) copy(ClientMark[2], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "换队伍提示一")) copy(ClientMark[3], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "换队伍提示二")) copy(ClientMark[4], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "换队伍提示三")) copy(ClientMark[5], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "成为BOSS提示")) copy(ClientMark[6], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "成为普通僵尸提示")) copy(ClientMark[7], charsmax(ClientMark[]), value)
	else if(!strcmp(key, "复活倒数文字")) copy(szWords[0], charsmax(szWords[]), value)
	else if(!strcmp(key, "禁止复活文字1")) copy(szWords[1], charsmax(szWords[]), value)
	else if(!strcmp(key, "禁止复活文字2")) copy(szWords[2], charsmax(szWords[]), value)
	else if(!strcmp(key, "禁止复活文字3")) copy(szWords[8], charsmax(szWords[]), value)
	else if(!strcmp(key, "允许复活文字")) copy(szWords[3], charsmax(szWords[]), value)
	else if(!strcmp(key, "复活提示文字")) copy(szWords[4], charsmax(szWords[]), value)
	else if(!strcmp(key, "更换僵尸类型提示")) copy(szWords[5], charsmax(szWords[]), value)
	else if(!strcmp(key, "更换人类类型提示")) copy(szWords[9], charsmax(szWords[]), value)
	else if(!strcmp(key, "人类胜利消息")) copy(szWords[6], charsmax(szWords[]), value)
	else if(!strcmp(key, "僵尸胜利消息")) copy(szWords[7], charsmax(szWords[]), value)
	else if(!strcmp(key, "加入提示")) copy(ConnectionMark[0], charsmax(ConnectionMark[]), value)
	else if(!strcmp(key, "离开提示")) copy(ConnectionMark[1], charsmax(ConnectionMark[]), value)
	else if(!strcmp(key, "开局音乐")) formatex(BeginMusic, charsmax(BeginMusic), "sound/zombieriot/%s", value)
	else
	if(!strcmp(key, "倒数复活文字颜色")) 
	{
	new wordscolor[5], i
	while(value[0] && strtok(value, wordscolor, charsmax(wordscolor), value, charsmax(value), ','))
	{
	trim(value)
	trim(wordscolor)
	szWordsColor[0][i] = str_to_num(wordscolor)
	i ++
	}
	}
	else
	if(!strcmp(key, "禁止复活文字颜色1")) 
	{
	new wordscolor[5], i
	while(value[0] && strtok(value, wordscolor, charsmax(wordscolor), value, charsmax(value), ','))
	{
	trim(value)
	trim(wordscolor)
	szWordsColor[1][i] = str_to_num(wordscolor)
	i ++
	}
	}
	else
	if(!strcmp(key, "禁止复活文字颜色2")) 
	{
	new wordscolor[5], i
	while(value[0] && strtok(value, wordscolor, charsmax(wordscolor), value, charsmax(value), ','))
	{
	trim(value)
	trim(wordscolor)
	szWordsColor[2][i] = str_to_num(wordscolor)
	i ++
	}
	}
	else
	if(!strcmp(key, "禁止复活文字颜色3")) 
	{
	new wordscolor[5], i
	while(value[0] && strtok(value, wordscolor, charsmax(wordscolor), value, charsmax(value), ','))
	{
	trim(value)
	trim(wordscolor)
	szWordsColor[5][i] = str_to_num(wordscolor)
	i ++
	}
	}
	else
	if(!strcmp(key, "允许复活文字颜色"))
	{
	new wordscolor[5], i
	while(value[0] && strtok(value, wordscolor, charsmax(wordscolor), value, charsmax(value), ','))
	{
	trim(value)
	trim(wordscolor)
	szWordsColor[3][i] = str_to_num(wordscolor)
	i ++
	}
	}
	else
	if(!strcmp(key, "复活提示文字颜色")) 
	{
	new wordscolor[5], i
	while(value[0] && strtok(value, wordscolor, charsmax(wordscolor), value, charsmax(value), ','))
	{
	trim(value)
	trim(wordscolor)
	szWordsColor[4][i] = str_to_num(wordscolor)
	i ++
	}
	}
	else
	if(!strcmp(key, "倒数声音") && !EscapeMode)
	{
	formatex(BeepSound, charsmax(BeepSound), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, BeepSound)
	}
	else
	if(!strcmp(key, "倒数完毕声音"))
	{
	formatex(BeginSound, charsmax(BeginSound), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, BeginSound)
	}
	else
	if(!strcmp(key, "第一次提示声音"))
	{
	formatex(FirstPrompt, charsmax(FirstPrompt), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, FirstPrompt)
	}
	else
	if(!strcmp(key, "第二次提示声音") && !EscapeMode)
	{
	formatex(SecondPrompt, charsmax(SecondPrompt), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, SecondPrompt)
	}
	else
	if(!strcmp(key, "最后提示声音") && !EscapeMode)
	{
	formatex(LastPrompt, charsmax(LastPrompt), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, LastPrompt)
	}
	else
	if(!strcmp(key, "人类胜利声音"))
	{
	formatex(WinSound[1], charsmax(WinSound[]), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, WinSound[1])
	}
	else
	if(!strcmp(key, "僵尸胜利声音"))
	{
	formatex(WinSound[0], charsmax(WinSound[]), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, WinSound[0])
	}
	else
	if(!strcmp(key, "允许复活的声音"))
	{
	formatex(GhostWillSpawn, charsmax(GhostWillSpawn), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, GhostWillSpawn)
	}
	else
	if(!strcmp(key, "已复活的声音"))
	{
	formatex(GhostSpawn, charsmax(GhostSpawn), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, GhostSpawn)
	}
	else
	if(!strcmp(key, "成为幽灵的声音"))
	{
	formatex(BeingGhost, charsmax(BeingGhost), "zombieriot/%s", value)
	engfunc(EngFunc_PrecacheSound, BeingGhost)
	}
	else
	if(!strcmp(key, "僵尸击空声"))
	{
	static sound[33]
	while(value[0] && strtok(value, Zombieslash[SoundStock[0]], charsmax(Zombieslash[]), value, charsmax(value), ','))
	{
	trim(value)
	trim(Zombieslash[SoundStock[0]])
	formatex(sound, charsmax(sound), "zombieriot/%s", Zombieslash[SoundStock[0]])
	engfunc(EngFunc_PrecacheSound, sound)
	SoundStock[0] ++
	}
	}
	else
	if(!strcmp(key, "僵尸击墙声"))
	{
	static sound[33]
	while(value[0] && strtok(value, ZombieWall[SoundStock[1]], charsmax(ZombieWall[]), value, charsmax(value), ','))
	{
	trim(value)
	trim(ZombieWall[SoundStock[1]])
	formatex(sound, charsmax(sound), "zombieriot/%s", ZombieWall[SoundStock[1]])
	engfunc(EngFunc_PrecacheSound, sound)
	SoundStock[1] ++
	}
	}
	else
	if(!strcmp(key, "僵尸轻击声音"))
	{
	static sound[33]
	while(value[0] && strtok(value, ZombieNormal[SoundStock[2]], charsmax(ZombieNormal[]), value, charsmax(value), ','))
	{
	trim(value)
	trim(ZombieNormal[SoundStock[2]])
	formatex(sound, charsmax(sound), "zombieriot/%s", ZombieNormal[SoundStock[2]])
	engfunc(EngFunc_PrecacheSound, sound)
	SoundStock[2] ++
	}
	}
	else
	if(!strcmp(key, "僵尸重击声音"))
	{
	static sound[33]
	while(value[0] && strtok(value, ZombieStab[SoundStock[3]], charsmax(ZombieStab[]), value, charsmax(value), ','))
	{
	trim(value)
	trim(ZombieStab[SoundStock[3]])
	formatex(sound, charsmax(sound), "zombieriot/%s", ZombieStab[SoundStock[3]])
	engfunc(EngFunc_PrecacheSound, sound)
	SoundStock[3] ++
	}
	}
	else
	if(!strcmp(key, "BOSS受伤声音"))
	{
	static sound[33]
	while(value[0] && strtok(value, BossPain[SoundStock[4]], charsmax(BossPain[]), value, charsmax(value), ','))
	{
	trim(value)
	trim(BossPain[SoundStock[4]])
	formatex(sound, charsmax(sound), "zombieriot/%s", BossPain[SoundStock[4]])
	engfunc(EngFunc_PrecacheSound, sound)
	SoundStock[4] ++
	}
	}
	else
	if(!strcmp(key, "僵尸受伤声音"))
	{
	static sound[33]
	while(value[0] && strtok(value, ZombiePain[SoundStock[5]], charsmax(ZombiePain[]), value, charsmax(value), ','))
	{
	trim(value)
	trim(ZombiePain[SoundStock[5]])
	formatex(sound, charsmax(sound), "zombieriot/%s", ZombiePain[SoundStock[5]])
	engfunc(EngFunc_PrecacheSound, sound)
	SoundStock[5] ++
	}
	}
	else
	if(!strcmp(key, "BOSS死亡声音"))
	{
	static sound[33]
	while(value[0] && strtok(value, BossDie[SoundStock[6]], charsmax(BossDie[]), value, charsmax(value), ','))
	{
	trim(value)
	trim(BossDie[SoundStock[6]])
	formatex(sound, charsmax(sound), "zombieriot/%s", BossDie[SoundStock[6]])
	engfunc(EngFunc_PrecacheSound, sound)
	SoundStock[6] ++
	}
	}
	else
	if(!strcmp(key, "僵尸死亡声音"))
	{
	static sound[33]
	while(value[0] && strtok(value, ZombieDie[SoundStock[7]], charsmax(ZombieDie[]), value, charsmax(value), ','))
	{
	trim(value)
	trim(ZombieDie[SoundStock[7]])
	formatex(sound, charsmax(sound), "zombieriot/%s", ZombieDie[SoundStock[7]])
	engfunc(EngFunc_PrecacheSound, sound)
	SoundStock[7] ++
	}
	}
	else
	if(!strcmp(key, "管理菜单权限"))
	{
	while(AdminStock < 24 && value[0] && strtok(value, Admins[AdminStock], charsmax(Admins[]), value, charsmax(value), ','))
	{
	trim(Admins[AdminStock])
	trim(value)
	AdminStock ++ 
	}
	}
	}
	fclose(file)
}

public plugin_precache()
{
	ArrayStock()
	static file[256], config[32]
	get_localinfo("amxx_configsdir", config, charsmax(config))
	formatex(file, charsmax(file), "%s/zombie.ini", config)
	zombiefile(file)
	formatex(file, charsmax(file), "%s/human.ini", config)
	humanfile(file)
	
	static szMapName[32]
	global_get(glb_mapname, szMapName, charsmax(szMapName))
	
	if(containi(szMapName, "zr_") != -1)
	{
	EscapeMode = true
	register_logevent("EscapeModeRest", 2, "1=Round_Start")
	register_forward(FM_TraceLine, "fw_BarrierMessage_Post", 1)
	for(new i = 1; i < sizeof g_szGameWeaponClassName; i++)
	{
	if(!g_szGameWeaponClassName[i][0] || i == CSW_KNIFE || i == CSW_HEGRENADE || i == CSW_FLASHBANG || i == CSW_SMOKEGRENADE || i == CSW_C4)
	continue
	RegisterHam(Ham_Weapon_PrimaryAttack, g_szGameWeaponClassName[i], "HAM_FIXBOTPrimaryAttack")
	}
	RegisterHam(Ham_TakeDamage, "func_breakable", "HAM_BarrierTakeDamage")
	RegisterHam(Ham_Touch, "trigger_multiple", "HAM_EscapeModeTouch_Post", 1)
	RegisterHam(Ham_Touch, "func_wall", "HAM_LadderTouch")
	RegisterHam(Ham_Use, "func_button", "HAM_ButtonUse")
	RegisterHam(Ham_Use, "func_breakable", "HAM_BarrierUsed")
	static command[33]
	for(new i = 0; i < 26; i ++)
	{
	formatex(command, charsmax(command), "zr_barrier_health_%s", lightsize[i+1])
	cvar_barrier[i] = register_cvar(command, "28.0")
	}
	}
	
	formatex(file, charsmax(file), "%s/ambience_%s.ini", config, szMapName)
	if(file_exists(file)) ambiencefile(file)
	else
	{
	formatex(file, charsmax(file), "%s/ambience.ini", config)
	ambiencefile(file)
	}
	
	if(!ZombieAmount || !HumanAmount || !WeatherAmount)
	{
	static ErrorMessage[256]
	formatex(ErrorMessage, charsmax(ErrorMessage), "%s加载失败:", MODENAME)
	if(!ZombieAmount) format(ErrorMessage, charsmax(ErrorMessage), "%s无%s类型, ", ErrorMessage, ZOMBIECALLED)
	if(!HumanAmount) format(ErrorMessage, charsmax(ErrorMessage), "%s无%s类型, ", ErrorMessage, HUMANCALLED)
	if(!WeatherAmount) format(ErrorMessage, charsmax(ErrorMessage), "%s无天气类型.", ErrorMessage)
	set_fail_state(ErrorMessage)
	}
	
	formatex(file, charsmax(file), "%s/settingmenu.ini", config)
	settingmenufile(file)
	
	static model[64]
	for(new i = 1; i <= ZombieAmount; i++)
	{
	static zModel[32], zVModel[32]
	ZrArrayGetString(ZombieModel, i, zModel, charsmax(zModel))
	formatex(model, charsmax(model), "models/player/%s/%s.mdl", zModel, zModel)
	engfunc(EngFunc_PrecacheModel, model)
	ZrArrayGetString(ZombieVModel, i, zVModel, charsmax(zVModel))
	formatex(model, charsmax(model), "models/zombieriot/%s", zVModel)
	engfunc(EngFunc_PrecacheModel, model)
	
	if(!PrecacheTModel)
	continue
	
	formatex(model, charsmax(model), "models/player/%s/%sT.mdl", zModel, zModel)
	if(!file_exists(model))
	continue
	
	engfunc(EngFunc_PrecacheModel, model)
	}
	for(new i = 1; i <= HumanAmount; i++)
	{
	static hModel[32]
	ZrArrayGetString(HumanModel, i, hModel, charsmax(hModel))
	formatex(model, charsmax(model), "models/player/%s/%s.mdl", hModel, hModel)
	engfunc(EngFunc_PrecacheModel, model)
	if(!PrecacheTModel)
	continue
	
	formatex(model, charsmax(model), "models/player/%s/%sT.mdl", hModel, hModel)
	if(!file_exists(model))
	continue
	
	engfunc(EngFunc_PrecacheModel, model)
	}
	for(new i = 0; i < sizeof thundersound; i ++) engfunc(EngFunc_PrecacheSound, thundersound[i])
	for(new i = 0; i < sizeof thunderclap; i ++) engfunc(EngFunc_PrecacheSound, thunderclap[i])
	for(new i = 0; i < sizeof rainsound; i ++) engfunc(EngFunc_PrecacheSound, rainsound[i])
	for(new i = 0; i < sizeof NvgSound; i ++) engfunc(EngFunc_PrecacheSound, NvgSound[i])
	g_fxbeam = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	g_fwPrecacheModel = register_forward(FM_PrecacheModel, "fw_PrecacheModel")
	g_fwPrecacheSound = register_forward(FM_PrecacheSound, "fw_PrecacheSound")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	set_msg_block(get_user_msgid("NVGToggle"), BLOCK_SET)
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET)
	set_msg_block(get_user_msgid("ScoreAttrib"), BLOCK_SET)
	set_msg_block(get_user_msgid("RoundTime"), BLOCK_SET)
	register_message(get_user_msgid("DeathMsg"), "Message_DeathMsg")
	register_message(get_user_msgid("ResetHUD"), "Message_ResetHUD")
	register_message(get_user_msgid("ShowMenu"), "Message_ShowMenu")
	register_message(get_user_msgid("StatusIcon"), "Message_StatusIcon")
	register_message(get_user_msgid("Money"), "Message_Money")
	register_message(get_user_msgid("AmmoPickup"), "Message_AmmoPickup")
	register_message(get_user_msgid("ScreenFade"), "Message_ScreenFade")
	register_message(get_user_msgid("SendAudio"), "Message_SendAudio")
	register_message(get_user_msgid("Health"), "Message_Health")
	register_message(get_user_msgid("Battery"), "Message_Battery")
	register_message(get_user_msgid("TextMsg"), "Message_TextMsg")
	register_message(get_user_msgid("HideWeapon"), "Message_HideWeapon")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	register_forward(FM_ClientKill, "fw_ClientKill")
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink_Post", 1)
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_EmitSound, "fw_EmitSound")
	register_forward(FM_StartFrame, "fw_StartFrame_Post", 1)
	register_forward(FM_TraceLine, "fw_TraceLine")
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	register_forward(FM_TraceHull, "fw_TraceHull")
	register_forward(FM_InfoKeyValue, "fw_InfoKeyValue")
	register_forward(FM_CreateNamedEntity, "fw_CreateNamedEntity")
	unregister_forward(FM_Spawn, g_fwSpawn)
	unregister_forward(FM_PrecacheModel, g_fwPrecacheModel)
	unregister_forward(FM_PrecacheModel, g_fwPrecacheSound)
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "HAM_Player_ResetMaxSpeed")
	RegisterHam(Ham_Touch, "weaponbox", "HAM_Touch")
	RegisterHam(Ham_Touch, "armoury_entity", "HAM_Touch")
	RegisterHam(Ham_Touch, "weapon_shield", "HAM_Touch")
	RegisterHam(Ham_Touch, "grenade", "HAM_Touch")
	RegisterHam(Ham_Touch, "player", "HAM_PlayerTouch_Post", 1)
	RegisterHam(Ham_CS_RoundRespawn, "player", "HAM_RoundRespawn")
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage_Post", 1)
	RegisterHam(Ham_Killed, "player", "HAM_Killed")
	RegisterHam(Ham_Killed, "player", "HAM_Killed_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "HAM_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "HAM_Weapon_SecondaryAttack_Post", 1)
	RegisterHam(Ham_Use, "func_tank", "HAM_UseStationary")
	RegisterHam(Ham_Use, "func_tankmortar", "HAM_UseStationary")
	RegisterHam(Ham_Use, "func_tankrocket", "HAM_UseStationary")
	RegisterHam(Ham_Use, "func_tanklaser", "HAM_UseStationary")
	for(new i = 1; i < sizeof g_szGameWeaponClassName; i++)
	{
	if(!g_szGameWeaponClassName[i][0] || i == CSW_KNIFE || i == CSW_HEGRENADE)
	continue
	RegisterHam(Ham_Item_AddToPlayer, g_szGameWeaponClassName[i], "HAM_Item_AddToPlayer")
	RegisterHam(Ham_Item_Deploy, g_szGameWeaponClassName[i], "HAM_Item_Deploy")
	}
	RoundBeginEvent = CreateMultiForward("zr_roundbegin_event", ET_IGNORE, FP_CELL)
	BeginRioting = CreateMultiForward("zr_riotbegin_event", ET_IGNORE)
	RoundEndEvent = CreateMultiForward("zr_roundend_event", ET_IGNORE, FP_CELL)
	ItemEvent = CreateMultiForward("zr_item_event", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	BeingZombieEvent = CreateMultiForward("zr_being_zombie", ET_IGNORE, FP_CELL)
	BeingHumanEvent = CreateMultiForward("zr_being_human", ET_IGNORE, FP_CELL)
	BeingGhostEvent = CreateMultiForward("zr_being_ghost", ET_IGNORE, FP_CELL)
	GhostSpawnEvent = CreateMultiForward("zr_ghost_spawn", ET_IGNORE, FP_CELL)
	FinishEvent = CreateMultiForward("zr_human_finish", ET_IGNORE, FP_CELL)
	ResetMaxspeedEvent = CreateMultiForward("zr_resetmaxspeed_event", ET_IGNORE, FP_CELL, FP_FLOAT)
	HookRoundEnd = CreateMultiForward("zr_hook_roundend", ET_CONTINUE, FP_CELL)
	HookExchangeTeam = CreateMultiForward("zr_hook_changeteam", ET_CONTINUE, FP_CELL)
	HookZombieSpawn = CreateMultiForward("zr_hook_zombiespawn", ET_CONTINUE, FP_CELL)
	HookBalance = CreateMultiForward("zr_hook_teambalance", ET_CONTINUE)
	HookGameDisConnected = CreateMultiForward("zr_hook_gamedisconnected", ET_CONTINUE)
	HookPlayerChangeTeam = CreateMultiForward("zr_hook_playerchangeteam", ET_CONTINUE, FP_CELL)
	HookPlayerKnockBack = CreateMultiForward("zr_hook_knockback", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL, FP_CELL)
	HookBotSetOrigin = CreateMultiForward("zr_hook_botsetorigin", ET_CONTINUE, FP_CELL)
	HookVelocityCheck = CreateMultiForward("zr_hook_velocitycheck", ET_CONTINUE, FP_CELL)
	HookBodyEvent = CreateMultiForward("zr_hook_spawnbody", ET_CONTINUE, FP_CELL)
	HookScreenFade = CreateMultiForward("zr_hook_screenfade", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	HookZombieSetSpawn = CreateMultiForward("zr_hook_zombiesetspawn", ET_CONTINUE, FP_CELL)
	HookBecomingZombie = CreateMultiForward("zr_being_zombie_pre", ET_CONTINUE, FP_CELL, FP_CELL)
	HookBecomingHuman = CreateMultiForward("zr_being_human_pre", ET_CONTINUE, FP_CELL, FP_CELL)
	HookPrintWord = CreateMultiForward("zr_hook_printword", ET_CONTINUE, FP_CELL, FP_STRING)
	HookHudMessage = CreateMultiForward("zr_hook_hudmessage", ET_CONTINUE, FP_CELL, FP_STRING, FP_CELL)
	HookLightStyle = CreateMultiForward("zr_hook_lightstyle", ET_CONTINUE, FP_CELL, FP_STRING)
	HookFog = CreateMultiForward("zr_hook_fog", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	cvar_enddeploy = register_cvar("zr_roundend_deploy", "4.0")				//一局结束的延迟时间
	zr_spawn = register_cvar("zr_zombie_spawn_time", "2.0")					//僵尸的复活时间
	cvar_sparksize = register_cvar("zr_spark_size", "20.0")					//闪电的大小
	cvar_reciprocal = register_cvar("zr_round_reciprocale", "15")			//僵尸暴动倒数时间(秒)
	cvar_spawndistance = register_cvar("zr_zombie_spawn_distance", "250.0")	//僵尸离人类多少距离外才能复活
	cvar_ghostspeed = register_cvar("zr_ghost_maxspeed", "320.0")			//幽灵的速度
	cvar_ghostgravity = register_cvar("zr_ghost_gravity", "0.5")			//幽灵的重力
	cvar_ghostnvg[0] = register_cvar("zr_ghost_R", "10")					//灵魂红(1-255)
	cvar_ghostnvg[1] = register_cvar("zr_ghost_G", "10")					//灵魂绿(1-255)
	cvar_ghostnvg[2] = register_cvar("zr_ghost_B", "255")					//灵魂蓝(1-255)
	cvar_ghostnvg[3] = register_cvar("zr_ghost_density", "60")				//灵魂透明度(1-255)
	cvar_ghostnvg[4] = register_cvar("zr_ghost_bright", "15")				//灵魂亮度(1-27)
	cvar_zombienvg[0] = register_cvar("zr_zombie_R", "255")					//僵尸红(1-255)
	cvar_zombienvg[1] = register_cvar("zr_zombie_G", "64")					//僵尸绿(1-255)
	cvar_zombienvg[2] = register_cvar("zr_zombie_B", "32")					//僵尸蓝(1-255)
	cvar_zombienvg[3] = register_cvar("zr_zombie_density", "60")			//僵尸透明度(1-255)
	cvar_zombienvg[4] = register_cvar("zr_zombie_bright", "15")				//僵尸亮度(1-27)
	cvar_humannvg[0] = register_cvar("zr_human_R", "0")						//人类红(1-255)
	cvar_humannvg[1] = register_cvar("zr_human_G", "255")					//人类绿(1-255)
	cvar_humannvg[2] = register_cvar("zr_human_B", "0")						//人类蓝(1-255)
	cvar_humannvg[3] = register_cvar("zr_human_density", "60")				//人类透明度(1-255)
	cvar_humannvg[4] = register_cvar("zr_human_bright", "20")				//人类亮度(1-27)
	cvar_winmoney = register_cvar("zr_winteam_money", "5000")				//胜利队伍所获得的金钱数
	cvar_zombiegetmoney = register_cvar("zr_zombie_get_money", "1000")		//僵尸杀死人类奖励的金钱数
	cvar_humangetmoney = register_cvar("zr_human_get_money", "500")			//人类杀死普通僵尸奖励的金钱数
	cvar_killedbossmoney = register_cvar("zr_killedboss_money", "2000")		//人类杀死僵尸BOSS奖励的金钱数
	cvar_knifeaddition = register_cvar("zr_knifekill_moneytimes", "2")		//人类刀杀僵尸奖励金钱倍数
	cvar_headaddition = register_cvar("zr_headkill_moneytimes", "2")		//人类爆头奖励金钱倍数(与刀杀可以有重叠效果,用刀子撸僵尸的头吧)
	cvar_zombiehitmoney = register_cvar("zr_human_hit_money", "50")			//僵尸攻击人类时得到的最大金钱数
	cvar_holdTime = register_cvar("zr_human_holdTime", "20")				//人类每局需要坚持的时间(分)
	cvar_bosspbty = register_cvar("zr_boss_probability", "0.1")				//僵尸每次复活成为BOSS的机率(0.1-1.0)
	cvar_finish[0] = register_cvar("zr_human_first_finish", "0.3")			//人类坚持到第一次提示的时间百分比(一定要比第二次的少)
	cvar_finish[1] = register_cvar("zr_human_second_finish", "0.6")			//人类坚持到第二次提示的时间百分比(一定要比最后一次的少)
	cvar_finish[2] = register_cvar("zr_human_last_finish", "0.8")			//人类坚持到最后一次提示的时间百分比(一定要第二次的少)
	cvar_humanrespawn = register_cvar("zr_respawn_to_zombie", "1")			//人类死后是否复活成僵尸(不会影响下一局的队伍平衡)
	cvar_botbuy = register_cvar("zr_bot_buy", "1")							//BOT是否随机购买物品
	cvar_botbuytime = register_cvar("zr_bot_buy_time", "150.0")				//BOT随机购买物品的时间间隔范围(非准确值,在这个数的附近)
	cvar_hedamage = register_cvar("zr_hedamage_times", "5.0")				//手雷对僵尸的伤害倍数(0.0为没改变.防止手雷成为鸡肋)
	cvar_hudmessage = register_cvar("zr_hud_message", "1")					//是否显示HUD提示文字
	cvar_healthhud = register_cvar("zr_hud_health", "1")					//血量是否以百分比显示
	cvar_armorhud = register_cvar("zr_hud_armor", "1")						//护甲是否以百分比显示
	cvar_linehud = register_cvar("zr_hud_line", "1")						//是否显示重生进度条
	cvar_knockthreshold = register_cvar("zr_knock_threshold", "2.0")		//击退阀值(数值越大,击退的影响越大)
	cvar_gloweffect = register_cvar("zr_glow_effect", "1")					//幽灵观察玩家的光圈效果
	cvar_modelindex = register_cvar("zr_player_modelindex", "1")			//是否设置玩家真实的身体模型击中部位
	cvar_realfalldamage = register_cvar("zr_real_falldamage", "0")			//是否开启真实掉落伤害
	TimeThink = 99999.0
	Waiting = true
	roundended = true
	CurrentWeather = 1
}

public plugin_cfg()
{
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
	set_cvar_float("sv_maxvelocity", 99999.0)
	set_cvar_float("sv_maxspeed", 9999.0)
	set_cvar_num("mp_autoteambalance", 0)
	set_cvar_num("mp_limitteams", 0)
	server_cmd("exec addons/amxmodx/configs/zombieriot.cfg")
}

public plugin_natives()
{
	register_native("zr_is_escapemode", "native_zr_is_escapemode", 1)
	register_native("zr_zbot_supported", "native_zbot_supported", 1)
	register_native("zr_set_round_end", "native_enforce_roundend", 1)
	register_native("zr_print_chat", "native_zr_print_chat")
	register_native("zr_get_zombie_id", "native_get_zombie_id", 1)
	register_native("zr_is_zombie_male", "native_is_zombie_male", 1)
	register_native("zr_get_nextzombie_id", "native_get_nextzombie_id", 1)
	register_native("zr_set_nextzombie_id", "native_set_nextzombie_id", 1)
	register_native("zr_get_zombie_name", "native_get_zombie_name")
	register_native("zr_get_zombie_info", "native_get_zombie_info")
	register_native("zr_get_zombie_health", "native_get_zombie_health", 1)
	register_native("zr_get_zombie_model", "native_get_zombie_model")
	register_native("zr_get_zombie_claw", "native_get_zombie_claw")
	register_native("zr_get_human_id", "native_get_human_id", 1)
	register_native("zr_is_human_male", "native_is_human_male", 1)
	register_native("zr_get_nexthuman_id", "native_get_nexthuman_id", 1)
	register_native("zr_set_nexthuman_id", "native_set_nexthuman_id", 1)
	register_native("zr_get_human_name", "native_get_human_name")
	register_native("zr_get_human_info", "native_get_human_info")
	register_native("zr_get_human_health", "native_get_human_health", 1)
	register_native("zr_get_human_model", "native_get_human_model")
	register_native("zr_get_human_nvg", "native_get_human_nvg", 1)
	register_native("zr_set_human_nvg", "native_set_human_nvg", 1)
	register_native("zr_is_user_zombie", "native_is_user_zombie", 1)
	register_native("zr_is_user_ghost", "native_is_user_ghost", 1)
	register_native("zr_is_zombie_boss", "native_is_zombie_boss", 1)
	register_native("zr_is_zombie_hidden", "native_is_zombie_hidden", 1)
	register_native("zr_is_human_hidden", "native_is_human_hidden", 1)
	register_native("zr_get_user_money", "native_get_user_money", 1)
	register_native("zr_get_team_score", "native_get_team_score", 1)
	register_native("zr_get_zombie_amount", "native_get_zombie_amount", 1)
	register_native("zr_get_human_amount", "native_get_human_amount", 1)
	register_native("zr_id_to_sequence", "IDToSequence", 1)
	register_native("zr_sequence_to_id", "SequenceToID", 1)
	register_native("zr_set_team_score", "native_set_team_score", 1)
	register_native("zr_set_user_money", "native_set_user_money", 1)
	register_native("zr_set_user_human", "native_set_user_human", 1)
	register_native("zr_set_user_zombie", "native_set_user_zombie", 1)
	register_native("zr_set_user_ghost", "native_set_user_ghost", 1)
	register_native("zr_set_user_model", "native_set_user_model")
	register_native("zr_set_user_item", "native_set_user_item", 1)
	register_native("zr_get_user_model", "native_get_user_model")
	register_native("zr_register_item", "native_register_item")
	register_native("zr_get_item_amount", "native_get_item_amount", 1)
	register_native("zr_get_item_name", "native_get_item_name")
	register_native("zr_get_item_team", "native_get_item_team", 1)
	register_native("zr_get_item_slot", "native_get_item_slot", 1)
	register_native("zr_set_user_anim", "native_set_animation", 1)
	register_native("zr_set_knockback", "native_set_knockback", 1)
	register_native("zr_get_lefttime", "native_get_lefttime", 1)
	register_native("zr_set_lefttime", "native_set_lefttime", 1)
	register_native("zr_check_admin", "native_check_admin", 1)
	register_native("zr_get_light", "native_get_light")
	register_native("zr_set_light", "native_set_light")
	register_native("zr_get_weather", "native_get_weather", 1)
	register_native("zr_set_weather", "native_set_weather", 1)
	register_native("zr_set_fog", "native_set_fog", 1)
	register_native("zr_get_wonteam", "native_get_wonteam", 1)
	register_native("zr_spawn_body", "native_spawn_body", 1)
	register_native("zr_reset_round", "native_reset_round", 1)
	register_native("zr_check_round", "CheckRound", 1)
	register_native("zr_spawn_zombie", "SpawnZombie", 1)
	register_native("zr_resetmaxspeed", "native_resetmaxspeed", 1)
	register_native("zr_get_snapchange", "native_get_snapchange", 1)
	register_native("zr_set_snapchange", "native_set_snapchange", 1)
	register_native("zr_get_linedata", "native_get_linedata")
	register_native("zr_set_linedata", "native_set_linedata")
	register_native("zr_register_zombie", "native_register_zombie")
	register_native("zr_register_human", "native_register_human")
	register_native("zr_get_maxsection", "native_zr_get_maxsection", 1)
}

public plugin_end() ZR_PatchRoundEnd(false)

public Event_CurWeapon(iPlayer)
{
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return PLUGIN_CONTINUE
	
	static viewmodel[64]
	ZrArrayGetString(ZombieVModel, BeingZombie[1][iPlayer], viewmodel, charsmax(viewmodel))
	format(viewmodel, charsmax(viewmodel), "models/zombieriot/%s", viewmodel)
	set_pev(iPlayer, pev_viewmodel2, viewmodel)
	set_pev(iPlayer, pev_weaponmodel2, 0)
	
	return PLUGIN_CONTINUE
}

public RestartRound()
{
	if(!roundended)
	return
	
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i) || !SnapChange[i])
	continue
	
	set_pdata_int(i, 114, HUMAN, 5)
	SnapChange[i] = false
	}
	
	SetTeamBalance()
	
	if(CheckGameDisConnected())
	return
	
	ZR_PatchRoundEnd(true)
	
	static SzWeather[3]
	ZrArrayGetString(Weather, CurrentWeather, SzWeather, charsmax(SzWeather))
	lightstyle[0] = SzWeather[0]
	engfunc(EngFunc_LightStyle, 0, lightstyle)
	WeatherStyle = str_to_num(SzWeather[1])
	switch(WeatherStyle)
	{
	case 1: sunny()
	case 2: drizzle()
	case 3: thunderstorm()
	case 4: tempest()
	case 5: snow()
	case 6: fog()
	case 7: blackfog()
	}
	if(WeatherStyle != 4) client_cmd(0, "mp3 play %s", BeginMusic)
	ChangeWeather()
	TimeThink = get_gametime()+1.0
	RoundTime = get_pcvar_num(cvar_reciprocal)
	Waiting = true
	roundended = false
	
	ExecuteForward(RoundBeginEvent, g_fwDummyResult, WeatherStyle)
}

public ChangeWeather()
{
	if(WeatherAmount == 1)
	return
	
	if(CurrentWeather < WeatherAmount)
	{
	CurrentWeather ++
	return
	}
	
	CurrentWeather = 1
}

public EscapeModeRest()
{
	KeepSection = 0
	
	SectionAmount = 0
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "trigger_multiple")))
	{
	static targetname[33]
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	if(strcmp(targetname, "zr_section"))
	continue
	
	set_pev(iEntity, pev_iuser2, 0)
	SectionAmount ++
	}
	
	new HAmount, ZAmount
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i))
	continue
	
	if(get_pdata_int(i, 114, 5) == HUMAN)
	{
	HAmount ++
	continue
	}
	
	ZAmount ++
	}
	
	if(!HAmount || !ZAmount)
	return PLUGIN_CONTINUE
	
	new Float:Threshold = (float(HAmount)/16.0)*(float(HAmount)/float(ZAmount))
	
	iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "func_breakable")))
	{
	static targetname[33]
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	if(contain(targetname, "zr_barrier") == -1)
	continue
	
	new Float:Health
	for(new i = 0; i < 26; i ++)
	{
	if(targetname[11] != lightsize[i+1][0])
	continue
	
	Health = get_pcvar_float(cvar_barrier[i])*Threshold
	}
	
	if(Health <= 0)
	continue
	
	set_pev(iEntity, pev_health, Health)
	}
	
	return PLUGIN_CONTINUE
}

public RoundEnd(Team)
{
	ExecuteForward(HookRoundEnd, g_fwDummyResult, Team)
	if(g_fwDummyResult)
	return
	
	native_enforce_roundend(Team)
	
	ExecuteForward(RoundEndEvent, g_fwDummyResult, Team)
}

public fw_GetGameDescription()
{
	forward_return(FMV_STRING, MODENAME)
	return FMRES_SUPERCEDE
}

public fw_StartFrame_Post()
{
	if(!EscapeMode) RoundTimer()
	WeatherSystem()
}

public RoundTimer()
{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(TimeThink > fCurTime || roundended)
	return
	
	RoundTime --
	TimeThink = fCurTime + 1.0
	
	message_begin(MSG_BROADCAST, get_user_msgid("RoundTime"))
	write_short(RoundTime+1)
	message_end()
	
	if(!Waiting)
	{
	if(RoundTime)
	{
	new Float:TimePercent = 1.0-float(RoundTime)/float(MaxTime*60)
	if(TimePercent >= get_pcvar_float(cvar_finish[0]) && szPrompt == 1)
	{
	ExecuteForward(FinishEvent, g_fwDummyResult, szPrompt)
	client_cmd(0, "spk %s", FirstPrompt)
	if(get_pcvar_num(cvar_hudmessage))
	{
	new Color[3] = { 255, 100, 255 }
	new Float:Coordinate[2] = { -1.0, 0.30 }
	new Float:Time[4] = { 6.0, 6.0, 0.1, 0.2 }
	ShowHudMessage(0, Color, Coordinate, 0, Time, -1, "人类已完成了%d%", floatround(get_pcvar_float(cvar_finish[0])*100.0))
	}
	szPrompt ++
	return
	}
	if(TimePercent >= get_pcvar_float(cvar_finish[1]) && szPrompt == 2)
	{
	ExecuteForward(FinishEvent, g_fwDummyResult, szPrompt)
	client_cmd(0, "spk %s", SecondPrompt)
	if(get_pcvar_num(cvar_hudmessage))
	{
	new Color[3] = { 255, 100, 255 }
	new Float:Coordinate[2] = { -1.0, 0.30 }
	new Float:Time[4] = { 6.0, 6.0, 0.1, 0.2 }
	ShowHudMessage(0, Color, Coordinate, 0, Time, -1, "人类已完成了%d%", floatround(get_pcvar_float(cvar_finish[1])*100.0))
	}
	szPrompt ++
	return
	}
	
	if(TimePercent < get_pcvar_float(cvar_finish[2]) || szPrompt != 3)
	return
	
	ExecuteForward(FinishEvent, g_fwDummyResult, szPrompt)
	client_cmd(0, "spk %s", LastPrompt)
	if(get_pcvar_num(cvar_hudmessage))
	{
	new Color[3] = { 255, 100, 255 }
	new Float:Coordinate[2] = { -1.0, 0.30 }
	new Float:Time[4] = { 6.0, 6.0, 0.1, 0.2 }
	ShowHudMessage(0, Color, Coordinate, 0, Time, -1, "人类已完成了%d%", floatround(get_pcvar_float(cvar_finish[2])*100.0))
	}
	szPrompt = 0
	return
	}
	
	RoundEnd(HUMAN)
	return
	}
	
	if(RoundTime <= 0)
	{
	client_cmd(0, "spk %s", BeginSound)
	ExecuteForward(BeginRioting, g_fwDummyResult)
	MaxTime = get_pcvar_num(cvar_holdTime)
	RoundTime = MaxTime*60
	szPrompt = 1
	Waiting = false
	return
	}
	
	if(RoundTime > 10)
	return
	
	client_cmd(0, "spk %s", BeepSound)
}

public WeatherSystem()
{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(WeatherStyle == 1)
	return
	
	if(1 < WeatherStyle < 5 && WeatherThink[0] <= fCurTime)
	{
	if(WeatherStyle == 4)
	{
	client_cmd(0, "spk %s", rainsound[1])
	WeatherThink[0] = fCurTime + 8.0
	}
	else
	{
	client_cmd(0, "spk %s", rainsound[0])
	WeatherThink[0] = fCurTime + 5.0
	}
	}
	
	if(WeatherStyle == 3 && WeatherThink[1] <= fCurTime)
	{
	WeatherThink[1] = fCurTime + random_float(10.0, 15.0)
	client_cmd(0, "spk %s", thundersound[random_num(0, sizeof thundersound - 1)])
	SetThunderLight()
	}
	else
	if(WeatherStyle == 4)
	{
	if(WeatherThink[2] <= fCurTime)
	{
	client_cmd(0, "spk %s", thunderclap[random_num(0, sizeof thunderclap - 1)])
	WeatherThink[2] = fCurTime + random_float(2.0, 2.5)
	SetFog(0, 0, 0, 0)
	SetThunderLight()
	MakeThunderSpark()
	}
	}
	
	if(WeatherThink[3] <= fCurTime && ThunderLight[0])
	{
	ThunderLight[0] --
	if(ThunderLight[1])
	{
	message_begin(MSG_BROADCAST, SVC_LIGHTSTYLE)
	write_byte(0)
	write_string("#")
	message_end()
	WeatherThink[3] = fCurTime + random_float(0.03, 0.04)
	ThunderLight[1] = false
	return
	}
	
	if(WeatherStyle == 4) SetFog(5, 5, 5, 5)
	
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i))
	continue
	
	if(get_pdata_int(i, 114, 5) == ZOMBIE) SetLightstyle(i, lightsize[get_pcvar_num(cvar_zombienvg[4])])
	else if(nvgstatus[i]) SetLightstyle(i, lightsize[get_pcvar_num(cvar_humannvg[4])])
	else SetLightstyle(i, lightstyle)
	}
	
	if(!ThunderLight[0])
	return
	
	ThunderLight[1] = true
	WeatherThink[3] = fCurTime + random_float(0.1, 0.2)
	}
}

public SetThunderLight()
{
	ThunderLight[0] = random_num(1, 2)*2
	ThunderLight[1] = true
	WeatherThink[3] = 0.0
}

public MakeThunderSpark()
{
	new Float:origin[33][3], GetPlayer[33], bool:IntheSky, amount
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	pev(i, pev_origin, origin[i])
	IntheSky = SkyFromPlayer(origin[i])
	if(!IntheSky)
	continue
	
	amount ++
	GetPlayer[amount] = i
	}
	
	if(!amount)
	return
	
	new Float:SparkEnd[3][3], Float:Sparksize = get_pcvar_float(cvar_sparksize)
	xs_vec_copy(origin[GetPlayer[random_num(1, amount)]], SparkEnd[0])
	xs_vec_copy(SparkEnd[0], SparkEnd[1])
	xs_vec_copy(SparkEnd[0], SparkEnd[2])
	SparkEnd[1][0] += random_float(-15.0, 15.0)*Sparksize
	SparkEnd[1][1] += random_float(-15.0, 15.0)*Sparksize
	SparkEnd[1][2] += random_float(-25.0, -20.0)*Sparksize
	SparkEnd[2][0] += random_float(-1.0, 1.0)*Sparksize
	SparkEnd[2][1] += random_float(-1.0, 1.0)*Sparksize
	SparkEnd[2][2] += random_float(-35.0, -30.0)*Sparksize
	
	for(new i = 1; i < 3; i ++)
	{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord, SparkEnd[i-1][0])
	engfunc(EngFunc_WriteCoord, SparkEnd[i-1][1])
	engfunc(EngFunc_WriteCoord, SparkEnd[i-1][2])
	engfunc(EngFunc_WriteCoord, SparkEnd[i][0])
	engfunc(EngFunc_WriteCoord, SparkEnd[i][1])
	engfunc(EngFunc_WriteCoord, SparkEnd[i][2])
	write_short(g_fxbeam)
	write_byte(0)
	write_byte(2)
	write_byte(2)
	write_byte(15)
	write_byte(150)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(random_num(20, 30))
	message_end()
	}
}

public sunny()
{
	client_cmd(0, "stopsound")
	SetFog(0, 0, 0, 0)
	SetReceiveW(0)
}

public drizzle()
{
	client_cmd(0, "stopsound")
	SetFog(0, 0, 0, 0)
	SetReceiveW(1)
	WeatherThink[0] = 0.0
}

public thunderstorm()
{
	client_cmd(0, "stopsound")
	SetFog(0, 0, 0, 0)
	SetReceiveW(1)
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	WeatherThink[1] = fCurTime + random_float(10.0, 15.0)
	WeatherThink[0] = 0.0
}

public tempest()
{
	client_cmd(0, "stopsound")
	SetFog(5, 5, 5, 5)
	SetReceiveW(1)
	WeatherThink[0] = 0.0
}

public snow()
{
	client_cmd(0, "stopsound")
	SetReceiveW(2)
	SetFog(200, 200, 200, 7)
}

public fog()
{
	client_cmd(0, "stopsound")
	SetFog(100, 100, 100, 6)
	SetReceiveW(0)
}

public blackfog()
{
	client_cmd(0, "stopsound")
	SetFog(0, 0, 0, 3)
	SetReceiveW(0)
}

public Message_DeathMsg(msg_id, msg_dest, msg_entity)
{
	new attacker = get_msg_arg_int(1)
	if(!is_user_connected(attacker))
	return PLUGIN_CONTINUE
	
	if(DeathMSGFIX[attacker])
	{
	DeathMSGFIX[attacker] = false
	return PLUGIN_CONTINUE
	}
	
	return PLUGIN_HANDLED
}

public Message_ResetHUD(msg_id, msg_dest, msg_entity)
{
	if(is_user_bot(msg_entity))
	return PLUGIN_HANDLED
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ResetHUD"), _, msg_entity)
	message_end()
	native_set_user_money(msg_entity, Money[msg_entity], 0)
	
	return PLUGIN_HANDLED
}

public Message_HideWeapon(msg_id, msg_dest, msg_entity)
{
	if(!EscapeMode || (get_msg_arg_int(1) & (1<<4)))
	return PLUGIN_CONTINUE
	
	set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | (1<<4))
	set_pdata_int(msg_entity, 361, get_pdata_int(msg_entity, 361)|(1<<4))
	
	return PLUGIN_CONTINUE
}

public Message_ScreenFade(msg_id, msg_dest, msg_entity)
{
	if(get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 || get_msg_arg_int(7) < 200)
	return PLUGIN_CONTINUE
	
	if(IsGhost[msg_entity] || pev(msg_entity, pev_deadflag) != DEAD_NO)
	return PLUGIN_HANDLED
	
	if(!nvgstatus[msg_entity] && get_pdata_int(msg_entity, 114, 5) != ZOMBIE)
	return PLUGIN_CONTINUE
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	flashing[msg_entity] = get_msg_arg_int(7)
	if(nvgstatus[msg_entity]) NvgScreen(msg_entity, get_pcvar_num(cvar_humannvg[0]), get_pcvar_num(cvar_humannvg[1]), get_pcvar_num(cvar_humannvg[2]), flashing[msg_entity])
	else NvgScreen(msg_entity, get_pcvar_num(cvar_zombienvg[0]), get_pcvar_num(cvar_zombienvg[1]), get_pcvar_num(cvar_zombienvg[2]), flashing[msg_entity])
	
	Playerthink[msg_entity] = fCurTime + float(get_msg_arg_int(1))/4096.0
	
	return PLUGIN_HANDLED
}

public Message_AmmoPickup(msg_id, msg_dest, msg_entity)
{
	if(get_pdata_int(msg_entity, 114, 5) != ZOMBIE)
	return PLUGIN_CONTINUE
	
	return PLUGIN_HANDLED
}

public Message_StatusIcon(msg_id, msg_dest, msg_entity)
{
	static szBuffer[8]
	get_msg_arg_string(2, szBuffer, charsmax(szBuffer))
	return strcmp(szBuffer, "buyzone") ? PLUGIN_CONTINUE : PLUGIN_HANDLED
}

public Message_SendAudio(msg_id, msg_dest, msg_entity)
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if(!strcmp(audio[7], "terwin") || !strcmp(audio[7], "ctwin") || !strcmp(audio[7], "rounddraw"))
	return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public Message_Money(msg_id, msg_dest, msg_entity)
{
	set_pdata_int(msg_entity, 115, 0, 5)
	set_msg_arg_int(1, ARG_LONG, Money[msg_entity])
}

public Message_Health(msg_id, msg_dest, msg_entity)
{
	if(!get_pcvar_num(cvar_healthhud))
	return PLUGIN_CONTINUE
	
	if(!IsGhost[msg_entity] && pev(msg_entity, pev_deadflag) != DEAD_NO)
	return PLUGIN_CONTINUE
	
	new Float:health, Float:MaxHealth
	pev(msg_entity, pev_health, health)
	
	if(get_pdata_int(msg_entity, 114, 5) == ZOMBIE)
	{
	MaxHealth = ZrArrayGetCell(Zombiehealth, BeingZombie[1][msg_entity])
	set_msg_arg_int(1, ARG_BYTE, max(floatround(health/MaxHealth*100.0), 1))
	return PLUGIN_CONTINUE
	}
	
	MaxHealth = ZrArrayGetCell(HumanHealth, BeingHuman[1][msg_entity])
	set_msg_arg_int(1, ARG_BYTE, max(floatround(health/MaxHealth*100.0), 1))
	
	return PLUGIN_CONTINUE
}

public Message_Battery(msg_id, msg_dest, msg_entity)
{
	if(!get_pcvar_num(cvar_armorhud))
	return PLUGIN_CONTINUE
	
	if(!IsGhost[msg_entity] && pev(msg_entity, pev_deadflag) != DEAD_NO)
	return PLUGIN_CONTINUE
	
	new Float:armor, Float:MaxArmor
	pev(msg_entity, pev_armorvalue, armor)
	
	if(get_pdata_int(msg_entity, 114, 5) == ZOMBIE)
	{
	MaxArmor = ZrArrayGetCell(Zombiehealth, BeingZombie[1][msg_entity])
	set_msg_arg_int(1, ARG_BYTE, floatround(armor/MaxArmor*100.0))
	return PLUGIN_CONTINUE
	}
	
	MaxArmor = ZrArrayGetCell(HumanHealth, BeingHuman[1][msg_entity])
	set_msg_arg_int(1, ARG_BYTE, floatround(armor/MaxArmor*100.0))
	
	return PLUGIN_CONTINUE
}

public Message_TextMsg(msg_id, msg_dest, msg_entity)
{
	static textmsg[33]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	if(!strcmp(textmsg, "#Weapon_Cannot_Be_Dropped"))
	return PLUGIN_HANDLED
	
	if(strcmp(textmsg, "#Game_Commencing"))
	return PLUGIN_CONTINUE
	
	ZR_PatchRoundEnd(false)
	roundended = true
	
	return PLUGIN_CONTINUE
}

public Message_ShowMenu(msg_id, msg_dest, msg_entity)
{
	static buffer[24]
	get_msg_arg_string(4, buffer, charsmax(buffer))
	
	if(!strcmp(buffer, "#Team_Select") || !strcmp(buffer, "#Team_Select_Spect") || !strcmp(buffer, "#IG_Team_Select") || !strcmp(buffer, "#IG_Team_Select_Spect"))
	{
	JoinTeam[msg_entity] = 2
	return PLUGIN_HANDLED
	}
	
	if(!strcmp(buffer, "#Terrorist_Select") || !strcmp(buffer, "#CT_Select"))
	return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public client_connect(iPlayer)
{
	Money[iPlayer] = get_cvar_num("mp_startmoney")
	
	for(new i = 1; i <= ZombieAmount; i++)
	{
	if(ZrArrayGetCell(ZombieStyle, i) || ZrArrayGetCell(HiddenZombie, i))
	continue
	
	BeingZombie[0][iPlayer] = i
	BeingZombie[1][iPlayer] = i
	
	break
	}
	for(new i = 1; i <= HumanAmount; i++)
	{
	if(ZrArrayGetCell(HiddenHuman, i))
	continue
	
	BeingHuman[0][iPlayer] = i
	BeingHuman[1][iPlayer] = i
	
	break
	}
	flashing[iPlayer] = 0
	nvgstatus[iPlayer] = false
	CanChange[iPlayer] = true
	IsGhost[iPlayer] = false
	SnapChange[iPlayer] = false
	DeathMSGFIX[iPlayer] = false
	SetZombieFixed[iPlayer] = false
}

public client_putinserver(iPlayer)
{
	static ConnectionWord[128]
	pev(iPlayer, pev_netname, ConnectionWord, charsmax(ConnectionWord))
	format(ConnectionWord, charsmax(ConnectionWord), "%s%s", ConnectionWord, ConnectionMark[0])
	ExecuteForward(HookPrintWord, g_fwDummyResult, 0, ConnectionWord)
	if(!g_fwDummyResult) client_print(0, print_chat, ConnectionWord)
	
	if(!is_user_bot(iPlayer))
	return
	
	Playerthink[iPlayer] = get_gametime() + 1.0
	ReSpawnPre[iPlayer] = true
}

public fw_ClientKill(iPlayer) return FMRES_SUPERCEDE

public fw_ClientDisconnect_Post(iPlayer)
{
	static DisconnectionWord[128]
	pev(iPlayer, pev_netname, DisconnectionWord, charsmax(DisconnectionWord))
	format(DisconnectionWord, charsmax(DisconnectionWord), "%s%s", DisconnectionWord, ConnectionMark[1])
	ExecuteForward(HookPrintWord, g_fwDummyResult, 0, DisconnectionWord)
	if(!g_fwDummyResult) client_print(0, print_chat, DisconnectionWord)
	CheckRound()
	CheckGameDisConnected()
}

public fw_ClientCommand(iPlayer)
{
	static szCommand[24]
	read_argv(0, szCommand, charsmax(szCommand))
	
	for(new i = 0; i < sizeof gBuyCommands; i++)
	{
	if(!strcmp(szCommand, gBuyCommands[i]))
	return FMRES_SUPERCEDE
	}
	
	if(!strcmp(szCommand, "zrchangeteam"))
	{
	ChangeTeam(iPlayer)
	return FMRES_SUPERCEDE
	}
	
	if(!strcmp(szCommand, "nightvision"))
	{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return FMRES_SUPERCEDE
	
	if(get_pdata_int(iPlayer, 114, 5) != HUMAN)
	return FMRES_SUPERCEDE
	
	if(!(get_pdata_int(iPlayer, 129, 5) & (1<<0)))
	return FMRES_SUPERCEDE
	
	if(flashing[iPlayer])
	return FMRES_SUPERCEDE
	
	if(get_pdata_float(iPlayer, 83, 5) > 0.0)
	return FMRES_SUPERCEDE
	
	nvgstatus[iPlayer] ? native_set_human_nvg(iPlayer, false) : native_set_human_nvg(iPlayer, true)
	
	set_pdata_float(iPlayer, 83, 0.2, 5)
	
	return FMRES_SUPERCEDE
	}
	
	if(contain(szCommand, "zritems_") != -1)
	{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return FMRES_SUPERCEDE
	
	new Item = str_to_num(szCommand[8])
	if(Item <= 0 || Item > szItemId)
	return FMRES_SUPERCEDE
	
	if(ZrArrayGetCell(ItemTeam, Item) != get_pdata_int(iPlayer, 114, 5))
	return FMRES_SUPERCEDE
	
	ExecuteForward(ItemEvent, g_fwDummyResult, iPlayer, Item, ZrArrayGetCell(ItemSlot, Item))
	
	return FMRES_SUPERCEDE
	}
	
	if(contain(szCommand, "zrhumans_") != -1)
	{
	new HumanType = str_to_num(szCommand[9])
	if(HumanType <= 0 || HumanType > HumanAmount)
	return FMRES_SUPERCEDE
	
	if(ZrArrayGetCell(HiddenHuman, HumanType))
	return FMRES_SUPERCEDE
	
	BeingHuman[0][iPlayer] = HumanType
	static hName[64], hInfo[64]
	ZrArrayGetString(HumanName, HumanType, hName, charsmax(hName))
	ZrArrayGetString(HumanInfo, HumanType, hInfo, charsmax(hInfo))
	PrintChat(iPlayer, BLUECHAT, "%s[%s]:%s", szWords[9], hName, hInfo)
	
	return FMRES_SUPERCEDE
	}
	
	if(contain(szCommand, "zrzombies_") != -1)
	{
	new ZombieType = str_to_num(szCommand[10])
	if(ZombieType <= 0 || ZombieType > ZombieAmount)
	return FMRES_SUPERCEDE
	
	if(ZrArrayGetCell(ZombieStyle, ZombieType) || ZrArrayGetCell(HiddenZombie, ZombieType))
	return FMRES_SUPERCEDE
	
	BeingZombie[0][iPlayer] = ZombieType
	
	static zName[64], zInfo[64]
	ZrArrayGetString(ZombieName, ZombieType, zName, charsmax(zName))
	ZrArrayGetString(ZombieInfo, ZombieType, zInfo, charsmax(zInfo))
	PrintChat(iPlayer, REDCHAT, "%s[%s]:%s", szWords[5], zName, zInfo)
	
	return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_InfoKeyValue(infobuffer[], key[])
{
	if(strcmp(key, "_vgui_menus"))
	return FMRES_IGNORED
	
	forward_return(FMV_STRING, "0")
	
	return FMRES_SUPERCEDE
}

public fw_EmitSound(iPlayer, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(!is_user_connected(iPlayer))
	return FMRES_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return FMRES_IGNORED
	
	if(!strcmp(sample, "items/gunpickup2.wav"))
	return FMRES_SUPERCEDE
	
	if(!strcmp(sample, "weapons/knife_deploy1.wav"))
	return FMRES_SUPERCEDE
	
	if(sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
	return FMRES_SUPERCEDE
	
	static sound[33]
	if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
	if(ZrArrayGetCell(ZombieStyle, BeingZombie[1][iPlayer])) formatex(sound, charsmax(sound), "zombieriot/%s", BossPain[random_num(0, SoundStock[4]-1)])
	else formatex(sound, charsmax(sound), "zombieriot/%s", ZombiePain[random_num(0, SoundStock[5]-1)])
	engfunc(EngFunc_EmitSound, iPlayer, channel, sound, volume, attn, flags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
	if(ZrArrayGetCell(ZombieStyle, BeingZombie[1][iPlayer])) formatex(sound, charsmax(sound), "zombieriot/%s", BossDie[random_num(0, SoundStock[6]-1)])
	else formatex(sound, charsmax(sound), "zombieriot/%s", ZombieDie[random_num(0, SoundStock[7]-1)])
	engfunc(EngFunc_EmitSound, iPlayer, channel, sound, volume, attn, flags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
	if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') formatex(sound, charsmax(sound), "zombieriot/%s", Zombieslash[random_num(0, SoundStock[0]-1)])
	else
	if(sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't')
	{
	if(sample[17] == 'w') formatex(sound, charsmax(sound), "zombieriot/%s", ZombieWall[random_num(0, SoundStock[1]-1)])
	else formatex(sound, charsmax(sound), "zombieriot/%s", ZombieNormal[random_num(0, SoundStock[2]-1)])
	}
	else if(sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') formatex(sound, charsmax(sound), "zombieriot/%s", ZombieStab[random_num(0, SoundStock[3]-1)])
	else return FMRES_IGNORED
	engfunc(EngFunc_EmitSound, iPlayer, channel, sound, volume, attn, flags, pitch)
	return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_TraceLine(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_alive(iPlayer))
	return FMRES_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return FMRES_IGNORED
	
	new iWeapon = get_pdata_cbase(iPlayer, 373, 5)
	
	if(iWeapon <= 0)
	return FMRES_IGNORED
	
	if(get_pdata_int(iWeapon, 43, 4) != CSW_KNIFE)
	return FMRES_IGNORED
	
	static Float:angles[3]
	pev(iPlayer, pev_v_angle, angles)
	engfunc(EngFunc_MakeVectors, angles)
	
	static Float:v_forward[3]
	global_get(glb_v_forward, v_forward)
	
	xs_vec_sub(vecEnd, vecStart, angles)
	
	angles[0] /= v_forward[0]
	angles[1] /= v_forward[1]
	angles[2] /= v_forward[2]
	
	new Float:dstance
	if(floatround(angles[0]) == 48 && floatround(angles[1]) == 48 && floatround(angles[2]) == 48) dstance = ZrArrayGetCell(ZombieAttackDist[0], BeingZombie[1][iPlayer])
	else if(floatround(angles[0]) == 32 && floatround(angles[1]) == 32 && floatround(angles[2]) == 32) dstance = ZrArrayGetCell(ZombieAttackDist[1], BeingZombie[1][iPlayer])
	else return FMRES_IGNORED
	
	xs_vec_copy(vecEnd, g_vecLastEnd[iPlayer])
	xs_vec_mul_scalar(v_forward, dstance, v_forward)
	xs_vec_add(vecStart, v_forward, vecEnd)
	xs_vec_copy(vecEnd, g_vecLastNewEnd[iPlayer])
	engfunc(EngFunc_TraceLine, vecStart, vecEnd, iConditions, iPlayer, iTrace)
	
	return FMRES_SUPERCEDE
}

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_connected(iPlayer))
	return
	
	if(!is_user_bot(iPlayer) || !IsGhost[iPlayer] || pev(iPlayer, pev_deadflag) != DEAD_RESPAWNABLE)
	return
	
	if(!Waiting && CanReSpawn[iPlayer] && !is_user_stucked(iPlayer))
	{
	native_set_user_ghost(iPlayer, false)
	set_pev(iPlayer, pev_velocity, {0.0, 0.0, 0.0})
	return
	}
	
	new Float:start[3], Float:dest[3], Float:size[3]
	xs_vec_add(vecStart, start, start)
	start[2] -= 17.0
	pev(iPlayer, pev_v_angle, dest)
	engfunc(EngFunc_MakeVectors, dest)
	global_get(glb_v_forward, dest)
	pev(iPlayer, pev_size, size)
	xs_vec_mul_scalar(dest, 1.5*size[0], dest)
	xs_vec_add(start, dest, dest)
	engfunc(EngFunc_TraceHull, dest, dest, IGNORE_MONSTERS, HULL_HUMAN, iPlayer, 0)
	
	if(!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
	{
	new Float:fVelocity[3], Float:FallSpeed
	pev(iPlayer, pev_velocity, fVelocity)
	FallSpeed = fVelocity[2]
	GetVelocityToOrigin(vecStart, dest, 1000.0, fVelocity)
	fVelocity[2] = FallSpeed
	set_pev(iPlayer, pev_velocity, fVelocity)
	return
	}
	
	new Float:angle[3]
	pev(iPlayer, pev_v_angle, angle)
	angle[1] += random_float(-90.0, 90.0)
	set_pev(iPlayer, pev_v_angle, angle)
}

public fw_BarrierMessage_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iPlayer, iTrace)
{
	if(!is_user_connected(iPlayer))
	return
	
	if(iConditions != DONT_IGNORE_MONSTERS)
	return
	
	if(is_user_bot(iPlayer))
	return
	
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	new iEntity = get_tr2(iTrace, TR_pHit)
	if(!pev_valid(iEntity))
	{
	if(!PointingBarrier[iPlayer])
	return
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusText"), {0, 0, 0}, iPlayer)
	write_byte(0)
	write_string("")
	message_end()
	set_pdata_int(iPlayer, 451, -1, 5)
	PointingBarrier[iPlayer] = false
	return
	}
	
	static targetname[33]
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	if(contain(targetname, "zr_barrier") == -1)
	{
	if(!PointingBarrier[iPlayer])
	return
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusText"), {0, 0, 0}, iPlayer)
	write_byte(0)
	write_string("")
	message_end()
	set_pdata_int(iPlayer, 451, -1, 5)
	PointingBarrier[iPlayer] = false
	return
	}
	
	new Float:Health
	pev(iEntity, pev_health, Health)
	
	static message[32]
	formatex(message, charsmax(message), "耐久值:%d", floatround(Health, floatround_ceil))
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusText"), {0, 0, 0}, iPlayer)
	write_byte(0)
	write_string(message)
	message_end()
	PointingBarrier[iPlayer] = true
}

public fw_TraceHull(Float:start[3], Float:end[3], iHullNumber, iNoMonsters, iPlayer, tr)
{
	if(!is_user_alive(iPlayer))
	return FMRES_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return FMRES_IGNORED
	
	new iWeapon = get_pdata_cbase(iPlayer, 373, 5)
	
	if(iWeapon <= 0)
	return FMRES_IGNORED
	
	if(get_pdata_int(iWeapon, 43, 4) != CSW_KNIFE)
	return FMRES_IGNORED
	
	if(g_vecLastEnd[iPlayer][0] != end[0] || g_vecLastEnd[iPlayer][1] != end[1] || g_vecLastEnd[iPlayer][2] != end[2])
	return FMRES_IGNORED
	
	g_vecLastEnd[iPlayer] = Float:{ 0.0, 0.0, 0.0 }
	engfunc(EngFunc_TraceHull, start, g_vecLastNewEnd[iPlayer], iHullNumber, iNoMonsters, iPlayer, tr)
	
	return FMRES_SUPERCEDE
}

public fw_AddToFullPack_Post(es_handle, e, iPlayer, host, hostflags, player, pset)
{
	if(!player || !is_user_connected(host))
	return
	
	if(IsGhost[iPlayer])
	{
	set_es(es_handle, ES_Effects, EF_NODRAW)
	return
	}
	
	if(IsGhost[host])
	{
	if(get_pcvar_num(cvar_gloweffect))
	{
	set_es(es_handle, ES_RenderMode, kRenderTransTexture)
	set_es(es_handle, ES_RenderAmt, 1)
	set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
	new Color[3]
	if(get_pdata_int(iPlayer, 114, 5) == HUMAN) for(new i = 0; i < 3; i ++) Color[i] = get_pcvar_num(cvar_humannvg[i])
	else for(new i = 0; i < 3; i ++) Color[i] = get_pcvar_num(cvar_zombienvg[i])
	set_es(es_handle, ES_RenderColor, Color)
	}
	else
	{
	set_es(es_handle, ES_RenderMode, kRenderTransAdd)
	set_es(es_handle, ES_RenderAmt, 50)
	}
	}
	
	if(pev(iPlayer, pev_deadflag) == DEAD_NO)
	return
	
	set_es(es_handle, ES_Effects, EF_NODRAW)
}

public fw_PlayerPreThink(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) == DEAD_NO)
	{
	new Float:fCurTime
	if(SetModelPost[iPlayer] > 0)
	{
	global_get(glb_time, fCurTime)
	if(SetModelPost[iPlayer] <= fCurTime)
	{
	set_user_model(iPlayer, KeepModel[iPlayer], true)
	SetModelPost[iPlayer] = -1.0
	}
	}
	
	if(Climbing[iPlayer])
	{
	set_pev(iPlayer, pev_velocity, KeepVelocity[iPlayer][0])
	Climbing[iPlayer] = false
	}
	else
	if(pev(iPlayer, pev_flags) & FL_ONGROUND)
	{
	pev(iPlayer, pev_velocity, KeepVelocity[iPlayer][0])
	HookKnockBack[iPlayer] = true
	}
	
	if(!get_pcvar_num(cvar_botbuy))
	return FMRES_IGNORED
	
	if(!is_user_bot(iPlayer))
	return FMRES_IGNORED
	
	global_get(glb_time, fCurTime)
	
	if(BotThink[iPlayer] > fCurTime)
	return FMRES_IGNORED
	
	BotThink[iPlayer] = fCurTime + random_float(get_pcvar_float(cvar_botbuytime)/2.0, get_pcvar_float(cvar_botbuytime)*1.5)
	
	new FirstSlot[MAXITEM], SecondSlot[MAXITEM], ThirdSlot[MAXITEM], FourthSlot[MAXITEM], a, b, c, d
	
	new team = get_pdata_int(iPlayer, 114, 5)
	
	for(new i = 1 ; i <= szItemId ; i++)
	{
	if(ZrArrayGetCell(ItemTeam, i) != team)
	continue
	
	if(ZrArrayGetCell(ItemSlot, i) == 1)
	{
	a ++
	FirstSlot[a] = i
	continue
	}
	
	if(ZrArrayGetCell(ItemSlot, i) == 2)
	{
	b ++
	SecondSlot[b] = i
	continue
	}
	
	if(ZrArrayGetCell(ItemSlot, i) == 3)
	{
	c ++
	ThirdSlot[c] = i
	continue
	}
	
	if(ZrArrayGetCell(ItemSlot, i) != 4)
	continue
	
	d ++
	FourthSlot[d] = i
	}
	
	if(a) ExecuteForward(ItemEvent, g_fwDummyResult, iPlayer, FirstSlot[random_num(1, a)], 1)
	if(b) ExecuteForward(ItemEvent, g_fwDummyResult, iPlayer, SecondSlot[random_num(1, b)], 2)
	if(c) ExecuteForward(ItemEvent, g_fwDummyResult, iPlayer, ThirdSlot[random_num(1, c)], 3)
	if(d) ExecuteForward(ItemEvent, g_fwDummyResult, iPlayer, FourthSlot[random_num(1, d)], 4)
	
	return FMRES_IGNORED
	}
	
	if(EscapeMode && (get_pdata_int(iPlayer, 245, 5) & IN_FORWARD) && (pev(iPlayer, pev_deadflag) == DEAD_RESPAWNABLE))
	{
	new Float:forigin[3], Float:view_ofs[3], Float:angles[3]
	pev(iPlayer, pev_origin, forigin)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(forigin, view_ofs, forigin)
	pev(iPlayer, pev_angles, angles)
	engfunc(EngFunc_MakeVectors, angles)
	global_get(glb_v_forward, angles)
	xs_vec_mul_scalar(angles, 10.0, angles)
	xs_vec_add(forigin, angles, forigin)
	engfunc(EngFunc_TraceHull, forigin, forigin, IGNORE_MONSTERS, ((pev(iPlayer, pev_flags) & FL_DUCKING) ? HULL_HEAD:HULL_HUMAN), iPlayer, 0)
	new iEntity = get_tr2(0, TR_pHit)
	if(pev_valid(iEntity))
	{
	static targetname[33]
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	if(!strcmp(targetname, "zr_ladder") && pev(iPlayer, pev_groundentity) != iEntity)
	{
	pev(iPlayer, pev_velocity, KeepVelocity[iPlayer][0])
	KeepVelocity[iPlayer][0][2] = 200.0
	set_pev(iPlayer, pev_velocity, KeepVelocity[iPlayer][0])
	}
	}
	}
	
	if(!JoinTeam[iPlayer])
	return FMRES_IGNORED
	
	if(JoinTeam[iPlayer] == 2) engclient_cmd(iPlayer, "jointeam", "5")
	else
	{
	Playerthink[iPlayer] = get_gametime() + 1.0
	ReSpawnPre[iPlayer] = true
	native_set_human_nvg(iPlayer, true)
	engclient_cmd(iPlayer, "joinclass", "5")
	}
	JoinTeam[iPlayer] --
	
	return FMRES_IGNORED
}

public fw_PlayerPreThink_Post(iPlayer)
{
	if(!HookKnockBack[iPlayer])
	return
	
	HookKnockBack[iPlayer] = false
	
	ExecuteForward(HookVelocityCheck, g_fwDummyResult, iPlayer)
	
	if(g_fwDummyResult)
	return
	
	if(pev(iPlayer, pev_flags) & FL_ONTRAIN)
	return
	
	new iEntity = pev(iPlayer, pev_groundentity)
	if(pev_valid(iEntity) && (pev(iEntity, pev_flags) & FL_CONVEYOR))
	{
	new Float:basevelocity[3]
	pev(iPlayer, pev_basevelocity, basevelocity)
	xs_vec_add(KeepVelocity[iPlayer][0], basevelocity, KeepVelocity[iPlayer][0])
	}
	
	set_pev(iPlayer, pev_velocity, KeepVelocity[iPlayer][0])
}

public fw_PlayerPostThink(iPlayer)
{
	if(!IsGhost[iPlayer] || pev(iPlayer, pev_deadflag) != DEAD_RESPAWNABLE)
	return FMRES_IGNORED
	
	set_pdata_float(iPlayer, 83, 99999.0, 5)
	
	if(roundended)
	return FMRES_IGNORED
	
	new Float:origin[2][3], Float:distance, Float:end[3], ButtonKey
	pev(iPlayer, pev_origin, origin[0])
	
	new Hplayer, KeepID[33]
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i) || i == iPlayer)
	continue
	
	if(get_pdata_int(i, 114, 5) == ZOMBIE)
	continue
	
	Hplayer ++
	KeepID[Hplayer] = i
	
	pev(i, pev_origin, origin[1])
	distance = get_distance_f(origin[0], origin[1])
	
	if(distance < get_pcvar_float(cvar_spawndistance))
	{
	ButtonKey = 1
	continue
	}
	
	engfunc(EngFunc_TraceLine, origin[0], origin[1], IGNORE_MONSTERS, iPlayer, 0)
	get_tr2(0, TR_vecEndPos, end)
	
	if(!xs_vec_equal(end, origin[1]))
	continue
	
	ButtonKey = 2
	}
	
	new Pressed = get_pdata_int(iPlayer, 246, 5)
	
	if((Pressed & IN_USE) && Hplayer)
	{
	new Target = KeepID[random_num(1, Hplayer)]
	if(is_user_stucked(Target))
	return FMRES_IGNORED
	pev(Target, pev_origin, origin[1])
	set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) | FL_DUCKING)
	engfunc(EngFunc_SetSize, iPlayer, {-16.0, -16.0, -18.0}, {16.0, 16.0, 32.0})
	set_pev(iPlayer, pev_view_ofs, {0.0, 0.0, 12.0})
	set_pev(iPlayer, pev_origin, origin[1])
	return FMRES_IGNORED
	}
	
	if(Waiting || is_user_stucked(iPlayer))
	{
	CanReSpawn[iPlayer] = false
	
	if(!get_pcvar_num(cvar_hudmessage))
	return FMRES_IGNORED
	
	new Float:Coordinate[2] = { -1.0, 0.7 }
	new Float:Time[4] = { 0.1, 0.1, 0.0, 0.0 }
	ShowHudMessage(iPlayer, szWordsColor[5], Coordinate, 0, Time, SHOWMARK, szWords[8])
	
	return FMRES_IGNORED
	}
	
	if(ButtonKey)
	{
	CanReSpawn[iPlayer] = false
	SoundRecord[iPlayer] = true
	if(get_pcvar_num(cvar_hudmessage))
	{
	if(ButtonKey == 1)
	{
	new Float:Coordinate[2] = { -1.0, 0.7 }
	new Float:Time[4] = { 0.1, 0.1, 0.0, 0.0 }
	ShowHudMessage(iPlayer, szWordsColor[2], Coordinate, 0, Time, SHOWMARK, szWords[2])
	return FMRES_IGNORED
	}
	if(ButtonKey == 2)
	{
	new Float:Coordinate[2] = { -1.0, 0.7 }
	new Float:Time[4] = { 0.1, 0.1, 0.0, 0.0 }
	ShowHudMessage(iPlayer, szWordsColor[1], Coordinate, 0, Time, SHOWMARK, szWords[1])
	return FMRES_IGNORED
	}
	}
	return FMRES_IGNORED
	}
	
	if(SoundRecord[iPlayer])
	{
	client_cmd(iPlayer, "spk %s", GhostWillSpawn)
	SoundRecord[iPlayer] = false
	}
	
	if(get_pcvar_num(cvar_hudmessage))
	{
	new Float:Coordinate[2] = { -1.0, 0.7 }
	new Float:Time[4] = { 0.1, 0.1, 0.0, 0.0 }
	ShowHudMessage(iPlayer, szWordsColor[3], Coordinate, 0, Time, SHOWMARK, szWords[3])
	}
	CanReSpawn[iPlayer] = true
	
	if(!(Pressed & IN_ATTACK))
	return FMRES_IGNORED
	
	native_set_user_ghost(iPlayer, false)
	if(get_pcvar_num(cvar_hudmessage))
	{
	new Float:Coordinate[2] = { -1.0, 0.7 }
	new Float:Time[4] = { 6.0, 2.0, 0.0, 0.0 }
	ShowHudMessage(iPlayer, szWordsColor[4], Coordinate, 0, Time, SHOWMARK, szWords[4])
	}
	client_cmd(iPlayer, "spk %s", GhostSpawn)
	
	return FMRES_IGNORED
}

public fw_PlayerPostThink_Post(iPlayer)
{
	new team = get_pdata_int(iPlayer, 114, 5)
	if(pev(iPlayer, pev_deadflag) == DEAD_NO)
	{
	if(get_pcvar_num(cvar_hudmessage))
	{
	new Float:health, Float:armorvalue
	pev(iPlayer, pev_health, health)
	pev(iPlayer, pev_armorvalue, armorvalue)
	new Color[3] = { 255, 255, 0 }
	new Float:Coordinate[2] = { -1.0, 0.90 }
	new Float:Time[4] = { 0.1, 0.1, 0.0, 0.0 }
	
	if(team == HUMAN)
	{
	static hName[64]
	ZrArrayGetString(HumanName, BeingHuman[1][iPlayer], hName, charsmax(hName))
	ShowHudMessage(iPlayer, Color,Coordinate, 0, Time, SHOWHUD, "%s:%s|生命:%d|护甲:%d", HUMANCALLED, hName, floatround(health), floatround(armorvalue))
	}
	else
	{
	static zName[64]
	ZrArrayGetString(ZombieName, BeingZombie[1][iPlayer], zName, charsmax(zName))
	ShowHudMessage(iPlayer, Color,Coordinate, 0, Time, SHOWHUD, "%s:%s|生命:%d|护甲:%d", ZOMBIECALLED, zName, floatround(health), floatround(armorvalue))
	}
	}
	if(team == HUMAN && nvgstatus[iPlayer]) FlashScreen(iPlayer, get_pcvar_num(cvar_humannvg[0]), get_pcvar_num(cvar_humannvg[1]), get_pcvar_num(cvar_humannvg[2]), get_pcvar_num(cvar_humannvg[3]))
	}
	
	if(team != ZOMBIE)
	return
	
	if(IsGhost[iPlayer])
	{
	set_pev(iPlayer, pev_flTimeStepSound, 1.0)
	return
	}
	
	if(pev(iPlayer, pev_deadflag) == DEAD_NO) FlashScreen(iPlayer, get_pcvar_num(cvar_zombienvg[0]), get_pcvar_num(cvar_zombienvg[1]), get_pcvar_num(cvar_zombienvg[2]), get_pcvar_num(cvar_zombienvg[3]))
	
	if(!ReSpawnPre[iPlayer])
	return
	
	if(roundended)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	if(get_pcvar_num(cvar_hudmessage))
	{
	new Float:Coordinate[2] = { -1.0, -1.0 }
	new Float:Time[4] = { 0.1, 0.1, 0.0, 0.0 }
	ShowHudMessage(iPlayer, szWordsColor[0], Coordinate, 0, Time, SHOWMARK, "%s%d", szWords[0], max(floatround(Playerthink[iPlayer]-fCurTime),0))
	}
	
	if(Playerthink[iPlayer] > fCurTime)
	return
	
	ExecuteForward(HookZombieSpawn, g_fwDummyResult, iPlayer)
	
	if(g_fwDummyResult)
	return
	
	ExecuteHam(Ham_CS_RoundRespawn, iPlayer)
}

public fw_CmdStart(iPlayer, uc_handle, seed)
{
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return FMRES_IGNORED
	
	if(get_uc(uc_handle, UC_Impulse) != 100)
	return FMRES_IGNORED
	
	set_uc(uc_handle, UC_Impulse, 0)
	
	return FMRES_IGNORED
}

public fw_SetClientKeyValue(iPlayer, infobuffer[], key[], value[])
{
	if(strcmp(key, "model"))
	return FMRES_IGNORED
	
	return FMRES_SUPERCEDE
}

public fw_Spawn(iEntity)
{
	if(!pev_valid(iEntity)) 
	return FMRES_IGNORED
	
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	for(new i = 0; i < sizeof g_remove_entities; i++)
	{
	if(strcmp(classname, g_remove_entities[i]))
	continue
	
	set_pev(iEntity, pev_flags, FL_KILLME)
	return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_PrecacheModel(const Model[])
{
	for(new i = 0; i < sizeof RemoveModelsPrecache; i++)
	{
	if(strcmp(Model, RemoveModelsPrecache[i]))
	continue
	
	return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_PrecacheSound(const Sound[])
{
	if(Sound[0] == 'h' && Sound[1] == 'o') 
	return FMRES_SUPERCEDE
	
	for(new i = 0; i < sizeof RemoveSoundsPrecache; i++)
	{
	if(strcmp(Sound, RemoveSoundsPrecache[i]))
	continue
	
	return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_CreateNamedEntity(strClassName)
{
	static classname[33]
	global_get(glb_pStringBase, strClassName, classname, charsmax(classname))
	
	if(strcmp(classname, "weapon_glock18") && strcmp(classname, "weapon_usp"))
	return FMRES_IGNORED
	
	return FMRES_SUPERCEDE
}

public HAM_UseStationary(iEntity, caller, activator, use_type)
{
	if(use_type != 2 || !is_user_alive(caller))
	return HAM_IGNORED
	
	if(get_pdata_int(caller, 114, 5) != ZOMBIE)
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public HAM_ButtonUse(iEntity, caller, activator, use_type)
{
	if(!is_user_alive(caller))
	return HAM_IGNORED
	
	if(get_pdata_int(caller, 114, 5) != ZOMBIE)
	return HAM_IGNORED
	
	static targetname[33]
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	
	if(strcmp(targetname, "zr_button"))
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public HAM_BarrierUsed(iEntity, caller, activator, use_type)
{
	static targetname[33]
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	
	if(contain(targetname, "zr_barrier") == -1)
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public HAM_RoundRespawn(iPlayer)
{
	if(!is_user_connected(iPlayer))
	return HAM_IGNORED
	
	RestartRound()
	
	CanChange[iPlayer] = true
	
	if(WonTeam == HUMAN)
	return HAM_IGNORED
	
	ExecuteForward(HookExchangeTeam, g_fwDummyResult, iPlayer)
	
	if(g_fwDummyResult)
	return HAM_IGNORED
	
	new team = get_pdata_int(iPlayer, 114, 5)
	if(team == ZOMBIE) set_pdata_int(iPlayer, 114, HUMAN, 5)
	else if(team == HUMAN) set_pdata_int(iPlayer, 114, ZOMBIE, 5)
	
	return HAM_IGNORED
}

public HAM_Spawn_Post(iPlayer)
{
	if(!is_user_connected(iPlayer))
	return
	
	if(is_user_bot(iPlayer))
	{
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	BotThink[iPlayer] = fCurTime + random_float(get_pcvar_float(cvar_botbuytime)/2.0, get_pcvar_float(cvar_botbuytime)*1.5)
	}
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	{
	native_set_user_human(iPlayer, 0)
	return
	}
	
	ReSpawnPre[iPlayer] = false
	
	native_set_user_zombie(iPlayer, -1)
	native_set_user_ghost(iPlayer, true)
	
	if(!is_user_bot(iPlayer))
	return
	
	ExecuteForward(HookBotSetOrigin, g_fwDummyResult, iPlayer)
	
	if(g_fwDummyResult)
	return
	
	new x, RecordHuman[33]
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	if(get_pdata_int(i, 114, 5) == ZOMBIE || is_user_stucked(i))
	continue
	
	x ++
	RecordHuman[x] = i
	}
	if(!x)
	return
	
	new Float:origin[3]
	pev(RecordHuman[random_num(1, x)], pev_origin, origin)
	set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) | FL_DUCKING)
	engfunc(EngFunc_SetSize, iPlayer, {-16.0, -16.0, -18.0}, {16.0, 16.0, 32.0})
	set_pev(iPlayer, pev_view_ofs, {0.0, 0.0, 12.0})
	set_pev(iPlayer, pev_origin, origin)
}

public HAM_Weapon_PrimaryAttack_Post(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return
	
	set_pdata_float(iEntity, 46, ZrArrayGetCell(ZombieAttackSpeed[0], BeingZombie[1][iPlayer]), 4)
}

public HAM_Weapon_SecondaryAttack_Post(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	if(!iPlayer)
	return
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return
	
	set_pdata_float(iEntity, 47, ZrArrayGetCell(ZombieAttackSpeed[1], BeingZombie[1][iPlayer]), 4)
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_alive(victim))
	return HAM_IGNORED
	
	if(roundended)
	return HAM_SUPERCEDE
	
	new team = get_pdata_int(victim, 114, 5)
	
	if(damage_type & DMG_FALL)
	{
	if(team == ZOMBIE)
	return HAM_SUPERCEDE
	
	if(!get_pcvar_num(cvar_realfalldamage))
	return HAM_IGNORED
	
	new Float:MaxHealth = (team == ZOMBIE) ?  ZrArrayGetCell(Zombiehealth, BeingZombie[1][victim]) : ZrArrayGetCell(HumanHealth, BeingHuman[1][victim])
	damage = damage/100.0*MaxHealth
	SetHamParamFloat(4, damage)
	return HAM_IGNORED
	}
	
	if(get_pcvar_float(cvar_hedamage) > 0.0 && team == ZOMBIE && (damage_type & (1<<24)))
	{
	damage *= get_pcvar_float(cvar_hedamage)
	SetHamParamFloat(4, damage)
	}
	
	if(is_user_connected(attacker))
	{
	if(get_pdata_int(attacker, 114, 5) == ZOMBIE)
	{
	new Float:dfDamge = ZrArrayGetCell(ZombieDamage, BeingZombie[1][attacker])
	damage *= dfDamge
	if(team == HUMAN)
	{
	SetHamParamFloat(4, damage)
	native_set_user_money(attacker, Money[attacker]+min(get_pcvar_num(cvar_zombiehitmoney), floatround(damage)), 1)
	}
	}
	}
	
	pev(victim, pev_velocity, KeepVelocity[victim][1])
	
	return HAM_IGNORED
}

public HAM_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_alive(victim))
	return
	
	if(roundended)
	return
	
	if((damage_type & DMG_FALL) || (damage_type & DMG_BURN) || (damage_type & DMG_SLOWBURN))
	return
	
	if(!is_user_connected(attacker) && !pev_valid(inflictor))
	return
	
	new Float:PainFree
	if(get_pdata_int(victim, 114, 5) == ZOMBIE) PainFree = ZrArrayGetCell(ZombiePainFree, BeingZombie[1][victim])
	else PainFree = ZrArrayGetCell(HumanPainFree, BeingHuman[1][victim])
	if(PainFree == 0.0) PainFree = 0.01
	new Knocker = (inflictor ? inflictor : attacker)
	new MaxSpeed = ZrArrayGetCell(ZombieMaxspeed, BeingZombie[1][victim])
	new Float:KnockBack = damage*(xs_vec_len(KeepVelocity[victim][1])/MaxSpeed+get_pcvar_float(cvar_knockthreshold))/PainFree
	ExecuteForward(HookPlayerKnockBack, g_fwDummyResult, Knocker, victim, KnockBack, inflictor, damage_type)
	
	if(g_fwDummyResult)
	{
	set_pev(victim, pev_velocity, KeepVelocity[victim][1])
	return
	}
	
	new Float:origin[3], Float:origin2[3], Float:velocity[3]
	pev(Knocker, pev_origin, origin)
	pev(victim, pev_origin, origin2)
	GetVelocityFromOrigin(origin2, origin, KnockBack, velocity)
	xs_vec_add(KeepVelocity[victim][1], velocity, KeepVelocity[victim][1])
	
	set_pev(victim, pev_velocity, KeepVelocity[victim][1])
}

public HAM_Killed(iPlayer, attacker, shouldgib)
{
	ExecuteForward(HookBodyEvent, g_fwDummyResult, iPlayer)
	if(!g_fwDummyResult) native_spawn_body(iPlayer)
	
	if(roundended)
	return HAM_IGNORED
	
	if(attacker == iPlayer || !is_user_connected(attacker))
	return HAM_IGNORED
	
	new team = get_pdata_int(iPlayer, 114, 5)
	new team2 = get_pdata_int(attacker, 114, 5)
	
	if(team == team2)
	return HAM_IGNORED
	
	if(team2 == HUMAN)
	{
	new GetMoney = ZrArrayGetCell(ZombieStyle, BeingZombie[1][iPlayer]) ? get_pcvar_num(cvar_killedbossmoney) : get_pcvar_num(cvar_humangetmoney)
	new iEntity = get_pdata_cbase(attacker, 373)
	if(pev_valid(iEntity) && get_pdata_int(iEntity, 43, 4) == CSW_KNIFE) GetMoney *= get_pcvar_num(cvar_knifeaddition)
	if(get_pdata_int(iPlayer, 75, 5) == HIT_HEAD) GetMoney *= get_pcvar_num(cvar_headaddition)
	Money[attacker] += GetMoney
	DeathMSGFIX[attacker] = true
	return HAM_IGNORED
	}
	
	Money[attacker] += get_pcvar_num(cvar_zombiegetmoney)
	
	message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"))
	write_byte(attacker)
	write_byte(iPlayer)
	write_byte(0)
	write_string("infection")
	message_end()
	
	return HAM_IGNORED
}

public HAM_Killed_Post(iPlayer, attacker, shouldgib)
{
	new team = get_pdata_int(iPlayer, 114, 5)
	
	if(team == HUMAN)
	{
	native_set_human_nvg(iPlayer, true)
	CheckRound()
	}
	
	if(roundended)
	return
	
	if(get_pcvar_num(cvar_humanrespawn) && team == HUMAN)
	{
	SnapChange[iPlayer] = true
	fm_set_user_team(iPlayer, ZOMBIE)
	team = ZOMBIE
	}
	
	if(team != ZOMBIE)
	return
	
	ExecuteForward(HookZombieSetSpawn, g_fwDummyResult, iPlayer)
	if(g_fwDummyResult)
	return
	
	SpawnZombie(iPlayer, get_pcvar_float(zr_spawn))
}

public HAM_Player_ResetMaxSpeed(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO && !IsGhost[iPlayer])
	return HAM_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) == HUMAN)
	{
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return HAM_SUPERCEDE
	
	new Float:maxspeed, Float:WeaponMaxspeed
	pev(iPlayer, pev_maxspeed, maxspeed)
	ExecuteHam(Ham_CS_Item_GetMaxSpeed, iEntity, WeaponMaxspeed)
	
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, maxspeed+WeaponMaxspeed-PostMaxSpeed[iPlayer])
	set_pev(iPlayer, pev_maxspeed, maxspeed+WeaponMaxspeed-PostMaxSpeed[iPlayer])
	
	PostMaxSpeed[iPlayer] = WeaponMaxspeed
	
	return HAM_SUPERCEDE
	}
	
	return HAM_SUPERCEDE
}

public HAM_Touch(iEntity, iPlayer)
{
	if(!is_user_alive(iPlayer))
	return HAM_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public HAM_PlayerTouch_Post(Block, Blocked)
{
	if(!is_user_alive(Blocked))
	return
	
	if(get_pdata_int(Block, 114, 5) != get_pdata_int(Blocked, 114, 5))
	return
	
	new Float:origin[2][3], Float:velocity[3]
	pev(Block, pev_origin, origin[0])
	pev(Blocked, pev_origin, origin[1])
	pev(Blocked, pev_velocity, velocity)
	xs_vec_sub(origin[1], origin[0], origin[1])
	origin[1][2] = 0.0
	xs_vec_add(origin[1], velocity, velocity)
	set_pev(Blocked, pev_velocity, velocity)
}

public HAM_Item_AddToPlayer(iEntity, iPlayer)
{
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return HAM_IGNORED
	
	set_pev(iEntity, pev_flags, FL_KILLME)
	
	return HAM_SUPERCEDE
}

public HAM_Item_Deploy(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return HAM_IGNORED
	
	engclient_cmd(iPlayer, "weapon_knife")
	
	return HAM_SUPERCEDE
}

public HAM_FIXBOTPrimaryAttack(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(!is_user_bot(iPlayer))
	return HAM_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) != HUMAN)
	return HAM_IGNORED
	
	if(get_pdata_int(iEntity, 51, 4))
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public HAM_BarrierTakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker))
	return HAM_IGNORED
	
	if(get_pdata_int(attacker, 114, 5) != ZOMBIE)
	return HAM_IGNORED
	
	if(!is_user_bot(attacker))
	return HAM_IGNORED
	
	static targetname[33]
	pev(victim, pev_targetname, targetname, charsmax(targetname))
	if(contain(targetname, "zr_barrier") == -1)
	return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public HAM_EscapeModeTouch_Post(iEntity, iPlayer)
{
	if(roundended)
	return
	
	if(!is_user_alive(iPlayer))
	return
	
	if(get_pdata_int(iPlayer, 114, 5) != HUMAN)
	return
	
	static targetname[33]
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	
	if(!strcmp(targetname, "zr_section") && SectionAmount > 1)
	{
	if(pev(iEntity, pev_iuser2) == TOUCHEDKEY)
	return
	
	if(get_pcvar_num(cvar_hudmessage))
	{
	new Color[3] = { 255, 100, 255 }
	new Float:Coordinate[2] = { -1.0, 0.3 }
	new Float:Time[4] = { 6.0, 6.0, 0.1, 0.2 }
	ShowHudMessage(0, Color, Coordinate, 0, Time, -1, "人类已完成了%d%", floatround(float(++ KeepSection)/float(SectionAmount+1)*100.0))
	}
	client_cmd(0, "spk %s", FirstPrompt)
	set_pev(iEntity, pev_iuser2, TOUCHEDKEY)
	
	ExecuteForward(FinishEvent, g_fwDummyResult, KeepSection)
	return
	}
	
	if(!Waiting)
	{
	if(strcmp(targetname, "zr_end"))
	return
	
	RoundEnd(HUMAN)
	
	return
	}
	
	if(strcmp(targetname, "zr_start"))
	return
	
	client_cmd(0, "spk %s", BeginSound)
	Waiting = false
}

public HAM_LadderTouch(iEntity, iPlayer)
{
	if(!is_user_connected(iPlayer))
	return HAM_IGNORED
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE || pev(iPlayer, pev_groundentity) == iEntity)
	return HAM_IGNORED
	
	static targetname[33]
	pev(iEntity, pev_targetname, targetname, charsmax(targetname))
	
	if(strcmp(targetname, "zr_ladder"))
	return HAM_IGNORED
	
	if(!(get_pdata_int(iPlayer, 245, 5) & IN_FORWARD))
	return HAM_IGNORED
	
	Climbing[iPlayer] = true
	KeepVelocity[iPlayer][0][2] = 200.0
	
	return HAM_IGNORED
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_Player_ResetMaxSpeed, iPlayer, "HAM_Player_ResetMaxSpeed")
	RegisterHamFromEntity(Ham_CS_RoundRespawn, iPlayer, "HAM_RoundRespawn")
	RegisterHamFromEntity(Ham_Spawn, iPlayer, "HAM_Spawn_Post", 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage")
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage_Post", 1)
	RegisterHamFromEntity(Ham_Killed, iPlayer, "HAM_Killed")
	RegisterHamFromEntity(Ham_Killed, iPlayer, "HAM_Killed_Post", 1)
	RegisterHamFromEntity(Ham_Touch, iPlayer, "HAM_PlayerTouch_Post", 1)
}

public CheckRound()
{
	if(roundended)
	return
	
	new bool:HumanAlive
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_alive(i))
	continue
	
	if(get_pdata_int(i, 114, 5) != HUMAN)
	continue
	
	HumanAlive = true
	break
	}
	if(!HumanAlive) RoundEnd(ZOMBIE)
}

public bool:CheckGameDisConnected()
{
	ExecuteForward(HookGameDisConnected, g_fwDummyResult)
	
	if(g_fwDummyResult)
	return false
	
	new Amount[2]
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i))
	continue
	
	new team = get_pdata_int(i, 114, 5)
	if(team == 3)
	continue
	
	Amount[get_pdata_int(i, 114, 5)-1] ++
	}
	
	if(!Amount[0] || !Amount[1])
	{
	roundended = false
	ZR_PatchRoundEnd(false)
	ZR_TerminateRound(1.0, 3)
	ExecuteForward(HookPrintWord, g_fwDummyResult, 0, ClientMark[0])
	if(g_fwDummyResult)
	return true
	
	client_print(0, print_center, ClientMark[0])
	
	return true
	}
	
	return false
}

public SetTeamBalance()
{
	ExecuteForward(HookBalance, g_fwDummyResult)
	
	if(g_fwDummyResult)
	return
	
	new Amount[2], KeepId[2][33]
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i))
	continue
	
	new TeamValue = get_pdata_int(i, 114, 5)-1
	Amount[TeamValue] ++
	KeepId[TeamValue][Amount[TeamValue]] = i
	}
	
	while(abs(Amount[0]-Amount[1]) > 1)
	{
	if(Amount[0] > Amount[1])
	{
	new BeTurned = KeepId[0][Amount[0]]
	fm_set_user_team(BeTurned, HUMAN)
	Amount[1] ++
	KeepId[1][Amount[1]] = BeTurned
	Amount[0] --
	
	ExecuteForward(HookPrintWord, g_fwDummyResult, BeTurned, ClientMark[1])
	if(!g_fwDummyResult) client_print(BeTurned, print_center, ClientMark[1])
	continue
	}
	
	new BeTurned = KeepId[1][Amount[1]]
	fm_set_user_team(BeTurned, ZOMBIE)
	ExecuteForward(HookPrintWord, g_fwDummyResult, BeTurned, ClientMark[2])
	if(!g_fwDummyResult) client_print(BeTurned, print_center, ClientMark[2])
	Amount[0] ++
	KeepId[0][Amount[0]] = BeTurned
	Amount[1] --
	}
}

public ChangeTeam(iPlayer)
{
	ExecuteForward(HookPlayerChangeTeam, g_fwDummyResult, iPlayer)
	
	if(g_fwDummyResult)
	return
	
	if(!CanChange[iPlayer])
	{
	ExecuteForward(HookPrintWord, g_fwDummyResult, iPlayer, ClientMark[3])
	if(!g_fwDummyResult) client_print(iPlayer, print_center, ClientMark[3])
	return
	}
	
	new Amount[2]
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i))
	continue
	
	Amount[get_pdata_int(i, 114, 5)-1] ++
	}
	
	if(!Waiting && Amount[0] && Amount[1])
	{
	ExecuteForward(HookPrintWord, g_fwDummyResult, iPlayer, ClientMark[4])
	if(!g_fwDummyResult) client_print(iPlayer, print_center, ClientMark[4])
	return
	}
	
	new Valve = get_pdata_int(iPlayer, 114, 5)-1
	if(Amount[Valve] < Amount[abs(Valve-1)])
	{
	ExecuteForward(HookPrintWord, g_fwDummyResult, iPlayer, ClientMark[5])
	if(!g_fwDummyResult) client_print(iPlayer, print_center, ClientMark[5])
	return
	}
	
	CanChange[iPlayer] = false
	if(!Valve)
	{
	if(pev(iPlayer, pev_deadflag) == DEAD_NO || IsGhost[iPlayer]) native_set_user_human(iPlayer, 0)
	else fm_set_user_team(iPlayer, HUMAN)
	CheckRound()
	CheckGameDisConnected()
	return
	}
	
	if(pev(iPlayer, pev_deadflag) == DEAD_NO || IsGhost[iPlayer])
	{
	native_set_user_zombie(iPlayer, -1)
	native_set_user_ghost(iPlayer, true)
	}
	else fm_set_user_team(iPlayer, ZOMBIE)
	CheckRound()
	CheckGameDisConnected()
}

public PrintChat(const iPlayer, const Color, const Message[], any:...)
{
	static buffer[192]
	if(1 <= Color <= 3) buffer[0] = 0x03
	else if(Color == 4) buffer[0] = 0x01
	else if(Color == 5) buffer[0] = 0x04
	vformat(buffer[1], charsmax(buffer), Message, 4)
	ShowChat(iPlayer, Color, buffer)
}

public ShowChat(const iPlayer, const Color, const Message[])
{
	ExecuteForward(HookPrintWord, g_fwDummyResult, iPlayer, Message)
	if(g_fwDummyResult)
	return
	
	new Client
	if(!iPlayer)
	{
	for(Client = 1; Client < 33; Client ++)
	{
	if(!is_user_connected(Client))
	continue
	
	break
	}
	}
	
	Client = max(Client, iPlayer)
	
	if(1 <= Color <= 3)
	{
	message_begin(iPlayer ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, get_user_msgid("TeamInfo"), _, Client)
	write_byte(Client)
	write_string(teamname[Color])
	message_end()
	}
	
	message_begin(iPlayer ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, get_user_msgid("SayText"), _, Client)
	write_byte(Client)
	write_string(Message)
	message_end()
	
	if(1 <= Color <= 3)
	{
	message_begin(iPlayer ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, get_user_msgid("TeamInfo"), _, Client)
	write_byte(Client)
	write_string(teamname[get_pdata_int(Client, 114, 5)])
	message_end()
	}
}

public bool:FlashScreen(iPlayer, R, B, G, density)
{
	if(flashing[iPlayer] <= density)
	{
	flashing[iPlayer] = 0
	return false
	}
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	if(Playerthink[iPlayer] > fCurTime)
	return true
	
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0, 0, 0}, iPlayer)
	write_short(~0)
	write_short(~0)
	write_short(0x0004)
	write_byte(R)
	write_byte(B)
	write_byte(G)
	write_byte(flashing[iPlayer])
	message_end()
	
	flashing[iPlayer] --
	
	return true
}

public NvgScreen(iPlayer, R, B, G, density)
{
	ExecuteForward(HookScreenFade, g_fwDummyResult, iPlayer, R, B, G, density)
	
	if(g_fwDummyResult)
	return
	
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0, 0, 0}, iPlayer)
	if(R || B || G || density)
	{
	write_short(~0)
	write_short(~0)
	write_short(0x0004)
	}
	else
	{
	write_short(0)
	write_short(0)
	write_short(0)
	}
	write_byte(R)
	write_byte(B)
	write_byte(G)
	write_byte(density)
	message_end()
}

public ZombieProperty(iPlayer, bool:Ghost)
{
	if(Ghost)
	{
	set_pev(iPlayer, pev_deadflag, DEAD_RESPAWNABLE)
	set_pev(iPlayer, pev_solid, SOLID_NOT)
	set_pev(iPlayer, pev_gravity, get_pcvar_float(cvar_ghostgravity))
	set_pev(iPlayer, pev_maxspeed, get_pcvar_float(cvar_ghostspeed))
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, get_pcvar_float(cvar_ghostspeed))
	SetLightstyle(iPlayer, lightsize[get_pcvar_num(cvar_ghostnvg[4])])
	NvgScreen(iPlayer, get_pcvar_num(cvar_ghostnvg[0]), get_pcvar_num(cvar_ghostnvg[1]), get_pcvar_num(cvar_ghostnvg[2]), get_pcvar_num(cvar_ghostnvg[3]))
	SetScoreAttrib(iPlayer, 1)
	return
	}
	
	set_pev(iPlayer, pev_deadflag, DEAD_NO)
	set_pev(iPlayer, pev_solid, SOLID_SLIDEBOX)
	set_pev(iPlayer, pev_gravity, ZrArrayGetCell(ZombieGravity, BeingZombie[1][iPlayer]))
	set_pev(iPlayer, pev_maxspeed, ZrArrayGetCell(ZombieMaxspeed, BeingZombie[1][iPlayer]))
	set_pev(iPlayer, pev_flTimeStepSound, 0.0)
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, ZrArrayGetCell(ZombieMaxspeed, BeingZombie[1][iPlayer]))
	set_pdata_float(iPlayer, 83, 0.5, 5)
	SetLightstyle(iPlayer, lightsize[get_pcvar_num(cvar_zombienvg[4])])
	NvgScreen(iPlayer, get_pcvar_num(cvar_zombienvg[0]), get_pcvar_num(cvar_zombienvg[1]), get_pcvar_num(cvar_zombienvg[2]), get_pcvar_num(cvar_zombienvg[3]))
	SetScoreAttrib(iPlayer, 0)
}

public SpawnZombie(iPlayer, Float:time)
{
	if(!is_user_connected(iPlayer))
	{
	log_error(AMX_ERR_NATIVE, "Error:zr_spawn_zombie")
	return
	}
	
	if(pev(iPlayer, pev_deadflag) == DEAD_NO)
	return
	
	if(get_pdata_int(iPlayer, 114, 5) != ZOMBIE)
	return
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	
	IsGhost[iPlayer] = false
	Playerthink[iPlayer] = fCurTime + time
	ReSpawnPre[iPlayer] = true
	
	if(!get_pcvar_num(cvar_linehud))
	return
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("BarTime"), _, iPlayer)
	write_short(floatround(time))
	message_end()
}

public native_enforce_roundend(Team)
{
	if(roundended)
	return
	
	roundended = true
	WonTeam = Team
	ExecuteForward(HookPrintWord, g_fwDummyResult, 0, szWords[8-Team])
	if(!g_fwDummyResult) client_print(0, print_center, szWords[8-Team])
	client_cmd(0, "spk %s", WinSound[Team-1])
	ZR_PatchRoundEnd(false)
	Team == HUMAN ? ZR_TerminateRound(get_pcvar_float(cvar_enddeploy), ZOMBIE) : ZR_TerminateRound(get_pcvar_float(cvar_enddeploy), HUMAN)
	ZR_SetTeamScore(Team, ZR_GetTeamScore(Team)+1)
	ZR_UpdateTeamScore(Team)
	for(new i = 1; i < 33; i ++)
	{
	if(!is_user_connected(i))
	continue
	
	if(get_pdata_int(i, 114, 5) != Team)
	continue
	
	native_set_user_money(i, Money[i]+get_pcvar_num(cvar_winmoney), 1)
	}
}

public bool:native_zr_is_escapemode() return EscapeMode

public bool:native_zbot_supported() return ZbotSupported

public bool:native_is_user_ghost(iPlayer) return IsGhost[iPlayer]

public bool:native_is_zombie_boss(type) return ZrArrayGetCell(ZombieStyle, IDToSequence(ZOMBIE, type))

public native_get_zombie_id(iPlayer) return ZrArrayGetCell(ZombieID, BeingZombie[1][iPlayer])

public bool:native_is_zombie_male(type) return ZrArrayGetCell(ZombieMale, IDToSequence(ZOMBIE, type))

public native_get_nextzombie_id(iPlayer) return ZrArrayGetCell(ZombieID, BeingZombie[0][iPlayer])

public native_set_nextzombie_id(iPlayer, type) BeingZombie[0][iPlayer] = IDToSequence(ZOMBIE, type)

public native_get_zombie_name(iPlugin, iParams)
{
	static zName[64]
	ZrArrayGetString(ZombieName, IDToSequence(ZOMBIE, get_param(1)), zName, charsmax(zName))
	set_string(2, zName, get_param(3))
}

public native_get_zombie_info(iPlugin, iParams)
{
	static zInfo[64]
	ZrArrayGetString(ZombieInfo, IDToSequence(ZOMBIE, get_param(1)), zInfo, charsmax(zInfo))
	set_string(2, zInfo, get_param(3))
}

public Float:native_get_zombie_health(type) return ZrArrayGetCell(Zombiehealth, IDToSequence(ZOMBIE, type))

public native_get_zombie_claw(iPlugin, iParams)
{
	static vModel[32]
	ZrArrayGetString(ZombieVModel, IDToSequence(ZOMBIE, get_param(1)), vModel, charsmax(vModel))
	set_string(2, vModel, get_param(3))
}

public native_get_zombie_model(iPlugin, iParams)
{
	static zModel[32]
	ZrArrayGetString(ZombieModel, IDToSequence(ZOMBIE, get_param(1)), zModel, charsmax(zModel))
	set_string(2, zModel, get_param(3))
}

public native_get_human_id(iPlayer) return ZrArrayGetCell(HumanID, BeingHuman[1][iPlayer])

public bool:native_is_human_male(type) return ZrArrayGetCell(HumanMale, IDToSequence(HUMAN, type))

public native_get_nexthuman_id(iPlayer) return ZrArrayGetCell(HumanID, BeingHuman[0][iPlayer])

public native_set_nexthuman_id(iPlayer, type) BeingHuman[0][iPlayer] = IDToSequence(HUMAN, get_param(1))

public native_get_human_name(iPlugin, iParams)
{
	static hName[64]
	ZrArrayGetString(HumanName, IDToSequence(HUMAN, get_param(1)), hName, charsmax(hName))
	set_string(2, hName, get_param(3))
}

public native_get_human_info(iPlugin, iParams)
{
	static hInfo[64]
	ZrArrayGetString(HumanInfo, IDToSequence(HUMAN, get_param(1)), hInfo, charsmax(hInfo))
	set_string(2, hInfo, get_param(3))
}

public Float:native_get_human_health(type) return ZrArrayGetCell(HumanHealth, IDToSequence(HUMAN, type))

public native_get_human_model(iPlugin, iParams)
{
	static hModel[32]
	ZrArrayGetString(HumanModel, IDToSequence(HUMAN, get_param(1)), hModel, charsmax(hModel))
	set_string(2, hModel, get_param(3))
}

public bool:native_get_human_nvg(iPlayer) return nvgstatus[iPlayer]

public native_get_user_money(iPlayer) return Money[iPlayer]

public native_set_animation(iPlayer, Float:Time, Anim, GaitAnim)
{
	if(!is_user_connected(iPlayer))
	{
	log_error(AMX_ERR_NATIVE, "Error:zr_set_user_anim")
	return
	}
	
	ZR_SetAnimation(iPlayer, Float:Time, Anim, GaitAnim)
}

public native_get_item_amount() return szItemId

public native_get_item_name(iPlugin, iParams)
{
	static szName[64]
	ZrArrayGetString(szItemName, get_param(1), szName, charsmax(szName))
	set_string(2, szName, get_param(3))
}

public native_get_item_team(item) return ZrArrayGetCell(ItemTeam, item)

public native_get_item_slot(item) return ZrArrayGetCell(ItemSlot, item)

public native_get_lefttime() return RoundTime

public native_get_light(iPlugin, iParams) set_string(1, lightstyle, get_param(2))

public native_set_user_item(iPlayer, item) ExecuteForward(ItemEvent, g_fwDummyResult, iPlayer, item, ZrArrayGetCell(ItemSlot, item))

public native_get_wonteam() return WonTeam

public native_get_zombie_amount() return ZombieAmount

public native_get_human_amount() return HumanAmount

public bool:native_get_snapchange(iPlayer) return SnapChange[iPlayer]

public bool:native_is_zombie_hidden(type) return ZrArrayGetCell(HiddenZombie, IDToSequence(ZOMBIE, type))

public bool:native_is_human_hidden(type) return ZrArrayGetCell(HiddenHuman, IDToSequence(HUMAN, type))

public native_set_user_zombie(iPlayer, value)
{
	ExecuteForward(HookBecomingZombie, g_fwDummyResult, iPlayer, value)
	
	if(g_fwDummyResult)
	return
	
	fm_set_user_team(iPlayer, ZOMBIE)
	
	new Sequence = IDToSequence(ZOMBIE, value)
	
	if(value > 0)
	{
	if(!ZrArrayGetCell(ZombieStyle, Sequence)) BeingZombie[0][iPlayer] = Sequence
	BeingZombie[1][iPlayer] = Sequence
	}
	else
	if(value <= 0 && pev(iPlayer, pev_deadflag) == DEAD_NO)
	{
	new BossZombieType[ZOMBIEMAX+1], bossconst
	if(!SetZombieFixed[iPlayer])
	{
	for(new i = 1 ; i <= ZombieAmount ; i++)
	{
	if(!ZrArrayGetCell(ZombieStyle, i) || ZrArrayGetCell(HiddenZombie, i))
	continue
	
	bossconst ++
	BossZombieType[bossconst] = i
	}
	}
	if(bossconst > 0 && random_float(0.0, 100.0) <= get_pcvar_float(cvar_bosspbty)*100.0)
	{
	BeingZombie[1][iPlayer] = BossZombieType[random_num(1, bossconst)]
	static netname[33], zName[64]
	pev(iPlayer, pev_netname, netname, charsmax(netname))
	ZrArrayGetString(ZombieName, BeingZombie[1][iPlayer], zName, charsmax(zName))
	PrintChat(0, GREENCHAT, "%s%s%s", netname, ClientMark[6], zName)
	}
	else
	{
	if(is_user_bot(iPlayer))
	{
	new BotZombieType[ZOMBIEMAX+1], zombieconst
	for(new i = 1 ; i <= ZombieAmount ; i++)
	{
	if(ZrArrayGetCell(ZombieStyle, i) || ZrArrayGetCell(HiddenZombie, i))
	continue
	
	zombieconst ++
	BotZombieType[zombieconst] = i
	}
	BeingZombie[1][iPlayer] = BotZombieType[random_num(1, zombieconst)]
	}
	else BeingZombie[1][iPlayer] = BeingZombie[0][iPlayer]
	if(!SetZombieFixed[iPlayer])
	{
	static zName[64]
	ZrArrayGetString(ZombieName, BeingZombie[1][iPlayer], zName, charsmax(zName))
	PrintChat(iPlayer, REDCHAT, "%s%s", ClientMark[7], zName)
	}
	}
	}
	
	if(pev(iPlayer, pev_deadflag) != DEAD_NO && !IsGhost[iPlayer])
	{
	SetZombieFixed[iPlayer] = true
	ExecuteHam(Ham_CS_RoundRespawn, iPlayer)
	return
	}
	
	if(value != -1) ZombieProperty(iPlayer, false)
	if(HideAcross) set_pdata_int(iPlayer, 361, get_pdata_int(iPlayer, 361) | (1<<6))
	if(pev(iPlayer, pev_effects) & EF_DIMLIGHT) set_pev(iPlayer, pev_impulse, 100)
	else set_pev(iPlayer, pev_impulse, 0)
	set_pev(iPlayer, pev_health, ZrArrayGetCell(Zombiehealth, BeingZombie[1][iPlayer]))
	set_pev(iPlayer, pev_armorvalue, 0.0)
	set_pev(iPlayer, pev_fuser4, 20520.0)
	set_pdata_int(iPlayer, 112, 0, 5)
	set_pdata_int(iPlayer, 363, 90, 5)
	set_pdata_int(iPlayer, 129, get_pdata_int(iPlayer, 129, 5) &~ (1<<0), 5)
	PostMaxSpeed[iPlayer] = 250.0
	nvgstatus[iPlayer] = false
	DeathMSGFIX[iPlayer] = false
	SetZombieFixed[iPlayer] = false
	flashing[iPlayer] = 0
	SetKnife(iPlayer)
	static viewmodel[64], zModel[32]
	ZrArrayGetString(ZombieModel, BeingZombie[1][iPlayer], zModel, charsmax(zModel))
	set_user_model(iPlayer, zModel, false)
	ZrArrayGetString(ZombieVModel, BeingZombie[1][iPlayer], viewmodel, charsmax(viewmodel))
	format(viewmodel, charsmax(viewmodel), "models/zombieriot/%s", viewmodel)
	set_pev(iPlayer, pev_viewmodel2, viewmodel)
	set_pev(iPlayer, pev_weaponmodel2, 0)
	ExecuteForward(BeingZombieEvent, g_fwDummyResult, iPlayer)
}

public native_set_user_ghost(iPlayer, bool:value)
{
	if(get_pdata_int(iPlayer, 114, 5) == HUMAN)
	return
	
	if(value)
	{
	IsGhost[iPlayer] = true
	ZombieProperty(iPlayer, true)
	client_cmd(iPlayer, "spk %s", BeingGhost)
	ExecuteForward(BeingGhostEvent, g_fwDummyResult, iPlayer)
	return
	}
	
	if(!IsGhost[iPlayer])
	return
	
	IsGhost[iPlayer] = false
	ZombieProperty(iPlayer, false)
	FlashScreen(iPlayer, get_pcvar_num(cvar_zombienvg[0]), get_pcvar_num(cvar_zombienvg[1]), get_pcvar_num(cvar_zombienvg[2]), get_pcvar_num(cvar_zombienvg[3]))
	
	ExecuteForward(GhostSpawnEvent, g_fwDummyResult, iPlayer)
}

public native_set_user_human(iPlayer, value)
{
	ExecuteForward(HookBecomingHuman, g_fwDummyResult, iPlayer, value)
	
	if(g_fwDummyResult)
	return
	
	new Sequence = IDToSequence(HUMAN, value)
	
	if(!value)
	{
	if(is_user_bot(iPlayer))
	{
	new BotHumanType[HUMANMAX+1], humanconst
	for(new i = 1 ; i <= HumanAmount ; i++)
	{
	if(ZrArrayGetCell(HiddenHuman, i))
	continue
	
	humanconst ++
	BotHumanType[humanconst] = i
	}
	BeingHuman[1][iPlayer] = BotHumanType[random_num(1, humanconst)]
	}
	else BeingHuman[1][iPlayer] = BeingHuman[0][iPlayer]
	}
	else BeingHuman[1][iPlayer] = Sequence
	
	fm_set_user_team(iPlayer, HUMAN)
	
	if(pev(iPlayer, pev_deadflag) != DEAD_NO && !IsGhost[iPlayer])
	{
	ExecuteHam(Ham_CS_RoundRespawn, iPlayer)
	return
	}
	
	if(HideAcross) set_pdata_int(iPlayer, 361, get_pdata_int(iPlayer, 361, 5) &~ (1<<6), 5)
	set_pev(iPlayer, pev_deadflag, DEAD_NO)
	set_pev(iPlayer, pev_solid, SOLID_SLIDEBOX)
	set_pev(iPlayer, pev_flTimeStepSound, 0.0)
	set_pev(iPlayer, pev_armorvalue, 0.0)
	set_pdata_int(iPlayer, 112, 0, 5)
	set_pev(iPlayer, pev_health, ZrArrayGetCell(HumanHealth, BeingHuman[1][iPlayer]))
	set_pev(iPlayer, pev_gravity, ZrArrayGetCell(HumanGravity, BeingHuman[1][iPlayer]))
	set_pev(iPlayer, pev_maxspeed, ZrArrayGetCell(HumanMaxSpeed, BeingHuman[1][iPlayer]))
	set_pev(iPlayer, pev_fuser4, 0.0)
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, ZrArrayGetCell(HumanMaxSpeed, BeingHuman[1][iPlayer]))
	PostMaxSpeed[iPlayer] = 250.0
	if(pev(iPlayer, pev_effects) & EF_DIMLIGHT) set_pev(iPlayer, pev_impulse, 100)
	else set_pev(iPlayer, pev_impulse, 0)
	static hModel[32]
	ZrArrayGetString(HumanModel, BeingHuman[1][iPlayer], hModel, charsmax(hModel))
	set_user_model(iPlayer, hModel, false)
	SetLightstyle(iPlayer, lightstyle)
	nvgstatus[iPlayer] = false
	IsGhost[iPlayer] = false
	DeathMSGFIX[iPlayer] = false
	flashing[iPlayer] = 0
	NvgScreen(iPlayer, 0, 0, 0, 0)
	SetScoreAttrib(iPlayer, 0)
	engclient_cmd(iPlayer, "weapon_knife")
	new iEntity = get_pdata_cbase(iPlayer, 370, 5)
	if(pev_valid(iEntity)) ExecuteHam(Ham_Item_Deploy, iEntity)
	ExecuteForward(BeingHumanEvent, g_fwDummyResult, iPlayer)
}

public native_set_user_money(iPlayer, money, Flag)
{
	if(!is_user_connected(iPlayer))
	{
	log_error(AMX_ERR_NATIVE, "Error:zr_set_user_money")
	return
	}
	
	Money[iPlayer] = money
	set_pdata_int(iPlayer, 115, 0, 5)
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Money"), {0,0,0}, iPlayer)
	write_long(money)
	write_byte(Flag)
	message_end()
}

public native_set_user_model(iPlugin, iParams)
{
	static model[33]
	get_string(2, model, charsmax(model))
	set_user_model(get_param(1), model, true)
}

public native_zr_print_chat(iPlugin, iParams)
{
	static buffer[192]
	if(1 <= get_param(2) <= 3) buffer[0] = 0x03
	else if(get_param(2) == 4) buffer[0] = 0x01
	else if(get_param(2) == 5) buffer[0] = 0x04
	vdformat(buffer[1], charsmax(buffer), 3, 4)
	ShowChat(get_param(1), get_param(2), buffer)
}

public bool:native_is_user_zombie(iPlayer)
{
	if(!is_user_connected(iPlayer))
	{
	log_error(AMX_ERR_NATIVE, "Error:zr_is_user_zombie")
	return false
	}
	
	if(get_pdata_int(iPlayer, 114, 5) == ZOMBIE)
	return true
	
	return false
}

public native_set_human_nvg(iPlayer, bool:Mode)
{
	if(get_pdata_int(iPlayer, 114, 5) == ZOMBIE)
	return
	
	if(pev(iPlayer, pev_deadflag) == DEAD_NO) client_cmd(iPlayer, "spk %s", NvgSound[Mode])
	
	nvgstatus[iPlayer] = Mode
	
	if(Mode)
	{
	NvgScreen(iPlayer, get_pcvar_num(cvar_humannvg[0]), get_pcvar_num(cvar_humannvg[1]), get_pcvar_num(cvar_humannvg[2]), get_pcvar_num(cvar_humannvg[3]))
	SetLightstyle(iPlayer, lightsize[get_pcvar_num(cvar_humannvg[4])])
	return
	}
	
	NvgScreen(iPlayer, 0, 0, 0, 0)
	SetLightstyle(iPlayer, lightstyle)
}

public native_get_user_model(iPlugin, iParams)
{
	static model[33]
	engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, get_param(1)), "model", model, charsmax(model))
	set_string(2, model, get_param(3))
}

public native_register_item(iPlugin, iParams)
{
	if(szItemId >= MAXITEM)
	return 0
	
	szItemId ++
	static szName[64]
	get_string(1, szName, charsmax(szName))
	ArrayPushString(szItemName, szName)
	ArrayPushCell(ItemTeam, get_param(2))
	ArrayPushCell(ItemSlot, get_param(3))
	
	return szItemId
}

public native_get_team_score(Team) return ZR_GetTeamScore(Team)

public native_set_team_score(Team, score) ZR_SetTeamScore(Team, score)

public set_user_model(iPlayer, const model[], bool:Pre)
{
	if(!Pre)
	{
	SetModelPost[iPlayer] = get_gametime() + 0.05
	copy(KeepModel[iPlayer], charsmax(KeepModel[]), model)
	return
	}
	
	engfunc(EngFunc_SetClientKeyValue, iPlayer, engfunc(EngFunc_GetInfoKeyBuffer, iPlayer), "model", model)
	static ModelPath[64]
	formatex(ModelPath, charsmax(ModelPath), "models/player/%s/%s.mdl", model, model)
	if(get_pcvar_num(cvar_modelindex)) set_pdata_int(iPlayer, 491, engfunc(EngFunc_ModelIndex, ModelPath), 5)
	SetModelPost[iPlayer] = -1.0
}

public IDToSequence(Team, Type)
{
	new Amount
	if(Team == ZOMBIE) Amount = ZombieAmount
	else Amount = HumanAmount
	
	new a
	for(new i = 1 ; i <= Amount ; i++)
	{
	if(Team == ZOMBIE) a = ZrArrayGetCell(ZombieID, i)
	else a = ZrArrayGetCell(HumanID, i)
	if(a != Type)
	continue
	
	return i
	}
	
	return 0
}

public SequenceToID(Team, Sequence)
{
	if(Team == ZOMBIE)
	return ZrArrayGetCell(ZombieID, Sequence)
	
	return ZrArrayGetCell(HumanID, Sequence)
}

public native_set_knockback(Knocker, victim, Float:Speed)
{
	if(Speed == 0.0)
	return
	
	new Float:origin1[3], Float:origin2[3], Float:velocity[3]
	pev(victim, pev_origin, origin1)
	pev(Knocker, pev_origin, origin2)
	
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/Speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
	
	new Float:velocity2[3]
	pev(victim, pev_velocity, velocity2)
	xs_vec_add(velocity, velocity2, velocity)
	set_pev(victim, pev_velocity, velocity)
}

public native_set_lefttime(lefttime)
{
	RoundTime = lefttime
	message_begin(MSG_BROADCAST, get_user_msgid("RoundTime"))
	write_short(RoundTime+1)
	message_end()
}

public native_set_light(iPlugin, iParams)
{
	get_string(1, lightstyle, charsmax(lightstyle))
	engfunc(EngFunc_LightStyle, 0, lightstyle)
}

public native_get_weather() return WeatherStyle

public native_set_weather(WeatherIndex)
{
	WeatherStyle = WeatherIndex
	switch(WeatherStyle)
	{
	case 1: sunny()
	case 2: drizzle()
	case 3: thunderstorm()
	case 4: tempest()
	case 5: snow()
	case 6: fog()
	case 7: blackfog()
	}
}

public native_set_fog(R, G, B, density)
{
	message_begin(MSG_BROADCAST, get_user_msgid("Fog"))
	write_byte(R)
	write_byte(G)
	write_byte(B)
	write_byte(g_fog_density[4*density])
	write_byte(g_fog_density[4*density+1])
	write_byte(g_fog_density[4*density+2])
	write_byte(g_fog_density[4*density+3])
	message_end()
}

public bool:native_check_admin(iPlayer)
{
	if(!is_user_connected(iPlayer))
	{
	log_error(AMX_ERR_NATIVE, "Error:zr_check_admin")
	return false
	}
	
	if(Admins[0][0] == '0')
	return true
	
	static Flags[33]
	get_flags(get_user_flags(iPlayer), Flags, charsmax(Flags))
	for(new i = 0; i < AdminStock; i ++)
	{
	if(contain(Flags, Admins[i]) == -1)
	continue
	
	return true
	}
	
	return false
}

public native_reset_round()
{
	roundended = true
	ZR_SetTeamScore(HUMAN, 0)
	ZR_UpdateTeamScore(HUMAN)
	ZR_SetTeamScore(ZOMBIE, 0)
	ZR_UpdateTeamScore(ZOMBIE)
	ZR_TerminateRound(get_pcvar_float(cvar_enddeploy), 3)
	CurrentWeather = 1
}

public native_spawn_body(iPlayer)
{
	if(!is_user_connected(iPlayer))
	{
	log_error(AMX_ERR_NATIVE, "Error:zr_spawn_body")
	return
	}
	
	new Float:origin[3], Float:angles[3]
	pev(iPlayer, pev_angles, angles)
	pev(iPlayer, pev_origin, origin)
	
	static model[64]
	engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, iPlayer), "model", model, charsmax(model))
	format(model, charsmax(model), "models/player/%s/%s.mdl", model, model)
	
	new HitGroup = get_pdata_int(iPlayer, 75, 5)
	new Sequence
	if(!(pev(iPlayer, pev_flags) & FL_DUCKING))
	{
	switch(HitGroup)
	{
	case HIT_GENERIC:
	{
	switch(random_num(0, 2))
	{
	case 0: Sequence = lookup_sequence(iPlayer, "death1")
	case 1: Sequence = lookup_sequence(iPlayer, "death2")
	case 2: Sequence = lookup_sequence(iPlayer, "death3")
	}
	}
	case HIT_HEAD: Sequence = lookup_sequence(iPlayer, "head")
	case HIT_CHEST:
	{
	switch(random_num(0, 4))
	{
	case 0: Sequence = lookup_sequence(iPlayer, "death1")
	case 1: Sequence = lookup_sequence(iPlayer, "death2")
	case 2: Sequence = lookup_sequence(iPlayer, "death3")
	case 3: Sequence = lookup_sequence(iPlayer, "forward")
	case 4: Sequence = lookup_sequence(iPlayer, "back")
	}
	}
	case HIT_STOMACH: Sequence = lookup_sequence(iPlayer, "gutshot")
	case HIT_LEFTARM: Sequence = lookup_sequence(iPlayer, "left")
	case HIT_RIGHTARM: Sequence = lookup_sequence(iPlayer, "right")
	case HIT_LEFTLEG: Sequence = lookup_sequence(iPlayer, "left")
	case HIT_RIGHTLEG: Sequence = lookup_sequence(iPlayer, "right")
	}
	}
	else Sequence = lookup_sequence(iPlayer, "crouch_die")
	
	message_begin(MSG_BROADCAST, get_user_msgid("ClCorpse"))
	write_string(model)
	write_long(floatround(origin[0])*128)
	write_long(floatround(origin[1])*128)
	write_long(floatround(origin[2])*128)
	engfunc(EngFunc_WriteCoord, angles[0])
	engfunc(EngFunc_WriteCoord, angles[1])
	engfunc(EngFunc_WriteCoord, angles[2])
	write_long(0)
	write_byte(Sequence)
	write_byte(pev(iPlayer, pev_body))
	message_end()
}

public native_resetmaxspeed(iPlayer)
{
	if(!is_user_connected(iPlayer))
	{
	log_error(AMX_ERR_NATIVE, "Error:zr_resetmaxspeed")
	return
	}
	
	new team = get_pdata_int(iPlayer, 114, 5)
	if(team == HUMAN)
	{
	set_pev(iPlayer, pev_maxspeed, ZrArrayGetCell(HumanMaxSpeed, BeingHuman[1][iPlayer]))
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, ZrArrayGetCell(HumanMaxSpeed, BeingHuman[1][iPlayer]))
	PostMaxSpeed[iPlayer] = 250.0
	ExecuteHam(Ham_Player_ResetMaxSpeed, iPlayer)
	ExecuteForward(ResetMaxspeedEvent, g_fwDummyResult, iPlayer, ZrArrayGetCell(HumanMaxSpeed, BeingHuman[1][iPlayer]))
	return
	}
	
	if(!IsGhost[iPlayer])
	{
	set_pev(iPlayer, pev_maxspeed, ZrArrayGetCell(ZombieMaxspeed, BeingZombie[1][iPlayer]))
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, ZrArrayGetCell(ZombieMaxspeed, BeingZombie[1][iPlayer]))
	ExecuteForward(ResetMaxspeedEvent, g_fwDummyResult, iPlayer, ZrArrayGetCell(ZombieMaxspeed, BeingZombie[1][iPlayer]))
	return
	}
	
	set_pev(iPlayer, pev_maxspeed, get_pcvar_float(cvar_ghostspeed))
	engfunc(EngFunc_SetClientMaxspeed, iPlayer, get_pcvar_float(cvar_ghostspeed))
	ExecuteForward(ResetMaxspeedEvent, g_fwDummyResult, iPlayer, get_pcvar_float(cvar_ghostspeed))
}

public native_set_snapchange(iPlayer, bool:value) SnapChange[iPlayer] = value

public native_get_linedata(iPlugin, iParams)
{
	static config[32], file[256], linedata[1024]
	get_localinfo("amxx_configsdir", config, charsmax(config))
	get_string(1, file, charsmax(file))
	format(file, charsmax(file), "%s/%s", config, file)
	new line = get_param(2)
	ReadFile(file, line, linedata, charsmax(linedata))
	set_string(3, linedata, get_param(4))
}

public native_set_linedata(iPlugin, iParams)
{
	static config[32], file[256], linedata[1024]
	get_localinfo("amxx_configsdir", config, charsmax(config))
	get_string(1, file, charsmax(file))
	get_string(3, linedata, charsmax(linedata))
	format(file, charsmax(file), "%s/%s", config, file)
	write_file(file, linedata, get_param(2)-1)
}

public native_register_zombie(iPlugin, iParams)
{
	if(ZombieAmount >= ZOMBIEMAX)
	return 0
	
	ZombieAmount ++
	ArrayPushCell(ZombieID, (++ExtraZombie)+ZombieIDSum)
	
	static zName[64], zInfo[64], zModel[64], zVModel[64]
	get_string(1, zName, charsmax(zName))
	get_string(2, zInfo, charsmax(zInfo))
	get_string(3, zModel, charsmax(zModel))
	get_string(4, zVModel, charsmax(zVModel))
	
	ArrayPushString(ZombieName, zName)
	ArrayPushString(ZombieInfo, zInfo)
	ArrayPushString(ZombieModel, zModel)
	ArrayPushString(ZombieVModel, zVModel)
	ArrayPushString(ZombieVModel, zVModel)
	ArrayPushCell(Zombiehealth, get_param_f(5))
	ArrayPushCell(ZombieMaxspeed, get_param_f(6))
	ArrayPushCell(ZombieGravity, get_param_f(7))
	ArrayPushCell(ZombieAttackSpeed[0], get_param_f(8))
	ArrayPushCell(ZombieAttackSpeed[1], get_param_f(8))
	ArrayPushCell(ZombieAttackDist[0], get_param_f(10))
	ArrayPushCell(ZombieAttackDist[1], get_param_f(11))
	ArrayPushCell(ZombieDamage, get_param_f(12))
	ArrayPushCell(ZombiePainFree, get_param_f(13))
	get_param(14)?ArrayPushCell(HiddenZombie, true):ArrayPushCell(HiddenZombie, false)
	get_param(15)?ArrayPushCell(ZombieStyle, true):ArrayPushCell(ZombieStyle, false)
	
	format(zModel, charsmax(zModel), "models/player/%s/%s.mdl", zModel, zModel)
	engfunc(EngFunc_PrecacheModel, zModel)
	format(zVModel, charsmax(zVModel), "models/zombieriot/%s", zVModel)
	engfunc(EngFunc_PrecacheModel, zVModel)
	
	return SequenceToID(ZOMBIE, ZombieAmount)
}

public native_register_human(iPlugin, iParams)
{
	if(HumanAmount >= HUMANMAX)
	return 0
	
	HumanAmount ++
	ArrayPushCell(HumanID, (++ExtraHuman)+HumanIDSum)

	static hName[64], hInfo[64], hModel[64]
	get_string(1, hName, charsmax(hName))
	get_string(2, hInfo, charsmax(hInfo))
	get_string(3, hModel, charsmax(hModel))
	
	ArrayPushCell(HumanHealth, get_param_f(4))
	ArrayPushCell(HumanMaxSpeed, get_param_f(5))
	ArrayPushCell(HumanGravity, get_param_f(6))
	ArrayPushCell(HumanPainFree, get_param_f(7))
	get_param(8)?ArrayPushCell(HiddenHuman, true):ArrayPushCell(HiddenHuman, false)
	ArrayPushString(HumanName, hName)
	ArrayPushString(HumanInfo, hInfo)
	ArrayPushString(HumanModel, hModel)
	
	format(hModel, charsmax(hModel), "models/player/%s/%s.mdl", hModel, hModel)
	engfunc(EngFunc_PrecacheModel, hModel)
	
	return SequenceToID(HUMAN, HumanAmount)
}

public native_zr_get_maxsection() return SectionAmount

public ShowHudMessage(iPlayer, const Color[3], const Float:Coordinate[2], const Effects, const Float:Time[4], const Channel, const Message[], any:...)
{
	static buffer[192]
	vformat(buffer, charsmax(buffer), Message, 8)
	
	ExecuteForward(HookHudMessage, g_fwDummyResult, iPlayer, buffer, Channel)
	if(g_fwDummyResult)
	return
	
	set_hudmessage(Color[0], Color[1], Color[2], Coordinate[0], Coordinate[1], Effects, Time[0], Time[1], Time[2], Time[3], Channel)
	show_hudmessage(iPlayer, buffer)
}

public SetKnife(iPlayer)
{
	for(new i = 1; i < 6; i ++)
	{
	new iEntity = get_pdata_cbase(iPlayer, 367+i, 5)
	while(iEntity > 0)
	{
	if(i == 3)
	{
	ExecuteHam(Ham_Item_Deploy, iEntity)
	break
	}
	ExecuteHamB(Ham_Weapon_RetireWeapon, iEntity)
	ExecuteHamB(Ham_RemovePlayerItem, iPlayer, iEntity)
	ExecuteHamB(Ham_Item_Kill, iEntity)
	set_pev(iPlayer, pev_weapons, pev(iPlayer, pev_weapons) & ~(1<<get_pdata_int(iEntity, 43, 4)))
	iEntity = get_pdata_cbase(iEntity, 42, 4)
	}
	set_pdata_cbase(iPlayer, 367, -1, 5)
	}
}

public SetScoreAttrib(iPlayer, value)
{
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
	write_byte(iPlayer)
	write_byte(value)
	message_end()
}

public SetLightstyle(iPlayer, const light[])
{
	ExecuteForward(HookLightStyle, g_fwDummyResult, iPlayer, light)
	if(g_fwDummyResult)
	return
	
	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, iPlayer)
	write_byte(0)
	write_string(light)
	message_end()
}

public SetReceiveW(value)
{
	message_begin(MSG_BROADCAST, get_user_msgid("ReceiveW"))
	write_byte(value)
	message_end()
}

public SetFog(R, G, B, density)
{
	ExecuteForward(HookFog, g_fwDummyResult, R, G, B, density)
	if(g_fwDummyResult)
	return
	
	native_set_fog(R, G, B, density)
}

public fm_set_user_team(iPlayer, team)
{
	set_pdata_int(iPlayer, 114, team, 5)
	message_begin(MSG_BROADCAST, get_user_msgid("TeamInfo"))
	write_byte(iPlayer)
	write_string(teamname[team])
	message_end()
}

public GetVelocityToOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin2, origin1, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}

public GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}

public bool:SkyFromPlayer(Float:origin[3])
{
	static Float:start[3]
	xs_vec_copy(origin, start)
	origin[2] += 9999.0
	engfunc(EngFunc_TraceLine, start, origin, IGNORE_MONSTERS, 0, 0)
	get_tr2(0, TR_vecEndPos, origin)
	
	if(engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY)
	return true
	
	return false
}

public bool:is_user_stucked(iPlayer)
{
	static Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	
	engfunc(EngFunc_TraceHull, origin, origin, DONT_IGNORE_MONSTERS, (pev(iPlayer, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, iPlayer, 0)
	
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
	return true
	
	return false
}

public ReadFile(const file[], line, linedata[], const len)
{
	new pf = fopen(file, "rt")
	if(!pf)
	return
	
	while(!feof(pf) && line --) fgets(pf, linedata, len)
	
	fclose(pf)
}

public any:ZrArrayGetCell(Array:which, item) return ArrayGetCell(which, item-1)

public ZrArrayGetString(Array:which, item, string[], len) ArrayGetString(which, item-1, string, len)