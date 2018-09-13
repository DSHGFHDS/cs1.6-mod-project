#include "amxxmodule.h"
#include "hook.h"
#include "gamerules.h"

int FN_RegUserMsg_Post(const char *pszName, int iSize)
{
	if (!strcmp(pszName, "TeamScore"))
	{
		gmsgTeamScore = META_RESULT_ORIG_RET(int);
		return gmsgTeamScore;
	}

	return META_RESULT_ORIG_RET(int);
}