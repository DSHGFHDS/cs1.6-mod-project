/* ammx编写头版 by Devzone*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieriot>
#include <zrmenu>
#include <xs>

#define PLUGIN "Zr Materials"
#define VERSION "1.0"
#define AUTHOR "DSHGFHDS"
#define MATERIALMAX 64
#define MENUNAME "建筑材料"
#define MCLASSNAME "material"
#define MAXENTITY 64

#define BREAK_GLASS 0x01
#define BREAK_METAL 0x02
#define BREAK_FLESH 0x04
#define BREAK_WOOD 0x08
#define BREAK_CONCRETE 0x40

enum
{
	STONE = 1,
	CEMENT,
	WOOD,
	GLASS,
	WIRECLOTH,
	METAL,
	FLESH, 
	EXPLOSION
}

new MainMenuID
new MaterialsAmount
new MaterialID[MATERIALMAX+1], MaterialName[MATERIALMAX+1][64], MaterialModelIndex[MATERIALMAX+1], MaterialCost[MATERIALMAX+1], Float:MaterialHealth[MATERIALMAX+1], Float:MaterialGravity[MATERIALMAX+1], Float:MaterialMin[MATERIALMAX+1][3], Float:MaterialMax[MATERIALMAX+1][3], MaterialGibs[MATERIALMAX+1]

new const StoneSounds[2][] =  { "weapons/ric_conc-1.wav", "weapons/ric_conc-2.wav" }
new const MetalSounds[2][] = { "weapons/ric_metal-1.wav", "weapons/ric_metal-2.wav" }
new const WoodSounds[2][] = { "debris/wood1.wav", "debris/wood3.wav" }
new const GibsModels[8][] = { "", "models/rockgibs.mdl", "models/concretegibs.mdl", "models/woodgibs.mdl", "models/glassgibs.mdl", "models/webgibs.mdl", "models/metalplategibs.mdl", "models/fleshgibs.mdl" }
new GibsIndex[8], spr_blood_spray, spr_blood_drop, g_smodelindexfireball2, g_smodelindexfireball3

new EntAmount
new PickUp[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)
	RegisterHam(Ham_Think, "info_target", "HAM_Think")
	RegisterHam(Ham_Touch, "info_target", "HAM_Touch")
	RegisterHam(Ham_TraceAttack, "info_target", "HAM_TraceAttack_Post", 1)
	RegisterHam(Ham_Killed, "info_target", "HAM_Killed")
	if(MaterialsAmount) MainMenuID = zr_register_menu(MENUNAME)
}

public plugin_precache()
{
	static file[256], config[32]
	get_localinfo("amxx_configsdir", config, charsmax(config))
	formatex(file, charsmax(file), "%s/materials.ini", config)
	LoadMaterialsFile(file)
	spr_blood_spray = engfunc(EngFunc_PrecacheModel, "sprites/bloodspray.spr")
	spr_blood_drop = engfunc(EngFunc_PrecacheModel, "sprites/blood.spr")
	g_smodelindexfireball2 = engfunc(EngFunc_PrecacheModel, "sprites/eexplo.spr")
	g_smodelindexfireball3 = engfunc(EngFunc_PrecacheModel, "sprites/fexplo.spr")
}

public LoadMaterialsFile(files[])
{
	static linedata[512], key[256], value[256]
	new file = fopen(files, "rt")
	while(file && !feof(file))
	{
		if(MaterialsAmount >= MATERIALMAX)
		break
	
		fgets(file, linedata, charsmax(linedata))
		if(!linedata[0] || linedata[0] == ';' || linedata[0] == '^n')
		continue
	
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		trim(key)
		trim(value)
	
		if(!strcmp(key, "ID"))
		{
			new ID = str_to_num(value)
			static ErrorMGE[128]
			if(ID <= 0)
			{
				formatex(ErrorMGE, charsmax(ErrorMGE), "%sID:材料注册失败,ID只能为非零正整数!", ID)
				set_fail_state(ErrorMGE)
			}
			for(new i = 1; i <= MaterialsAmount; i ++)
			{
				if(MaterialID[i] == ID)
				{
					formatex(ErrorMGE, charsmax(ErrorMGE), "%sID:材料注册失败,此ID已重复!", ID)
					set_fail_state(ErrorMGE)
				}
			}
			MaterialID[++MaterialsAmount] = ID
		}
		else if(!strcmp(key, "名称")) copy(MaterialName[MaterialsAmount], charsmax(MaterialName[]), value)
		else if(!strcmp(key, "材料模型")) MaterialModelIndex[MaterialsAmount] = engfunc(EngFunc_PrecacheModel, value)
		else if(!strcmp(key, "价格")) MaterialCost[MaterialsAmount] = str_to_num(value)
		else if(!strcmp(key, "生命")) MaterialHealth[MaterialsAmount] = str_to_float(value)
		else if(!strcmp(key, "重量")) MaterialGravity[MaterialsAmount] = str_to_float(value)
		else 
		if(!strcmp(key, "尺寸min"))
		{
			new Size[10], i
			while(value[0] && strtok(value, Size, charsmax(Size), value, charsmax(value), ','))
			{
				trim(value)
				trim(Size)
				MaterialMin[MaterialsAmount][i ++] = str_to_float(Size)
			}
		}
		else 
		if(!strcmp(key, "尺寸max"))
		{
			new Size[10], i
			while(value[0] && strtok(value, Size, charsmax(Size), value, charsmax(value), ','))
			{
				trim(value)
				trim(Size)
				MaterialMax[MaterialsAmount][i ++] = str_to_float(Size)
			}
		}
		else
		if(!strcmp(key, "碎片材料"))
		{
			MaterialGibs[MaterialsAmount] = str_to_num(value)
			if(MaterialGibs[MaterialsAmount] != EXPLOSION && !GibsIndex[MaterialGibs[MaterialsAmount]]) GibsIndex[MaterialGibs[MaterialsAmount]] = engfunc(EngFunc_PrecacheModel, GibsModels[MaterialGibs[MaterialsAmount]])
		}
	}
	fclose(file)
}

public zr_roundbegin_event(Weather)
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", MCLASSNAME))) RemoveMaterial(iEntity)
}

public fw_PlayerPostThink_Post(iPlayer)
{
	if(pev(iPlayer, pev_deadflag) != DEAD_NO)
	return
	
	if(zr_is_user_zombie(iPlayer))
	return
	
	new Pressed = get_pdata_int(iPlayer, 246, 5)
	if(!(Pressed & IN_USE))
	return
	
	if(PickUp[iPlayer])
	{
	if(!pev_valid(PickUp[iPlayer]))
	{
	PickUp[iPlayer] = 0
	return
	}
	SetFree(PickUp[iPlayer])
	return
	}
	
	new Float:start[3], Float:view_ofs[3], Float:end[3]
	pev(iPlayer, pev_origin, start)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	
	pev(iPlayer, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, 100.0, end)
	xs_vec_add(start, end, end)
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, iPlayer, 0)
	
	new iEntity = get_tr2(0, TR_pHit)
	if(!pev_valid(iEntity))
	return
	
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, MCLASSNAME))
	return
	
	SetPickedUp(iEntity, iPlayer)
}

public HAM_Think(iEntity)
{
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, MCLASSNAME))
	return HAM_IGNORED
	
	set_pev(iEntity, pev_nextthink, get_gametime())
	
	CheckPickedUp(iEntity)
	CheckFalling(iEntity)
	
	return HAM_SUPERCEDE
}

public HAM_Touch(iEntity, iPtd)
{
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, MCLASSNAME))
	return HAM_IGNORED
	
	if(is_user_alive(iPtd) && pev(iPtd, pev_groundentity) == iEntity && pev(iEntity, pev_iuser4))
	{
	SetFree(iEntity)
	return HAM_SUPERCEDE
	}
	
	if(pev_valid(iPtd))
	return HAM_SUPERCEDE
	
	if(!engfunc(EngFunc_EntIsOnFloor, iEntity))
	return HAM_SUPERCEDE
	
	new Sequence = pev(iEntity, pev_iuser2)
	
	new Float:start[3], Float:end[3], Float:fraction
	pev(iEntity, pev_origin, start)
	pev(iEntity, pev_origin, end)
	end[2] -= MaterialMax[Sequence][2]-MaterialMin[Sequence][2]
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, iEntity, 0)
	get_tr2(0, TR_flFraction, fraction)
	
	if(fraction == 1.0)
	return HAM_SUPERCEDE
	
	new Float:vector[3], Float:angles[2][3]
	pev(iEntity, pev_angles, angles[0])
	angle_vector(angles[0], ANGLEVECTOR_FORWARD, vector)
	
	new Float:right[3], Float:up[3], Float:fwd[3]
	
	get_tr2(0, TR_vecPlaneNormal, up)
	xs_vec_cross(vector, up, right)
	xs_vec_cross(up, right, fwd)
	engfunc(EngFunc_VecToAngles, fwd, angles[0])
	engfunc(EngFunc_VecToAngles, right, angles[1])
	angles[0][2] = -angles[1][0]
	set_pev(iEntity, pev_angles, angles[0])
	
	return HAM_SUPERCEDE
}

public HAM_TraceAttack_Post(iEntity, attacker, Float:damage, Float:Dir[3], iTrace, damagetype)
{
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, MCLASSNAME))
	return
	
	new Float:origin[3]
	get_tr2(iTrace, TR_vecEndPos, origin)
	
	new Material = MaterialGibs[pev(iEntity, pev_iuser2)]
	
	if(Material == FLESH)
	{
	SpawnBlood(origin, 247, floatround(damage))
	return
	}
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()
	
	if(Material == EXPLOSION)
	return
	
	if(Material == STONE || Material == CEMENT || Material == GLASS)
	{
	engfunc(EngFunc_EmitSound, iEntity, CHAN_ITEM, StoneSounds[random_num(0, 1)], 0.5, ATTN_STATIC, 0, PITCH_NORM)
	return
	}
	
	if(Material == WIRECLOTH || Material == WIRECLOTH)
	{
	engfunc(EngFunc_EmitSound, iEntity, CHAN_ITEM, MetalSounds[random_num(0, 1)], 0.5, ATTN_STATIC, 0, PITCH_NORM)
	return
	}
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_ITEM, WoodSounds[random_num(0, 1)], 0.5, ATTN_STATIC, 0, PITCH_NORM)
}

public HAM_Killed(iEntity, attacker, shouldgib)
{
	static classname[33]
	pev(iEntity, pev_classname, classname, charsmax(classname))
	if(strcmp(classname, MCLASSNAME))
	return HAM_IGNORED
	
	new Sequence = pev(iEntity, pev_iuser2)
	
	if(MaterialGibs[Sequence] == EXPLOSION)
	{
	Explose(iEntity)
	return HAM_SUPERCEDE
	}
	
	new Float:Hight = MaterialMax[Sequence][2]-MaterialMin[Sequence][2]
	new Float:Area = (MaterialMax[Sequence][0]-MaterialMin[Sequence][0])*(MaterialMax[Sequence][1]-MaterialMin[Sequence][1])*Hight
	
	new Float:origin[2][3], Float:velocity[3]
	pev(iEntity, pev_origin, origin[0])
	pev(iEntity, pev_origin, origin[1])
	origin[1][2] += Hight/2.0
	GetVelocityFromOrigin(origin[1], origin[0], Hight/2.0, velocity)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin[0], 0)
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, origin[0][0])
	engfunc(EngFunc_WriteCoord, origin[0][1])
	engfunc(EngFunc_WriteCoord, origin[0][2])
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, velocity[0])
	engfunc(EngFunc_WriteCoord, velocity[1])
	engfunc(EngFunc_WriteCoord, velocity[2])
	write_byte(clamp(floatround(Area*0.00006), 10, 25))
	write_short(GibsIndex[MaterialGibs[Sequence]])
	write_byte(clamp(floatround(Area*0.00006), 10, 45))
	write_byte(10)
	switch(MaterialGibs[Sequence])
	{
	case 1:write_byte(BREAK_CONCRETE)
	case 2:write_byte(BREAK_CONCRETE)
	case 3:write_byte(BREAK_WOOD)
	case 4:write_byte(BREAK_GLASS)
	case 5:write_byte(BREAK_METAL)
	case 6:write_byte(BREAK_METAL)
	case 7:write_byte(BREAK_FLESH)
	}
	message_end()
	
	RemoveMaterial(iEntity)
	
	return HAM_SUPERCEDE
}

public zr_addmenu_event(iPlayer, MenuID)
{
	if(MenuID != MainMenuID)
	return
	
	if(zr_is_user_zombie(iPlayer))
	{
	zr_print_chat(iPlayer, GREYCHAT, "僵尸无法使用!")
	return
	}
	
	MaterialsMenu(iPlayer)
}

public MaterialsMenu(iPlayer)
{
	static ItemInfo[64], Sequence[10]
	new menuid = menu_create(MENUNAME, "MainMenuThouch")
	for(new i = 1; i <= MaterialsAmount; i ++)
	{
	formatex(ItemInfo, charsmax(ItemInfo), "%s %d$", MaterialName[i], MaterialCost[i])
	num_to_str(i, Sequence, charsmax(Sequence))
	menu_additem(menuid, ItemInfo, Sequence, 0)
	}
	menu_setprop(menuid, MPROP_BACKNAME, "上一页")
	menu_setprop(menuid, MPROP_NEXTNAME, "下一页")
	menu_setprop(menuid, MPROP_EXITNAME, "离开")
	menu_display(iPlayer, menuid)
}

public MainMenuThouch(iPlayer, menuid, item)
{
	if(item == MENU_EXIT || !is_user_alive(iPlayer))
	{
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	if(zr_is_user_zombie(iPlayer))
	{
	zr_print_chat(iPlayer, GREYCHAT, "僵尸无法使用!")
	menu_destroy(menuid)
	return PLUGIN_HANDLED
	}
	
	new command[10], name[32], access, callback
	menu_item_getinfo(menuid, item, access, command, charsmax(command), name, charsmax(name), callback)
	new Sequence = str_to_num(command)
	
	if(1 <= Sequence <= MaterialsAmount) BuyMaterial(iPlayer, Sequence)
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED
}

public BuyMaterial(iPlayer, Sequence)
{
	if(zr_is_user_zombie(iPlayer))
	{
	zr_print_chat(iPlayer, GREYCHAT, "僵尸无法使用!")
	return
	}
	
	MaterialsMenu(iPlayer)
	
	new money = zr_get_user_money(iPlayer)
	if(money < MaterialCost[Sequence])
	{
	zr_print_chat(iPlayer, GREYCHAT, "不够金钱!")
	return
	}
	
	if(CreateMaterial(iPlayer, Sequence))
	{
	zr_set_user_money(iPlayer, money-MaterialCost[Sequence], 1)
	return
	}
	
	zr_print_chat(iPlayer, GREYCHAT, "这个位置无法放置!")
}

public bool:CreateMaterial(iPlayer, Sequence)
{
	if(EntAmount >= MAXENTITY)
	{
	zr_print_chat(iPlayer, GREYCHAT, "实体数已超过%d,无法再创建!", MAXENTITY)
	return false
	}
	
	new Float:Length = MaterialMax[Sequence][0]-MaterialMin[Sequence][0]
	new Float:Width = MaterialMax[Sequence][1]-MaterialMin[Sequence][1]
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEntity, pev_classname, MCLASSNAME)
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_modelindex, MaterialModelIndex[Sequence])
	set_pev(iEntity, pev_takedamage, DAMAGE_YES)
	set_pev(iEntity, pev_gravity, MaterialGravity[Sequence])
	set_pev(iEntity, pev_health, MaterialHealth[Sequence])
	set_pev(iEntity, pev_iuser1, MaterialID[Sequence])
	set_pev(iEntity, pev_iuser2, Sequence)
	set_pev(iEntity, pev_nextthink, get_gametime())
	engfunc(EngFunc_SetSize, iEntity, MaterialMin[Sequence], MaterialMax[Sequence])
	
	new Float:start[3], Float:view_ofs[3], Float:end[3], Float:Distance = 36.0+floatsqroot(floatpower(Length, 2.0)+floatpower(Width, 2.0))/2.0
	pev(iPlayer, pev_origin, start)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	
	pev(iPlayer, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, Distance, end)
	xs_vec_add(start, end, end)
	
	engfunc(EngFunc_TraceMonsterHull, iEntity, end, end, DONT_IGNORE_MONSTERS, iEntity, 0)
	
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
	{
	engfunc(EngFunc_RemoveEntity, iEntity)
	return false
	}
	
	engfunc(EngFunc_SetOrigin, iEntity, end)
	EntAmount ++
	
	return true
}

public Explose(iEntity)
{
	new Float:origin[3]
	pev(iEntity, pev_origin, origin)
	
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, origin, 350.0)) > 0)
	{
	if(!pev_valid(i) || iEntity == i)
	continue
	
	if(pev(i, pev_takedamage) == DAMAGE_NO)
	continue
	
	static classname[33]
	pev(i, pev_classname, classname, charsmax(classname))
	if(!strcmp(classname, "func_breakable"))
	{
	ExecuteHamB(Ham_TakeDamage, i, iEntity, iEntity, 100.0, (1<<24))
	continue
	}
	
	new Float:origin2[3]
	pev(i, pev_origin, origin2)
	
	new Float:damage = floatclamp(100.0*(1.0-(get_distance_f(origin2, origin)-21.0)/350.0), 0.0, 100.0)
	if(damage == 0.0)
	continue
	
	ExecuteHamB(Ham_TakeDamage, i, iEntity, iEntity, damage, (1<<24))
	}
	
	new Float:OffSet = random_float(50.0, 55.0)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2]+OffSet)
	write_short(g_smodelindexfireball3)
	write_byte(25)
	write_byte(30)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	OffSet = random_float(70.0, 95.0)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2]+OffSet)
	write_short(g_smodelindexfireball2)
	write_byte(30)
	write_byte(30)
	write_byte(TE_EXPLFLAG_NONE)
	message_end()
	
	RemoveMaterial(iEntity)
}

public CheckPickedUp(iEntity)
{
	new iPlayer = pev(iEntity, pev_iuser4)
	if(!iPlayer)
	return
	
	if(!is_user_alive(iPlayer) || zr_is_user_zombie(iPlayer))
	{
	SetFree(iEntity)
	return
	}
	
	new Sequence = pev(iEntity, pev_iuser2)
	new Float:Length = MaterialMax[Sequence][0]-MaterialMin[Sequence][0]
	new Float:Width = MaterialMax[Sequence][1]-MaterialMin[Sequence][1]
	new Float:Distance = 30.0+floatsqroot(floatpower(Length, 2.0)+floatpower(Width, 2.0))/2.0
	
	new Float:start[3], Float:view_ofs[3], Float:end[3]
	pev(iPlayer, pev_origin, start)
	pev(iPlayer, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	pev(iEntity, pev_origin, end)
	
	if(get_distance_f(start, end) > Distance+50.0)
	{
	SetFree(iEntity)
	return
	}
	
	pev(iPlayer, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, Distance, end)
	xs_vec_add(start, end, end)
	
	new Float:velocity[3]
	pev(iEntity, pev_origin, start)
	
	if(get_distance_f(start, end) <= 5.0)
	{
	set_pev(iEntity, pev_velocity, { 0.0, 0.0, 0.0 })
	return
	}
	
	get_speed_vector(start, end, 1000.0, velocity)
	set_pev(iEntity, pev_velocity, velocity)
}

public CheckFalling(iEntity)
{
	new GroundEntity = pev(iEntity, pev_groundentity)
	if(!GroundEntity)
	return
	
	set_pev(iEntity, pev_groundentity, 0)
	set_pev(iEntity, pev_flags, (pev(iEntity, pev_flags) & ~FL_ONGROUND))
}

public SetPickedUp(iEntity, iPlayer)
{
	PickUp[iPlayer] = iEntity
	set_pev(iEntity, pev_iuser4, iPlayer)
	set_pev(iEntity, pev_movetype, MOVETYPE_FLY)
	set_pev(iEntity, pev_groundentity, 0)
}

public SetFree(iEntity)
{
	PickUp[pev(iEntity, pev_iuser4)] = 0
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_velocity, { 0.0, 0.0, 0.0 })
	set_pev(iEntity, pev_iuser4, 0)
}

public RemoveMaterial(iEntity)
{
	PickUp[pev(iEntity, pev_iuser4)] = 0
	engfunc(EngFunc_RemoveEntity, iEntity)
	EntAmount --
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

stock GetVelocityFromOrigin(Float:origin1[3], Float:origin2[3], Float:speed, Float:velocity[3])
{
	xs_vec_sub(origin1, origin2, velocity)
	new Float:valve = get_distance_f(origin1, origin2)/speed
	
	if(valve <= 0.0)
	return
	
	xs_vec_div_scalar(velocity, valve, velocity)
}

stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	xs_vec_sub(origin2, origin1, new_velocity)
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	xs_vec_mul_scalar(new_velocity, num, new_velocity)
}