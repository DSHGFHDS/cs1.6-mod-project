/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <xs>

#define PLUGIN "Zr M32 Launcher"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define ZRM32 52020

enum
{
	IDLEMODE,
	OVERMODE,
	AFTERMODE,
	INSERTMODE,
	STARTMODE
}

enum
{
	anim_idle,
	anim_draw,
	anim_shoot,
	anim_insert,
	anim_start_reload,
	anim_after_reload
}

new TraceIndex, M32Index, g_smodelindexfireball2, g_smodelindexfireball3

new const M32Sounds[2][] = { "weapons/m32/m32_fire.wav", "weapons/m32/m32_explode.wav" }
new const M32Models[2][] = { "models/zombieriot/v_m32.mdl", "models/zombieriot/x_m32.mdl" }

new cvar_rate, cvar_recoil, cvar_clip, cvar_range, cvar_damage, cvar_velocity

new M32Id
new const M32Cost = 8500				//购买费用
new const M32Name[] = "M32榴弹发射器"		//物品名称

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45", "HAM_Weapon_PrimaryAttack")
	RegisterHam(Ham_Item_Deploy, "weapon_ump45", "HAM_ItemDeploy_Post", 1)
	RegisterHam(Ham_Weapon_Reload, "weapon_ump45", "HAM_Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_ump45", "HAM_Weapon_Reload_Post", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_ump45", "HAM_Weapon_PostFrame")
	RegisterHam(Ham_Think, "info_target", "HAM_Think_Post", 1)
	RegisterHam(Ham_Touch, "info_target", "HAM_Touch_Post", 1)
	static M32Info[64]
	formatex(M32Info, charsmax(M32Info), "%s %d$", M32Name, M32Cost)
	M32Id = zr_register_item(M32Info, HUMAN, 4)
	cvar_rate = register_cvar("m32_firerate", "0.5")			//射速
	cvar_recoil = register_cvar("m32_recoil", "4.0")			//后坐力
	cvar_clip = register_cvar("m32_clip", "6")					//装弹数
	cvar_range = register_cvar("m32_range", "450.0")			//爆炸范围
	cvar_damage = register_cvar("m32_damage", "300.0")			//伤害
	cvar_velocity = register_cvar("m32_velocity", "1500.0")		//飞行速度
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, M32Sounds[0])
	engfunc(EngFunc_PrecacheSound, M32Sounds[1])
	engfunc(EngFunc_PrecacheModel, M32Models[0])
	M32Index = engfunc(EngFunc_PrecacheModel, M32Models[1])
	TraceIndex = engfunc(EngFunc_PrecacheModel, "sprites/zombieriot/FireSmoke.spr")
	g_smodelindexfireball2 = engfunc(EngFunc_PrecacheModel, "sprites/eexplo.spr")
	g_smodelindexfireball3 = engfunc(EngFunc_PrecacheModel, "sprites/fexplo.spr")
}

public zr_item_event(iPlayer, item, Slot)
{
	if(item != M32Id)
	return
	
	new money = zr_get_user_money(iPlayer)
	if(money < M32Cost)
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金币!")
	return
	}
	
	DropWeapons(iPlayer, 1)
	static netname[64]
	pev(iPlayer, pev_netname, netname, charsmax(netname))
	zr_print_chat(0, GREENCHAT, "%s购买了一把%s!", netname, M32Name)
	zr_set_user_money(iPlayer, money-M32Cost, true)
	GiveM32(iPlayer)
}

public fw_SetModel(iEntity, szModel[])
{
	if(strcmp(szModel, "models/w_ump45.mdl"))
	return FMRES_IGNORED
	
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "weaponbox"))
	return FMRES_IGNORED
	
	new iEntity2 = get_pdata_cbase(iEntity, 35, 4)
	
	if(!iEntity2)
	return FMRES_IGNORED
	
	if(pev(iEntity2, pev_weapons) != ZRM32)
	return FMRES_IGNORED
	
	set_pev(iEntity, pev_modelindex, M32Index)
	
	return FMRES_SUPERCEDE
}

public fw_UpdateClientData_Post(iPlayer, iSendWeapon, CD_Handle)
{
	if(get_cd(CD_Handle, CD_DeadFlag) != DEAD_NO)
	return
	
	if(get_cd(CD_Handle, CD_ID) != CSW_UMP45)
	return
	
	new iEntity = get_pdata_cbase(iPlayer, 373)
	if(iEntity <= 0)
	return
	
	if(pev(iEntity, pev_weapons) != ZRM32)
	return
	
	if(get_pdata_float(iPlayer, 83, 5) > 0.0)
	return
	
	set_cd(CD_Handle, CD_ID, 0)
}

public HAM_Weapon_PrimaryAttack(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRM32)
	return HAM_IGNORED
	
	new Clip = get_pdata_int(iEntity, 51, 4)
	if(!Clip)
	return HAM_IGNORED
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	set_pdata_float(iEntity, 46, get_pcvar_float(cvar_rate), 4)
	
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_WEAPON, M32Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pdata_int(iEntity, 51, Clip-1, 4)
	CreateGrenade(iPlayer)
	
	new Float:punchangle[3]
	pev(iPlayer, pev_punchangle, punchangle)
	new Float:recoil = get_pcvar_float(cvar_recoil)
	punchangle[0] -= recoil
	punchangle[1] += random_float(-recoil/2.0, recoil/2.0)
	set_pev(iPlayer, pev_punchangle, punchangle)
	
	SendWeaponAnim(iPlayer, anim_shoot)
	
	return HAM_SUPERCEDE
}

public HAM_ItemDeploy_Post(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRM32)
	return
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	set_pev(iPlayer, pev_viewmodel2, M32Models[0])
	set_pev(iPlayer, pev_weaponmodel2, M32Models[1])
	SendWeaponAnim(iPlayer, anim_draw)
	set_pdata_float(iPlayer, 83, 1.3, 5)
}

public HAM_Weapon_Reload(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRM32)
	return HAM_IGNORED
	
	if(get_pdata_int(iEntity, 51, 4) >= get_pcvar_num(cvar_clip))
	return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

public HAM_Weapon_Reload_Post(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRM32)
	return
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if(get_pdata_float(iPlayer, 83, 5) <= 0.0)
	return
	
	set_pdata_float(iPlayer, 83, 2.0, 5)
	set_pdata_float(iEntity, 48, 2.0, 4)
	set_pdata_int(iEntity, 54, STARTMODE, 4)
	SendWeaponAnim(iPlayer, anim_start_reload)
}

public HAM_Weapon_PostFrame(iEntity)
{
	if(pev(iEntity, pev_weapons) != ZRM32)
	return HAM_IGNORED
	
	new ReloadMode = get_pdata_int(iEntity, 54, 4)
	if(!ReloadMode)
	return HAM_IGNORED
	
	new iPlayer = get_pdata_cbase(iEntity, 41, 4)
	
	if((get_pdata_int(iPlayer, 245, 5) & IN_ATTACK) && ReloadMode == INSERTMODE)
	{
	set_pdata_int(iEntity, 54, AFTERMODE, 4)
	return HAM_SUPERCEDE
	}
	
	if(get_pdata_float(iEntity, 48, 4) > 0.0)
	return HAM_SUPERCEDE
	
	if(ReloadMode == OVERMODE)
	{
	set_pdata_int(iEntity, 54, IDLEMODE, 4)
	SendWeaponAnim(iPlayer, anim_idle)
	return HAM_SUPERCEDE
	}
	
	new Clip = get_pdata_int(iEntity, 51, 4)
	new Ammo = get_pdata_int(iPlayer, 382, 5)
	
	if(ReloadMode != STARTMODE)
	{
	set_pdata_int(iEntity, 51, ++Clip, 4)
	set_pdata_int(iPlayer, 382, --Ammo, 5)
	}
	else set_pdata_int(iEntity, 54, INSERTMODE, 4)
	
	if(Clip >= get_pcvar_num(cvar_clip) || !Ammo || ReloadMode == AFTERMODE)
	{
	set_pdata_int(iEntity, 54, OVERMODE, 4)
	set_pdata_float(iEntity, 48, 1.27, 4)
	SendWeaponAnim(iPlayer, anim_after_reload)
	return HAM_SUPERCEDE
	}
	
	set_pdata_float(iEntity, 48, 0.85, 4)
	SendWeaponAnim(iPlayer, anim_insert)
	
	return HAM_SUPERCEDE
}

public HAM_Think_Post(iEntity)
{
	if(!pev_valid(iEntity))
	return
	
	static classname[32]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "m32grenade"))
	return
	
	new Float:velocity[3], Float:angles[3]
	pev(iEntity, pev_velocity, velocity)
	
	engfunc(EngFunc_VecToAngles, velocity, angles)
	set_pev(iEntity, pev_angles, angles)
	
	set_pev(iEntity, pev_nextthink, get_gametime())
}

public HAM_Touch_Post(iEntity)
{
	if(!pev_valid(iEntity))
	return
	
	static classname[32]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	
	if(strcmp(classname, "m32grenade"))
	return
	
	GrenadeExplose(iEntity)
}

public CreateGrenade(iPlayer)
{
	new Float:origin[3], Float:angles[3]
	get_aim_origin_vector(iPlayer, 16.0, 3.0, -3.0, origin)
	pev(iPlayer, pev_angles, angles)
	angles[0] *= 3.0
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEntity, pev_classname, "m32grenade")
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)
	set_pev(iEntity, pev_gravity, 0.5)
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_angles, angles)
	set_pev(iEntity, pev_modelindex, M32Index)
	set_pev(iEntity, pev_body, 1)
	set_pev(iEntity, pev_iuser3, get_pdata_cbase(iPlayer, 373))
	set_pev(iEntity, pev_owner, iPlayer)
	set_pev(iEntity, pev_nextthink, get_gametime())
	engfunc(EngFunc_SetOrigin, iEntity, origin)
	engfunc(EngFunc_SetSize, iEntity, {-1.0, -1.0, -1.0}, {1.0, 1.0, 1.0})
	SetPenetrationToGhost(iEntity, true)
	
	new Float:start[3], Float:view_ofs[3], Float:end[3]
	pev(iPlayer, pev_origin, start)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	
	pev(iPlayer, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, 8120.0, end)
	xs_vec_add(start, end, end)
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, iPlayer, 0)
	get_tr2(0, TR_vecEndPos, end)
	
	new Float:velocity[2][3]
	pev(iPlayer, pev_velocity, velocity[0])
	get_speed_vector(origin, end, get_pcvar_float(cvar_velocity), velocity[1])
	xs_vec_add(velocity[0], velocity[1], velocity[0])
	set_pev(iEntity, pev_velocity, velocity[0])
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(iEntity)
	write_short(TraceIndex)
	write_byte(2)
	write_byte(1)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(25)
	message_end()
}

public GrenadeExplose(iEntity)
{
	new iPlayer = pev(iEntity, pev_owner)
	
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	
	if(engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY)
	{
	set_pev(iEntity, pev_flags, FL_KILLME)
	return
	}
	
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, get_pcvar_float(cvar_range))) > 0)
	{
	if(!pev_valid(i) || iEntity == i)
	continue
	
	if(pev(i, pev_takedamage) == DAMAGE_NO)
	continue
	
	static classname[33]
	pev(i, pev_classname, classname, charsmax(classname))
	if(!strcmp(classname, "func_breakable"))
	{
	ExecuteHamB(Ham_TakeDamage, i, iPlayer, iPlayer, get_pcvar_float(cvar_damage), DMG_GENERIC)
	continue
	}
	
	new Float:origin2[3]
	pev(i, pev_origin, origin2)
	
	new Float:damage = floatclamp(get_pcvar_float(cvar_damage)*(1.0-(get_distance_f(origin2, origin)-21.0)/get_pcvar_float(cvar_range)), 0.0, get_pcvar_float(cvar_damage))
	if(damage == 0.0)
	continue
	
	ExecuteHamB(Ham_TakeDamage, i, pev(iEntity, pev_iuser3), iPlayer, damage, DMG_GENERIC)
	}
	
	new Float:velocity[3], Float:End[3], Float:OffSet[3]
	pev(iEntity, pev_velocity, velocity)
	
	xs_vec_add(origin, velocity, End)
	engfunc(EngFunc_TraceLine, origin, End, IGNORE_MONSTERS, iEntity, 0)
	
	new Float:PlaneNormal[3]
	get_tr2(0, TR_vecPlaneNormal, PlaneNormal)
	
	xs_vec_mul_scalar(PlaneNormal, random_float(50.0, 55.0), OffSet)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0]+OffSet[0])
	engfunc(EngFunc_WriteCoord, origin[1]+OffSet[1])
	engfunc(EngFunc_WriteCoord, origin[2]+OffSet[2])
	write_short(g_smodelindexfireball3)
	write_byte(25)
	write_byte(30)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	xs_vec_mul_scalar(PlaneNormal, random_float(70.0, 95.0), OffSet)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0]+OffSet[0])
	engfunc(EngFunc_WriteCoord, origin[1]+OffSet[1])
	engfunc(EngFunc_WriteCoord, origin[2]+OffSet[2])
	write_short(g_smodelindexfireball2)
	write_byte(30)
	write_byte(30)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_WEAPON, M32Sounds[1], VOL_NORM, 0.4, 0, PITCH_NORM)
	
	set_pev(iEntity, pev_flags, FL_KILLME)
}

public GiveM32(iPlayer)
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "weapon_ump45"))
	new Float:origin[3]
	pev(iPlayer, pev_origin, origin)
	set_pev(iEntity, pev_weapons, ZRM32)
	set_pev(iEntity, pev_origin, origin)
	set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, iEntity)
	new KeepSolid = pev(iEntity, pev_solid)
	dllfunc(DLLFunc_Touch, iEntity, iPlayer)
	
	if(pev(iEntity, pev_solid) == KeepSolid)
	{
	set_pev(iEntity, pev_flags, FL_KILLME)
	return
	}
	
	set_pdata_int(iEntity, 51, get_pcvar_num(cvar_clip), 4)
	set_pdata_int(iPlayer, 382, min(get_pcvar_num(cvar_clip)*5, 250), 4)
}

stock SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0,0,0}, iPlayer)
	write_byte(iAnim)
	write_byte(1)
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

stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	xs_vec_sub(origin2, origin1, new_velocity)
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	xs_vec_mul_scalar(new_velocity, num, new_velocity)
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