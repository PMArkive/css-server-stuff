#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <testing>

public Plugin myinfo =
{
	name = "Block stupid sounds extension",
	author = "GoD-Tony [Fixed by The Count] && Me",
	description = "Block all of those stupid sounds and music.",
	version = "1.0",
	url = "https://www.google.com/"
}

#define MAX_EDICTS 2048

int g_iSoundEnts[MAX_EDICTS];
int g_iNumSounds;

bool isSoundFileName(const char[] str)
{
	int len = strlen(str);
	return (len < 4 || (!StrEqual(str[len-3], "mp3") && !StrEqual(str[len-3], "wav")));
}

void addSoundEnt(ent)
{
	SetTestContext("blockstupidsounds");
	AssertTrue("Too many ambient-sound entities added!", g_iNumSounds < MAX_EDICTS);
	g_iSoundEnts[g_iNumSounds++] = EntIndexToEntRef(ent);
}

public void OnPluginStart()
{
	//AddNormalSoundHook(NormalSoundHook);
	CreateTimer(10.0, StopSoundTimer, _, TIMER_REPEAT);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
}

public void Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	// Ents are recreated every round.
	g_iNumSounds = 0;

	// Find all ambient sounds played by the map.
	RefreshSounds();
	CreateTimer(0.8, StopSoundTimer);
}

void stopSingleSoundOnClients(int ent, const char[] sSound)
{
	for (int client = 1; client <= MaxClients; ++client)
	{
		if (IsClientInGame(client))
		{
			Client_StopSound(client, ent, SNDCHAN_STATIC, sSound);
		}
	}
}

void stopSoundsOnClients()
{
	if (GetClientCount() <= 0)
		return;

	char sSound[PLATFORM_MAX_PATH];
	for (int i = 0; i < g_iNumSounds; ++i)
	{
		int ent = EntRefToEntIndex(g_iSoundEnts[i]);
		if (ent != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(ent, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
			stopSingleSoundOnClients(ent, sSound);
		}
	}
}

public void OnEntityCreated(int ent, const char[] classname)
{
	if (!StrEqual(classname, "ambient_generic", false))
		return;

	char sSound[PLATFORM_MAX_PATH];
	GetEntPropString(ent, Prop_Data, "m_iszSound", sSound, sizeof(sSound));

	if (isSoundFileName(sSound))
	{
		addSoundEnt(ent);
		stopSingleSoundOnClients(ent, sSound);
	}
}

void RefreshSounds()
{
	char sSound[PLATFORM_MAX_PATH];
	int ent = INVALID_ENT_REFERENCE;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(ent, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
		if (isSoundFileName(sSound))
			addSoundEnt(ent);
	}
}

public Action StopSoundTimer(Handle timer)
{
	stopSoundsOnClients();
	return Plugin_Continue;
}

/**
 * Stops a sound for one client.
 *
 * @param client	Client index.
 * @param entity	Entity index.
 * @param channel	Channel number.
 * @param name		Sound file name relative to the "sounds" folder.
 * @noreturn
 */
stock Client_StopSound(client, entity, channel, const String:name[])
{
	EmitSoundToClient(client, name, entity, channel, SNDLEVEL_NONE, SND_STOP,
		0.0, SNDPITCH_NORMAL, _, _, _, true);
}

// public Action NormalSoundHook(int clients[64], int &numClients,
// 	char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume,
// 	int &level, int &pitch, int &flags)
// {
// 	char className[30];
// 	char message[512];

// 	if (GetEntityClassname(entity, className, sizeof(className)))
// 	{
// 		Format(message, sizeof(message), "Entity[%d]: \'%s\' - Sample: \'%s\'",
// 			entity, className, sample);
// 	}
// 	else
// 	{
// 		Format(message, sizeof(message), "Entity[%d] - Sample: \'%s\'",
// 			entity, sample);
// 	}

// 	for (int i = 1; i <= MaxClients; ++i)
// 	{
// 		if (IsClientInGame(i))
// 			PrintToConsole(i, message);
// 	}

// 	return Plugin_Continue;
// }
