//=============================================================================
// CoopMiscTimer_NETCallRestoreMusic.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMiscTimer_NETCallRestoreMusic extends CoopMiscTimer;

var CoopPlayerController myCoopPC;

simulated function PostBeginPlay()
{
	SetTimer(3,false);
}

simulated function Timer()
{
	local CoopGameInfo myGameInfo;
	myGameInfo = CoopGameInfo(Owner);
	if( myGameInfo != None )
		myGameInfo.xNETCallRestoreMusic(myCoopPC);
	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
}
