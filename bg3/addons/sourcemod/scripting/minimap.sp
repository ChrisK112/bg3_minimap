#include <sourcemod>
#include <sdktools>

#define SPEC_TEAM 1
#define AMER_TEAM 2
#define BRIT_TEAM 3


Handle cvar_red = null;
Handle cvar_green = null;
Handle cvar_blue = null;
Handle cvar_fadein = null;
Handle cvar_fadeout = null;
Handle cvar_xcord = null;
Handle cvar_ycord = null;
Handle cvar_holdtime = null;

int red;
int green;
int blue;
float fadein;
float fadeout;
float holdtime;
float xcord;
float ycord;

//client info
new bool:EnabledClients[64];
new Float:ClientX[64];
new Float:ClientY[64];


//DONT TOUCH THESE U FOOKER
float tg_x_offset = 0.16;
float tg_y_offset = 0.209;

float tg_x_offset_multiplier = 0.0000307028;
float tg_y_offset_multiplier = 0.00005328148;

float tg_x_landmark = 2479.968750;
float tg_y_landmark = -623.968750;

public Plugin:myinfo =
{
    name = "BG3 Minimap",
    author = "ChrisK112",
    description = "Display a minimap with player positions",
    version = "0.1",
    url = "https://chrisk112.github.io/portfolio/#/"
}

public OnPluginStart()
{
	RegConsoleCmd("sm_minimap", Command_Mini);
	
	//cvars
	cvar_red = CreateConVar("sm_retakes_hud_red", "255", "How much red would you like?", _, true, 0.0, true, 255.0);
	cvar_green = CreateConVar("sm_retakes_hud_green", "255", "How much green would you like?", _, true, 0.0, true, 255.0);
	cvar_blue = CreateConVar("sm_retakes_hud_blue", "255", "How much blue would you like?", _, true, 0.0, true, 255.0);
	cvar_fadein = CreateConVar("sm_retakes_hud_fade_in", "0.5", "How long would you like the fade in animation to last in seconds?", _, true, 0.0);
	cvar_fadeout = CreateConVar("sm_retakes_hud_fade_out", "0.5", "How long would you like the fade out animation to last in seconds?", _, true, 0.0);
	cvar_holdtime = CreateConVar("sm_retakes_hud_time", "5.0", "Time in seconds to display the HUD.", _, true, 1.0);
	cvar_xcord = CreateConVar("sm_retakes_hud_position_x", "0.42", "The position of the HUD on the X axis.", _, true, 0.0);
	cvar_ycord = CreateConVar("sm_retakes_hud_position_y", "0.3", "The position of the HUD on the Y axis.", _, true, 0.0);
	
	
	//start the loop
	//CreateTimer(0.1, Minimap_Update, _, TIMER_REPEAT); 
	

}


public Action:Minimap_Update(Handle:timer)
{
	//update all client positions
	UpdateClients();
	
	//loop through clients, check if they want to draw minimap
	for (new i = 1; i <= MaxClients; i++)	
    {	
		new client = i;

		if (IsValidClient(client) && EnabledClients[client])		
		{
			new team = GetClientTeam(client);
			
			for(new j = 1; j <= MaxClients; j++)
			{
				if(IsValidClient(j))
				{
					if(team == GetClientTeam(j))
					{
						PaintForClient(client, ClientX[j], ClientY[j]);
					}
					
				}
			}
			

		}                          
    }
}


public void UpdateClients()
{
	for (new i = 1; i <= MaxClients; i++)	
    {	
		new client = i;

		if (IsValidClient(client))		
		{
			new Float:pos[3];
			GetClientEyePosition(client,pos);
			ClientX[client] = GetXCoord(pos[1]);
			ClientY[client] = GetYCoord(pos[0]);

		}                          
    }
}


public Action:Command_Mini(client,args) 
{
	//enable text/dot drawing
	EnabledClients[client] = true;
	
	//show minimap to client
	new Handle:cvar = FindConVar("sv_cheats"), flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	ServerCommand("sv_cheats 1");
	

	ClientCommand(client, "r_screenoverlay \"custom/minimap/tg_minimap.vtf\"")
	
	CreateTimer(0.2, resetCheats, client);
}

public void PaintForClient(int client, float xpos, float ypos)
{
	red = GetConVarInt(cvar_red);
	green = 0;
	blue = 0;
		
	fadein = GetConVarFloat(cvar_fadein);
	fadeout = GetConVarFloat(cvar_fadeout);
	holdtime = GetConVarFloat(cvar_holdtime);

	xcord = xpos;
	ycord = ypos;

		
	char message[64];
	message = "·";
	SetHudTextParams(xcord, ycord, holdtime, red, green, blue, 255, 0, 0.25, fadein, fadeout);
	int test = ShowHudText(client, -1, "%s", message);
}

*/
public void OnGameFrame()
{
	//update all client positions
	UpdateClients();
	
	//loop through clients, check if they want to draw minimap
	for (new i = 1; i <= MaxClients; i++)	
    {	
		new client = i;

		if (IsValidClient(client) && EnabledClients[client])		
		{
			new team = GetClientTeam(client);
			
			for(new j = 1; j <= MaxClients; j++)
			{
				if(IsValidClient(j))
				{
					if(team == GetClientTeam(j))
					{
						PaintForClient(client, ClientX[j], ClientY[j]);
					}
					
				}
			}
			

		}                          
    }
}
*/

public Action:resetCheats(Handle:timer, int client)
{
	new Handle:cvar = FindConVar("sv_cheats"), flags = GetConVarFlags(cvar);
	flags &= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	ServerCommand("sv_cheats 0");
}


stock float GetXCoord(float xpos){
	float realXPos;
	float difference;
	difference = xpos - tg_x_landmark;
	realXPos = difference * tg_x_offset_multiplier;
	
	return (realXPos + tg_x_offset);
	

}

stock float GetYCoord(float ypos){
	float realYPos;
	float difference;
	difference = ypos - tg_y_landmark;
	realYPos = difference * tg_y_offset_multiplier;
	
	return (realYPos + tg_y_offset);
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client);
}

