#if defined _zrconst_included
  #endinput
#endif
#define _zrconst_included

//这个文件会影响ZR主代码和子插件代码的编译,谨慎修改.

//事件返回值
#define ZR_IGNORED 0	//正常返回
#define ZR_SUPERCEDE 1	//打断

//基础数据
#define MODENAME "ZombieRiot"					//模式名称
#define ZOMBIECALLED "感染者"					//僵尸队伍名称
#define HUMANCALLED "生存者"					//人类队伍名称
#define MAXWEATHER 32							//最大天气数量
#define ZOMBIEMAX 64							//最大僵尸类型数量
#define HUMANMAX 64								//最大人类类型数量
#define MAXITEM 128								//最大道具数量
#define ZOMBIE 1								//僵尸队伍标记
#define HUMAN 2									//人类队伍标记

//HUD信息
#define SHOWMARK 1								//HUD提示消息通道
#define SHOWHUD 2								//HUD属性信息通道
#define REDCHAT 1								//红色
#define BLUECHAT 2								//蓝色
#define GREYCHAT 3								//灰色
#define NORMALCHAT 4							//默认色
#define GREENCHAT 5								//绿色

//购买菜单队伍
#define ALLPEOPLE 0		//所有人
#define ZOMBIE 1		//僵尸
#define HUMAN 2			//人类

//天气
#define SUN 1			//晴朗
#define RAIN 2			//多雨
#define THUNDERSTORM 3	//雷雨
#define TEMPEST 4		//暴风雨
#define SNOW 5			//雪
#define FOX 6			//雾
#define BLACKFOX 7		//黑雾

//公用数据密钥(给各个子插件间任意使用)
enum
{
	DATAKEY_1 = 898734,
	DATAKEY_2,
	DATAKEY_3,
	DATAKEY_4,
	DATAKEY_5,
	DATAKEY_6,
	DATAKEY_7,
	DATAKEY_8,
	DATAKEY_9,
	DATAKEY_10,
	DATAKEY_11,
	DATAKEY_12,
	DATAKEY_13,
	DATAKEY_14,
	DATAKEY_15,
	DATAKEY_16,
	DATAKEY_17,
	DATAKEY_18,
	DATAKEY_19,
	DATAKEY_20,
	DATAKEY_21,
	DATAKEY_22,
	DATAKEY_23,
	DATAKEY_24,
	DATAKEY_25,
	DATAKEY_26,
	DATAKEY_27,
	DATAKEY_28,
	DATAKEY_29,
	DATAKEY_30,
	DATAKEY_31,
	DATAKEY_32
}

//zombieriot_amxx.dll通过对实体的pev_iuser2设置标志,来区分幽灵是否能穿透这实体(占用了iuser2,要小心使用)
native SetPenetrationToGhost(iEntity, bool:value)

//zombieriot_amxx.dll提供的接口,你可以直接使用.但也可以使用zombieriot.inc提供的接口来代替.
native ZR_PatchRoundEnd(noend)
native ZR_TerminateRound(Float:delay, winstatus)
native ZR_GetTeamScore(team)
native ZR_SetTeamScore(team, score)
native ZR_UpdateTeamScore(team)
native ZR_SetAnimation(iPlayer, Float:Time, Anim, GaitAnim = -1)