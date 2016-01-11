#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <clientprefs>

public Plugin myinfo =
{
	name = "Player hiding extension",
	author = "Me && exvel",
	description = "Hide players becuase they're in your way.",
	version = "1.0",
	url = "https://www.google.com/"
}

bool hiddenStatus[MAXPLAYERS+1];

public void OnPluginStart()
{
	RegAdminCmd("sm_hide", Command_hide, 0);
}

void blah(int client, const char[] msg)
{
	PrintToChat(client, msg);
	PrintToConsole(client, msg);
}

Handle getHideplayersCookie(int client, char buffer[4])
{
	// If cookie already exists, the handle to it is returned.
	Handle hCookie = RegClientCookie("hideplayers", "Player hiding cookie", CookieAccess_Public);

	GetClientCookie(client, hCookie, buffer, sizeof(buffer));

	return hCookie;
}

public void OnClientDisconnect(client)
{
	hiddenStatus[client] = false;
}

public void OnClientPutInServer(client)
{
	char buffer[4];
	Handle hCookie = getHideplayersCookie(client, buffer);
	CloseHandle(hCookie);

	hiddenStatus[client] = StrEqual(buffer, "yes");

	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
}

bool IsClientInSpectator(client)
{
	int team = GetClientTeam(client);
	return team == CS_TEAM_NONE || team == CS_TEAM_SPECTATOR;
}

public Action Hook_SetTransmit(int entity, int client)
{
	if ((client != entity && (0 < entity <= MaxClients) &&
			hiddenStatus[client]) && !IsClientInSpectator(client))
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Command_hide(int client, int args)
{
	char buffer[4];
	Handle hCookie = getHideplayersCookie(client, buffer);

	bool bIsHiding = StrEqual(buffer, "yes");
	hiddenStatus[client] = !bIsHiding; // toggle

	if (bIsHiding)
	{
		SetClientCookie(client, hCookie, "no");
		blah(client, "[BLAH] Players are now unhidden");
	}
	else
	{
		SetClientCookie(client, hCookie, "yes");
		blah(client, "[BLAH] Players are now hidden");
	}

	CloseHandle(hCookie);

	return Plugin_Handled;
}
