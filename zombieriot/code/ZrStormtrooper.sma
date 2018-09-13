/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>

#define PLUGIN "Zr Stormtrooper"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"

new const StormtrooperID = 1			//突击卫士ID

public plugin_init() register_plugin(PLUGIN, VERSION, AUTHOR)

public zr_being_human(iPlayer)
{
	if(zr_get_human_id(iPlayer) != StormtrooperID)
	return
	
	set_pev(iPlayer, pev_armorvalue, zr_get_human_health(StormtrooperID))
	set_pdata_int(iPlayer, 112, 2, 5)
	set_pdata_int(iPlayer, 129, get_pdata_int(iPlayer, 129, 5)|(1<<0), 5)
	fm_give_item(iPlayer, "weapon_hegrenade")
	fm_give_item(iPlayer, "weapon_flashbang")
	fm_give_item(iPlayer, "weapon_flashbang")
	fm_give_item(iPlayer, "weapon_smokegrenade")
	
	if(pev_valid(get_pdata_cbase(iPlayer, 368)))
	return
	
	if(random_num(0, 1))
	{
	fm_give_item(iPlayer, "weapon_ak47")
	ExecuteHamB(Ham_GiveAmmo, iPlayer, 240, "762nato", 240)
	return
	}
	fm_give_item(iPlayer, "weapon_m4a1")
	ExecuteHamB(Ham_GiveAmmo, iPlayer, 240, "556nato", 240)
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