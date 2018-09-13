/***
*
*	Copyright (c) 1996-2002, Valve LLC. All rights reserved.
*
*	This product contains software technology licensed from Id
*	Software, Inc. ("Id Technology").  Id Technology (c) 1996 Id Software, Inc.
*	All Rights Reserved.
*
*   Use, distribution, and modification of this source code and/or resulting
*   object code is restricted to non-commercial enhancements to products from
*   Valve LLC.  All other use, distribution, or modification is prohibited
*   without written permission from Valve LLC.
*
****/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>

extern "C"
{
#include "mathlib.h"
}

#include "const.h"
#include "progdefs.h"
#include "edict.h"
#include "eiface.h"
#include "studio.h"

#ifndef ACTIVITY_H
#include "activity.h"
#endif

#include "activitymap.h"

#ifndef ANIMATION_H
#include "animation.h"
#endif

#ifndef SCRIPTEVENT_H
#include "scriptevent.h"
#endif

#ifndef ENGINECALLBACK_H
#include "enginecallback.h"
#endif

int LookupActivity(void *pmodel, entvars_t *pev, int activity)
{
	studiohdr_t *pstudiohdr = (studiohdr_t *)pmodel;

	if (!pstudiohdr)
		return 0;

	mstudioseqdesc_t *pseqdesc = (mstudioseqdesc_t *)((byte *)pstudiohdr + pstudiohdr->seqindex);
	int weighttotal = 0;
	int seq = ACTIVITY_NOT_AVAILABLE;

	for (int i = 0; i < pstudiohdr->numseq; i++)
	{
		if (pseqdesc[i].activity == activity)
		{
			weighttotal += pseqdesc[i].actweight;

			if (!weighttotal || RANDOM_LONG(0, weighttotal - 1) < pseqdesc[i].actweight)
				seq = i;
		}
	}

	return seq;
}

int LookupSequence(void *pmodel, const char *label)
{
	studiohdr_t *pstudiohdr = (studiohdr_t *)pmodel;

	if (!pstudiohdr)
		return 0;

	mstudioseqdesc_t *pseqdesc = (mstudioseqdesc_t *)((byte *)pstudiohdr + pstudiohdr->seqindex);

	for (int i = 0; i < pstudiohdr->numseq; i++)
	{
		if (!stricmp(pseqdesc[i].label, label))
			return i;
	}

	return -1;
}

void GetSequenceInfo(void *pmodel, entvars_t *pev, float *pflFrameRate, float *pflGroundSpeed)
{
	studiohdr_t *pstudiohdr = (studiohdr_t *)pmodel;

	if (!pstudiohdr)
		return;

	if (pev->sequence >= pstudiohdr->numseq)
	{
		*pflFrameRate = 0;
		*pflGroundSpeed = 0;
		return;
	}

	mstudioseqdesc_t *pseqdesc = (mstudioseqdesc_t *)((byte *)pstudiohdr + pstudiohdr->seqindex) + (int)pev->sequence;

	if (pseqdesc->numframes > 1)
	{
		*pflFrameRate = 256 * pseqdesc->fps / (pseqdesc->numframes - 1);
		*pflGroundSpeed = sqrt(pseqdesc->linearmovement[0] * pseqdesc->linearmovement[0] + pseqdesc->linearmovement[1] * pseqdesc->linearmovement[1] + pseqdesc->linearmovement[2] * pseqdesc->linearmovement[2]);
		*pflGroundSpeed = *pflGroundSpeed * pseqdesc->fps / (pseqdesc->numframes - 1);
	}
	else
	{
		*pflFrameRate = 256;
		*pflGroundSpeed = 0;
	}
}

int GetSequenceFlags(void *pmodel, entvars_t *pev)
{
	studiohdr_t *pstudiohdr = (studiohdr_t *)pmodel;

	if (!pstudiohdr || pev->sequence >= pstudiohdr->numseq)
		return 0;

	mstudioseqdesc_t *pseqdesc = (mstudioseqdesc_t *)((byte *)pstudiohdr + pstudiohdr->seqindex) + (int)pev->sequence;
	return pseqdesc->flags;
}
