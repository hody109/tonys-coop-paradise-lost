//=============================================================================
// CoopPlayerControllerHostMenu.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopPlayerControllerHostMenu extends DudePlayer;

simulated function PostBeginPlay()
{
	/*if( DefaultFOV <= 1 )
	{
		DefaultFOV = 85;
		log(self @ "FOV 1 GLITCH FIXED");
	}*/
	Super.PostBeginPlay();
}

///steam 25/08/2017
event TravelPostAccept()
{
	Super.TravelPostAccept();
	CoopClientFixScreens();
}

///steam 25/08/2017 - interactions uses invalid objects, fix
function CoopClientFixScreens()
{
	local int i;
	for (i = 0; i < Player.LocalInteractions.Length; i++)
	{
		if( P2Screen(Player.LocalInteractions[i]) != None )
			P2Screen(Player.LocalInteractions[i]).PreTravel();
	}
}

defaultproperties
{
	Buoyancy=75.0
}
