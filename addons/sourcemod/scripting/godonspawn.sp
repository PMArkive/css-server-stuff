#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "God-on-spawn extension",
	author = "Me",
	description = "Enables godmode on all players.",
	version = "1.0",
	url = "https://www.google.com/"
}

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_player_spawn);
}

public void Event_player_spawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
}
