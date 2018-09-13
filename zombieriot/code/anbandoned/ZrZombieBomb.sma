/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Zombie Bomb"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define ZOMBIEBOMB 83547

new BombSPR
new cvar_dmgtime, cvar_range, cvar_knockback
new BombClaw[64][64]

new BombId
new const BombCost = 1000					//购买价格
new const BombName[] = "爆兽头颅"		//物品名称
new const WorldModel[][] = { "models/zombieriot/p_zombiebomb.mdl", "models/zombieriot/w_zombiebomb.mdl" }
new const BombSound[] = "zombieriot/zombiebomb.wav"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_Think, "fw_Think_Post", 1)
	static BombInfo[64]
	formatex(BombInfo, charsmax(BombInfo), "%s %d$", BombName, BombCost)
	BombId = zr_register_item(BombInfo, ZOMBIE, 3)
	cvar_dmgtime = register_cvar("zr_zombiebomb_dmgtime", "1.5")			//爆炸时间
	cvar_range = register_cvar("zr_zombiebomb_range", "350.0")				//爆炸范围
	cvar_knockback = register_cvar("zr_zombiebomb_knockback", "1000.0")		//爆炸击退
}

public plugin_precache()
{
	static ZombieClaw[64]
	for(new i = 1; i <= zr_get_zombie_amount(); i ++)
	{
	zr_get_zombie_claw(zr_sequence_to_id(ZOMBIE, i), ZombieClaw, charsmax(ZombieClaw))
	replace(ZombieClaw, charsmax(ZombieClaw), ".mdl", "_bomb.mdl")
	format(ZombieClaw, charsmax(ZombieClaw), "models/zombieriot/%s", ZombieClaw)
	if(!file_exists(ZombieClaw))
	continue
	copy(BombClaw[i], charsmax(ZombieClaw), ZombieClaw)
	engfunc(EngFunc_PrecacheModel, BombClaw[i])
	}
	
	for(new i = 0; i < 2; i ++) engfunc(EngFunc_PrecacheModel, WorldModel[i])
	engfunc(EngFunc_PrecacheSound, BombSound)
	BombSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/skillexplosion.spr")
}

public zr_being_human(iPlayer)
{
	new iEntity = get_pdata_cbase(iPlayer, 371, 4)
	if(iEntity <= 0)
	return
	
	if(pev(iEntity, pev_weapons) != ZOMBIEBOMB)
	return
	
	ExecuteHamB(Ham_Weapon_RetireWeapon, iEntity)
	ExecuteHamB(Ham_RemovePlayerItem, iPlayer, iEntity)
	ExecuteHamB(Ham_Item_Kill, iEntity)
	set_pev(iPlayer, pev_weapons, pev(iPlayer, pev_weapons) & ~(1<<get_pdata_int(iEntity, 43, 4)))
}

public Event_CurWeapon(iPlayer)
{
	if(!zr_is_user_zombie(iPlayer))
	return PLUGIN_CONTINUE
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(pev(iEntity, pev_weapons) != ZOMBIEBOMB)
	return PLUGIN_CONTINUE
	
	set_pev(iPlayer, pev_viewmodel2, BombClaw[zr_id_to_sequence(ZOMBIE, zr_get_zombie_id(iPlayer))])
	set_pev(iPlayer, pev_weaponmodel2, WorldModel[0])
	
	return PLUGIN_CONTINUE
}

public zr_item_event(iPlayer, item, Slot)
{
	if(item != BombId)
	return
	
	if(!BombClaw[zr_id_to_sequence(ZOMBIE, zr_get_zombie_id(iPlayer))][0])
	{
	zr_print_chat(iPlayer, GREYCHAT, "没有配套的手臂模型无法购买!")
	return
	}
	
	new money = zr_get_user_money(iPlayer)
	if(money < BombCost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金钱!")
	return
	}
	
	new iEntity
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "weapon_hegrenade")))
	{
	if(pev(iEntity, pev_owner) != iPlayer)
	continue
	
	zr_print_chat(iPlayer, GREYCHAT, "不能再购买了!")
	return
	}
	
	zr_set_user_money(iPlayer, money-BombCost, 1)
	iEntity = fm_give_item(iPlayer, "weapon_hegrenade")
	set_pev(iEntity, pev_weapons, ZOMBIEBOMB)
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一个%s!", BombName)
}

public fw_SetModel(iEntity, szModel[])
{
	if(strlen(szModel) < 8)
	return FMRES_IGNORED
	
	if(szModel[7] != 'w' || szModel[8] != '_')
	return FMRES_IGNORED
	
	static szClassName[33]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	if(strcmp(szClassName, "grenade"))
	return FMRES_IGNORED
	
	new iEntity2 = get_pdata_cbase(pev(iEntity, pev_owner), 373)
	
	if(pev(iEntity2, pev_weapons) != ZOMBIEBOMB)
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_weapons, ZOMBIEBOMB)
	set_pev(iEntity, pev_dmgtime, 9999.0)
	set_pev(iEntity, pev_nextthink, get_gametime()+get_pcvar_float(cvar_dmgtime))
	engfunc(EngFunc_SetModel, iEntity, WorldModel[1])
	
	return FMRES_SUPERCEDE
}

public fw_Think_Post(iEntity)
{
	if(!pev_valid(iEntity)) 
	return
	
	static szClassName[33]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	if(strcmp(szClassName, "grenade"))
	return
	
	if(pev(iEntity, pev_weapons) != ZOMBIEBOMB)
	return
	
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, get_pcvar_float(cvar_range))) > 0)
	{
	if(!is_user_alive(i))
	continue
	
	new Float:origin2[3]
	pev(i, pev_origin, origin2)
	
	engfunc(EngFunc_TraceLine, origin2, origin, IGNORE_MONSTERS, i, 0)
	new Float:fraction
	get_tr2(0, TR_flFraction, fraction)
	if(fraction != 1.0)
	continue
	
	new Float:velocity[3]
	GetVelocityFromOrigin(origin2, origin, get_pcvar_float(cvar_knockback), velocity)
	set_pev(i, pev_velocity, velocity)
	
	if(zr_is_user_zombie(i))
	continue
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, i)
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<14)
	message_end()
	}
	
	if(pev(iEntity, pev_flags) & FL_ONGROUND) origin[2] += 35.0
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(BombSPR)
	write_byte(22)
	write_byte(255)
	message_end()
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, BombSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	engfunc(EngFunc_RemoveEntity, iEntity)
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

stock GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}