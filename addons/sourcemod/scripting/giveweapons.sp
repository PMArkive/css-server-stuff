#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdktools_functions>

public Plugin myinfo =
{
	name = "Weapon Giving extension",
	author = "Me",
	description = "Give people guns.",
	version = "1.0",
	url = "https://www.google.com/"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_glock", Command_glock, 0);
	RegAdminCmd("sm_usp", Command_usp, 0);
	RegAdminCmd("sm_knife", Command_knife, 0);
	RegAdminCmd("sm_scout", Command_scout, 0);
	RegAdminCmd("sm_p90", Command_p90, 0);
	RegAdminCmd("sm_m3", Command_m3, 0);
	RegAdminCmd("sm_xm1014", Command_xm1014, 0);
}

void RemoveWeaponInSlot(client, slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (weapon != -1)
	{
		CS_DropWeapon(client, weapon, true, true);
		RemoveEdict(weapon);
	}
}

public Action Command_glock(int client, int args)
{
	RemoveWeaponInSlot(client, 1);
	GivePlayerItem(client, "weapon_glock", 0);
	return Plugin_Continue;
}

public Action Command_usp(int client, int args)
{
	RemoveWeaponInSlot(client, 1);
	GivePlayerItem(client, "weapon_usp", 0);
	return Plugin_Continue;
}

public Action Command_knife(int client, int args)
{
	RemoveWeaponInSlot(client, 2);
	GivePlayerItem(client, "weapon_knife", 0);
	return Plugin_Continue;
}

public Action Command_scout(int client, int args)
{
	RemoveWeaponInSlot(client, 0);
	GivePlayerItem(client, "weapon_scout", 0);
	return Plugin_Continue;
}

public Action Command_p90(int client, int args)
{
	RemoveWeaponInSlot(client, 0);
	GivePlayerItem(client, "weapon_p90", 0);
	return Plugin_Continue;
}

public Action Command_m3(int client, int args)
{
	RemoveWeaponInSlot(client, 0);
	GivePlayerItem(client, "weapon_m3", 0);
	return Plugin_Continue;
}

public Action Command_xm1014(int client, int args)
{
	RemoveWeaponInSlot(client, 0);
	GivePlayerItem(client, "weapon_xm1014", 0);
	return Plugin_Continue;
}
