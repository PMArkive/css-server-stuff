#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "Ezhop extension",
	author = "Me",
	description = "Enable easy bunnyhopping.",
	version = "1.0",
	url = "https://www.google.com/"
}

bool ezhopClients[MAXPLAYERS+1];

public void OnPluginStart()
{
	HookEvent("player_jump", Event_player_jump);
	RegAdminCmd("sm_ezhop", Command_ezhop, 0);
	RegAdminCmd("sm_normalhop", Command_normalhop, 0);
	RegAdminCmd("sm_ez", Command_ezhop, 0);
	RegAdminCmd("sm_n", Command_normalhop, 0);
}

public void OnClientConnected(client)
{
	ezhopClients[client] = true;
}

public Action Command_ezhop(int client, int args)
{
	ezhopClients[client] = true;
	ReplyToCommand(client, "[BHOP] Using ezhop");
	return Plugin_Continue;
}

public Action Command_normalhop(int client, int args)
{
	ezhopClients[client] = false;
	ReplyToCommand(client, "[BHOP] Using normalhop");
	return Plugin_Continue;
}

public void Event_player_jump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (ezhopClients[client])
		SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0);
}
