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
�������Զ���pev,ֻ��Ϊ������������,��ԭ����pevֵҲ����ν

AI��ֹ����:pev_idle
AI�ƶ�����:pev_move
AI��Ծ����:pev_jump
AI��������:pev_attack
AI��������[3]:pev_die

AI����:pev_ainame
AI�������:pev_max_health
AI����ٶ�:pev_maxspeed
AI����:pev_gravity
AI����:pev_team
AI�����˺�:pev_damage
AI������Χ:pev_distance
AI�����ٶ�:pev_attackrate
AI��Ӧʱ��:pev_thinkrate
AI��������������ʱ��:pev_dyingtime

*/

/*���������ݽӿ�---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

//��ȡ��ʵ���Ƿ���AI
native bool:IsAi(iEntity)

//����һ��AI(��������,AI����,AIģ�ͻ�������,AI����Max[3],AI����Min[3],AI�������,AI����ٶ�,AI����,AI�˺�,AI�˺�����,AI�����ٶ�,AI��Ӧʱ��,AI��������������ʱ��,AI����),����AI��ʵ������
native CreateAi(Float:origin[3], AiName[], modelindex, Float:maxhull[3], Float:minhull[3], Float:maxhealth, Float:maxspeed, Float:gravity, Float:damage, Float:distance, Float:attackrate, Float:thinkrate, Float:dyingtime, team)

//���ø�AIʵ��Ķ���(ID����, ��ֹ����, �ƶ�����, ��Ծ����, ��������, ��������[3��])
native SetAiAnim(iEntity, idle, move, jump, attack, die[3])

/*
�ڴ���AI��ʱ�����ö����Ϳ�����
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
	
	new iEntity = CreateAi(origin, "SB��ʬ", modelindex, MAX_HULL, MIN_HULL, 100.0, 240.0, 1.0, 5.0, 70.0, 1.0, 0.5, 2.0, 1)
	SetAiAnim(iEntity, 1, 2, 3, 4, {5, 6, 7})
}
*/

//�Ƴ������ֵ�����AI
native RemoveAi(const ainame[])

//�Ƴ�����AI
native RemoveAllAi()

//��ȡ�����ֵ�����AI����
native GetAIAmount(const ainame[])

//��ȡ����AI������
native GetAllAIAmount()

//����AI�Ķ���
native SendAiAnim(iEntity, anim)

/*�������¼������ӿ�-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
//Post�¼����ص�ʱ����Ҫ�����κ�ֵ,Pre�¼���Ҫ.

//Pre�¼�:AI��think,AI������Ķ���,�ƶ�,�жϵȶ��������,ÿ��"AI��Ӧʱ��"�ʹ���һ��.
forward AI_PreThink(iEntity)

//Post�¼�:���ܺ�AI_PreThinkһ��,ֻ���������Դ��,��Ϊ��post�¼�.
forward AI_PostThink(iEntity)

//Pre�¼�:AI����ʱ����,��ʵ����Ham_TraceAttack,ֻ�����˸�Float:direction[3]
forward AI_PreHurted(iEntity, attacker, Float:damage, tracehandle, damagetype)

//Post�¼�:���ܺ�AI_PreHurtedһ��,ֻ���������Դ��,��Ϊ��post�¼�.
forward AI_PostHurted(iEntity, attacker, Float:damage, tracehandle, damagetype)

//Pre�¼�:AI��ɱ��ʱ�ᴥ��.
forward AI_PreKilled(iEntity, killer)

//Post�¼�:���ܺ�AI_PreKilledһ��,ֻ���������Դ��,��Ϊ��post�¼�.
forward AI_PostKilled(iEntity, killer)