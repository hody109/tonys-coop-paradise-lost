//=============================================================================
// CoopMiscTimer_ForceReturnView.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMiscTimer_ForceReturnView extends CoopMiscTimer;

simulated function PostBeginPlay()
{
	SetTimer(0.5,false);
}

simulated function Timer()
{
	if( Owner != None && CoopPlayerController(Owner) != None )
		CoopPlayerController(Owner).xForceReturnViewToPawn();
	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
}
