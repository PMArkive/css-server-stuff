#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "Noblock extension",
	author = "Me",
	description = "Disable players from colliding.",
	version = "1.0",
	url = "https://www.google.com/"
}

#define COLLISION_GROUP_DEBRIS_TRIGGER 2
#define COLLISION_GROUP_PLAYER 5

ConVar convarNoblock;

public void OnPluginStart()
{
	convarNoblock = CreateConVar("noblock_enabled", "1", "Enable/disable player collision.");
	HookConVarChange(convarNoblock, ConVarChanged);
	HookEvent("player_spawn", Event_player_spawn);
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	int collisionGroup = COLLISION_GROUP_PLAYER;
	if (convar.IntValue == 1)
		collisionGroup = COLLISION_GROUP_DEBRIS_TRIGGER;
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			PrintToConsole(i, "toggling collision on u bb");
			SetEntProp(i, Prop_Data, "m_CollisionGroup", collisionGroup);
		}
	}
}

public Action Event_player_spawn(Event event, const char[] name, bool dontBroadcast)
{
	if (GetConVarInt(convarNoblock) == 1)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		SetEntProp(client, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_DEBRIS_TRIGGER);
	}
	return Plugin_Continue;
}
