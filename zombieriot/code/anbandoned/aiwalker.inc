#if defined _aiwalker_included
  #endinput
#endif
#define _aiwalker_included

#define AI_IGNORED 0
#define AI_SUPERCEDE 1

#define pev_idle pev_iuser1
#define pev_move pev_iuser2
#define pev_jump pev_iuser3
#define pev_attack pev_iuser4
#define pev_die pev_vuser4

#define pev_ainame pev_targetname
#define pev_damage pev_speed
#define pev_distance pev_fuser1
#define pev_attackrate pev_fuser2
#define pev_thinkrate pev_fuser3
#define pev_dyingtime pev_fuser4

/*
以下是自定义pev,只是为了用起来方便,用原来的pev值也无所谓

AI静止动作:pev_idle
AI移动动作:pev_move
AI跳跃动作:pev_jump
AI攻击动作:pev_attack
AI死亡动作[3]:pev_die

AI名字:pev_ainame
AI最大生命:pev_max_health
AI最大速度:pev_maxspeed
AI重力:pev_gravity
AI队伍:pev_team
AI攻击伤害:pev_damage
AI攻击范围:pev_distance
AI攻击速度:pev_attackrate
AI反应时间:pev_thinkrate
AI播放死亡动作的时间:pev_dyingtime

*/

/*以下是数据接口---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

//获取该实体是否是AI
native bool:IsAi(iEntity)

//创建一个AI(创建坐标,AI名字,AI模型缓存索引,AI体型Max[3],AI体型Min[3],AI最大生命,AI最大速度,AI重力,AI伤害,AI伤害距离,AI攻击速度,AI反应时间,AI播放死亡动作的时间,AI队伍),返回AI的实体索引
native CreateAi(Float:origin[3], AiName[], modelindex, Float:maxhull[3], Float:minhull[3], Float:maxhealth, Float:maxspeed, Float:gravity, Float:damage, Float:distance, Float:attackrate, Float:thinkrate, Float:dyingtime, team)

//设置该AI实体的动作(ID索引, 静止动作, 移动动作, 跳跃动作, 攻击动作, 死亡动作[3个])
native SetAiAnim(iEntity, idle, move, jump, attack, die[3])

/*
在创建AI的时候设置动作就可以了
new modelindex
public plugin_precache() modelindex = engfunc(EngFunc_PrecacheModel, "models/zombie.mdl")
makezombie()
{
	new Float:MAX_HULL[3], Float:MIN_HULL[3]
	
	MAX_HULL[0] = -16.0
	MAX_HULL[1] = -10.0
	MAX_HULL[2] = -36.0
	MIN_HULL[0] = 16.0
	MIN_HULL[1] = 10.0
	MIN_HULL[2] = 36.0
	
	new iEntity = CreateAi(origin, "SB僵尸", modelindex, MAX_HULL, MIN_HULL, 100.0, 240.0, 1.0, 5.0, 70.0, 1.0, 0.5, 2.0, 1)
	SetAiAnim(iEntity, 1, 2, 3, 4, {5, 6, 7})
}
*/

//移除该名字的所有AI
native RemoveAi(const ainame[])

//移除所有AI
native RemoveAllAi()

//获取该名字的所有AI数量
native GetAIAmount(const ainame[])

//获取所有AI的数量
native GetAllAIAmount()

//播放AI的动作
native SendAiAnim(iEntity, anim)

/*以下是事件触发接口-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
//Post事件返回的时候不需要返回任何值,Pre事件则要.

//Pre事件:AI的think,AI最基本的动作,移动,判断等都在这进行,每隔"AI反应时间"就触发一次.
forward AI_PreThink(iEntity)

//Post事件:功能和AI_PreThink一样,只不过不可以打断,因为是post事件.
forward AI_PostThink(iEntity)

//Pre事件:AI受伤时触发,其实就是Ham_TraceAttack,只是少了个Float:direction[3]
forward AI_PreHurted(iEntity, attacker, Float:damage, tracehandle, damagetype)

//Post事件:功能和AI_PreHurted一样,只不过不可以打断,因为是post事件.
forward AI_PostHurted(iEntity, attacker, Float:damage, tracehandle, damagetype)

//Pre事件:AI被杀死时会触发.
forward AI_PreKilled(iEntity, killer)

//Post事件:功能和AI_PreKilled一样,只不过不可以打断,因为是post事件.
forward AI_PostKilled(iEntity, killer)