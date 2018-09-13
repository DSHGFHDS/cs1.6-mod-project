#include <windows.h>
#include <assert.h>
#include "metahook.h"

#define DISABLE_INLINEHOOK 0 // ÓÃ²»µ½ InlineHook.

#if DISABLE_INLINEHOOK == 0
#include "Detours/detours.h"
#endif

#pragma warning( disable : 4018 )

hook_t *MH_FindInlineHooked(void *pOldFuncAddr);
hook_t *MH_FindVFTHooked(void *pClass, int iTableIndex, int iFuncIndex);
hook_t *MH_FindIATHooked(HMODULE hModule, const char *pszModuleName, const char *pszFuncName);
BOOL MH_UnHook(hook_t *pHook);
hook_t *MH_InlineHook(void *pOldFuncAddr, void *pNewFuncAddr, void *&pCallBackFuncAddr);
hook_t *MH_VFTHook(void *pClass, int iTableIndex, int iFuncIndex, void *pNewFuncAddr, void *&pCallBackFuncAddr);
hook_t *MH_IATHook(HMODULE hModule, const char *pszModuleName, const char *pszFuncName, void *pNewFuncAddr, void *&pCallBackFuncAddr);
void *MH_GetClassFuncAddr(...);
DWORD MH_GetModuleBase(HMODULE hModule);
DWORD MH_GetModuleSize(HMODULE hModule);
void *MH_SearchPattern(void *pStartSearch, DWORD dwSearchLen, char *pPattern, DWORD dwPatternLen);
void MH_WriteDWORD(void *pAddress, DWORD dwValue);
DWORD MH_ReadDWORD(void *pAddress);
DWORD MH_WriteMemory(void *pAddress, BYTE *pData, DWORD dwDataSize);
DWORD MH_ReadMemory(void *pAddress, BYTE *pData, DWORD dwDataSize);
void MH_FreeAllHook(void);

hook_t *g_pHookBase = NULL;

hook_t *MH_NewHook(void)
{
	hook_t *h = new hook_t;
	memset(h, 0, sizeof(hook_t));
	h->pNext = g_pHookBase;
	g_pHookBase = h;
	return h;
}

hook_t *MH_FindInlineHooked(void *pOldFuncAddr)
{
	for (hook_t *h = g_pHookBase; h; h = h->pNext)
	{
		if (h->pOldFuncAddr == pOldFuncAddr)
			return h;
	}

	return NULL;
}

hook_t *MH_FindVFTHooked(void *pClass, int iTableIndex, int iFuncIndex)
{
	for (hook_t *h = g_pHookBase; h; h = h->pNext)
	{
		if (h->pClass == pClass && h->iTableIndex == iTableIndex && h->iFuncIndex == iFuncIndex)
			return h;
	}

	return NULL;
}

hook_t *MH_FindIATHooked(HMODULE hModule, const char *pszModuleName, const char *pszFuncName)
{
	for (hook_t *h = g_pHookBase; h; h = h->pNext)
	{
		if (h->hModule == hModule && h->pszModuleName == pszModuleName && h->pszFuncName == pszFuncName)
			return h;
	}

	return NULL;
}

#pragma pack(push, 1)

struct tagIATDATA
{
	void *pAPIInfoAddr;
};

struct tagCLASS
{
	DWORD *pVMT;
};

struct tagVTABLEDATA
{
	tagCLASS *pInstance;
	void *pVFTInfoAddr;
};

#pragma pack(pop)

void MH_FreeHook(hook_t *pHook)
{
	if (pHook->pClass)
	{
		tagVTABLEDATA *info = (tagVTABLEDATA *)pHook->pInfo;
		MH_WriteMemory(info->pVFTInfoAddr, (BYTE *)pHook->pOldFuncAddr, sizeof(DWORD));
	}
	else if (pHook->hModule)
	{
		tagIATDATA *info = (tagIATDATA *)pHook->pInfo;
		MH_WriteMemory(info->pAPIInfoAddr, (BYTE *)pHook->pOldFuncAddr, sizeof(DWORD));
	}
	else
	{
		DetourTransactionBegin();
		DetourUpdateThread(GetCurrentThread());
		DetourDetach(&(void *&)pHook->pOldFuncAddr, pHook->pNewFuncAddr);
		DetourTransactionCommit();
	}

	if (pHook->pInfo)
		delete pHook->pInfo;

	delete pHook;
}

void MH_FreeAllHook(void)
{
	hook_t *next = NULL;

	for (hook_t *h = g_pHookBase; h; h = next)
	{
		next = h->pNext;
		MH_FreeHook(h);
	}

	g_pHookBase = NULL;
}

BOOL MH_UnHook(hook_t *pHook)
{
	if (!g_pHookBase)
		return FALSE;

	if (!g_pHookBase->pNext)
	{
		MH_FreeHook(pHook);
		g_pHookBase = NULL;
		return TRUE;
	}

	hook_t *last = NULL;

	for (hook_t *h = g_pHookBase->pNext; h; h = h->pNext)
	{
		if (h->pNext != pHook)
		{
			last = h;
			continue;
		}

		last->pNext = h->pNext;
		MH_FreeHook(h);
		return TRUE;
	}

	return FALSE;
}

hook_t *MH_InlineHook(void *pOldFuncAddr, void *pNewFuncAddr, void *&pCallBackFuncAddr)
{
	hook_t *h = MH_FindInlineHooked(pOldFuncAddr);

	if (h)
		return NULL;

	h = MH_NewHook();
	h->pOldFuncAddr = pOldFuncAddr;
	h->pNewFuncAddr = pNewFuncAddr;

	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());
	DetourAttach(&(void *&)h->pOldFuncAddr, pNewFuncAddr);
	DetourTransactionCommit();

	pCallBackFuncAddr = h->pOldFuncAddr; 
	return h;
}

hook_t *MH_VFTHook(void *pClass, int iTableIndex, int iFuncIndex, void *pNewFuncAddr, void *&pCallBackFuncAddr)
{
	hook_t *h = MH_FindVFTHooked(pClass, iTableIndex, iFuncIndex);

	if (h)
		return NULL;

	tagVTABLEDATA *info = new tagVTABLEDATA;
	info->pInstance = (tagCLASS *)pClass;

	DWORD *pVMT = ((tagCLASS *)pClass + iTableIndex)->pVMT;
	info->pVFTInfoAddr = pVMT + iFuncIndex;

	h = MH_NewHook();
	h->pOldFuncAddr = (void *)pVMT[iFuncIndex];
	h->pNewFuncAddr = pNewFuncAddr;
	h->pInfo = info;
	h->pClass = pClass;
	h->iTableIndex = iTableIndex;
	h->iFuncIndex = iFuncIndex;

	pCallBackFuncAddr = h->pOldFuncAddr;
	MH_WriteMemory(info->pVFTInfoAddr, (BYTE *)&pNewFuncAddr, sizeof(DWORD));
	return 0;
}

hook_t *MH_IATHook(HMODULE hModule, const char *pszModuleName, const char *pszFuncName, void *pNewFuncAddr, void *&pCallBackFuncAddr)
{
	hook_t *h = MH_FindIATHooked(hModule, pszModuleName, pszFuncName);

	if (h)
		return NULL;

	IMAGE_NT_HEADERS *pHeader = (IMAGE_NT_HEADERS *)((DWORD)hModule + ((IMAGE_DOS_HEADER *)hModule)->e_lfanew);
	IMAGE_IMPORT_DESCRIPTOR *pImport = (IMAGE_IMPORT_DESCRIPTOR *)((DWORD)hModule + pHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);

	while (pImport->Name && stricmp((const char *)((DWORD)hModule + pImport->Name), pszModuleName))
		pImport++;

	DWORD dwFuncAddr = (DWORD)GetProcAddress(GetModuleHandle(pszModuleName), pszFuncName);
	IMAGE_THUNK_DATA *pThunk = (IMAGE_THUNK_DATA *)((DWORD)hModule + pImport->FirstThunk);

	while (pThunk->u1.Function != dwFuncAddr)
		pThunk++;

	tagIATDATA *info = new tagIATDATA;
	info->pAPIInfoAddr = &pThunk->u1.Function;

	h = MH_NewHook();
	h->pOldFuncAddr = (void *)pThunk->u1.Function;
	h->pNewFuncAddr = pNewFuncAddr;
	h->pInfo = info;
	h->hModule = hModule;
	h->pszModuleName = pszModuleName;
	h->pszFuncName = pszFuncName;

	pCallBackFuncAddr = h->pOldFuncAddr;
	MH_WriteMemory(info->pAPIInfoAddr, (BYTE *)&pNewFuncAddr, sizeof(DWORD));
	return h;
}

void *MH_GetClassFuncAddr(...)
{
	DWORD address;

	__asm
	{
		lea eax,address
		mov edx, [ebp + 8]
		mov [eax], edx
	}

	return (void *)address;
}

DWORD MH_GetModuleBase(HMODULE hModule)
{
	MEMORY_BASIC_INFORMATION mem;

	if (!VirtualQuery(hModule, &mem, sizeof(MEMORY_BASIC_INFORMATION)))
		return 0;

	return (DWORD)mem.AllocationBase;
}

DWORD MH_GetModuleSize(HMODULE hModule)
{
	return ((IMAGE_NT_HEADERS *)((DWORD)hModule + ((IMAGE_DOS_HEADER *)hModule)->e_lfanew))->OptionalHeader.SizeOfImage;
}

void *MH_SearchPattern(void *pStartSearch, DWORD dwSearchLen, char *pPattern, DWORD dwPatternLen)
{
	DWORD dwStartAddr = (DWORD)pStartSearch;
	DWORD dwEndAddr = dwStartAddr + dwSearchLen - dwPatternLen;

	while (dwStartAddr < dwEndAddr)
	{
		bool found = true;

		for (int i = 0; i < dwPatternLen; i++)
		{
			char code = *(char *)(dwStartAddr + i);

			if (pPattern[i] != 0x2A && pPattern[i] != code)
			{
				found = false;
				break;
			}
		}

		if (found)
			return (void *)dwStartAddr;

		dwStartAddr++;
	}

	return 0;
}

void MH_WriteDWORD(void *pAddress, DWORD dwValue)
{
	DWORD dwProtect;

	if (VirtualProtect((void *)pAddress, 4, PAGE_EXECUTE_READWRITE, &dwProtect))
	{
		*(DWORD *)pAddress = dwValue;
		VirtualProtect((void *)pAddress, 4, dwProtect, &dwProtect);
	}
}

DWORD MH_ReadDWORD(void *pAddress)
{
	DWORD dwProtect;
	DWORD dwValue = 0;

	if (VirtualProtect((void *)pAddress, 4, PAGE_EXECUTE_READWRITE, &dwProtect))
	{
		dwValue = *(DWORD *)pAddress;
		VirtualProtect((void *)pAddress, 4, dwProtect, &dwProtect);
	}

	return dwValue;
}

DWORD MH_WriteMemory(void *pAddress, BYTE *pData, DWORD dwDataSize)
{
	static DWORD dwProtect;

	if (VirtualProtect(pAddress, dwDataSize, PAGE_EXECUTE_READWRITE, &dwProtect))
	{
		memcpy(pAddress, pData, dwDataSize);
		VirtualProtect(pAddress, dwDataSize, dwProtect, &dwProtect);
	}

	return dwDataSize;
}

DWORD MH_ReadMemory(void *pAddress, BYTE *pData, DWORD dwDataSize)
{
	static DWORD dwProtect;

	if (VirtualProtect(pAddress, dwDataSize, PAGE_EXECUTE_READWRITE, &dwProtect))
	{
		memcpy(pData, pAddress, dwDataSize);
		VirtualProtect(pAddress, dwDataSize, dwProtect, &dwProtect);
	}

	return dwDataSize;
}