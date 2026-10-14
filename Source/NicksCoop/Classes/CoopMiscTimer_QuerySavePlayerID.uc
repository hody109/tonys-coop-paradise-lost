//=============================================================================
// CoopMiscTimer_QuerySavePlayerID.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopMiscTimer_QuerySavePlayerID extends CoopMiscTimer;

simulated function PostBeginPlay()
{
	SetTimer(1.1,false);//0.1
}

simulated function Timer()
{
	CoopGameInfo(Level.Game).QuerySavePlayerID(CoopPlayerController(Owner));
	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
}
