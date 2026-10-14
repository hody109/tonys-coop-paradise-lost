//=============================================================================
// CoopMiscTimerMulticast.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2019.
//=============================================================================

class CoopMiscTimerMulticast extends CoopMiscTimer;

defaultproperties
{
	LifeSpan=1.0
	NetPriority=3.0
	bNetTemporary=true
	RemoteRole=ROLE_SimulatedProxy
}
