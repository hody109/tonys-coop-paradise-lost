//=============================================================================
// CoopSpectatorFakePawn.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopSpectatorFakePawn extends CoopPostalDude;

simulated event FellOutOfWorld()
{
	///STUBED
}

defaultproperties
{
	bHidden=true
	Physics=PHYS_None
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	bBlockNonZeroExtentTraces=false
	bBlockZeroExtentTraces=false
	bIgnoreOutOfWorld=true
	CollisionRadius=1.0
	CollisionHeight=1.0
}
