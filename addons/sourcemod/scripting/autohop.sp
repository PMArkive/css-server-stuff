#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "Autohop + Autostrafe",
	author = "shavit && Swillzyy && Me",
	description = "Enable auto jumping & auto strafing (when autohop enabled).",
	version = "1.0",
	url = "https://www.google.com/"
}

bool autoClients[MAXPLAYERS+1];
bool autostrafeClients[MAXPLAYERS+1];

bool RIGHT[MAXPLAYERS+1] = {false, ...};
bool LEFT[MAXPLAYERS+1] = {false, ...};
float Second[MAXPLAYERS+1][3];
float AngDiff[MAXPLAYERS+1];

public void OnPluginStart()
{
	RegAdminCmd("sm_auto", Command_auto, 0);
	RegAdminCmd("sm_scroll", Command_scroll, 0);
	RegAdminCmd("sm_killfingers", Command_killfingers, 0);
	RegAdminCmd("sm_autostrafe", Command_autostrafe, 0);
}

public void OnClientConnected(client)
{
	autoClients[client] = true;
	autostrafeClients[client] = false;
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

public Action Command_killfingers(int client, int args)
{
	autostrafeClients[client] = false;
	ReplyToCommand(client, "[BHOP] Disabling autostrafe");
	return Plugin_Handled;
}

public Action Command_autostrafe(int client, int args)
{
	autostrafeClients[client] = true;
	ReplyToCommand(client, "[BHOP] Enabling autostrafe");
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse,
		float vel[3], float angles[3])
{
	if (!autoClients[client] || !IsClientInGame(client) ||
			!IsPlayerAlive(client) || IsFakeClient(client))
		return Plugin_Continue;

	int iOldButtons = GetEntProp(client, Prop_Data, "m_nOldButtons");
	iOldButtons &= ~IN_JUMP;

	SetEntProp(client, Prop_Data, "m_nOldButtons", iOldButtons);

	// Anti-doublestepping
	//if ( g_bClientHoldingJump[client] && fFlags & FL_ONGROUND ) buttons |= IN_JUMP;

	// Auto-strafing shit.
	if (!autostrafeClients[client] || (GetEntityFlags(client) & FL_ONGROUND) ||
			(GetEntityMoveType(client) & MOVETYPE_LADDER) ||
			(buttons & IN_FORWARD) || (buttons & IN_BACK) ||
			(buttons & IN_MOVELEFT) || (buttons & IN_MOVERIGHT))
	{
		RIGHT[client] = false;
		LEFT[client] = false;
		return Plugin_Continue;
	}

	AngDiff[client] = (Second[client][1] - angles[1]);
	Second[client] = angles;

	if (AngDiff[client] > 180)
		AngDiff[client] -= 360;
	if (AngDiff[client] < -180)
		AngDiff[client] += 360;

	if (AngDiff[client] < 0.0 || LEFT[client])
	{
		vel[1] = -400.0;
		LEFT[client] = true;
		RIGHT[client] = false;
	}

	if (AngDiff[client] > 0.0 || RIGHT[client])
	{
		vel[1] = 400.0;
		RIGHT[client] = true;
		LEFT[client] = false;
	}

	return Plugin_Continue;
}
