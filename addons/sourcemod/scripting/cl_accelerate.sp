#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo =
{
	name = "Client-side A & AA extension",
	author = "Me",
	description = "Client-side A & AA changing.",
	version = "1.0",
	url = "https://www.google.com/"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_accel", Command_accel, 0);
	RegAdminCmd("sm_airaccel", Command_airaccel, 0);
}

public Action Command_accel(int client, int args)
{
	if (args == 0)
	{
		//usingClientAccel[client] = false;
		// call native metamod function:
		// resetAccel(client);
		ReplyToCommand(client, "[ACCEL] Resetting client-side sv_accelerate");
	}
	else if (args == 1)
	{
		char value[10];
		GetCmdArg(1, value, sizeof(value));
		int accelerateValue = StringToInt(value);
		if (accelerateValue == 0)
		{
			ReplyToCommand(client, "[ACCEL] Invalid value");
			return Plugin_Continue;
		}
		//clientAccel[client] = accelerateValue;
		//usingClientAccel[client] = true;
		// call native metamod function:
		// setAccel(client, accelerateValue);
		ReplyToCommand(client, "[ACCEL] Using custom sv_accelerate");
	}
	else
	{
		ReplyToCommand(client, "[ACCEL] Invalid arguments");
	}
	return Plugin_Continue;
}

public Action Command_airaccel(int client, int args)
{
	if (args == 0)
	{
		//usingClientAirAccel[client] = false;
		// call native metamod function:
		// resetAirAccel(client);
		ReplyToCommand(client, "[AIRACCEL] Stopping client-side sv_airaccelerate");
	}
	else if (args == 1)
	{
		char value[10];
		GetCmdArg(1, value, sizeof(value));
		int airaccelerateValue = StringToInt(value);
		if (airaccelerateValue == 0)
		{
			ReplyToCommand(client, "[AIRACCEL] Invalid value");
			return Plugin_Continue;
		}
		//clientAirAccel[client] = airaccelerateValue;
		//usingClientAirAccel[client] = true;
		// call native metamod function:
		// setAirAccel(client, airaccelerateValue);
		ReplyToCommand(client, "[AIRACCEL] Using custom sv_airaccelerate");
	}
	else
	{
		ReplyToCommand(client, "[AIRACCEL] Invalid arguments");
	}
	return Plugin_Continue;
}
