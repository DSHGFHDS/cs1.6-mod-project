#include "amxxmodule.h"


void OnAmxxAttach()
{
	g_hMod = GetModuleHandle("mp.dll");

	g_dwModBase = MH_GetModuleBase(g_hMod);
	g_dwModSize = MH_GetModuleSize(g_hMod);


}





