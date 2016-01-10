#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "Autohop",
	author = "shavit && Me",
	description = "Enable auto jumping.",
	version = "1.0",
	url = "https://www.google.com/"
}

bool autoClients[MAXPLAYERS+1];

public void OnPluginStart()
{
	RegAdminCmd("sm_auto", Command_auto, 0);
	RegAdminCmd("sm_scroll", Command_scroll, 0);
}

public void OnClientConnected(client)
{
	autoClients[client] = true;
}

public Action Command_auto(int client, int args)
{
	autoClients[client] = true;
	ReplyToCommand(client, "[BHOP] Enabling autohop");
	return Plugin_Handled;
}

public Action Command_scroll(int client, int args)
{
	autoClients[client] = false;
	ReplyToCommand(client, "[BHOP] Disabling autohop");
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if (autoClients[client] && IsClientInGame(client) &&
			IsPlayerAlive(client) && !IsFakeClient(client))
	{
		int iOldButtons = GetEntProp(client, Prop_Data, "m_nOldButtons");
		iOldButtons &= ~IN_JUMP;

		SetEntProp(client, Prop_Data, "m_nOldButtons", iOldButtons);

		// Anti-doublestepping
		//if ( g_bClientHoldingJump[client] && fFlags & FL_ONGROUND ) buttons |= IN_JUMP;
	}

	return Plugin_Continue;
}
