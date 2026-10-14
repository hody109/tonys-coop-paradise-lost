//=============================================================================
// CoopMiscTimer_DelayedURLTravel.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopMiscTimer_DelayedURLTravel extends CoopMiscTimer;

var string URL;

simulated function SetupTravelTimer(string sURL, float fTime)
{
	URL = sURL;
	SetTimer(fTime,false);
}

simulated function Timer()
{
	local CoopPlayerController myPC;

	myPC = CoopPlayerController(Owner);
	if( URL != "" )
		CoopGameInfo(Level.Game).SendPlayerEx(myPC, URL);

	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
	bAlwaysTick=true
}
