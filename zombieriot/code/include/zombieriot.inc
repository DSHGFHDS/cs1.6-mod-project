#if defined _zombieriot_included
  #endinput
#endif
#define _zombieriot_included

#include <zrconst>

/*ZR�������͡���ʬ���ͺ���Ʒ����ע��ԭ��
��Ϸ���������ͺͽ�ʬ���Ͷ���ͨ��iniģ���ļ����ص�,cstrike\addons\amxmodx\configs\(zombie.ini)��(human.ini).
������Ϸʱ,�ͻ��Զ���ȡ�������Ϣ,���Ȼ��Ȱ����ϵ��µ�˳��ذ����ͼ���.����������,���е��������ͺͽ�ʬ������Ϣ����ͨ��iniģ�������˳���������,����������Լ����õ�ID.
���������õ�ID����������û�����κ�����,ֻ���ṩ��д�Ӳ�����������ʹ�õ�,Ҳ���������µĸ���������ͽ�ʬ���͵����ݽӿ�,����Ĳ�����iniģ�������˳��,�����������õ�ID.
�������ͺͽ�ʬ���͵�ID������˳���Ƕ���������,���Բ��ص����������ͺͽ�ʬ���͵�ID�����ظ���������(��Ҳ�������������˳���ID����ת���Ľ�ڻ�Ҫ����������ԭ��).
���Ӳ����,�õ���iniģ�������˳��ĵط�Ҳ��ֻ�������ط�,һ�Ƕ������������ͻ����ǽ�ʬ����ѭ������ʱ��,���Ǵ���ѡ������ zrzombies_˳�� �� zrhumans_˳��.
ѭ�����͵�ʱ��,������zr_get_zombie_amount()��zr_get_human_amount()����ȡ���͵�������,��Ϊ����˳���Ǵ�1��ʼ,һֱ��ģ��������Ϊֹ,���������������͵�˳����,Ҳ��������������͵�������,��ϸ���ӿ�ע��.
������������,�����ṩ��zr_sequence_to_id��zr_id_to_sequence�������ӿ�,��������ID������˳��֮���ת��.
��1.12�汾�Ժ�,��ʬ���ͺ���������������ֱ��ͨ���ӿ�ע��İ취,�ڴ�INC�¿��ҵ�.��ģ��ע�᲻ͬ����,����ע������Ͳ������Լ�����ID,�����ɲ���Լ�����,���ڽӿ��ﷵ��,����ֻҪ���ü�¼�Ϳ�����.

��Ʒ��ע����Լ�,��Ϊ��֧��ģ��ע��,������Ʒ��ID���ɲ�������,���ҷ����ID��ע��˳����һ����,��1��ʼ,һֱ�����һ��ע�����Ʒ.


���������ݽӿ�---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

//�ж��Ƿ�������ģʽ(zr_��ͷ�ĵ�ͼ)
native bool:zr_is_escapemode()

//�ж��Ƿ�����֧ԮZBOT(settingmenu.ini������)
native bool:zr_zbot_supported()

//���һ�����½���Ϣ,ʹ�÷�����client_print����,֧����ɫѡ��͸�ʽ��,���޷����м���ʾ.
native zr_print_chat(const iPlayer, const Color, const Message[], any:...)
/*
	��:REDCHAT
	��:GREENCHAT
	��:BLUECHAT
	��:GREYCHAT
	Ĭ��:NORMALCHAT
	
	������������һ���ɫ����Ϣ
	
	new JJamount = 0
	zr_print_chat(0, REDCHAT, "����%d��JJ", JJamount)
*/

//ǿ�ƽ���һ��(Team��ʤ������HUMAN��ZOMBIE,����zr_hook_roundend(WinTeam)��ϵ�Ӱ��)
native zr_set_round_end(Team)

//��ȡ��ҵ�ǰ��ʬ��ID
native zr_get_zombie_id(iPlayer)

//��ȡ�ý�ʬID�Ƿ�������
native bool:zr_is_zombie_male(Type)

//��ȡ���ѡ��Ľ�ʬ��ID
native zr_get_nextzombie_id(iPlayer)

//�������ѡ��Ľ�ʬ��ID
native zr_set_nextzombie_id(iPlayer, Type)

//��ȡ�ý�ʬID������(�ʬID)
native zr_get_zombie_name(Type, name[], len)

//��ȡ�ý�ʬID�Ľ���(�ʬID)
native zr_get_zombie_info(Type, info[], len)

//��ȡ�ý�ʬID�ĳ�ʼ����ֵ(�ʬID)
native Float:zr_get_zombie_health(Type)

//��ȡ�ý�ʬID������ģ��(�ʬID)
native zr_get_zombie_model(Type, model[], len)

//��ȡ�ý�ʬID���ֱ�ģ��(�ʬID)
native zr_get_zombie_claw(Type, model[], len)

//��ȡ��ҵ�ǰ�����ID
native zr_get_human_id(iPlayer)

//��ȡ������ID�Ƿ�������
native bool:zr_is_human_male(Type)

//��ȡ���ѡ��������ID
native zr_get_nexthuman_id(iPlayer)

//�������ѡ��������ID
native zr_set_nexthuman_id(iPlayer, Type)

//��ȡ������ID������(������ID)
native zr_get_human_name(Type, name[], len)

//��ȡ������ID�Ľ���(������ID)
native zr_get_human_info(Type, info[], len)

//��ȡ������ID�ĳ�ʼ����ֵ(������ID)
native Float:zr_get_human_health(Type)

//��ȡ������ID������ģ��(������ID)
native zr_get_human_model(Type, model[], len)

//��ȡ����Ƿ�����ҹ����(�������Ч)
native bool:zr_get_human_nvg(iPlayer)

//������ҵ�ҹ����(Mode:true�ǿ�false�ǹ�,ֻ��������Ч)
native zr_set_human_nvg(iPlayer, bool:Mode)

//��ȡ�ý�ʬID�Ƿ�ΪBOSS(�ʬID)
native bool:zr_is_zombie_boss(Type)

//��ȡ�ý�ʬID�Ƿ�Ϊ���ؽ�ɫ
native bool:zr_is_zombie_hidden(Type)

//��ȡ������ID�Ƿ�Ϊ���ؽ�ɫ
native bool:zr_is_human_hidden(Type)

//��ȡ����Ƿ��ǽ�ʬ(�����ʵ��ͨ��offset����ȡ����,����һ��Ҫע��,���ȷ����Ҫ��ȡ��id����Ҳ�ʹ��,�����ը��)
native bool:zr_is_user_zombie(iPlayer)

//��ȡ����Ƿ�������
native bool:zr_is_user_ghost(iPlayer)

//����ʬ�������IDת������ģ�����ID����˳��,����ͽ�ʬ��ID����˳�������ֿ�����,����Ҫ��������ж�(��һ�����ID�Ķ���, �ڶ�����Ҫת����ID����˳��)
native zr_id_to_sequence(Team, sequence)

//��������ģ�����ID����˳��ת��������ID, ����ͽ�ʬ��ID����˳�������ֿ�����,����Ҫ��������ж�(��һ�����ID�Ķ���, �ڶ�����Ҫת����ID)
native zr_sequence_to_id(Team, Type)

//��ȡ��ע��Ľ�ʬ��������
native zr_get_zombie_amount()
/*���zr_sequence_to_idʹ�ÿɻ�ȡĳ����ID�Ƿ���BOSS
	new amount = zr_get_zombie_amount()
	for(new i = 1; i <= amount; i ++)
	{
	new Type = zr_sequence_to_id(ZOMBIE, i)
	if(zr_is_zombie_boss(Type))
	{
	client_print(0, print_chat, "ID:%d��BOSS", Type)
	}
	}

*/

//��ȡ��ע���������������
native zr_get_human_amount()

//��ȡĳ������ĵ÷�(Team�Ƕ���), ��ZR��÷ֲ�֪����ʲô����,�����ӿ��Լ����Ű��.
native zr_get_team_score(Team)

//����ĳ������ĵ÷�(Team�Ƕ���, score�Ƿ���), ��ZR��÷ֲ�֪����ʲô����,�����ӿ��Լ����Ű��.
native zr_set_team_score(Team, score)

//��ȡ��ҵĽ�Ǯ,��ԭ��Ľ�Ǯ��ͬ,ԭ��Ľ�Ǯֵ�Ѿ����ҿ۳�0��,��ֹBOT������.
native zr_get_user_money(iPlayer)

//������ҵĽ�Ǯ(����flag,�����1,�����ʾ��֮ǰ�Ľ�Ǯ�����ڵĽ�Ǯ�Ĳ��,0���)
native zr_set_user_money(iPlayer, money, flag)

//����ұ������(Type��Ҫ�������ID,�����0������ѡ�����������)
native zr_set_user_human(iPlayer, Type)

//����ұ�ɽ�ʬ(Type�����Ҫ��Ľ�ʬID,�����0������ѡ��Ľ�ʬ����,��������ó�BOSS��ID,�����ҾͲ���дzr_set_user_boss��)
native zr_set_user_zombie(iPlayer, Type)

//��������Ƿ�������״̬(true = ��, false = ����).
native zr_set_user_ghost(iPlayer, value)

//��ȡ��ҵ�����ģ��,�ǻ�ȡģ�͵��޺�׺����
native zr_get_user_model(iPlayer, model[], len)

//������ҵ�����ģ��,��ģ�͵��޺�׺����,����zr_set_user_model(iPlayer, "arctic"), ģ�͵�·����cstrike\models\player\arctic\arctic.mdl
native zr_set_user_model(iPlayer, const model[])

//�����ѡ��һ������(��ʵ��������Ҵ���zr_item_event)
native zr_set_user_item(iPlayer, item)

//ע�����(ֻ������Ʒ�˵������,��û�κι��ܺ�����,��Ҫ�Լ�д,������Ǯ���㶨,��һ����������,�ڶ�����������(HUMAN(����), ZOMBIE(��ʬ), ALLPEOPLE(������)), Slot������ڵڼ���˵�(��4��))
native zr_register_item(const Name[], Team, Slot)
/*ʾ��

new itemId

plugin_init()
{
	//ʹ�õĶ�����HUMAN(����), ZOMBIE(��ʬ), ALLPEOPLE(������)
	itemId = zr_register_item("ɵBҩˮ 50Ԫ", HUMAN, 1) //ע�������Ʒ,ֻ��������ʹ�����ڵ�һ���˵���
}

public zr_item_event(iPlayer, item, Slot) //ѡ����ߺ�ͻᴥ�����¼�,iPlayer�Ǵ��������ID,item����ƷID, Slot�ǲ˵���
{
	if(item != itemId) //�����¼�����ṩһ������������ƷID(item),���������жϸ���Ʒ�ǲ���"ɵBҩˮ",���Ǿͷ���
	return

	new money = zr_get_user_money(iPlayer) //�����ж��㹻����Ǯ��,�������50Ԫ,�ͷ���
	if(money < 50)
	return
	
	zr_set_user_money(iPlayer, money-50, 1) //�۳�50Ԫ
	client_print(iPlayer, print_center, "��ϲ���Ϊ��ɵB")
}
*/

//��ȡ��ע����ߵ�����(��Ʒ��ID�Ǵ�1��ʼ,��zr_get_item_amount()Ϊֹ)
native zr_get_item_amount()

//��ȡ�õ��ߵ�����
native zr_get_item_name(item, name[], len)

//��ȡ�õ��ߵĹ������
native zr_get_item_team(item)

//��ȡ�õ������ڵĲ˵���
native zr_get_item_slot(item)

//������ҵ�����ģ�Ͷ���(�Ѿ�ͨ��zombieriot_amxx.dll��д����Ҷ���,��������ʹ��)
native zr_set_user_anim(iPlayer, Float:Time, Anim, GaitAnim = -1)
/*
	iPlayerΪ�������
	Float:TimeΪ���Ŷ�����ʱ��
	AnimΪ�ϰ�������
	GaitAnimΪ�°�������(���Բ���)
*/

//����ĳ�����������һ����(Knocker�ǻ�������, victim�Ǳ���������, Speed�ǻ����ٶ�)
native zr_set_knockback(Knocker, victim, Float:Speed)

//��ȡʣ���ʱ��(�ڵ�����ʱ���ȡ,���ǵ�����ʣ��ʱ��,��������ȡ,�������ʣ���ʱ��, ��λ:��)
native zr_get_lefttime()

//����ʣ���ʱ��
native zr_set_lefttime(leftime)

//��ȡ����Ƿ��ܴ򿪹����˵�
native zr_check_admin(iPlayer)

//��ȡ��ǰ����
native zr_get_light(light[], len)

//���õ�ǰ����
native zr_set_light(const light[])

//��ȡ��ǰ����
native zr_get_weather()

//���õ�ǰ����
native zr_set_weather(weather)

//������(density�ķ�Χ��0-9)
native zr_set_fog(R, G, B, density)

//��ȡ��һ�ֻ�ʤ�Ķ���
native zr_get_wonteam()

//��ĳ��Ҵ���һ��ʬ��
native zr_spawn_body(iPlayer)

//ˢ��һ��
native zr_reset_round()

//����Ƿ�ý���һ��,�������һ��(�����������˻򻻶�����,ȴû�н���һ��,����ʹ�����,ֻ�������,����齩ʬ)
native zr_check_round()

//���ʬ(ֻ�������Ľ�ʬ��Ч,time�Ǹ����ʱ��,�˽ӿڻᴥ��zr_hook_zombiespawn,������zr_hook_zombiespawn�����,��ӿ�Ҳ��ûЧ��)
native zr_spawn_zombie(iPlayer, Float:time)

//���ø���ҵ�����ƶ��ٶ�
native zr_resetmaxspeed(iPlayer)

//��ȡ����Ƿ�����ʱת������(���������������ɽ�ʬ,�Ǿ�����ʱ��ת������,����һ�ֻ�ת��������)
native bool:zr_get_snapchange(iPlayer)

//��������Ƿ�����ʱת������
native zr_set_snapchange(iPlayer, bool:value)

//��ȡcstrike\addons\amxmodx\configs�µ�ĳ���ļ���ĳһ�е�����
native zr_get_linedata(const filename[], line, linedata[], const len)
/*����(��ȡzrmenu.ini�еĵ�5������)
static linedata[1024]
zr_get_linedata("zrmenu.ini", 5, linedata, charsmax(linedata))
client_print(0, print_chat, "zrmenu.ini��5��������:%s", linedata)
*/

//����cstrike\addons\amxmodx\configs�µ�ĳ���ļ���ĳһ�е����� lineΪ0ʱ,�ͻ�д�����һ��
native zr_set_linedata(const filename[], const line, const linedata[])
/*����(�޸�zrmenu.ini�еĵ�8������)
zr_set_linedata("zrmenu.ini", 8, "��ȥ!")
*/

//ע����ʱ��ʬ����,����cstrike\addons\amxmodx\configs\zombie.ini�������½�ʬ��ͬ,���ְ취����ZP,���ӵĽ�ʬID��zombieriot�Զ�����,������plugin_precache()ע��
//(����, ����, ����ģ��, �ֱ�ģ��, ����, �ٶ�, ����, ����ٶ�, �ػ��ٶ�, �����Χ, �ػ���Χ, �����˺�����, ������, �Ƿ�����, ����)
//���ؽ�ʬID
native zr_register_zombie(const name[], const info[], const model[], const vmodel[], Float:health, Float:maxspeed, Float:gravity, Float:attackspeed1, Float:attackspeed2, Float:attackrange1, Float:attackrange2, Float:damage, Float:painfree, hidden, boss)

//ע����ʱ��������
//(����, ����, ����ģ��, ����, �ٶ�, ����, ������, �Ƿ�����)
//��������ID
native zr_register_human(const name[], const info[], const model[], Float:health, Float:maxspeed, Float:gravity, Float:painfree, hidden)

//��ȡ����ģʽ��,��ɵ���������(���ǹ����������ʾ����˰ٷֶ��ٵĵ�)
native zr_get_maxsection()

/*�������¼������ӿ�-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
//Post�¼����ص�ʱ����Ҫ�����κ�ֵ,Pre�¼���Ҫ(ֻ��Pre�¼����Դ��,Post�¼����ܴ��).

//Post�¼�:���ִ����¼�(���Ի�ȡ��������,���¼��ٶȱ�logevent��HLTV�Ŀ����¼���Ҫ��,��ʱ��һ�δ����)
forward zr_roundbegin_event(Weather)

//Post�¼�:������󴥷�(ɶҲû�û�ȡ)
forward zr_riotbegin_event()

//Post�¼�:һ�ֽ��������¼�(���Ի�ȡʤ���Ķ���,��һֱ�ھ���,ZR������û��Ҫ���ֶ���?)
forward zr_roundend_event(WinTeam)

//Post�¼�:���ߴ����¼�(ѡ���˵��ߺ�ͻᴥ��, item�Ǵ����ĵ���ID,Slot�ǲ˵���,��˼���ڵڼ����˵�)
forward zr_item_event(iPlayer, item, Slot)

//Post�¼�:��Ϊ���鴥���¼�(ֻҪ����zr_set_user_ghost(iPlaer, true)�ͻᴥ��,����Դ�����������Ҳ������zr_set_user_ghost(iPlaer, true))
forward zr_being_ghost(iPlayer)

//Post�¼�:�������ɽ�ʬʱ�������¼�(ֻҪ����zr_set_user_ghost(iPlaer, false)�ͻᴥ��,����Դ������Ҳ������zr_set_user_ghost(iPlaer, false))
forward zr_ghost_spawn(iPlayer)

//Post�¼�:��Ϊ��ʬ�����¼�(ֻҪ����zr_set_user_zombie�ͻᴥ��,����Դ������佩ʬҲ������zr_set_user_zombie)
forward zr_being_zombie(iPlayer)

//Post�¼�:��Ϊ���ഥ���¼�(ֻҪ����zr_set_user_human�ͻᴥ��,����Դ�����������Ҳ������zr_set_user_human)
forward zr_being_human(iPlayer)

//Post�¼�:������ʱ��ﵽָ���ٷֱ�ʱ����,Times�ǵڼ��δ���,����ģʽ��ÿ�����ɴ���3��,����ģʽû����.
forward zr_human_finish(Times)

//Post�¼�:��������ٶȺ󴥷�
forward zr_resetmaxspeed_event(iPlayer, Float:MaxSpeed)

//Pre�¼�:��Ϊ���ഥ���¼�(ֻҪ����zr_set_user_human�ͻᴥ��,����Դ�����������Ҳ������zr_set_user_human)
forward zr_being_human_pre(iPlayer)

//Pre�¼�:��Ϊ��ʬ�����¼�(ֻҪ����zr_set_user_zombie�ͻᴥ��,����Դ������佩ʬҲ������zr_set_user_zombie)
forward zr_being_zombie_pre(iPlayer)

//Pre�¼�:һ�ֽ��������¼�(��zr_roundend_event��ͬ,������Դ��,��������ϵĻ�,��zr_roundend_event��ʡЧ��Ŷ)
forward zr_hook_roundend(WinTeam)

//Pre�¼�:ÿ���Զ���������ʱ�Ĵ����¼�(����Ժ�,����ҾͲ����Զ�����������)
forward zr_hook_changeteam(iPlayer)

//Pre�¼�:��ʬ׼�������ʱ�򴥷�(���ǽ�ʬ��������ָ����������ʱ�򴥷�,��zr_hook_zombiespawn��ͬ,��Ϻ�zr_hook_zombiespawnҲ���ᴥ����)
forward zr_hook_zombiesetspawn(iPlayer)

//Pre�¼�:��ʬ���󸴻�ʱ�Ĵ����¼�(����Ժ������ֹ�ý�ʬ����)
forward zr_hook_zombiespawn(iPlayer)

//Pre�¼�:���ö���ƽ��ʱ�Ĵ����¼�(�ڿ���ʱ����,�ٶȱ�zr_roundbegin_event����,������������濪���¼�,����Ժ������ֹ�Զ�ƽ�����.)
forward zr_hook_teambalance()

//Pre�¼�:����Ƿ��пն���ʱ�Ĵ����¼�(���ǳ���"û���㹻�������������Ϸ!",Ȼ�����¿��ֵ��¼�.����Ժ������ֹ����.д��Ⱦģʽ�Ļ�,��ӿڻ��а�����)
forward zr_hook_gamedisconnected()

//Pre�¼�:��Ҹ�������ʱ����(���Զ��������鲻ͬ,�������M���˵���ĸ�������)
forward zr_hook_playerchangeteam(iPlayer)

//Pre�¼�:��ұ�����ʱ����(Knocker�ǲ������˵�����,���������,Ҳ������ʵ��,��������, victim�Ǳ�������,Speed�ǻ����ٶ�,inflictor����ý����,����������ը,����������׵�ʵ��ID, damage_type���˺�����, �˽ӿڲ�����zr_set_knockbackӰ��)
forward zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
/*ʾ��(����2�����˽�ʬ��ֵ)

public zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
{
	if(!zr_is_user_zombie(victim))	//��������˵���Ҳ��ǽ�ʬ,����������
	return ZR_IGNORED
	
	zr_set_knockback(Knocker, victim, Speed*2.0)	//���û���Ϊԭ����2��
	
	return ZR_SUPERCEDE	//���ԭ���Ļ���
}

*/

//Pre�¼�:BOT���������λ�ô����¼�(BOT����ʬ�����,���������λ�ø���)
forward zr_hook_botsetorigin(iPlayer)

//Pre�¼�:Velocity��prethink��postthink���,��ϸ��������(��Ͽɽ��ĳЩ������޷�������ҵ�velocity)
forward zr_hook_velocitycheck(iPlayer)

//Pre�¼�:���󴴽�ʬ��ʱ����(��Ϻ������ֹʬ�����)
forward zr_hook_spawnbody(iPlayer)

//Pre�¼�:�ı���Ļ��ɫ�¼�(�ı���Ļ��ɫʱ����,��Ҫ������ͽ�ʬ��ҹ�ӿ����͹ر�,�����ⵯ���е����)
forward zr_hook_screenfade(iPlayer, R, B, G, density)

//Pre�¼�:ZR��client_print�Ͳ�ɫprint�ᴥ��
forward zr_hook_printword(iPlayer, const Word[])

//Pre�¼�:ZR���hudmessage�ᴥ��
forward zr_hook_hudmessage(iPlayer, const HudMessage[], Channel)

//Pre�¼�:ZR���������û��������Ǵ���,��ҹ���Ǻ�����
forward zr_hook_lightstyle(iPlayer, const light[])

//Pre�¼�:ZR��������ʱ����
forward zr_hook_fog(R, G, B, density)