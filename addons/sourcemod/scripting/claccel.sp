#pragma semicolon 1

#include <sourcemod>
//#include <sdktools>
#include <sdkhooks>

ConVar g_ConVar_Accelerate;
ConVar g_ConVar_AirAccelerate;

ConVar g_ConVar_Def_Accelerate;
ConVar g_ConVar_Def_AirAccelerate;

float g_flDefAccelerate = 5.0;
float g_flDefAirAccelerate = 100.0;

float clientAccel[MAXPLAYERS+1];
float clientAirAccel[MAXPLAYERS+1];

bool usingClientAccel[MAXPLAYERS+1];
bool usingClientAirAccel[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "Client-side sv_accelerate & sv_airaccelerate",
	author = "Mehis && Me",
	description = "Client-side sv_accelerate & sv_airaccelerate changing.",
	version = "1.0",
	url = "https://www.google.com/"
}

public void OnPluginStart()
{
	RegAdminCmd( "sm_accel", Command_accel, 0 );
	RegAdminCmd( "sm_airaccel", Command_airaccel, 0 );

	g_ConVar_Def_Accelerate = CreateConVar( "timer_def_accelerate", "5", "What is the normal accelerate?", FCVAR_NOTIFY );
	g_ConVar_Def_AirAccelerate = CreateConVar( "timer_def_airaccelerate", "1000", "What is the normal airaccelerate?", FCVAR_NOTIFY );

	// sv_accelerate stuff
	/////////////////////////
	g_ConVar_Accelerate = FindConVar( "sv_accelerate" );

	if ( g_ConVar_Accelerate == null )
		SetFailState( "Unable to find cvar handle for sv_accelerate!" );

	int flags = GetConVarFlags( g_ConVar_Accelerate );

	flags &= ~FCVAR_NOTIFY;
	flags &= ~FCVAR_REPLICATED;

	SetConVarFlags( g_ConVar_Accelerate, flags );

	// sv_airaccelerate stuff
	/////////////////////////
	g_ConVar_AirAccelerate = FindConVar( "sv_airaccelerate" );

	if ( g_ConVar_AirAccelerate == null )
		SetFailState( "Unable to find cvar handle for sv_airaccelerate!" );

	flags = GetConVarFlags( g_ConVar_AirAccelerate );

	flags &= ~FCVAR_NOTIFY;
	flags &= ~FCVAR_REPLICATED;

	SetConVarFlags( g_ConVar_AirAccelerate, flags );

	HookConVarChange( g_ConVar_Def_Accelerate, Event_ConVar_Def_Accelerate );
	HookConVarChange( g_ConVar_Def_AirAccelerate, Event_ConVar_Def_AirAccelerate );
}

public void Event_ConVar_Def_Accelerate( Handle hConVar, const char[] szOldValue, const char[] szNewValue )
{
	g_flDefAccelerate = StringToFloat( szNewValue );
}

public void Event_ConVar_Def_AirAccelerate( Handle hConVar, const char[] szOldValue, const char[] szNewValue )
{
	g_flDefAirAccelerate = StringToFloat( szNewValue );
}

public void OnConfigsExecuted()
{
	g_flDefAccelerate = GetConVarFloat( g_ConVar_Accelerate );
	g_flDefAirAccelerate = GetConVarFloat( g_ConVar_AirAccelerate );
}

public Action Command_accel( int client, int args )
{
	if ( args == 0 )
	{
		usingClientAccel[client] = false;
		ReplyToCommand( client, "[ACCEL] Resetting client-side sv_accelerate" );
	}
	else if ( args == 1 )
	{
		char value[20];
		GetCmdArg( 1, value, sizeof( value ) );
		float accelerateValue = StringToFloat( value );
		if ( accelerateValue == 0.0 )
		{
			ReplyToCommand( client, "[ACCEL] Invalid value" );
			return Plugin_Handled;
		}
		clientAccel[client] = accelerateValue;
		usingClientAccel[client] = true;
		ReplyToCommand( client, "[ACCEL] Using custom sv_accelerate" );
	}
	else
	{
		ReplyToCommand( client, "[ACCEL] Invalid arguments" );
	}
	return Plugin_Handled;
}

public Action Command_airaccel( int client, int args )
{
	if ( args == 0 )
	{
		usingClientAirAccel[client] = false;
		ReplyToCommand( client, "[AIRACCEL] Stopping client-side sv_airaccelerate" );
	}
	else if ( args == 1 )
	{
		char value[20];
		GetCmdArg( 1, value, sizeof( value ) );
		float airaccelerateValue = StringToFloat( value );
		if ( airaccelerateValue == 0.0 )
		{
			ReplyToCommand( client, "[AIRACCEL] Invalid value" );
			return Plugin_Handled;
		}
		clientAirAccel[client] = airaccelerateValue;
		usingClientAirAccel[client] = true;
		ReplyToCommand( client, "[AIRACCEL] Using custom sv_airaccelerate" );
	}
	else
	{
		ReplyToCommand( client, "[AIRACCEL] Invalid arguments" );
	}
	return Plugin_Handled;
}

public void Event_PreThinkPost_Client( int client )
{
	// Called before AirMove()
	// Which is then called for living players that are in the air.

	// Set our sv_airaccelerate value to client's preferred style.
	// Airmove calculates acceleration by taking the sv_airaccelerate-cvar value.
	// This means we can change the value before the calculations happen.
	SetConVarFloat( g_ConVar_AirAccelerate, ( usingClientAirAccel[client] ) ? clientAirAccel[client] : g_flDefAirAccelerate );

	SetConVarFloat( g_ConVar_Accelerate, ( usingClientAccel[client] ) ? clientAccel[client] : g_flDefAccelerate );
}

void SetClientPredictedAcceleration( int client, float aa )
{
	char szValue[8];
	FormatEx( szValue, sizeof( szValue ), "%0.f", aa );

	SendConVarValue( client, g_ConVar_Accelerate, szValue );
}

void SetClientPredictedAirAcceleration( int client, float aa )
{
	char szValue[8];
	FormatEx( szValue, sizeof( szValue ), "%0.f", aa );

	SendConVarValue( client, g_ConVar_AirAccelerate, szValue );
}

public void OnClientPutInServer( int client )
{
	usingClientAccel[client] = false;
	usingClientAirAccel[client] = false;

	SetClientPredictedAcceleration( client , g_flDefAccelerate );
	SetClientPredictedAirAcceleration( client, g_flDefAirAccelerate );
	SDKHook( client, SDKHook_PreThinkPost, Event_PreThinkPost_Client );
}

public void OnClientDisconnect(int client)
{
	SDKUnhook( client, SDKHook_PreThinkPost, Event_PreThinkPost_Client );
}
