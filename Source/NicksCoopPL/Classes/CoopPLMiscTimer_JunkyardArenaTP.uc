//=============================================================================
// CoopPLMiscTimer_JunkyardArenaTP.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLMiscTimer_JunkyardArenaTP extends Actor;

var vector TeleportPos;

simulated function PostBeginPlay()
{
	SetTimer(30,false);
}

simulated function Timer()
{
	local Controller con;
	if( CoopGameInfo(Level.Game) == None )
		return;
	if( CoopGameInfo(Level.Game).IsCinematic() )
	{
		SetTimer(1,false);
		return;
	}
	for( con = Level.ControllerList; con != None; con = con.NextController )
	{
		if( CoopPlayerController(con) != None && con.Buoyancy != 75 && con.Pawn != None )
		{
			CoopGameInfo(Level.Game).xForceSetLocationFor(con.Pawn, TeleportPos);
		}
	}
	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
	TeleportPos=(X=1860.0,Y=-2279.0,Z=273.0)
}
