/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>

#define PLUGIN "Fire grenade"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

#define OPEN 1523
#define CLOSED 3521

new ItemId
new const ItemCost = 500 //购买价格
new const ItemName[] = "燃烧手雷" //物品名称
new const FireGrenadeModels[][] = { "models/v_hegrenade.mdl", "models/p_hegrenade.mdl", "models/w_hegrenade.mdl"}
new const FireSounds[][] = { "zombieriot/molotov_detonate_3.wav", "zombieriot/fire_loop_1.wav", "zombieriot/fire_loop_fadeout_01.wav" }
new cvar_dmgtime, fire, cvar_range, cvar_damage, cvar_interval

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_Touch, "fw_Touch")
	register_forward(FM_Think, "fw_Think")
	static ItemInfo[33]
	formatex(ItemInfo, charsmax(ItemInfo), "%s %d$", ItemName, ItemCost)
	ItemId = zr_register_item(ItemInfo, HUMAN, 3)
	cvar_dmgtime = register_cvar("firegrenade_dmgtime", "11.5")		//燃烧的时间
	cvar_damage = register_cvar("firegrenade_damage", "50.0")		//燃烧的伤害
	cvar_range = register_cvar("firegrenade_range", "350.0")		//燃烧的范围
	cvar_interval = register_cvar("firegrenade_interval", "0.5")	//伤害触发的时间间隔
}

public plugin_precache()
{
	for(new i = 0; i < 3; i ++)
	{
	engfunc(EngFunc_PrecacheModel, FireGrenadeModels[i])
	engfunc(EngFunc_PrecacheSound, FireSounds[i])
	}
	fire = engfunc(EngFunc_PrecacheModel, "sprites/flame.spr")
}

public zr_item_event(iPlayer, item, Slot)
{
	if(item != ItemId)
	return
	
	new money = zr_get_user_money(iPlayer)
	if(money < ItemCost)
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
	
	zr_set_user_money(iPlayer, money-ItemCost, 1)
	iEntity = fm_give_item(iPlayer, "weapon_hegrenade")
	set_pev(iEntity, pev_weapons, OPEN)
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一个%s!", ItemName)
}

public Event_CurWeapon(iPlayer)
{
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(pev(iEntity, pev_weapons) != OPEN)
	return PLUGIN_CONTINUE
	
	set_pev(iPlayer, pev_viewmodel2, FireGrenadeModels[0])
	set_pev(iPlayer, pev_weaponmodel2, FireGrenadeModels[1])
	
	return PLUGIN_CONTINUE
}

public fw_Think(iEntity)
{
	static szClassName[33]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	if(strcmp(szClassName, "grenade"))
	return FMRES_IGNORED
	
	if(pev(iEntity, pev_weapons) != CLOSED)
	return FMRES_IGNORED
	
	new Float:dmgtime
	pev(iEntity, pev_dmgtime, dmgtime)
	if(dmgtime-get_gametime() <= 10.0)
	{
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, FireSounds[1], 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, FireSounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
	engfunc(EngFunc_RemoveEntity, iEntity)
	return FMRES_SUPERCEDE
	}
	
	new Float:fCurTime, Float:ThinkTime
	global_get(glb_time, fCurTime)
	set_pev(iEntity, pev_nextthink, fCurTime + 0.01)
	pev(iEntity, pev_fuser1, ThinkTime)
	
	if(ThinkTime <= fCurTime)
	{
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, get_pcvar_float(cvar_range))) > 0)
	{
	if(!pev_valid(i))
	continue
	
	if(pev(i, pev_takedamage) == DAMAGE_NO)
	continue
	
	new Float:fOrigin[3]
	pev(i, pev_origin, fOrigin)
	
	if(!GetVisible(origin, fOrigin))
	continue
	
	new Float:fDistance = get_distance_f(fOrigin, origin)
	new Float:range = get_pcvar_float(cvar_range)
	new Float:fMaxDamage = floatmax(get_pcvar_float(cvar_damage)*((range-fDistance)/range), 0.0)
	
	if(fMaxDamage <= 1.0)
	continue
	
	ExecuteHamB(Ham_TakeDamage, i, iEntity, pev(iEntity, pev_owner), fMaxDamage, DMG_SLOWBURN)
	}
	set_pev(iEntity, pev_fuser1, fCurTime+get_pcvar_float(cvar_interval))
	}
	
	pev(iEntity, pev_fuser3, ThinkTime)
	if(ThinkTime <= fCurTime)
	{
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, FireSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(iEntity, pev_fuser3, fCurTime+4.0)
	}
	
	pev(iEntity, pev_fuser2, ThinkTime)
	if(ThinkTime > fCurTime)
	return FMRES_SUPERCEDE
	
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	MakeFlames(origin)
	set_pev(iEntity, pev_fuser2, fCurTime+0.1)
	
	return FMRES_SUPERCEDE
}

public fw_SetModel(iEntity, szModel[])
{
	if(strlen(szModel) < 8)
	return FMRES_IGNORED
	
	if(szModel[7] != 'w' || szModel[8] != '_')
	return FMRES_IGNORED
	
	new Float:dmgtime
	pev(iEntity, pev_dmgtime, dmgtime)
	
	if(dmgtime == 0.0)
	return FMRES_IGNORED
	
	static szClassName[33]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	if(strcmp(szClassName, "grenade"))
	return FMRES_IGNORED
	
	new iEntity2 = get_pdata_cbase(pev(iEntity, pev_owner), 373)
	
	if(pev(iEntity2, pev_weapons) != OPEN)
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_weapons, OPEN)
	set_pev(iEntity, pev_dmgtime, 9999.0)
	engfunc(EngFunc_SetModel, iEntity, FireGrenadeModels[2])
	
	return FMRES_SUPERCEDE
}

public fw_Touch(iEntity, iPtd)
{
	if(!pev_valid(iEntity))
	return FMRES_IGNORED
	
	static szClassName[33]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	if(strcmp(szClassName, "grenade"))
	return FMRES_IGNORED
	
	if(pev(iEntity, pev_weapons) != OPEN)
	return FMRES_IGNORED
	
	if(!engfunc(EngFunc_EntIsOnFloor, iEntity))
	return FMRES_IGNORED
	
	new Float:fCurTime
	global_get(glb_time, fCurTime)
	set_pev(iEntity, pev_rendermode, kRenderTransAlpha)
	set_pev(iEntity, pev_renderamt, 0.0)
	set_pev(iEntity, pev_solid, SOLID_NOT)
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE)
	set_pev(iEntity, pev_dmgtime, fCurTime+get_pcvar_float(cvar_dmgtime)+10.0)
	set_pev(iEntity, pev_weapons, CLOSED)
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, FireSounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(iEntity, pev_fuser3, fCurTime+1.0)
	
	return FMRES_IGNORED
}

public MakeFlames(const Float:origin[3])
{
	new Float:fOrigin[3], Float:Range = get_pcvar_float(cvar_range)
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	for(new i = 0; i < floatround(Range/40.0); i++)
	{
	fOrigin[0] = origin[0] + random_float(-Range/2.0, Range/2.0)
	fOrigin[1] = origin[1] + random_float(-Range/2.0, Range/2.0)
	fOrigin[2] = origin[2]
	if(engfunc(EngFunc_PointContents, fOrigin) != CONTENTS_EMPTY) fOrigin[2] += get_distance_f(fOrigin, origin)
	set_pev(iEntity, pev_origin, fOrigin)
	engfunc(EngFunc_DropToFloor, iEntity)
	pev(iEntity, pev_origin, fOrigin)
	
	if(engfunc(EngFunc_PointContents, fOrigin) != CONTENTS_EMPTY)
	continue
	
	if(!GetVisible(origin, fOrigin))
	continue
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, fOrigin[0])
	engfunc(EngFunc_WriteCoord, fOrigin[1])
	engfunc(EngFunc_WriteCoord, fOrigin[2]+random_float(75.0, 95.0))
	write_short(fire)
	write_byte(random_num(9, 11))
	write_byte(100)
	message_end()
	}
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

stock bool:GetVisible(const Float:PointA[3], const Float:PointB[3])
{
	engfunc(EngFunc_TraceLine, PointA, PointB, 1, 0, 0)
	new Float:fraction
	get_tr2(0, TR_flFraction, fraction)
	if(fraction == 1.0) return true
	return false
}