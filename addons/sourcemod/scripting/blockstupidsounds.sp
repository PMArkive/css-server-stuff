#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <testing>

public Plugin myinfo =
{
	name = "Block stupid sounds",
	author = "GoD-Tony && The Count && Me",
	description = "Block all of those stupid sounds and music.",
	version = "1.0",
	url = "https://www.google.com/"
}

#define MAX_EDICTS 2048

int g_soundEnts[MAX_EDICTS];
int g_numSoundEnts;

StringMap lameMap;
char lameClasses[2][] = {
	"ambient_generic",
	"env_soundscape"
};
char lameKeys[2][] = {
	"m_iszSound",
	"m_soundscapeName"
};

public void OnPluginStart()
{
	lameMap = CreateTrie();
	for (int i = 0; i < sizeof(lameClasses); ++i)
		lameMap.SetString(lameClasses[i], lameKeys[i], false);

	RefreshSounds();
	StopSounds();
	CreateTimer(10.0, StopSoundsTimer, _, TIMER_REPEAT);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
}

public void Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	// Ents are recreated every round. blah
	g_numSoundEnts = 0;

	// Find all ambient sounds played by the map.
	RefreshSounds();
	CreateTimer(0.8, StopSoundsTimer);
}

bool isAudioFileName(const char[] str)
{
	int len = strlen(str);
	if (len < 4)
		return false;
	return (StrEqual(str[len-3], "mp3") || !StrEqual(str[len-3], "wav"));
}

void addAmbientSound(ent)
{
	//SetTestContext("blockstupidsounds");
	//AssertTrue("Too many ambient-sound entities added!", g_numSoundEnts < MAX_EDICTS);
	g_soundEnts[g_numSoundEnts++] = EntIndexToEntRef(ent);
}

void addSoundsByClass(const char[] classname)
{
	char sound[PLATFORM_MAX_PATH];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, classname)) != -1)
	{
		char value[64];
		lameMap.GetString(classname, value, sizeof(value));

		GetEntPropString(ent, Prop_Data, value, sound, sizeof(sound));
		if (isAudioFileName(sound))
			addAmbientSound(ent);
	}
}

void RefreshSounds()
{
	g_numSoundEnts = 0;

	for (int i = 0; i < sizeof(lameClasses); ++i)
		addSoundsByClass(lameClasses[i]);
}

public void OnEntityCreated(int ent, const char[] classname)
{
	int i = 0;
	bool found = false;
	for (; i < sizeof(lameClasses); ++i)
	{
		if (StrEqual(classname, lameClasses[i], false))
		{
			found = true;
			break;
		}
	}

	if (!found)
		return;

	char sound[PLATFORM_MAX_PATH];
	GetEntPropString(ent, Prop_Data, lameKeys[i], sound, sizeof(sound));

	if (isAudioFileName(sound))
		addAmbientSound(ent);
}

void StopSounds()
{
	if (GetClientCount() <= 0)
		return;

	//char message[128];
	char key[64];
	char classname[64];
	char sound[PLATFORM_MAX_PATH];

	for (int client = 1; client <= MaxClients; ++client)
	{
		if (!IsClientInGame(client))
			continue;
		for (int i = 0; i < g_numSoundEnts; ++i)
		{
			int ent = EntRefToEntIndex(g_soundEnts[i]);
			if (IsValidEntity(ent))
			{
				GetEntityClassname(g_soundEnts[i], classname, sizeof(classname));
				lameMap.GetString(classname, key, sizeof(key));

				GetEntPropString(ent, Prop_Data, key, sound, sizeof(sound));
				//PrecacheScriptSound(sound);
				//PrecacheScriptSound();

				Client_StopSound(client, ent, SNDCHAN_STATIC, sound);
			}
		}
	}
}

public Action StopSoundsTimer(Handle timer)
{
	StopSounds();
}

stock void Client_StopSound(int client, int entity, int channel, const char[] name)
{
	EmitSoundToClient(client, name, entity, channel, SNDLEVEL_NONE, SND_STOP,
		0.0, SNDPITCH_NORMAL, _, _, _, true);
}
