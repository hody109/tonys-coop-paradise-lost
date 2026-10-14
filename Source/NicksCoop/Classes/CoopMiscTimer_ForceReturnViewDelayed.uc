//=============================================================================
// CoopMiscTimer_ForceReturnViewDelayed.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMiscTimer_ForceReturnViewDelayed extends CoopMiscTimer_ForceReturnView;

simulated function PostBeginPlay()
{
	SetTimer(2.0,false);
}

defaultproperties
{
}
