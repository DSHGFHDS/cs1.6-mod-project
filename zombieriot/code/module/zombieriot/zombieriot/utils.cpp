#include <extdll.h>
#include <enginecallback.h>

DWORD UTIL_SIGFind(DWORD dwStartAddr, DWORD dwFindLen, char *sig, int len)
{
	DWORD dwEndAddr = dwStartAddr + dwFindLen - len;

	while (dwStartAddr < dwEndAddr)
	{
		bool found = true;

		for (int i = 0; i < len; i++)
		{
			char code = *(char *)(dwStartAddr + i);

			if (sig[i] != (char)0x2A && sig[i] != code)
			{
				found = false;
				break;
			}
		}

		if (found)
			return dwStartAddr;

		dwStartAddr++;
	}

	return 0;
}

void UTIL_WriteMemory(void *addr, BYTE *value, int size)
{
	static DWORD dwProtect;

	if (VirtualProtect(addr, size, PAGE_EXECUTE_READWRITE, &dwProtect))
	{
		memcpy(addr, value, size);
		VirtualProtect(addr, size, dwProtect, &dwProtect);
	}
}

void UTIL_WriteMemoryBYTE(void *addr, BYTE value)
{
	static DWORD dwProtect;

	if (VirtualProtect(addr, sizeof(value), PAGE_EXECUTE_READWRITE, &dwProtect))
	{
		*(BYTE *)addr = value;
		VirtualProtect(addr, sizeof(value), dwProtect, &dwProtect);
	}
}