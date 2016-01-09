#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "Client-side ConVars",
	author = "Me",
	description = "Set ConVars on the client.",
	version = "1.0",
	url = "https://www.google.com/"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_clcvar", Command_clcvar, 0);
}

public Action Command_clcvar(int client, int args)
{
	if (args != 2)
	{
		ReplyToCommand(client, "[CLCVARS] Missing arguments");
		return Plugin_Continue;
	}

	char convarName[51];
	GetCmdArg(1, convarName, sizeof(convarName));

	Handle convar = FindConVar(convarName);
	if (convar == null)
	{
		ReplyToCommand(client, "[CLCVARS] Invalid ConVar");
	}
	else
	{
		char convarValue[51];
		GetCmdArg(2, convarValue, sizeof(convarValue));
		SendConVarValue(client, convar, convarValue);

		ReplyToCommand(client, "[CLCVARS] Done");
	}

	return Plugin_Continue;
}
