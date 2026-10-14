//=============================================================================
// CoopMiscTimer_ClientInitPingOptimize.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopMiscTimer_ClientInitPingOptimize extends CoopMiscTimer;

simulated function PostBeginPlay()
{
	SetTimer(1.16,false);//0.16
}

simulated function Timer()
{
	if( CoopPlayerController(Owner) != None )
		CoopPlayerController(Owner).xClientInitPingOptimize();
	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
}
