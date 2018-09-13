#include "amxxmodule.h"
#include "hook.h"
#include "gamerules.h"
#include "metahook.h"
#include "cbase.h"
#include "weapons.h"
#include "player.h"
#include "activity.h"
#include "pm_defs.h"
#include "entity_state.h"


#define SEMICLIPKEY 13854
#define ZRWALLCLIPKEY 242241
#define SIGNATURE "\x83\xEC\x4C\x53\x55\x8B\x2A\x56\x57\x8B\x4D\x04\x8B\x2A\x2A\x2A\x2A\x2A\x85\xC0"

typedef enum
{
	HITGROUP_GENERIC,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG,
	HITGROUP_SHIELD,
	NUM_HITGROUPS
};

char const EntityClassname[7][33] = { "func_door", "func_door_rotating", "momentary_door", "momentary_rot_button", "func_breakable", "hostage_entity", "func_pushable" };
int wanted[128];
int wantedcount;
int Sequence[33];
int GaitSequence[33];	
float PlayTime[33];
float RecordTiime[33];

typedef void (__fastcall *Func_SetAnimation)(void *pPlayer, int, int playerAnim);
Func_SetAnimation SetAnimationOri = NULL;
void __fastcall SetAnimationHook(void *pPlayer, int, int playerAnim);

HMODULE g_hProgs;

static cell AMX_NATIVE_CALL ZR_PatchRoundEnd(AMX *amx, cell *params)
{
	PatchRoundEnd(params[1]);
	return 1;
}

static cell AMX_NATIVE_CALL ZR_TerminateRound(AMX *amx, cell *params)
{
	TerminateRound(amx_ctof(params[1]), params[2]);
	return 1;
}

static cell AMX_NATIVE_CALL ZR_GetTeamScore(AMX *amx, cell *params)
{
	return GetTeamScore(params[1]);
}

static cell AMX_NATIVE_CALL ZR_SetTeamScore(AMX *amx, cell *params)
{
	SetTeamScore(params[1], params[2]);
	return 1;
}

static cell AMX_NATIVE_CALL ZR_UpdateTeamScore(AMX *amx, cell *params)
{
	UpdateTeamScore(params[1]);
	return 1;
}

static cell AMX_NATIVE_CALL ZR_SetAnimation(AMX *amx, cell *params)
{	
	PlayTime[params[1]] = amx_ctof(params[2]);
	Sequence[params[1]] = params[3];
	GaitSequence[params[1]] = params[4];

	if(params[4] < 0)
	{
	SetAnimationHook(INDEXENT(params[1])->pvPrivateData, 0, PLAYER_CUSTOM);
	return 1;
	}

	CBasePlayer *iPlayer = (CBasePlayer *)(INDEXENT(params[1])->pvPrivateData);

	RecordTiime[params[1]] = gpGlobals->time;
	iPlayer->pev->sequence = Sequence[params[1]];
	iPlayer->pev->gaitsequence = GaitSequence[params[1]];
	iPlayer->pev->frame = 0;
	iPlayer->ResetSequenceInfo();

	return 1;
}

static cell AMX_NATIVE_CALL SetPenetrationToGhost(AMX *amx, cell *params)
{
	if(params[2])
	{
	edict_t *iEntity = INDEXENT(params[1]);
	iEntity->v.iuser2 = SEMICLIPKEY;
	return 1;
	}

	return 1;
}

int FN_DispatchSpawn_Post(edict_t *pent)
{
	if(!pent)
	RETURN_META_VALUE(MRES_IGNORED, 0);
	
	char szClassName[33];
	strcpy(szClassName, STRING(pent->v.classname));

	if(!strcmp(szClassName, "func_wall"))
	{
		char szTargetName[33];
		strcpy(szTargetName, STRING(pent->v.targetname));
		if(!strcmp(szTargetName, "zr_wall"))
		{
			pent->v.iuser2 = ZRWALLCLIPKEY;
			RETURN_META_VALUE(MRES_IGNORED, 0);
		}
	}

	for(int i = 0; i < 7; i ++)
	{
		if(strcmp(szClassName, EntityClassname[i]))
		continue;
		
		if(i == 4 && !pent->v.takedamage)
		break;

		pent->v.iuser2 = SEMICLIPKEY;

		break;
	}
	
	RETURN_META_VALUE(MRES_IGNORED, 0);
}

void FN_PM_Move(struct playermove_s *ppmove, qboolean server)
{
	if(ppmove->spectator)
	RETURN_META(MRES_IGNORED);

	wantedcount = 0;
	
	for(int i = 0; i < ppmove->numphysent; i++)
	{
		if(!ppmove->physents[i].info)
		{
			wanted[wantedcount++] = i;
			continue;
		}
		
		if(ppmove->fuser4 == 20520.0 && ppmove->physents[i].iuser2 == ZRWALLCLIPKEY)
		continue;
		
		if(ppmove->deadflag == DEAD_RESPAWNABLE && (ppmove->physents[i].player || ppmove->physents[i].iuser2 == SEMICLIPKEY))
		continue;

		wanted[wantedcount++] = i;
		
	}
	for(int i = 0; i < wantedcount; i++) if(i != wanted[i]) ppmove->physents[i] = ppmove->physents[wanted[i]];
	ppmove->numphysent = wantedcount;

	RETURN_META(MRES_IGNORED);
}

int FN_AddToFullPack_Post(struct entity_state_s *state, int e, edict_t *ent, edict_t *host, int hostflags, int player, unsigned char *pSet)
{
	if(!g_fn_IsPlayerIngame(ENTINDEX(host)))
	RETURN_META_VALUE(MRES_IGNORED, 0);
	
	CBasePlayer *iPlayer = (CBasePlayer *)host->pvPrivateData;
	if(iPlayer->m_iTeam == 1 && ent->v.iuser2 == ZRWALLCLIPKEY)
	{
		state->solid = SOLID_NOT;
		RETURN_META_VALUE(MRES_IGNORED, 0);
	}

	if(!g_fn_IsPlayerIngame(ENTINDEX(ent)) && ent->v.iuser2 != SEMICLIPKEY)
	RETURN_META_VALUE(MRES_IGNORED, 0);

	if(host->v.deadflag != DEAD_RESPAWNABLE)
	RETURN_META_VALUE(MRES_IGNORED, 0);

	state->solid = SOLID_NOT;
	
	for(int i = 0; i < 7; i ++)
	{
		char szClassName[33];
		if(strcmp(szClassName, EntityClassname[i]))
		continue;
		
		state->rendermode = kRenderTransTexture;
		state->renderamt = 130;
		break;
	}
	
	RETURN_META_VALUE(MRES_IGNORED, 0);
}


void __fastcall SetAnimationHook(void *pPlayer, int, int playerAnim)
{
	CBasePlayer *iPlayer = (CBasePlayer *)pPlayer;
	
	if(GaitSequence[ENTINDEX(ENT(iPlayer->pev))] >= 0 && iPlayer->pev->deadflag == DEAD_NO)
	{
		if(gpGlobals->time > RecordTiime[ENTINDEX(ENT(iPlayer->pev))]+PlayTime[ENTINDEX(ENT(iPlayer->pev))]) GaitSequence[ENTINDEX(ENT(iPlayer->pev))] = -1;
		iPlayer->pev->sequence = Sequence[ENTINDEX(ENT(iPlayer->pev))];
		iPlayer->pev->gaitsequence = GaitSequence[ENTINDEX(ENT(iPlayer->pev))];
		return;
	}

	int animDesired;
	float speed;
	char szAnim[64];
	int hopSeq, leapSeq;

	if (!iPlayer->pev->modelindex)
		return;
	
	if ((playerAnim == PLAYER_FLINCH || playerAnim == PLAYER_LARGE_FLINCH) && iPlayer->m_bOwnsShield == true)
		return;
	
	if (!(playerAnim == PLAYER_FLINCH || playerAnim == PLAYER_LARGE_FLINCH || gpGlobals->time > iPlayer->m_flFlinchTime || iPlayer->pev->health <= 0))
		return;

	speed = iPlayer->pev->velocity.Length2D();

	if (FBitSet(iPlayer->pev->flags, FL_FROZEN))
	{
		speed = 0;
		playerAnim = PLAYER_IDLE;
	}

	hopSeq = iPlayer->LookupActivity(ACT_HOP);
	leapSeq = iPlayer->LookupActivity(ACT_LEAP);

	switch (playerAnim)
	{
		case PLAYER_CUSTOM:
		{	
			if (iPlayer->m_Activity == ACT_SWIM || iPlayer->m_Activity == ACT_DIESIMPLE || iPlayer->m_Activity == ACT_HOVER)
				iPlayer->m_IdealActivity = iPlayer->m_Activity;
			else
				iPlayer->m_IdealActivity = ACT_CUSTOM;

			break;
		}

		case PLAYER_JUMP:
		{
			if (iPlayer->m_Activity == ACT_SWIM || iPlayer->m_Activity == ACT_DIESIMPLE || iPlayer->m_Activity == ACT_HOVER)
				iPlayer->m_IdealActivity = iPlayer->m_Activity;
			else
				iPlayer->m_IdealActivity = ACT_HOP;

			break;
		}

		case PLAYER_SUPERJUMP:
		{
			if (iPlayer->m_Activity == ACT_SWIM || iPlayer->m_Activity == ACT_DIESIMPLE || iPlayer->m_Activity == ACT_HOVER)
				iPlayer->m_IdealActivity = iPlayer->m_Activity;
			else
				iPlayer->m_IdealActivity = ACT_LEAP;

			break;
		}

		case PLAYER_DIE:
		{
			iPlayer->m_IdealActivity = ACT_DIESIMPLE;
			iPlayer->DeathSound();
			break;
		}

		case PLAYER_ATTACK1:
		{
			if (iPlayer->m_Activity == ACT_SWIM || iPlayer->m_Activity == ACT_DIESIMPLE || iPlayer->m_Activity == ACT_HOVER)
				iPlayer->m_IdealActivity = iPlayer->m_Activity;
			else
				iPlayer->m_IdealActivity = ACT_RANGE_ATTACK1;

			break;
		}

		case PLAYER_ATTACK2:
		{
			if (iPlayer->m_Activity == ACT_SWIM || iPlayer->m_Activity == ACT_DIESIMPLE || iPlayer->m_Activity == ACT_HOVER)
				iPlayer->m_IdealActivity = iPlayer->m_Activity;
			else
				iPlayer->m_IdealActivity = ACT_RANGE_ATTACK2;

			break;
		}

		case PLAYER_RELOAD:
		{
			if (iPlayer->m_Activity == ACT_SWIM || iPlayer->m_Activity == ACT_DIESIMPLE || iPlayer->m_Activity == ACT_HOVER)
				iPlayer->m_IdealActivity = iPlayer->m_Activity;
			else
				iPlayer->m_IdealActivity = ACT_RELOAD;

			break;
		}

		case PLAYER_IDLE:
		case PLAYER_WALK:
		{
			if (FBitSet(iPlayer->pev->flags, FL_ONGROUND) || (iPlayer->m_Activity != ACT_HOP && iPlayer->m_Activity != ACT_LEAP))
			{
				if (iPlayer->pev->waterlevel <= 1)
					iPlayer->m_IdealActivity = ACT_WALK;
				else if (!speed)
					iPlayer->m_IdealActivity = ACT_HOVER;
				else
					iPlayer->m_IdealActivity = ACT_SWIM;
			}
			else
				iPlayer->m_IdealActivity = iPlayer->m_Activity;

			break;
		}

		case PLAYER_HOLDBOMB: iPlayer->m_IdealActivity = ACT_HOLDBOMB; break;
		case PLAYER_FLINCH: iPlayer->m_IdealActivity = ACT_FLINCH; break;
		case PLAYER_LARGE_FLINCH: iPlayer->m_IdealActivity = ACT_LARGE_FLINCH; break;
	}

	switch (iPlayer->m_IdealActivity)
	{
		case ACT_CUSTOM:
		{
			RecordTiime[ENTINDEX(ENT(iPlayer->pev))] = gpGlobals->time;

			animDesired = Sequence[ENTINDEX(ENT(iPlayer->pev))];
			
			if (animDesired == -1)
				animDesired = 0;
			
			iPlayer->pev->sequence = animDesired;
			iPlayer->pev->frame = 0;
			iPlayer->ResetSequenceInfo();
			iPlayer->m_Activity = iPlayer->m_IdealActivity;
			
			break;
		}

		case ACT_HOP:
		case ACT_LEAP:
		{
			if (iPlayer->m_Activity == iPlayer->m_IdealActivity)
				return;
			
			if (iPlayer->m_Activity == ACT_CUSTOM) animDesired = Sequence[ENTINDEX(ENT(iPlayer->pev))];
			else
			{
			if (iPlayer->m_Activity == ACT_RANGE_ATTACK1)
				strcpy(szAnim, "ref_shoot_");
			else if (iPlayer->m_Activity == ACT_RANGE_ATTACK2)
				strcpy(szAnim, "ref_shoot2_");
			else if (iPlayer->m_Activity == ACT_RELOAD)
				strcpy(szAnim, "ref_reload_");
			else
				strcpy(szAnim, "ref_aim_");

			strcat(szAnim, iPlayer->m_szAnimExtention);
			animDesired = iPlayer->LookupSequence(szAnim);
			}

			if (animDesired == -1)
				animDesired = 0;

			if (iPlayer->pev->sequence != animDesired || !iPlayer->m_fSequenceLoops)
				iPlayer->pev->frame = 0;

			if (!iPlayer->m_fSequenceLoops)
				iPlayer->pev->effects |= EF_NOINTERP;

			if (iPlayer->m_IdealActivity == ACT_LEAP)
			{
				iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_LEAP);
				iPlayer->m_Activity = iPlayer->m_IdealActivity;
			}
			else
			{
				iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_HOP);
				iPlayer->m_Activity = iPlayer->m_IdealActivity;
			}

			break;
		}

		case ACT_RANGE_ATTACK1:
		{
			iPlayer->m_flLastFired = gpGlobals->time;

			if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
				strcpy(szAnim, "crouch_shoot_");
			else
				strcpy(szAnim, "ref_shoot_");

			strcat(szAnim, iPlayer->m_szAnimExtention);

			animDesired = iPlayer->LookupSequence(szAnim);
			
			if (animDesired == -1)
				animDesired = 0;

			iPlayer->pev->sequence = animDesired;
			iPlayer->pev->frame = 0;
			iPlayer->ResetSequenceInfo();
			iPlayer->m_Activity = iPlayer->m_IdealActivity;
			
			break;
		}

		case ACT_RANGE_ATTACK2:
		{
			iPlayer->m_flLastFired = gpGlobals->time;

			if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
				strcpy(szAnim, "crouch_shoot2_");
			else
				strcpy(szAnim, "ref_shoot2_");

			strcat(szAnim, iPlayer->m_szAnimExtention);
			animDesired = iPlayer->LookupSequence(szAnim);

			if (animDesired == -1)
				animDesired = 0;

			iPlayer->pev->sequence = animDesired;
			iPlayer->pev->frame = 0;
			iPlayer->ResetSequenceInfo();
			iPlayer->m_Activity = iPlayer->m_IdealActivity;
			break;
		}

		case ACT_RELOAD:
		{
			if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
				strcpy(szAnim, "crouch_reload_");
			else
				strcpy(szAnim, "ref_reload_");
			
			strcat(szAnim, iPlayer->m_szAnimExtention);
			animDesired = iPlayer->LookupSequence(szAnim);

			if (animDesired == -1)
				animDesired = 0;

			if (iPlayer->pev->sequence != animDesired || !iPlayer->m_fSequenceLoops)
				iPlayer->pev->frame = 0;

			if (!iPlayer->m_fSequenceLoops)
				iPlayer->pev->effects |= EF_NOINTERP;

			iPlayer->m_Activity = iPlayer->m_IdealActivity;
			break;
		}

		case ACT_HOLDBOMB:
		{
			if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
				strcpy(szAnim, "crouch_aim_");
			else
				strcpy(szAnim, "ref_aim_");

			strcat(szAnim, iPlayer->m_szAnimExtention);
			animDesired = iPlayer->LookupSequence(szAnim);

			if (animDesired == -1)
				animDesired = 0;

			iPlayer->m_Activity = iPlayer->m_IdealActivity;
			break;
		}

		case ACT_WALK:
		{
			if ((iPlayer->m_Activity != ACT_CUSTOM || iPlayer->m_fSequenceFinished) && (iPlayer->m_Activity != ACT_RANGE_ATTACK1 || iPlayer->m_fSequenceFinished) && (iPlayer->m_Activity != ACT_RANGE_ATTACK2 || iPlayer->m_fSequenceFinished) && (iPlayer->m_Activity != ACT_FLINCH || iPlayer->m_fSequenceFinished) && (iPlayer->m_Activity != ACT_LARGE_FLINCH || iPlayer->m_fSequenceFinished) && (iPlayer->m_Activity != ACT_RELOAD || iPlayer->m_fSequenceFinished))
			{
				if (speed <= 135 || gpGlobals->time <= iPlayer->m_flLastFired + 2 || gpGlobals->time <= RecordTiime[ENTINDEX(ENT(iPlayer->pev))]+PlayTime[ENTINDEX(ENT(iPlayer->pev))])
				{
					if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
						strcpy(szAnim, "crouch_aim_");
					else
						strcpy(szAnim, "ref_aim_");

					strcat(szAnim, iPlayer->m_szAnimExtention);
					animDesired = iPlayer->LookupSequence(szAnim);

					if (animDesired == -1)
						animDesired = 0;

					iPlayer->m_Activity = ACT_WALK;
				}
				else
				{
					strcpy(szAnim, "run_");
					strcat(szAnim, iPlayer->m_szAnimExtention);
					
					animDesired = iPlayer->LookupSequence(szAnim);
					
					if (animDesired == -1)
					{
					if(iPlayer->m_iTeam == 2)
					{
						if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
							strcpy(szAnim, "crouch_aim_");
						else
							strcpy(szAnim, "ref_aim_");

						strcat(szAnim, iPlayer->m_szAnimExtention);
						animDesired = iPlayer->LookupSequence(szAnim);
					}
					else animDesired = iPlayer->LookupSequence("run");

						if (animDesired == -1)
							animDesired = 0;

						iPlayer->m_Activity = ACT_RUN;
						iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_RUN);
					}
					else
					{
						iPlayer->m_Activity = ACT_RUN;
						iPlayer->pev->gaitsequence = animDesired;
					}
				}
			}
			else
				animDesired = iPlayer->pev->sequence;

			if (speed <= 135)
				iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_WALK);
			else
				iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_RUN);

			break;
		}

		case ACT_FLINCH:
		case ACT_LARGE_FLINCH:
		{
			iPlayer->m_Activity = iPlayer->m_IdealActivity;

			switch (iPlayer->m_LastHitGroup)
			{
				case HITGROUP_GENERIC:
				{
					if (RANDOM_LONG(0, 1))
						animDesired = iPlayer->LookupSequence("gut_flinch");
					else
						animDesired = iPlayer->LookupSequence("head_flinch");

					break;
				}

				case HITGROUP_HEAD:
				case HITGROUP_CHEST:
				{
					animDesired = iPlayer->LookupSequence("head_flinch");
					break;
				}

				default: animDesired = iPlayer->LookupSequence("gut_flinch");
			}

			if (animDesired == -1)
				animDesired = 0;

			break;
		}

		case ACT_DIESIMPLE:
		{
			if (iPlayer->m_Activity != iPlayer->m_IdealActivity)
			{
				iPlayer->m_Activity = iPlayer->m_IdealActivity;
				iPlayer->m_flDeathThrowTime = 0;
				iPlayer->m_iThrowDirection = THROW_NONE;

				switch (iPlayer->m_LastHitGroup)
				{
					case HITGROUP_GENERIC:
					{
						switch (RANDOM_LONG(0, 8))
						{
							case 0: animDesired = iPlayer->LookupActivity(ACT_DIE_HEADSHOT); iPlayer->m_iThrowDirection = THROW_BACKWARD; break;
							case 1: animDesired = iPlayer->LookupActivity(ACT_DIE_GUTSHOT); break;
							case 2: animDesired = iPlayer->LookupActivity(ACT_DIE_BACKSHOT); iPlayer->m_iThrowDirection = THROW_HITVEL; break;
							case 3: animDesired = iPlayer->LookupActivity(ACT_DIESIMPLE); break;
							case 4: animDesired = iPlayer->LookupActivity(ACT_DIEBACKWARD); iPlayer->m_iThrowDirection = THROW_HITVEL; break;
							case 5: animDesired = iPlayer->LookupActivity(ACT_DIEFORWARD); iPlayer->m_iThrowDirection = THROW_FORWARD; break;
							case 6: animDesired = iPlayer->LookupActivity(ACT_DIE_CHESTSHOT); break;
							case 7: animDesired = iPlayer->LookupActivity(ACT_DIE_GUTSHOT); break;
							case 8: animDesired = iPlayer->LookupActivity(ACT_DIE_HEADSHOT); break;
							default: animDesired = iPlayer->LookupActivity(ACT_DIESIMPLE); break;
						}

						break;
					}

					case HITGROUP_HEAD:
					{
						int random = RANDOM_LONG(0, 8);
						iPlayer->m_bHeadshotKilled = true;

						if (iPlayer->m_bHighDamage == true)
							random++;

						switch (random)
						{
							case 0: iPlayer->m_iThrowDirection = THROW_NONE; break;
							case 1: iPlayer->m_iThrowDirection = THROW_BACKWARD; break;
							case 2: iPlayer->m_iThrowDirection = THROW_BACKWARD; break;
							case 3: iPlayer->m_iThrowDirection = THROW_FORWARD; break;
							case 4: iPlayer->m_iThrowDirection = THROW_FORWARD; break;
							case 5: iPlayer->m_iThrowDirection = THROW_HITVEL; break;
							case 6: iPlayer->m_iThrowDirection = THROW_HITVEL; break;
							case 7: iPlayer->m_iThrowDirection = THROW_NONE; break;
							case 8: iPlayer->m_iThrowDirection = THROW_NONE; break;
							default: iPlayer->m_iThrowDirection = THROW_NONE; break;
						}

						animDesired = iPlayer->LookupActivity(ACT_DIE_HEADSHOT);
						break;
					}

					case HITGROUP_CHEST: animDesired = iPlayer->LookupActivity(ACT_DIE_CHESTSHOT); break;
					case HITGROUP_STOMACH: animDesired = iPlayer->LookupActivity(ACT_DIE_GUTSHOT); break;
					case HITGROUP_LEFTARM: animDesired = iPlayer->LookupSequence("left"); break;
					case HITGROUP_RIGHTARM:
					{
						iPlayer->m_iThrowDirection = RANDOM_LONG(0, 1) ? THROW_HITVEL : THROW_HITVEL_MINUS_AIRVEL;
						animDesired = iPlayer->LookupSequence("right");
						break;
					}

					case HITGROUP_LEFTLEG:
					case HITGROUP_RIGHTLEG: animDesired = iPlayer->LookupActivity(ACT_DIESIMPLE); break;
				}

				if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
				{
					animDesired = iPlayer->LookupSequence("crouch_die");
					iPlayer->m_iThrowDirection = THROW_BACKWARD;
				}
				else
				{
					if (iPlayer->m_bKilledByBomb == true || iPlayer->m_bKilledByGrenade == true)
					{
						MAKE_VECTORS(iPlayer->pev->angles);

						if (DotProduct(gpGlobals->v_forward, iPlayer->m_vBlastVector) > 0)
							animDesired = iPlayer->LookupSequence("left");
						else if (RANDOM_LONG(0, 1))
							animDesired = iPlayer->LookupSequence("crouch_die");
						else
							animDesired = iPlayer->LookupActivity(ACT_DIE_HEADSHOT);

						if (iPlayer->m_bKilledByBomb == true)
							iPlayer->m_iThrowDirection = THROW_BOMB;
						else if (iPlayer->m_bKilledByGrenade == true)
							iPlayer->m_iThrowDirection = THROW_GRENADE;
					}
				}

				if (animDesired == -1)
					animDesired = 0;

				if (iPlayer->pev->sequence != animDesired)
				{
					iPlayer->pev->gaitsequence = 0;
					iPlayer->pev->sequence = animDesired;
					iPlayer->pev->frame = 0;
					iPlayer->ResetSequenceInfo();
				}
			}

			return;
		}

		default:
		{
			if (iPlayer->m_Activity == iPlayer->m_IdealActivity)
				return;

			iPlayer->m_Activity = iPlayer->m_IdealActivity;
			animDesired = iPlayer->LookupActivity(iPlayer->m_IdealActivity);

			if (iPlayer->pev->gaitsequence != animDesired)
			{
				iPlayer->pev->gaitsequence = 0;
				iPlayer->pev->sequence = animDesired;
				iPlayer->pev->frame = 0;
				iPlayer->ResetSequenceInfo();
			}

			return;
		}
	}

	if (iPlayer->pev->gaitsequence != hopSeq && iPlayer->pev->gaitsequence != leapSeq)
	{
		if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
		{
			if (speed)
				iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_CROUCH);
			else
				iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_CROUCHIDLE);
		}
		else if (speed > 135)
		{
			if (gpGlobals->time > iPlayer->m_flLastFired + 2 && gpGlobals->time > RecordTiime[ENTINDEX(ENT(iPlayer->pev))]+PlayTime[ENTINDEX(ENT(iPlayer->pev))])
			{
				if (iPlayer->m_Activity != ACT_FLINCH && iPlayer->m_Activity != ACT_LARGE_FLINCH)
				{
					strcpy(szAnim, "run_");
					strcat(szAnim, iPlayer->m_szAnimExtention);
					animDesired = iPlayer->LookupSequence(szAnim);

					if (animDesired == -1)
					{
					if(iPlayer->m_iTeam == 2)
					{
						if (FBitSet(iPlayer->pev->flags, FL_DUCKING))
							strcpy(szAnim, "crouch_aim_");
						else
							strcpy(szAnim, "ref_aim_");

						strcat(szAnim, iPlayer->m_szAnimExtention);
						animDesired = iPlayer->LookupSequence(szAnim);
					}
					else animDesired = iPlayer->LookupSequence("run");
					}
					else
						iPlayer->pev->gaitsequence = animDesired;

					iPlayer->m_Activity = ACT_RUN;
				}
			}

			iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_RUN);
		}
		else if (speed > 0)
			iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_WALK);
		else
			iPlayer->pev->gaitsequence = iPlayer->LookupActivity(ACT_IDLE);
	}

	if (iPlayer->pev->sequence == animDesired)
		return;

	iPlayer->pev->sequence = animDesired;
	iPlayer->pev->frame = 0;
	iPlayer->ResetSequenceInfo();
}

void CBasePlayer::DeathSound(void)
{
	switch (RANDOM_LONG(1, 4))
	{
		case 1: EMIT_SOUND_DYN2(ENT(pev), CHAN_VOICE, "player/die1.wav", VOL_NORM, ATTN_NORM, 0, 0); break;
		case 2: EMIT_SOUND_DYN2(ENT(pev), CHAN_VOICE, "player/die2.wav", VOL_NORM, ATTN_NORM, 0, 0); break;
		case 3: EMIT_SOUND_DYN2(ENT(pev), CHAN_VOICE, "player/die3.wav", VOL_NORM, ATTN_NORM, 0, 0); break;
		case 4: EMIT_SOUND_DYN2(ENT(pev), CHAN_VOICE, "player/death6.wav", VOL_NORM, ATTN_NORM, 0, 0); break;
	}
}

AMX_NATIVE_INFO zombieriot_Exports[] =
{
	{ "ZR_PatchRoundEnd", ZR_PatchRoundEnd },
	{ "ZR_TerminateRound", ZR_TerminateRound },
	{ "ZR_GetTeamScore", ZR_GetTeamScore },
	{ "ZR_SetTeamScore", ZR_SetTeamScore },
	{ "ZR_UpdateTeamScore", ZR_UpdateTeamScore },
	{ "ZR_SetAnimation", ZR_SetAnimation },
	{ "SetPenetrationToGhost", SetPenetrationToGhost },
	{ NULL, NULL }
};

void OnAmxxAttach(void)
{
	for(int i = 0; i < 33; i ++) GaitSequence[i] = -1;
	g_pfnInstallGameRules = NULL;
	g_hProgs = GetModuleHandle("mp");

	int size;
	gmsgTeamScore = GET_USER_MSG_ID(PLID, "TeamScore", &size);
	MF_AddNatives(zombieriot_Exports);
	
	//SetAnimationOri = (void (__fastcall *)(void *, int, int))((DWORD)g_hProgs + 0xA8290);
	SetAnimationOri = (Func_SetAnimation)MH_SearchPattern((void*)MH_GetModuleBase(g_hProgs), MH_GetModuleSize(g_hProgs), SIGNATURE, sizeof(SIGNATURE) - 1);
	MH_InlineHook(SetAnimationOri, SetAnimationHook, (void *&)SetAnimationOri);
}

void OnPluginsLoaded()
{
	
}