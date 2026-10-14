//=============================================================================
// CoopMiscTimer_DelayedBegin.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2019.
//=============================================================================

class CoopMiscTimer_DelayedBegin extends CoopMiscTimer;

function PostBeginPlay()
{
	SetTimer(0.6,false);
}

function Timer()
{
	CoopGameInfo(Level.Game).CoopDelayedBegin();
	LifeSpan = 0.1;
}

defaultproperties
{
}
