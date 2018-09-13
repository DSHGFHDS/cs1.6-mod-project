/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr Gauss Rifle"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define ZRGAUSS 167235

new const models[][] = { "models/zombieriot/v_gaussrifle.mdl", "models/zombieriot/w_gaussrifle.mdl" }
new const Sound[] = "zombieriot/Gauss1.wav"

new const GUNSHOT_DECALS[] = {41, 42, 43, 44, 45}

new m_iTrail, spr_blood_spray, spr_blood_drop, ModelIndex
new cvar_firerate, cvar_recoil, cvar_damage, cvar_reload, cvar_deploy, cvar_clip, cvar_range

new GaussId
new const GaussCost = 7500				//购买费用
new const GaussName[] = "高斯枪"		//物品名称

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_message(get_user_msgid("CurWeapon"), "Message_CurWeapon")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "HAM_Weapon_PrimaryAttack")
	RegisterHam(Ham_Item_PostFrame, "weapon_awp", "HAM_Weapon_PostFrame")
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "HAM_ItemDeploy_Post", 1)
	RegisterHam(Ham_Weapon_Reload, "weapon_awp", "HAM_Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_awp", "HAM_Weapon_Reload_Post", 1)
	static GaussInfo[64]
	formatex(GaussInfo, charsmax(GaussInfo), "%s %d$", GaussName, GaussCost)
	GaussId = zr_register_item(GaussInfo, HUMAN, 4)
	cvar_firerate = register_cvar("gauss_firerate", "0.5")		//射速
	cvar_recoil = register_cvar("gauss_recoil", "4.0")			//后坐力
	cvar_damage = register_cvar("gauss_damage", "550.0")		//伤害
	cvar_range = register_cvar("gauss_range", "18.0")			//衍伤范围
	cvar_reload = register_cvar("gauss_reload", "2.9")			//上弹速度
	cvar_deploy = register_cvar("gauss_deploy", "0.8")			//切换速度
	cvar_clip = register_cvar("gauss_clip", "5")				//弹夹容量
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, models[0])
	ModelIndex = engfunc(EngFunc_PrecacheModel, models[1])
	engfunc(EngFunc_PrecacheSound, Sound)
	m_iTrail = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
	spr_blood_spray = engfunc(EngFunc_PrecacheModel, "sprites/bloodspray.spr")
	spr_blood_drop = engfunc(EngFunc_PrecacheModel, "sprites/blood.spr")
}

public zr_item_event(iPlayer, item, Slot)
{
	if(item != GaussId)
	return
	
	new money = zr_get_user_money(iPlayer)
	if(money < GaussCost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金币!")
	return
	}
	
	DropWeapons(iPlayer, 1)
	static netname[64]
	pev(iPlayer, pev_netname, netname, charsmax(netname))
	zr_print_chat(0, GREENCHAT, "%s购买了一把%s!", netname, GaussName)
	zr_set_user_money(iPlayer, money-GaussCost, true)
	new iEntity = fm_give_item(iPlayer, "weapon_awp")
	if(!pev_valid(iEntity))
	return
	
	set_pev(iEntity, pev_weapons, ZRGAUSS)
	set_pdata_int(iEntity, 51, get_pcvar_num(cvar_clip), 4)
	set_pdata_int(iPlayer, 377, min(get_pcvar_num(cvar_clip)*9, 250), 4)
}

public Message_CurWeapon(msg_id, msg_dest, iPlayer)
{
	if(get_msg_arg_int(2) != CSW_AWP)
	return PLUGIN_CONTINUE
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return PLUGIN_CONTINUE
	
	if(pev(iEntity, pev_weapons) != ZRGAUSS)
	return PLUGIN_CONTINUE
	
	set_pev(iPlayer, pev_weaponmodel2, models[1])
	
	if(get_pdata_int(iPlayer, 363, 5) >= 90)
	{
	set_pev(iPlayer, pev_viewmodel2, models[0])
	return PLUGIN_CONTINUE
	}
	
	set_pev(iPlayer, pev_viewmodel2, 0)
	
	return PLUGIN_CONTINUE
}

public fw_SetModel(iEntity, szModel[])
{
	if(strcmp(szModel, "models/w_awp.mdl"))
	return FMRES_IGNORED
	
	static szClassName[32]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	
	if(strcmp(szClassName, "weaponbox"))
	return FMRES_IGNORED
	
	new iEntity2 = get_pdata_cbase(iEntity, 35, 4)
	
	if(!iEntity2)
	return FMRES_IGNORED
	
	if(pev(iEntity2, pev_weapons) != ZRGAUSS)
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_modelindex, ModelIndex)
	
	return FMRES_SUPERCEDE
}

public fw_UpdateClientData_Post(iPlayer, iSendWeapon, CD_Handle)
{
	if(get_cd(CD_Handle, CD_DeadFlag) != DEAD_NO)
	return
	
	if(get_cd(CD_Handle, CD_ID) != CSW_AWP)
	return
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return
	
	if(pev(iEntity, pev_weapons) != ZRGAUSS)
	return
	
	if(get_pdata_float(iPlayer, 83, 5) > 0.0)
	return
	
	set_cd(CD_Handle, CD_ID, 0)
}

public HAM_Weapon_PrimaryAttack(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRGAUSS)
	return HAM_IGNORED
	
	new Clip = get_pdata_int(iEntity, 51, 4)
	if(!Clip)
	return HAM_IGNORED
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	set_pdata_float(iEntity, 46, get_pcvar_float(cvar_firerate), 4)
	set_pdata_int(iEntity, 51, Clip-1, 4)
	
	new Float:punchangle[3]
	pev(iPlayer, pev_punchangle, punchangle)
	new Float:recoil = get_pcvar_float(cvar_recoil)
	punchangle[0] -= recoil
	punchangle[1] += random_float(-recoil/2.0, recoil/2.0)
	set_pev(iPlayer, pev_punchangle, punchangle)
	screen_shake(iPlayer, floatmin(-punchangle[0]*3.0, 5.0), 0.2, 10.0)
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_WEAPON, Sound, 1.0, 0.4, 0, PITCH_NORM)
	GaussFire(iPlayer)
	
	if(get_pdata_int(iPlayer, 363, 5) < 90)
	return HAM_SUPERCEDE
	
	SendWeaponAnim(iPlayer, 0)
	SendWeaponAnim(iPlayer, random_num(1,3))
	
	return HAM_SUPERCEDE
}

public HAM_Weapon_PostFrame(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRGAUSS)
	return HAM_IGNORED
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(!get_pdata_int(iEntity, 54, 4))
	return HAM_IGNORED
	
	new iAmmoType = get_pdata_int(iEntity, 49, 4)
	new iAmmo = get_pdata_int(iPlayer, 376 + iAmmoType, 4)
	new iClip = get_pdata_int(iEntity, 51, 4)
	
	new j = min(get_pcvar_num(cvar_clip)-iClip, iAmmo)
	set_pdata_int(iEntity, 51, iClip + j)
	set_pdata_int(iPlayer, 376 + iAmmoType, iAmmo - j, 4)
	set_pdata_int(iEntity, 54, 0, 4)
	
	return HAM_SUPERCEDE
}

public HAM_ItemDeploy_Post(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRGAUSS)
	return
	
	set_pdata_float(get_pdata_cbase(iEntity, 41, 4), 83, get_pcvar_float(cvar_deploy), 5)
}

public HAM_Weapon_Reload(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRGAUSS)
	return HAM_IGNORED
	
	if(get_pdata_int(iEntity, 51, 4) >= get_pcvar_num(cvar_clip))
	return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

public HAM_Weapon_Reload_Post(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRGAUSS)
	return
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(get_pdata_float(iPlayer, 83, 5) <= 0.0)
	return
	
	set_pdata_float(iPlayer, 83, get_pcvar_float(cvar_reload), 5)
	SendWeaponAnim(iPlayer, 4)
}

public BulletHit(iPlayer, iTrace, Float:origin[3])
{
	if(engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY)
	return
	
	new Victim = get_tr2(iTrace, TR_pHit)
	if(pev_valid(Victim) && pev(Victim, pev_takedamage) != DAMAGE_NO)
	{
	new Float:damage = get_pcvar_float(cvar_damage)
	if(is_user_alive(Victim))
	{
	new HitGroup = get_tr2(iTrace, TR_iHitgroup)
	set_pdata_int(Victim, 75, HitGroup, 5)
	if(HitGroup != HIT_GENERIC)
	{
	if(HitGroup == HIT_HEAD) damage *= random_float(2.0, 2.5)
	else if(HIT_CHEST <= HitGroup <= HIT_RIGHTARM) damage *= random_float(1.0, 1.5)
	else damage *= random_float(0.5, 1.0)
	SpawnBlood(origin, 247, floatround(damage))
	}
	}
	else CreatHole(origin)
	ExecuteHamB(Ham_TakeDamage, Victim, get_pdata_cbase(iPlayer, 373), iPlayer, damage, DMG_BULLET | DMG_SHOCK)
	}
	else CreatHole(origin)
	
	new i = -1, Float:damage = get_pcvar_float(cvar_damage)/get_pcvar_float(cvar_range)
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, get_pcvar_float(cvar_range))) > 0)
	{
	if(!pev_valid(i) || Victim == i)
	continue
	
	if(pev(i, pev_takedamage) == DAMAGE_NO)
	continue
	
	ExecuteHamB(Ham_TakeDamage, i, get_pdata_cbase(iPlayer, 373), iPlayer, damage, DMG_SHOCK)
	}
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte (TE_DLIGHT)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_byte(floatround(get_pcvar_float(cvar_range)/2.0))
	write_byte(100)
	write_byte(150)
	write_byte(255)
	write_byte(1)
	write_byte(0)
	message_end()
}

public GaussFire(iPlayer)
{
	new Float:origin[3], Float:v_angle[3], Float:velocity[3], iTrace
	get_aim_origin_vector(iPlayer, 8.0, 0.0, 0.0, origin)
	pev(iPlayer, pev_v_angle, v_angle)
	pev(iPlayer, pev_velocity, velocity)
	new Float:Value = vector_length(velocity)/100.0
	v_angle[0] += random_float(-Value, Value)
	v_angle[1] += random_float(-Value, Value)
	engfunc(EngFunc_MakeVectors, v_angle)
	global_get(glb_v_forward, v_angle)
	xs_vec_mul_scalar(v_angle, 8120.0, v_angle)
	xs_vec_add(origin, v_angle, v_angle)
	engfunc(EngFunc_TraceLine, origin, v_angle, DONT_IGNORE_MONSTERS, iPlayer, iTrace)
	get_tr2(iTrace, TR_vecEndPos, v_angle)
	if(get_pdata_int(iPlayer, 363, 5) >= 90) get_aim_origin_vector(iPlayer, 16.0, 7.0, -6.0, origin)
	else get_aim_origin_vector(iPlayer, 16.0, 0.0, 0.0, origin)
	BulletHit(iPlayer, iTrace, v_angle)
	free_tr2(iTrace)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	engfunc(EngFunc_WriteCoord, v_angle[0])
	engfunc(EngFunc_WriteCoord, v_angle[1])
	engfunc(EngFunc_WriteCoord, v_angle[2])
	write_short(m_iTrail)
	write_byte(0)
	write_byte(1)
	write_byte(1)
	write_byte(1)
	write_byte(0)
	write_byte(100)
	write_byte(100)
	write_byte(255)
	write_byte(180)
	write_byte(1)
	message_end()
}

public CreatHole(Float:origin[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_ARMOR_RICOCHET)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_byte(1)
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_GUNSHOTDECAL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(0)
	write_byte(GUNSHOT_DECALS[random_num(0, sizeof GUNSHOT_DECALS - 1)])
	message_end()
}

stock SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, iPlayer)
	write_byte(iAnim)
	write_byte(pev(iPlayer, pev_body))
	message_end()
}

stock screen_shake(iPlayer, Float:amplitude, Float:duration, Float:frequency)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, iPlayer)
	write_short(floatround(4096.0*amplitude))
	write_short(floatround(4096.0*duration))
	write_short(floatround(4096.0*frequency))
	message_end()
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

stock SpawnBlood(const Float:vecOrigin[3], iColor, iAmount)
{
	if(iAmount == 0)
	return
	iAmount *= 2
	if(iAmount > 255) iAmount = 255
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(iColor)
	write_byte(min(max(3, iAmount / 10), 16))
	message_end()
}

stock DropWeapons(iPlayer, Slot)
{
	new item = get_pdata_cbase(iPlayer, 367+Slot, 4)
	while(item > 0)
	{
	static classname[24]
	pev(item, pev_classname, classname, charsmax(classname))
	engclient_cmd(iPlayer, "drop", classname)
	item = get_pdata_cbase(item, 42, 5)
	}
	set_pdata_cbase(iPlayer, 367, -1, 4)
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