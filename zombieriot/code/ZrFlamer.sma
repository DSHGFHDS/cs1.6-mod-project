/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Flamer"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS & REX"

#define OPEN 1523
#define CLOSED 3521

new const g_szGameWeaponClassName[][] = { "", "", "", "weapon_scout", "", "", "", "", "weapon_aug", "", "", "", "", "weapon_sg550", "weapon_galil", "weapon_famas", "", "", "weapon_awp", "", "weapon_m249", "", "weapon_m4a1", "", "weapon_g3sg1", "", "", "weapon_sg552", "weapon_ak47", "",
	"" }

new FireIndex, GrenadeIndex, TraceIndex, HitIndex

new ItemId
new const ItemCost = 2000			//购买价格
new const ItemName[] = "燃烧手雷"	//物品名称

new const FireGrenadeModels[3][] = { "models/zombieriot/v_firebomb.mdl", "models/zombieriot/p_firebomb.mdl", "models/zombieriot/w_firebomb.mdl"}
new const FireSounds[3][] = { "zombieriot/molotov_detonate_3.wav", "zombieriot/fire_loop_1.wav", "zombieriot/fire_loop_fadeout_01.wav" }
new Firing[33], bool:FixHoldTime[33]

new cvar_dmgtime, cvar_range, cvar_damage, cvar_interval, cvar_flamebullet, cvar_FireWeaken

new const FlamerID = 3		//纵火者ID
new g_fwBotForwardRegister

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_Touch, "fw_Touch")
	register_forward(FM_Think, "fw_Think")
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	g_fwBotForwardRegister = register_forward(FM_PlayerPostThink, "fw_BotForwardRegister_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "HAM_TakeDamage")
	for(new i = 1; i < sizeof g_szGameWeaponClassName; i++)
	{
	if(!g_szGameWeaponClassName[i][0])
	continue
	RegisterHam(Ham_Weapon_PrimaryAttack, g_szGameWeaponClassName[i], "HAM_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, g_szGameWeaponClassName[i], "HAM_Weapon_PrimaryAttack_Post", 1)
	}
	static ItemInfo[33]
	formatex(ItemInfo, charsmax(ItemInfo), "%s %d$", ItemName, ItemCost)
	ItemId = zr_register_item(ItemInfo, HUMAN, 4)
	cvar_dmgtime = register_cvar("zr_firegrenade_dmgtime", "21.0")		//燃烧的时间
	cvar_damage = register_cvar("zr_firegrenade_damage", "350.0")		//燃烧的伤害
	cvar_range = register_cvar("zr_firegrenade_range", "350.0")			//燃烧的范围
	cvar_interval = register_cvar("zr_firegrenade_interval", "0.3")		//伤害触发的时间间隔
	cvar_flamebullet = register_cvar("zr_flamebullet_time", "0.5")		//火焰弹攻击伤害的倍数加成
	cvar_FireWeaken = register_cvar("zr_fire_weaken", "0.5")			//纵火者受燃烧伤害的倍数
}

public plugin_precache()
{
	for(new i = 0; i < 3; i ++) engfunc(EngFunc_PrecacheSound, FireSounds[i])
	engfunc(EngFunc_PrecacheModel, FireGrenadeModels[0])
	engfunc(EngFunc_PrecacheModel, FireGrenadeModels[1])
	GrenadeIndex = engfunc(EngFunc_PrecacheModel, FireGrenadeModels[2])
	FireIndex = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/flame.spr")
	TraceIndex = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/FireSmoke.spr")
	HitIndex = engfunc(EngFunc_PrecacheModel, "sprites/xspark4.spr")
}

public Event_CurWeapon(iPlayer)
{
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(pev(iEntity, pev_iuser3) != OPEN)
	return PLUGIN_CONTINUE
	
	set_pev(iPlayer, pev_viewmodel2, FireGrenadeModels[0])
	set_pev(iPlayer, pev_weaponmodel2, FireGrenadeModels[1])
	
	return PLUGIN_CONTINUE
}

public fw_TraceLine_Post(Float:vecStart[3], Float:vecEnd[3], iConditions, iSkipEntity, iTrace)
{
	if(!is_user_connected(iSkipEntity))
	return
	
	if(!Firing[iSkipEntity])
	return
	
	new iEntity = get_pdata_cbase(iSkipEntity, 373)
	if(iEntity <= 0)
	return
	
	if(FixHoldTime[iSkipEntity] && get_pdata_int(iEntity, 74, 4) == 16)
	{
	FixHoldTime[iSkipEntity] = false
	return
	}
	
	new Float:origin[3]
	get_tr2(iTrace, TR_vecEndPos, origin)
	CreateTrace(iSkipEntity, origin)
	
	Firing[iSkipEntity] --
	FixHoldTime[iSkipEntity] = true
}

public fw_Think(iEntity)
{
	static szClassName[33]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	if(strcmp(szClassName, "grenade"))
	return FMRES_IGNORED
	
	if(pev(iEntity, pev_iuser3) != CLOSED)
	return FMRES_IGNORED
	
	new Float:dmgtime
	pev(iEntity, pev_dmgtime, dmgtime)
	if(dmgtime-get_gametime() <= 10.0)
	{
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, FireSounds[1], 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, FireSounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(iEntity, pev_flags, FL_KILLME)
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
	
	if(pev(iEntity2, pev_iuser3) != OPEN)
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_iuser3, OPEN)
	set_pev(iEntity, pev_dmgtime, 9999.0)
	set_pev(iEntity, pev_modelindex, GrenadeIndex)
	
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
	
	if(pev(iEntity, pev_iuser3) != OPEN)
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
	set_pev(iEntity, pev_iuser3, CLOSED)
	engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, FireSounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(iEntity, pev_fuser3, fCurTime+1.0)
	
	return FMRES_IGNORED
}

public HAM_Weapon_PrimaryAttack(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(zr_is_user_zombie(iPlayer))
	return FMRES_IGNORED
	
	if(zr_get_human_id(iPlayer) != FlamerID)
	return FMRES_IGNORED
	
	if(!get_pdata_int(iEntity, 51, 4))
	return FMRES_IGNORED
	
	new burstmode = get_pdata_int(iEntity, 74, 5)
	if(burstmode == 16 || burstmode == 2)
	{
	Firing[iPlayer] = min(3, get_pdata_int(iEntity, 51, 4))
	FixHoldTime[iPlayer] = false
	return FMRES_IGNORED
	}
	
	Firing[iPlayer] = 1
	
	return FMRES_IGNORED
}

public HAM_Weapon_PrimaryAttack_Post(iEntity)
{
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	if(Firing[iPlayer] != 1)
	return
	
	new burstmode = get_pdata_int(iEntity, 74, 4)
	if(burstmode == 16)
	return
	
	Firing[iPlayer] = 0
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(victim))
	return HAM_IGNORED 
	
	if(zr_is_user_zombie(victim))
	{
	if(!is_user_connected(attacker))
	return HAM_IGNORED
	
	if(zr_is_user_zombie(attacker))
	return HAM_IGNORED
	
	if(zr_get_human_id(attacker) != FlamerID)
	return HAM_IGNORED
	
	if(!(damage_type & DMG_BULLET))
	return HAM_IGNORED
	
	new iEntity = get_pdata_cbase(attacker, 373)
	if(iEntity <= 0)
	return HAM_IGNORED
	
	if(!g_szGameWeaponClassName[get_pdata_int(iEntity, 43, 4)][0])
	return HAM_IGNORED
	
	ExecuteHamB(Ham_TakeDamage, victim, inflictor, attacker, damage*get_pcvar_float(cvar_flamebullet), DMG_BURN)
	
	return HAM_IGNORED
	}
	
	if(zr_get_human_id(victim) != FlamerID)
	return HAM_IGNORED 
	
	if(!(damage_type & DMG_BURN) && !(damage_type & DMG_SLOWBURN))
	return HAM_IGNORED
	
	SetHamParamFloat(4, damage*get_pcvar_float(cvar_FireWeaken))
	
	return HAM_IGNORED
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
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, fOrigin[0])
	engfunc(EngFunc_WriteCoord, fOrigin[1])
	engfunc(EngFunc_WriteCoord, fOrigin[2]+random_float(75.0, 95.0))
	write_short(FireIndex)
	write_byte(random_num(9, 11))
	write_byte(100)
	message_end()
	}
	set_pev(iEntity, pev_flags, FL_KILLME)
}

public CreateTrace(iPlayer, Float:End[3])
{
	new Float:origin[3]
	if(get_pdata_int(iPlayer, 363, 5) >= 90) get_aim_origin_vector(iPlayer, 16.0, 3.0, -3.0, origin)
	else get_aim_origin_vector(iPlayer, 0.0, 0.0, 0.0, origin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, End[0])
	engfunc(EngFunc_WriteCoord, End[1])
	engfunc(EngFunc_WriteCoord, End[2])
	write_short(TraceIndex)
	write_byte(1)
	write_byte(10)
	write_byte(15)
	write_byte(6)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(10)
	write_byte(10)
	message_end()
	
	if(engfunc(EngFunc_PointContents, End) == CONTENTS_SKY)
	return
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, End, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, End[0])
	engfunc(EngFunc_WriteCoord, End[1])
	engfunc(EngFunc_WriteCoord, End[2])
	write_short(HitIndex)
	write_byte(3)
	write_byte(180)
	message_end()
}

public zr_item_event(iPlayer, item, Slot)
{
	if(item != ItemId)
	return
	
	if(zr_get_human_id(iPlayer) != FlamerID)
	{
	zr_print_chat(iPlayer, GREYCHAT, "只有纵火者才能购买!")
	return 
	}
	
	new money = zr_get_user_money(iPlayer)
	if(money < ItemCost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "没有足够的金币!")
	return
	}
	
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "weapon_hegrenade")))
	{
	if(pev(iEntity, pev_owner) != iPlayer)
	continue
	
	zr_print_chat(iPlayer, GREYCHAT, "不能再购买了!")
	return
	}
	
	zr_set_user_money(iPlayer, money-ItemCost, true)
	iEntity = fm_give_item(iPlayer, "weapon_hegrenade")
	set_pev(iEntity, pev_iuser3, OPEN)
	zr_print_chat(iPlayer, GREENCHAT, "你购买了一个%s!", ItemName)
}

public zr_being_human(iPlayer)
{
	if(zr_get_human_id(iPlayer) != FlamerID)
	return
	
	new iEntity = fm_give_item(iPlayer, "weapon_hegrenade")
	if(!pev_valid(iEntity))
	return
	
	set_pev(iEntity, pev_iuser3, OPEN)
}

public fw_BotForwardRegister_Post(iPlayer)
{
	if(!is_user_bot(iPlayer))
	return
	
	unregister_forward(FM_PlayerPostThink, g_fwBotForwardRegister, 1)
	RegisterHamFromEntity(Ham_TakeDamage, iPlayer, "HAM_TakeDamage")
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
	engfunc(EngFunc_TraceLine, PointA, PointB, IGNORE_MONSTERS, 0, 0)
	new Float:fraction
	get_tr2(0, TR_flFraction, fraction)
	if(fraction == 1.0) return true
	return false
}

stock get_aim_origin_vector(iPlayer, Float:forw, Float:right, Float:up, Float:vStart[])
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(iPlayer, pev_origin, vOrigin)
	pev(iPlayer, pev_view_ofs, vUp)
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(iPlayer, pev_v_angle, vAngle)
	
	angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward)
	angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle, ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}