/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <zombieriot>
#include <xs>

#define PLUGIN "Show Human"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define ICONNAME "HumanIcon"
#define ICONKEY 132111

new HumanSPR
new KeepIcon[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
}

public plugin_precache() HumanSPR = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/human_new.spr")

public client_putinserver(iPlayer) CreateIcon(iPlayer)

public fw_ClientDisconnect_Post(iPlayer) RemoveIcon(iPlayer)

public fw_AddToFullPack_Post(ES_Handle, e, iEntity, iHost, iHostFlags, iPlayer, iSet)
{
	if(!is_user_connected(iHost) || !zr_is_user_zombie(iHost))
	return
	
	if(!pev_valid(iEntity))
	return
	
	if(pev(iEntity, pev_iuser4) != ICONKEY)
	return
	
	new Human = pev(iEntity, pev_owner)
	
	if(!is_user_alive(Human) || zr_is_user_zombie(Human))
	return
	
	new Float:origin[3], Float:view_ofs[3]
	pev(iHost, pev_origin, origin)
	pev(iHost, pev_view_ofs, view_ofs)
	xs_vec_add(origin, view_ofs, origin)
	
	new Float:end[3], Float:fraction
	pev(Human, pev_origin, end)
	engfunc(EngFunc_TraceLine, origin, end, IGNORE_MONSTERS, iHost, 0)
	get_tr2(0, TR_flFraction, fraction)
	if(fraction == 1.0)
	return
	
	get_tr2(0, TR_vecEndPos, end)
	new Float:dest[3], Float:Distance
	xs_vec_sub(end, origin, dest)
	Distance = get_distance_f(origin, end)
	xs_vec_copy(dest, end)
	xs_vec_div_scalar(end, xs_vec_len(dest), end)
	xs_vec_mul_scalar(end, Distance*0.6, end)
	xs_vec_add(end, origin, end)
	
	new Float:Health, Float:MaxHealth = zr_get_human_health(zr_get_human_id(Human))
	pev(Human, pev_health, Health)
	Health = floatmin(Health, MaxHealth)
	set_es(ES_Handle, ES_Frame, Health/MaxHealth*20.0-1.0)
	set_es(ES_Handle, ES_Scale, Distance/4000.0)
	set_es(ES_Handle, ES_RenderAmt, 80)
	set_es(ES_Handle, ES_Origin, end)
}

public zr_being_human(iPlayer) ShowIcon(iPlayer)

public zr_being_zombie(iPlayer) HideIcon(iPlayer)

public zr_hook_spawnbody(iPlayer) HideIcon(iPlayer)

public CreateIcon(iPlayer)
{
	KeepIcon[iPlayer] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(KeepIcon[iPlayer], pev_classname, ICONNAME)
	set_pev(KeepIcon[iPlayer], pev_modelindex, HumanSPR)
	set_pev(KeepIcon[iPlayer], pev_rendermode, kRenderTransAdd)
	set_pev(KeepIcon[iPlayer], pev_owner, iPlayer)
}

public ShowIcon(iPlayer)
{
	if(!pev_valid(KeepIcon[iPlayer]))
	return
	
	set_pev(KeepIcon[iPlayer], pev_iuser4, ICONKEY)
}

public HideIcon(iPlayer)
{
	if(!pev_valid(KeepIcon[iPlayer]))
	return
	
	set_pev(KeepIcon[iPlayer], pev_iuser4,  0)
}

public RemoveIcon(iPlayer)
{
	if(!pev_valid(KeepIcon[iPlayer]))
	{
	KeepIcon[iPlayer] = 0
	return
	}
	
	set_pev(KeepIcon[iPlayer], pev_flags, FL_KILLME)
	KeepIcon[iPlayer] = 0
}