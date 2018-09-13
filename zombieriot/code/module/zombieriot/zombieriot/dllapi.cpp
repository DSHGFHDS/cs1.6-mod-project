#include "amxxmodule.h"
#include "hook.h"
#include "gamerules.h"
#include "utils.h"

int DispatchSpawn(edict_t *pent)
{
	if (ENTINDEX(pent) == 0 && !g_pfnInstallGameRules)
	{
		void *pdata = GET_PRIVATE(pent);
		DWORD *vtfuncs = *(DWORD **)pdata;
		DWORD dwPrecache = vtfuncs[1] + 0x50;
		DWORD dwAddr = UTIL_SIGFind(dwPrecache, 0xFF, "\x83\xC4\x04\x56\xE8", 5) + 5;
		g_pfnInstallGameRules = (void *(*)(void))(dwAddr + *(DWORD *)dwAddr + 0x4);
		g_phInstallGameRules = new JMPHook(g_pfnInstallGameRules, InstallGameRules);
		g_phInstallGameRules->Attach();
	}

	RETURN_META_VALUE(MRES_IGNORED, 0);
}