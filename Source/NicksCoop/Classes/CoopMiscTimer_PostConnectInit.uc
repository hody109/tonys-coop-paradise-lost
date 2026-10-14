//=============================================================================
// CoopMiscTimer_PostConnectInit.uc
// - CoopPostConnectInit() must call very important functions after delay again
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopMiscTimer_PostConnectInit extends CoopMiscTimer;

simulated function PostBeginPlay()
{
	SetTimer(4.0,false);
}

simulated function Timer()
{
	if( Owner != None )
	{
		if( CoopPostalDude(Owner) != None )
			CoopPostalDude(Owner).CoopPostConnectInit();
		else if( CoopPlayerController(Owner) != None )
			CoopPlayerController(Owner).CoopPostConnectInit();
	}
	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
}
