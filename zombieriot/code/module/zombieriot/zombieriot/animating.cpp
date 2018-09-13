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

#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "animation.h"

int CBaseAnimating::LookupActivity(int activity)
{
	void *pmodel = GET_MODEL_PTR(ENT(pev));
	return ::LookupActivity(pmodel, pev, activity);
}

int CBaseAnimating::LookupSequence(const char *label)
{
	void *pmodel = GET_MODEL_PTR(ENT(pev));
	return ::LookupSequence(pmodel, label);
}

void CBaseAnimating::ResetSequenceInfo(void)
{
	void *pmodel = GET_MODEL_PTR(ENT(pev));

	GetSequenceInfo(pmodel, pev, &m_flFrameRate, &m_flGroundSpeed);
	m_fSequenceLoops = ((GetSequenceFlags() & STUDIO_LOOPING) != 0);
	pev->animtime = gpGlobals->time;
	pev->framerate = 1;
	m_fSequenceFinished = FALSE;
	m_flLastEventCheck = gpGlobals->time;
}

BOOL CBaseAnimating::GetSequenceFlags(void)
{
	void *pmodel = GET_MODEL_PTR(ENT(pev));
	return ::GetSequenceFlags(pmodel, pev);
}