#if defined _zombieriot_included
  #endinput
#endif
#define _zombieriot_included

#include <zrconst>

/*ZR人类类型、僵尸类型和物品类型注册原理
游戏中人类类型和僵尸类型都是通过ini模板文件加载的,cstrike\addons\amxmodx\configs\(zombie.ini)和(human.ini).
载入游戏时,就会自动读取里面的信息,首先会先按从上到下的顺序地把类型加载.在主代码中,所有的人类类型和僵尸类型信息都是通过ini模板的排列顺序来保存的,而不是玩家自己设置的ID.
其中所设置的ID在主代码中没发挥任何作用,只是提供给写子插件的人做标记使用的,也就是在以下的各个对人类和僵尸类型的数据接口,填入的并不是ini模板的排列顺序,而是你所设置的ID.
人类类型和僵尸类型的ID和排列顺序都是独立开来的,所以不必担心人类类型和僵尸类型的ID出现重复的问题了(这也就是下面的排列顺序和ID互相转换的借口会要求填入队伍的原因).
在子插件中,用得上ini模板的排列顺序的地方也就只有两个地方,一是对所有人类类型或者是僵尸类型循环检测的时候,二是触发选择命令 zrzombies_顺序 和 zrhumans_顺序.
循环类型的时候,会用上zr_get_zombie_amount()或zr_get_human_amount()来获取类型的总数量,因为排列顺序是从1开始,一直到模板载入完为止,所以排再最后的类型的顺序数,也就是所载入的类型的总数了,详细看接口注释.
面对这两种情况,我们提供了zr_sequence_to_id和zr_id_to_sequence这两个接口,用于类型ID和排列顺序之间的转换.
在1.12版本以后,僵尸类型和人类类型添加了直接通过接口注册的办法,在此INC下可找到.与模板注册不同的是,这样注册的类型不允许自己设置ID,而是由插件自己分配,并在接口里返回,所以只要做好记录就可以了.

物品的注册相对简单,因为不支持模板注册,所以物品的ID是由插件分配的,而且分配的ID和注册顺序是一样的,从1开始,一直到最后一个注册的物品.


以下是数据接口---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

//判断是否是逃生模式(zr_开头的地图)
native bool:zr_is_escapemode()

//判断是否开启了支援ZBOT(settingmenu.ini里设置)
native bool:zr_zbot_supported()

//输出一个左下角信息,使用方法和client_print类似,支持颜色选择和格式化,但无法在中间显示.
native zr_print_chat(const iPlayer, const Color, const Message[], any:...)
/*
	红:REDCHAT
	绿:GREENCHAT
	蓝:BLUECHAT
	灰:GREYCHAT
	默认:NORMALCHAT
	
	给所有玩家输出一天红色的信息
	
	new JJamount = 0
	zr_print_chat(0, REDCHAT, "你有%d条JJ", JJamount)
*/

//强制结束一局(Team是胜利队伍HUMAN或ZOMBIE,不受zr_hook_roundend(WinTeam)打断的影响)
native zr_set_round_end(Team)

//获取玩家当前僵尸的ID
native zr_get_zombie_id(iPlayer)

//获取该僵尸ID是否是男性
native bool:zr_is_zombie_male(Type)

//获取玩家选择的僵尸的ID
native zr_get_nextzombie_id(iPlayer)

//设置玩家选择的僵尸的ID
native zr_set_nextzombie_id(iPlayer, Type)

//获取该僵尸ID的名字(填僵尸ID)
native zr_get_zombie_name(Type, name[], len)

//获取该僵尸ID的介绍(填僵尸ID)
native zr_get_zombie_info(Type, info[], len)

//获取该僵尸ID的初始生命值(填僵尸ID)
native Float:zr_get_zombie_health(Type)

//获取该僵尸ID的身体模型(填僵尸ID)
native zr_get_zombie_model(Type, model[], len)

//获取该僵尸ID的手臂模型(填僵尸ID)
native zr_get_zombie_claw(Type, model[], len)

//获取玩家当前人类的ID
native zr_get_human_id(iPlayer)

//获取该人类ID是否是男性
native bool:zr_is_human_male(Type)

//获取玩家选择的人类的ID
native zr_get_nexthuman_id(iPlayer)

//设置玩家选择的人类的ID
native zr_set_nexthuman_id(iPlayer, Type)

//获取该人类ID的名字(填人类ID)
native zr_get_human_name(Type, name[], len)

//获取该人类ID的介绍(填人类ID)
native zr_get_human_info(Type, info[], len)

//获取该人类ID的初始生命值(填人类ID)
native Float:zr_get_human_health(Type)

//获取该人类ID的身体模型(填人类ID)
native zr_get_human_model(Type, model[], len)

//获取玩家是否开启了夜视仪(人类才有效)
native bool:zr_get_human_nvg(iPlayer)

//设置玩家的夜视仪(Mode:true是开false是关,只对人类有效)
native zr_set_human_nvg(iPlayer, bool:Mode)

//获取该僵尸ID是否为BOSS(填僵尸ID)
native bool:zr_is_zombie_boss(Type)

//获取该僵尸ID是否为隐藏角色
native bool:zr_is_zombie_hidden(Type)

//获取该人类ID是否为隐藏角色
native bool:zr_is_human_hidden(Type)

//获取玩家是否是僵尸(这个其实是通过offset来获取队伍,所以一定要注意,务必确定将要获取的id是玩家才使用,否则会炸服)
native bool:zr_is_user_zombie(iPlayer)

//获取玩家是否是幽灵
native bool:zr_is_user_ghost(iPlayer)

//将僵尸或人类的ID转换成在模板里的ID排列顺序,人类和僵尸的ID排列顺序是区分开来的,所以要填队伍来判断(第一个填该ID的队伍, 第二个填要转换的ID排列顺序)
native zr_id_to_sequence(Team, sequence)

//将该类型模板里的ID排列顺序转换成类型ID, 人类和僵尸的ID排列顺序是区分开来的,所以要填队伍来判断(第一个填该ID的队伍, 第二个填要转换的ID)
native zr_sequence_to_id(Team, Type)

//获取所注册的僵尸类型总数
native zr_get_zombie_amount()
/*配合zr_sequence_to_id使用可获取某类型ID是否是BOSS
	new amount = zr_get_zombie_amount()
	for(new i = 1; i <= amount; i ++)
	{
	new Type = zr_sequence_to_id(ZOMBIE, i)
	if(zr_is_zombie_boss(Type))
	{
	client_print(0, print_chat, "ID:%d是BOSS", Type)
	}
	}

*/

//获取所注册的人类类型总数
native zr_get_human_amount()

//获取某个队伍的得分(Team是队伍), 在ZR里得分不知道有什么意义,给出接口自己看着办吧.
native zr_get_team_score(Team)

//设置某个队伍的得分(Team是队伍, score是分数), 在ZR里得分不知道有什么意义,给出接口自己看着办吧.
native zr_set_team_score(Team, score)

//获取玩家的金钱,跟原版的金钱不同,原版的金钱值已经被我扣成0了,防止BOT乱买东西.
native zr_get_user_money(iPlayer)

//设置玩家的金钱(最后的flag,如果填1,则会显示出之前的金钱与现在的金钱的差额,0则否)
native zr_set_user_money(iPlayer, money, flag)

//把玩家变成人类(Type填要变的人类ID,如果填0则变成已选择的人类类型)
native zr_set_user_human(iPlayer, Type)

//把玩家变成僵尸(Type填的是要变的僵尸ID,如果填0则变成已选择的僵尸类型,你可以设置成BOSS的ID,这样我就不用写zr_set_user_boss了)
native zr_set_user_zombie(iPlayer, Type)

//设置玩家是否在幽灵状态(true = 是, false = 不是).
native zr_set_user_ghost(iPlayer, value)

//获取玩家的身体模型,是获取模型的无后缀名称
native zr_get_user_model(iPlayer, model[], len)

//设置玩家的身体模型,填模型的无后缀名称,比如zr_set_user_model(iPlayer, "arctic"), 模型的路径是cstrike\models\player\arctic\arctic.mdl
native zr_set_user_model(iPlayer, const model[])

//让玩家选择一个道具(其实就是让玩家触发zr_item_event)
native zr_set_user_item(iPlayer, item)

//注册道具(只是在物品菜单里出现,但没任何功能和属性,需要自己写,花不花钱由你定,第一个空填名称,第二个空填购买队伍(HUMAN(人类), ZOMBIE(僵尸), ALLPEOPLE(所有人)), Slot填出现在第几项菜单(共4项))
native zr_register_item(const Name[], Team, Slot)
/*示例

new itemId

plugin_init()
{
	//使用的队伍有HUMAN(人类), ZOMBIE(僵尸), ALLPEOPLE(所有人)
	itemId = zr_register_item("傻B药水 50元", HUMAN, 1) //注册这个物品,只有人类能使用且在第一个菜单里
}

public zr_item_event(iPlayer, item, Slot) //选择道具后就会触发这事件,iPlayer是触发的玩家ID,item是物品ID, Slot是菜单槽
{
	if(item != itemId) //触发事件后会提供一个被触发的物品ID(item),现在用来判断该物品是不是"傻B药水",不是就返回
	return

	new money = zr_get_user_money(iPlayer) //这是判断你够不够钱买,如果不够50元,就返回
	if(money < 50)
	return
	
	zr_set_user_money(iPlayer, money-50, 1) //扣除50元
	client_print(iPlayer, print_center, "恭喜你成为了傻B")
}
*/

//获取已注册道具的数量(物品的ID是从1开始,到zr_get_item_amount()为止)
native zr_get_item_amount()

//获取该道具的名称
native zr_get_item_name(item, name[], len)

//获取该道具的购买队伍
native zr_get_item_team(item)

//获取该道具所在的菜单项
native zr_get_item_slot(item)

//播放玩家的身体模型动作(已经通过zombieriot_amxx.dll重写了玩家动作,可以完美使用)
native zr_set_user_anim(iPlayer, Float:Time, Anim, GaitAnim = -1)
/*
	iPlayer为玩家索引
	Float:Time为播放动作的时间
	Anim为上半身动作
	GaitAnim为下半身动作(可以不填)
*/

//设置某物体击退另外一物体(Knocker是击退物体, victim是被击退物体, Speed是击退速度)
native zr_set_knockback(Knocker, victim, Float:Speed)

//获取剩余的时间(在倒数的时候获取,就是倒数的剩余时间,倒数完后获取,就离结束剩余的时间, 单位:秒)
native zr_get_lefttime()

//设置剩余的时间
native zr_set_lefttime(leftime)

//获取玩家是否能打开管理菜单
native zr_check_admin(iPlayer)

//获取当前亮度
native zr_get_light(light[], len)

//设置当前亮度
native zr_set_light(const light[])

//获取当前天气
native zr_get_weather()

//设置当前天气
native zr_set_weather(weather)

//设置雾(density的范围是0-9)
native zr_set_fog(R, G, B, density)

//获取上一局获胜的队伍
native zr_get_wonteam()

//给某玩家创建一个尸体
native zr_spawn_body(iPlayer)

//刷新一局
native zr_reset_round()

//检查是否该结束一局,是则结束一局(像人类死光了或换队伍了,却没有结束一局,可以使用这个,只检查人类,不检查僵尸)
native zr_check_round()

//复活僵尸(只对死亡的僵尸有效,time是复活的时间,此接口会触发zr_hook_zombiespawn,如果你把zr_hook_zombiespawn打断了,这接口也会没效果)
native zr_spawn_zombie(iPlayer, Float:time)

//重置该玩家的最大移动速度
native zr_resetmaxspeed(iPlayer)

//获取玩家是否是临时转换队伍(人类死后如果复活成僵尸,那就是临时地转换队伍,到下一局会转换回人类)
native bool:zr_get_snapchange(iPlayer)

//设置玩家是否是临时转换队伍
native zr_set_snapchange(iPlayer, bool:value)

//获取cstrike\addons\amxmodx\configs下的某个文件中某一行的内容
native zr_get_linedata(const filename[], line, linedata[], const len)
/*例子(获取zrmenu.ini中的第5行内容)
static linedata[1024]
zr_get_linedata("zrmenu.ini", 5, linedata, charsmax(linedata))
client_print(0, print_chat, "zrmenu.ini第5行内容是:%s", linedata)
*/

//覆盖cstrike\addons\amxmodx\configs下的某个文件中某一行的内容 line为0时,就会写在最后一行
native zr_set_linedata(const filename[], const line, const linedata[])
/*例子(修改zrmenu.ini中的第8行内容)
zr_set_linedata("zrmenu.ini", 8, "我去!")
*/

//注册临时僵尸类型,与在cstrike\addons\amxmodx\configs\zombie.ini下添加新僵尸不同,这种办法类似ZP,添加的僵尸ID由zombieriot自动分配,必须在plugin_precache()注册
//(名称, 介绍, 人物模型, 手臂模型, 生命, 速度, 重量, 轻击速度, 重击速度, 轻击范围, 重击范围, 攻击伤害倍数, 抗击退, 是否隐藏, 类型)
//返回僵尸ID
native zr_register_zombie(const name[], const info[], const model[], const vmodel[], Float:health, Float:maxspeed, Float:gravity, Float:attackspeed1, Float:attackspeed2, Float:attackrange1, Float:attackrange2, Float:damage, Float:painfree, hidden, boss)

//注册临时人类类型
//(名称, 介绍, 人物模型, 生命, 速度, 重量, 抗击退, 是否隐藏)
//返回人类ID
native zr_register_human(const name[], const info[], const model[], Float:health, Float:maxspeed, Float:gravity, Float:painfree, hidden)

//获取逃生模式下,完成点的最大数量(就是过了那里就显示完成了百分多少的点)
native zr_get_maxsection()

/*以下是事件触发接口-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
//Post事件返回的时候不需要返回任何值,Pre事件则要(只有Pre事件可以打断,Post事件不能打断).

//Post事件:开局触发事件(可以获取当局天气,此事件速度比logevent和HLTV的开局事件都要快,此时玩家还未复活)
forward zr_roundbegin_event(Weather)

//Post事件:倒数完后触发(啥也没得获取)
forward zr_riotbegin_event()

//Post事件:一局结束触发事件(可以获取胜利的队伍,我一直在纠结,ZR到底有没必要区分队伍?)
forward zr_roundend_event(WinTeam)

//Post事件:道具触发事件(选择了道具后就会触发, item是触发的道具ID,Slot是菜单槽,意思是在第几个菜单)
forward zr_item_event(iPlayer, item, Slot)

//Post事件:成为幽灵触发事件(只要用了zr_set_user_ghost(iPlaer, true)就会触发,在主源码里面变幽灵也是用了zr_set_user_ghost(iPlaer, true))
forward zr_being_ghost(iPlayer)

//Post事件:从幽灵变成僵尸时触发的事件(只要用了zr_set_user_ghost(iPlaer, false)就会触发,在主源码里面也是用了zr_set_user_ghost(iPlaer, false))
forward zr_ghost_spawn(iPlayer)

//Post事件:成为僵尸触发事件(只要用了zr_set_user_zombie就会触发,在主源码里面变僵尸也是用了zr_set_user_zombie)
forward zr_being_zombie(iPlayer)

//Post事件:成为人类触发事件(只要用了zr_set_user_human就会触发,在主源码里面变人类也是用了zr_set_user_human)
forward zr_being_human(iPlayer)

//Post事件:人类坚持时间达到指定百分比时触发,Times是第几次触发,生存模式下每局最多可触发3次,逃跑模式没限制.
forward zr_human_finish(Times)

//Post事件:重置玩家速度后触发
forward zr_resetmaxspeed_event(iPlayer, Float:MaxSpeed)

//Pre事件:成为人类触发事件(只要用了zr_set_user_human就会触发,在主源码里面变人类也是用了zr_set_user_human)
forward zr_being_human_pre(iPlayer)

//Pre事件:成为僵尸触发事件(只要用了zr_set_user_zombie就会触发,在主源码里面变僵尸也是用了zr_set_user_zombie)
forward zr_being_zombie_pre(iPlayer)

//Pre事件:一局结束触发事件(与zr_roundend_event不同,这个可以打断,如果不想打断的话,用zr_roundend_event更省效率哦)
forward zr_hook_roundend(WinTeam)

//Pre事件:每局自动更换队伍时的触发事件(打断以后,该玩家就不会自动更换队伍了)
forward zr_hook_changeteam(iPlayer)

//Pre事件:僵尸准备复活的时候触发(就是僵尸死亡后出现复活进度条的时候触发,与zr_hook_zombiespawn不同,打断后zr_hook_zombiespawn也不会触发了)
forward zr_hook_zombiesetspawn(iPlayer)

//Pre事件:僵尸死后复活时的触发事件(打断以后可以阻止该僵尸复活)
forward zr_hook_zombiespawn(iPlayer)

//Pre事件:设置队伍平衡时的触发事件(在开局时触发,速度比zr_roundbegin_event还快,你可以用来代替开局事件,打断以后可以阻止自动平衡队伍.)
forward zr_hook_teambalance()

//Pre事件:检查是否有空队伍时的触发事件(就是出现"没有足够的玩家来进行游戏!",然后重新开局的事件.打断以后可以阻止发生.写感染模式的话,这接口会有帮助的)
forward zr_hook_gamedisconnected()

//Pre事件:玩家更换队伍时触发(与自动更换队伍不同,这个是在M键菜单里的更换队伍)
forward zr_hook_playerchangeteam(iPlayer)

//Pre事件:玩家被击退时触发(Knocker是产生击退的物体,可以是玩家,也可以是实体,比如手雷, victim是被击退者,Speed是击退速度,inflictor攻击媒介物,利用用手雷炸,则这个是手雷的实体ID, damage_type是伤害类型, 此接口不会受zr_set_knockback影响)
forward zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
/*示例(增大2倍击退僵尸的值)

public zr_hook_knockback(Knocker, victim, Float:Speed, inflictor, damage_type)
{
	if(!zr_is_user_zombie(victim))	//如果被击退的玩家不是僵尸,则正常返回
	return ZR_IGNORED
	
	zr_set_knockback(Knocker, victim, Speed*2.0)	//设置击退为原来的2倍
	
	return ZR_SUPERCEDE	//打断原来的击退
}

*/

//Pre事件:BOT复活后设置位置触发事件(BOT当僵尸复活后,会在人类的位置复活)
forward zr_hook_botsetorigin(iPlayer)

//Pre事件:Velocity的prethink和postthink检查,详细见主代码(打断可解决某些情况下无法设置玩家的velocity)
forward zr_hook_velocitycheck(iPlayer)

//Pre事件:死后创建尸体时触发(打断后可以阻止尸体产生)
forward zr_hook_spawnbody(iPlayer)

//Pre事件:改变屏幕颜色事件(改变屏幕颜色时触发,主要是人类和僵尸的夜视开启和关闭,被闪光弹闪中等情况)
forward zr_hook_screenfade(iPlayer, R, B, G, density)

//Pre事件:ZR的client_print和彩色print会触发
forward zr_hook_printword(iPlayer, const Word[])

//Pre事件:ZR里的hudmessage会触发
forward zr_hook_hudmessage(iPlayer, const HudMessage[], Channel)

//Pre事件:ZR里对玩家设置环境亮度是触发,像夜视仪和闪电
forward zr_hook_lightstyle(iPlayer, const light[])

//Pre事件:ZR里设置雾时触发
forward zr_hook_fog(R, G, B, density)