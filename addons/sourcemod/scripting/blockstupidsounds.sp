#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <testing>

public Plugin myinfo =
{
	name = "Block stupid sounds",
	author = "Me",
	description = "Block all of those stupid sounds and music.",
	version = "1.0",
	url = "https://www.google.com/"
}

char lameClasses[ 2 ][] = {
	"ambient_generic",
	"env_soundscape"
};

public void OnEntityCreated( int ent, const char[] classname )
{
	bool found = false;
	for ( int i = 0; i < sizeof( lameClasses ); ++i )
	{
		if ( StrEqual( classname, lameClasses[ i ], false ) )
		{
			found = true;
			break;
		}
	}

	if ( !found )
		return;

	PrintToServer( "Killing %s[%d]", classname, ent );
	// https://github.com/altexdim/sourcemod-plugin-gungame/blob/master/doc/csgo/hacks.txt#L1
	AcceptEntityInput( ent, "Kill" );
}
